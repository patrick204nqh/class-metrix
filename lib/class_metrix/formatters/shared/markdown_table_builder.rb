# frozen_string_literal: true

require "set"
require_relative "table_builder"

module ClassMetrix
  module Formatters
    module Shared
      class MarkdownTableBuilder < TableBuilder
        private

        def process_value(value)
          @value_processor.process_for_markdown(value)
        end

        def get_null_value
          @value_processor.missing_hash_key
        end

        # Create proper flat table structure for hash expansion
        def expand_row(row, headers)
          behavior_name = row[behavior_column_index]
          values = row[value_start_index..-1]

          # Find all unique hash keys across all hash values in this row
          all_hash_keys = Set.new
          values.each do |value|
            all_hash_keys.merge(value.keys.map(&:to_s)) if value.is_a?(Hash)
          end

          return [process_row(row)] if all_hash_keys.empty?

          # Create expanded rows with proper flat structure
          expanded_rows = []

          # Main row with processed hash values
          main_row = if has_type_column?
                       [row[0], behavior_name] + values.map { |value| process_value(value) }
                     else
                       [behavior_name] + values.map { |value| process_value(value) }
                     end
          expanded_rows << main_row

          # Flat rows for each hash key - use proper type names
          all_hash_keys.to_a.sort.each do |key|
            path_name = "#{behavior_name}.#{key}"

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
                        [row[0], path_name] + key_values # Keep original type
                      else
                        [path_name] + key_values
                      end

            expanded_rows << key_row
          end

          expanded_rows
        end
      end
    end
  end
end
