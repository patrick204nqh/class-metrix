# frozen_string_literal: true

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
        def expand_row(row, _headers)
          behavior_name = row[behavior_column_index]
          values = row[value_start_index..]

          all_hash_keys = collect_unique_hash_keys(values)
          return [process_row(row)] if all_hash_keys.empty?

          build_expanded_row_structure(row, behavior_name, values, all_hash_keys)
        end

        def collect_unique_hash_keys(values)
          all_hash_keys = Set.new
          values.each do |value|
            all_hash_keys.merge(value.keys.map(&:to_s)) if value.is_a?(Hash)
          end
          all_hash_keys
        end

        def build_expanded_row_structure(row, behavior_name, values, all_hash_keys)
          expanded_rows = []
          expanded_rows << build_main_row(row, behavior_name, values)
          expanded_rows.concat(build_hash_key_rows(row, behavior_name, values, all_hash_keys))
          expanded_rows
        end

        def build_main_row(row, behavior_name, values)
          processed_values = values.map { |value| process_value(value) }

          if has_type_column?
            [row[0], behavior_name] + processed_values
          else
            [behavior_name] + processed_values
          end
        end

        def build_hash_key_rows(row, behavior_name, values, all_hash_keys)
          all_hash_keys.to_a.sort.map do |key|
            build_single_key_row(row, behavior_name, values, key)
          end
        end

        def build_single_key_row(row, behavior_name, values, key)
          path_name = "#{behavior_name}.#{key}"
          key_values = extract_key_values_for_row(values, key)

          if has_type_column?
            [row[0], path_name] + key_values # Keep original type
          else
            [path_name] + key_values
          end
        end

        def extract_key_values_for_row(values, key)
          values.map do |value|
            extract_single_key_value(value, key)
          end
        end

        def extract_single_key_value(value, key)
          if value.is_a?(Hash)
            extract_hash_key_value(value, key)
          else
            get_null_value
          end
        end

        def extract_hash_key_value(hash, key)
          if @value_processor.has_hash_key?(hash, key)
            hash_value = @value_processor.safe_hash_lookup(hash, key)
            process_value(hash_value)
          else
            get_null_value
          end
        end
      end
    end
  end
end
