# frozen_string_literal: true

require "csv"
require "stringio"
require "set"
require_relative "../../processors/value_processor"

module ClassMetrix
  module Formatters
    module CsvComponents
      class CsvTableComponent
        def initialize(data, options = {})
          @data = data
          @options = options
          @expand_hashes = options.fetch(:expand_hashes, false)
          @separator = options.fetch(:separator, ",")
          @quote_char = options.fetch(:quote_char, '"')
          @flatten_hashes = options.fetch(:flatten_hashes, true)
          @null_value = options.fetch(:null_value, "")
        end

        def generate
          return "" if @data[:headers].empty? || @data[:rows].empty?

          if @expand_hashes && @flatten_hashes
            format_with_flattened_hashes
          elsif @expand_hashes
            format_with_expanded_rows
          else
            format_simple_table
          end
        end

        private

        def format_simple_table
          headers = @data[:headers]
          rows = @data[:rows]

          # Process values for CSV
          processed_rows = rows.map do |row|
            process_row_for_csv(row)
          end

          generate_csv(headers, processed_rows)
        end

        def format_with_expanded_rows
          headers = @data[:headers]
          rows = @data[:rows]
          expanded_rows = []

          rows.each do |row|
            # Check if any cell contains a hash that needs expansion
            has_type_column = headers.first == "Type"
            value_start_index = has_type_column ? 2 : 1
            has_expandable_hash = row[value_start_index..-1].any? { |cell| cell.is_a?(Hash) }

            if has_expandable_hash
              # Expand this row into multiple sub-rows
              expanded_rows.concat(expand_row_for_csv(row, headers))
            else
              # Process the row values for CSV
              processed_row = process_row_for_csv(row)
              expanded_rows << processed_row
            end
          end

          generate_csv(headers, expanded_rows)
        end

        def format_with_flattened_hashes
          # Flatten all hash keys into separate columns
          headers = @data[:headers]
          rows = @data[:rows]

          # First pass: collect all unique hash keys
          all_hash_keys = collect_all_hash_keys(rows, headers)

          # Create new headers with flattened hash columns
          flattened_headers = create_flattened_headers(headers, all_hash_keys)

          # Second pass: create flattened rows
          flattened_rows = rows.map do |row|
            flatten_row(row, headers, all_hash_keys)
          end

          generate_csv(flattened_headers, flattened_rows)
        end

        def process_row_for_csv(row)
          row.map do |value|
            process_value_for_csv(value)
          end
        end

        def process_value_for_csv(value)
          case value
          when Hash
            # For non-flattened CSV, represent hash as JSON-like string
            value.inspect
          when Array
            value.join("; ") # Use semicolon to avoid CSV comma conflicts
          when true
            "TRUE"
          when false
            "FALSE"
          when nil
            @null_value
          when String
            # Clean up emoji for CSV compatibility (always clean, not just for errors)
            clean_value = value.gsub(/🚫|⚠️|✅|❌/, "").strip
            clean_value.empty? ? @null_value : clean_value
          else
            value.to_s
          end
        end

        def expand_row_for_csv(row, headers)
          # Determine if this is multi-type extraction (has Type column)
          has_type_column = headers.first == "Type"

          if has_type_column
            type_value = row[0]
            behavior_name = row[1]
            values = row[2..-1]
          else
            behavior_name = row[0]
            values = row[1..-1]
          end

          # Find all unique hash keys across all hash values in this row
          all_hash_keys = Set.new
          values.each do |value|
            all_hash_keys.merge(value.keys.map(&:to_s)) if value.is_a?(Hash)
          end

          return [process_row_for_csv(row)] if all_hash_keys.empty?

          # Create expanded rows
          expanded_rows = []

          # Main row with processed hash values
          main_row = if has_type_column
                       [type_value, behavior_name] + values.map { |value| process_value_for_csv(value) }
                     else
                       [behavior_name] + values.map { |value| process_value_for_csv(value) }
                     end
          expanded_rows << main_row

          # Sub-rows for each hash key
          all_hash_keys.to_a.sort.each do |key|
            path_name = ".#{key}"

            key_values = values.map do |value|
              if value.is_a?(Hash)
                has_key = value.key?(key.to_sym) || value.key?(key.to_s)
                if has_key
                  hash_value = value.key?(key.to_sym) ? value[key.to_sym] : value[key.to_s]
                  process_value_for_csv(hash_value)
                else
                  @null_value
                end
              else
                @null_value
              end
            end

            key_row = if has_type_column
                        ["", path_name] + key_values # Empty type for sub-rows
                      else
                        [path_name] + key_values
                      end

            expanded_rows << key_row
          end

          expanded_rows
        end

        def collect_all_hash_keys(rows, headers)
          has_type_column = headers.first == "Type"
          value_start_index = has_type_column ? 2 : 1

          all_keys = {} # behavior_name => Set of keys

          rows.each do |row|
            behavior_name = has_type_column ? row[1] : row[0]
            values = row[value_start_index..-1]

            values.each do |value|
              if value.is_a?(Hash)
                all_keys[behavior_name] ||= Set.new
                all_keys[behavior_name].merge(value.keys.map(&:to_s))
              end
            end
          end

          all_keys
        end

        def create_flattened_headers(headers, all_hash_keys)
          flattened = headers.dup

          has_type_column = headers.first == "Type"
          class_headers = if has_type_column
                            headers[2..-1] # Skip "Type" and "Behavior"
                          else
                            headers[1..-1] # Skip first column (behavior name)
                          end

          # For each behavior that has hash keys, add flattened columns
          all_hash_keys.each do |behavior_name, keys|
            keys.to_a.sort.each do |key|
              # Add one column for each class for each key
              class_headers.each do |class_name|
                flattened << "#{behavior_name}.#{key}.#{class_name}"
              end
            end
          end

          flattened
        end

        def flatten_row(row, headers, all_hash_keys)
          has_type_column = headers.first == "Type"
          behavior_name = has_type_column ? row[1] : row[0]

          # Start with basic processed row
          flattened = process_row_for_csv(row)

          # Add flattened hash values
          if all_hash_keys[behavior_name]
            values = has_type_column ? row[2..-1] : row[1..-1]

            # For each unique key across all hashes in this behavior
            all_hash_keys[behavior_name].to_a.sort.each do |key|
              # For each class column, get the value for this key
              values.each_with_index do |value, class_index|
                if value.is_a?(Hash)
                  has_key = value.key?(key.to_sym) || value.key?(key.to_s)
                  if has_key
                    hash_value = value.key?(key.to_sym) ? value[key.to_sym] : value[key.to_s]
                    flattened << process_value_for_csv(hash_value)
                  else
                    flattened << @null_value
                  end
                else
                  flattened << @null_value
                end
              end
            end
          end

          flattened
        end

        def generate_csv(headers, rows)
          csv_options = {
            col_sep: @separator,
            quote_char: @quote_char,
            force_quotes: false
          }

          CSV.generate(**csv_options) do |csv|
            csv << headers
            rows.each { |row| csv << row }
          end.strip
        end
      end
    end
  end
end
