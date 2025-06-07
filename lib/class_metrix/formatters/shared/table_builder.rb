# frozen_string_literal: true

require "set"
require_relative "value_processor"

module ClassMetrix
  module Formatters
    module Shared
      class TableBuilder
        attr_reader :data, :expand_hashes, :options

        def initialize(data, expand_hashes = false, options = {})
          @data = data
          @expand_hashes = expand_hashes
          @options = options
          @value_processor = ValueProcessor
        end

        def build_simple_table
          {
            headers: @data[:headers],
            rows: @data[:rows].map { |row| process_row(row) }
          }
        end

        def build_expanded_table
          return build_simple_table unless @expand_hashes

          headers = @data[:headers]
          expanded_rows = []

          @data[:rows].each do |row|
            has_expandable_hash = row[value_start_index..-1].any? { |cell| cell.is_a?(Hash) }

            if has_expandable_hash
              expanded_rows.concat(expand_row(row, headers))
            else
              expanded_rows << process_row(row)
            end
          end

          {
            headers: headers,
            rows: expanded_rows
          }
        end

        def build_flattened_table
          return build_simple_table unless @expand_hashes

          headers = @data[:headers]
          rows = @data[:rows]

          # Collect all unique hash keys
          all_hash_keys = collect_all_hash_keys(rows, headers)

          # Create flattened headers
          flattened_headers = create_flattened_headers(headers, all_hash_keys)

          # Create flattened rows
          flattened_rows = rows.map do |row|
            flatten_row(row, headers, all_hash_keys)
          end

          {
            headers: flattened_headers,
            rows: flattened_rows
          }
        end

        private

        def has_type_column?
          @data[:headers].first == "Type"
        end

        def behavior_column_index
          has_type_column? ? 1 : 0
        end

        def value_start_index
          has_type_column? ? 2 : 1
        end

        def class_headers
          if has_type_column?
            @data[:headers][2..-1] # Skip "Type" and "Behavior"
          else
            @data[:headers][1..-1] # Skip first column (behavior name)
          end
        end

        def process_row(row)
          row.map { |value| process_value(value) }
        end

        def process_value(value)
          # This will be overridden by subclasses
          value
        end

        def expand_row(row, headers)
          behavior_name = row[behavior_column_index]
          values = row[value_start_index..-1]

          # Find all unique hash keys across all hash values in this row
          all_hash_keys = Set.new
          values.each do |value|
            all_hash_keys.merge(value.keys.map(&:to_s)) if value.is_a?(Hash)
          end

          return [process_row(row)] if all_hash_keys.empty?

          # Create expanded rows
          expanded_rows = []

          # Main row with processed hash values
          main_row = if has_type_column?
                       [row[0], behavior_name] + values.map { |value| process_value(value) }
                     else
                       [behavior_name] + values.map { |value| process_value(value) }
                     end
          expanded_rows << main_row

          # Sub-rows for each hash key
          all_hash_keys.to_a.sort.each do |key|
            path_name = ".#{key}"

            key_values = values.map do |value|
              if value.is_a?(Hash)
                if @value_processor.has_hash_key?(value, key)
                  hash_value = @value_processor.safe_hash_lookup(value, key)
                  process_value(hash_value)
                else
                  get_null_value
                end
              else
                get_null_value
              end
            end

            key_row = if has_type_column?
                        ["", path_name] + key_values # Empty type for sub-rows
                      else
                        [path_name] + key_values
                      end

            expanded_rows << key_row
          end

          expanded_rows
        end

        def collect_all_hash_keys(rows, headers)
          value_start_idx = value_start_index
          all_keys = {} # behavior_name => Set of keys

          rows.each do |row|
            behavior_name = row[behavior_column_index]
            values = row[value_start_idx..-1]

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

          class_hdrs = class_headers

          # For each behavior that has hash keys, add flattened columns
          all_hash_keys.each do |behavior_name, keys|
            keys.to_a.sort.each do |key|
              # Add one column for each class for each key
              class_hdrs.each do |class_name|
                flattened << "#{behavior_name}.#{key}.#{class_name}"
              end
            end
          end

          flattened
        end

        def flatten_row(row, headers, all_hash_keys)
          behavior_name = row[behavior_column_index]

          # Start with basic processed row
          flattened = process_row(row)

          # Add flattened hash values
          if all_hash_keys[behavior_name]
            values = row[value_start_index..-1]

            # For each unique key across all hashes in this behavior
            all_hash_keys[behavior_name].to_a.sort.each do |key|
              # For each class column, get the value for this key
              values.each do |value|
                if value.is_a?(Hash)
                  if @value_processor.has_hash_key?(value, key)
                    hash_value = @value_processor.safe_hash_lookup(value, key)
                    flattened << process_value(hash_value)
                  else
                    flattened << get_null_value
                  end
                else
                  flattened << get_null_value
                end
              end
            end
          end

          flattened
        end

        def get_null_value
          # Override in subclasses
          ""
        end
      end
    end
  end
end
