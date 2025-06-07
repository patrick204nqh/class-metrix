# frozen_string_literal: true

module ClassMetrix
  module Formatters
    module Components
      class TableComponent
        class TableDataExtractor
          def initialize(headers)
            @headers = headers
          end

          def has_type_column?
            @headers.first == "Type"
          end

          def value_start_index
            has_type_column? ? 2 : 1
          end

          def behavior_column_index
            has_type_column? ? 1 : 0
          end

          def extract_row_data(row)
            if has_type_column?
              {
                type_value: row[0],
                behavior_name: row[1],
                values: row[2..]
              }
            else
              {
                behavior_name: row[0],
                values: row[1..]
              }
            end
          end

          def row_has_expandable_hash?(row)
            values = row[value_start_index..] || []
            return false if values.nil?

            values.any? { |cell| cell.is_a?(Hash) }
          end

          def collect_hash_keys(values)
            all_hash_keys = Set.new
            values.each do |value|
              all_hash_keys.merge(value.keys.map(&:to_s)) if value.is_a?(Hash)
            end
            all_hash_keys
          end
        end
      end
    end
  end
end
