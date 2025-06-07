# frozen_string_literal: true

module ClassMetrix
  module Formatters
    module Components
      class TableComponent
        class TableRenderer
          def initialize(table_style: :standard, max_column_width: 50)
            @table_style = table_style
            @max_column_width = max_column_width
          end

          def render_table(headers, rows, column_widths)
            output = []
            output << build_row(headers, column_widths)
            output << build_separator(column_widths)

            rows.each do |row|
              output << build_row(row, column_widths)
            end

            output.join("\n")
          end

          private

          def build_row(cells, col_widths)
            formatted_cells = format_cells(cells, col_widths)
            "|#{formatted_cells.join("|")}|"
          end

          def format_cells(cells, col_widths)
            cells.each_with_index.map do |cell, i|
              width = col_widths[i] || 10
              cell_str = format_cell_content(cell)
              " #{cell_str.ljust(width)} "
            end
          end

          def format_cell_content(cell)
            cell_str = cell.to_s
            return cell_str unless @table_style == :compact && cell_str.length > @max_column_width

            "#{cell_str[0...(@max_column_width - 3)]}..."
          end

          def build_separator(col_widths)
            separators = col_widths.map { |width| "-" * (width + 2) }
            "|#{separators.join("|")}|"
          end
        end
      end
    end
  end
end
