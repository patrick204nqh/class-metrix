# frozen_string_literal: true

require_relative "table_component/table_data_extractor"
require_relative "table_component/row_processor"
require_relative "table_component/column_width_calculator"
require_relative "table_component/table_renderer"

module ClassMetrix
  module Formatters
    module Components
      class TableComponent
        def initialize(data, options = {})
          @data = data
          @options = options
          @expand_hashes = options.fetch(:expand_hashes, false)
          @table_style = options.fetch(:table_style, :standard)
          @min_column_width = options.fetch(:min_column_width, 3)
          @max_column_width = options.fetch(:max_column_width, 50)
          @hide_main_row = options.fetch(:hide_main_row, false)
          @hide_key_rows = options.fetch(:hide_key_rows, true) # Default: show only main rows

          # Initialize helper objects
          @data_extractor = TableDataExtractor.new(@data[:headers])
          @row_processor = RowProcessor.new(@data_extractor,
                                            hide_main_row: @hide_main_row,
                                            hide_key_rows: @hide_key_rows)
          @width_calculator = ColumnWidthCalculator.new(
            table_style: @table_style,
            min_column_width: @min_column_width,
            max_column_width: @max_column_width
          )
          @renderer = TableRenderer.new(
            table_style: @table_style,
            max_column_width: @max_column_width
          )
        end

        def generate
          return "" if @data[:headers].empty? || @data[:rows].empty?

          headers = @data[:headers]
          rows = if @expand_hashes
                   @row_processor.process_expanded_rows(@data[:rows])
                 else
                   @row_processor.process_simple_rows(@data[:rows])
                 end

          column_widths = @width_calculator.calculate_widths(headers, rows)
          @renderer.render_table(headers, rows, column_widths)
        end
      end
    end
  end
end
