# frozen_string_literal: true

module ClassMetrix
  module Formatters
    module Components
      class TableComponent
        class ColumnWidthCalculator
          def initialize(table_style: :standard, min_column_width: 3, max_column_width: 50)
            @table_style = table_style
            @min_column_width = min_column_width
            @max_column_width = max_column_width
          end

          def calculate_widths(headers, rows)
            col_count = headers.length
            widths = initialize_column_widths(col_count, headers)

            update_widths_from_rows(widths, rows, col_count)
            apply_minimum_widths(widths)
          end

          private

          def initialize_column_widths(col_count, headers)
            widths = Array.new(col_count, 0)
            headers.each_with_index do |header, i|
              widths[i] = [widths[i], header.to_s.length].max
            end
            widths
          end

          def update_widths_from_rows(widths, rows, col_count)
            rows.each do |row|
              row.each_with_index do |cell, i|
                next if i >= col_count

                cell_width = calculate_cell_width(cell)
                widths[i] = [widths[i], cell_width].max
              end
            end
          end

          def calculate_cell_width(cell)
            cell_width = cell.to_s.length
            # Apply max width limit for readability
            @table_style == :compact ? [@max_column_width, cell_width].min : cell_width
          end

          def apply_minimum_widths(widths)
            widths.map { |w| [w, @min_column_width].max }
          end
        end
      end
    end
  end
end
