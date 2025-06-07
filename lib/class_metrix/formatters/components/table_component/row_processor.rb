# frozen_string_literal: true

require_relative "../../../processors/value_processor"

module ClassMetrix
  module Formatters
    module Components
      class TableComponent
        class RowProcessor
          def initialize(data_extractor, options = {})
            @data_extractor = data_extractor
            @hide_main_row = options.fetch(:hide_main_row, false)
            @hide_key_rows = options.fetch(:hide_key_rows, true) # Default: show only main rows
          end

          def process_simple_rows(rows)
            rows.map do |row|
              processed_row = [row[0]] # Keep the behavior name as-is
              rest_values = row[1..] || []
              rest_values.each do |value|
                processed_row << ValueProcessor.process(value)
              end
              processed_row
            end
          end

          def process_expanded_rows(rows)
            expanded_rows = [] # : Array[Array[String]]

            rows.each do |row|
              if @data_extractor.row_has_expandable_hash?(row)
                expanded_rows.concat(expand_row(row))
              else
                expanded_rows << process_non_hash_row(row)
              end
            end

            expanded_rows
          end

          private

          def process_non_hash_row(row)
            if @data_extractor.has_type_column?
              rest_values = row[2..] || []
              [row[0], row[1]] + rest_values.map { |value| ValueProcessor.process(value) }
            else
              rest_values = row[1..] || []
              [row[0]] + rest_values.map { |value| ValueProcessor.process(value) }
            end
          end

          def expand_row(row)
            row_data = @data_extractor.extract_row_data(row)
            all_hash_keys = @data_extractor.collect_hash_keys(row_data[:values])

            return [row] if all_hash_keys.empty?

            build_expanded_rows(row_data, all_hash_keys, row)
          end

          def build_expanded_rows(row_data, all_hash_keys, original_row)
            expanded_rows = [] # : Array[Array[String]]

            # Add main row if configured to show
            expanded_rows << build_main_expanded_row(row_data) if should_show_main_row?

            # Add key rows if configured to show
            expanded_rows.concat(build_key_rows(all_hash_keys, row_data, original_row)) if should_show_key_rows?

            expanded_rows
          end

          def should_show_main_row?
            !@hide_main_row
          end

          def should_show_key_rows?
            !@hide_key_rows
          end

          def build_key_rows(all_hash_keys, row_data, original_row)
            all_hash_keys.to_a.sort.map do |key|
              build_key_row(key, row_data, original_row)
            end
          end

          def build_main_expanded_row(row_data)
            processed_values = row_data[:values].map { |value| ValueProcessor.process(value) }

            if @data_extractor.has_type_column?
              [row_data[:type_value], row_data[:behavior_name]] + processed_values
            else
              [row_data[:behavior_name]] + processed_values
            end
          end

          def build_key_row(key, row_data, original_row)
            path_name = ".#{key}"
            key_values = process_key_values(key, row_data[:values], original_row)

            if @data_extractor.has_type_column?
              ["-", path_name] + key_values
            else
              [path_name] + key_values
            end
          end

          def process_key_values(key, values, original_row)
            values.map.with_index do |value, index|
              if value.is_a?(Hash)
                extract_hash_value(value, key)
              else
                handle_non_hash_value(original_row, index)
              end
            end
          end

          def extract_hash_value(hash, key)
            has_key = hash.key?(key.to_sym) || hash.key?(key.to_s)
            if has_key
              hash_value = hash[key.to_sym] || hash[key.to_s]
              ValueProcessor.process(hash_value)
            else
              "—" # Missing hash key
            end
          end

          def handle_non_hash_value(original_row, index)
            original_value = original_row[@data_extractor.has_type_column? ? (index + 2) : (index + 1)]
            if original_value.to_s.include?("🚫")
              "🚫 Not defined"
            else
              "—" # Non-hash values don't have this key
            end
          end
        end
      end
    end
  end
end
