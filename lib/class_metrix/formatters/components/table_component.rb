# frozen_string_literal: true

require_relative "../../processors/value_processor"

module ClassMetrix
  module Formatters
    module Components
      class TableComponent
        def initialize(data, options = {})
          @data = data
          @options = options
          @expand_hashes = options.fetch(:expand_hashes, false)
          @table_style = options.fetch(:table_style, :standard) # :standard, :compact, :wide
          @min_column_width = options.fetch(:min_column_width, 3)
          @max_column_width = options.fetch(:max_column_width, 50)
        end

        def generate
          return "" if @data[:headers].empty? || @data[:rows].empty?

          if @expand_hashes
            format_with_hash_expansion
          else
            format_simple_table
          end
        end

        private

        def format_simple_table
          headers = @data[:headers]
          rows = @data[:rows]

          processed_rows = process_simple_rows(rows)
          build_table(headers, processed_rows)
        end

        def format_with_hash_expansion
          headers = @data[:headers]
          rows = @data[:rows]

          expanded_rows = process_expanded_rows(rows, headers)
          build_table(headers, expanded_rows)
        end

        def process_simple_rows(rows)
          rows.map do |row|
            processed_row = [row[0]] # Keep the behavior name as-is
            row[1..].each do |value|
              processed_row << ValueProcessor.process(value)
            end
            processed_row
          end
        end

        def process_expanded_rows(rows, headers)
          expanded_rows = []

          rows.each do |row|
            if row_has_expandable_hash?(row, headers)
              expanded_rows.concat(expand_row(row, headers))
            else
              expanded_rows << process_non_hash_row(row, headers)
            end
          end

          expanded_rows
        end

        def row_has_expandable_hash?(row, headers)
          has_type_column = headers.first == "Type"
          value_start_index = has_type_column ? 2 : 1
          row[value_start_index..].any? { |cell| cell.is_a?(Hash) }
        end

        def process_non_hash_row(row, headers)
          has_type_column = headers.first == "Type"
          if has_type_column
            [row[0], row[1]] + row[2..].map { |value| ValueProcessor.process(value) }
          else
            [row[0]] + row[1..].map { |value| ValueProcessor.process(value) }
          end
        end

        def build_table(headers, rows)
          col_widths = calculate_column_widths(headers, rows)

          output = []
          output << build_row(headers, col_widths)
          output << build_separator(col_widths)

          rows.each do |row|
            output << build_row(row, col_widths)
          end

          output.join("\n")
        end

        def expand_row(row, headers)
          has_type_column = headers.first == "Type"
          row_data = extract_row_data(row, has_type_column)

          all_hash_keys = collect_hash_keys(row_data[:values])
          return [row] if all_hash_keys.empty?

          build_expanded_rows(row_data, all_hash_keys, has_type_column, row)
        end

        def extract_row_data(row, has_type_column)
          if has_type_column
            build_type_column_data(row)
          else
            build_standard_column_data(row)
          end
        end

        def build_type_column_data(row)
          {
            type_value: row[0],
            behavior_name: row[1],
            values: row[2..]
          }
        end

        def build_standard_column_data(row)
          {
            behavior_name: row[0],
            values: row[1..]
          }
        end

        def collect_hash_keys(values)
          all_hash_keys = Set.new
          values.each do |value|
            all_hash_keys.merge(value.keys.map(&:to_s)) if value.is_a?(Hash)
          end
          all_hash_keys
        end

        def build_expanded_rows(row_data, all_hash_keys, has_type_column, original_row)
          expanded_rows = []

          # Add main row
          expanded_rows << build_main_expanded_row(row_data, has_type_column)

          # Add key rows
          all_hash_keys.to_a.sort.each do |key|
            expanded_rows << build_key_row(key, row_data, has_type_column, original_row)
          end

          expanded_rows
        end

        def build_main_expanded_row(row_data, has_type_column)
          processed_values = row_data[:values].map { |value| ValueProcessor.process(value) }

          if has_type_column
            [row_data[:type_value], row_data[:behavior_name]] + processed_values
          else
            [row_data[:behavior_name]] + processed_values
          end
        end

        def build_key_row(key, row_data, has_type_column, original_row)
          path_name = ".#{key}"
          key_values = process_key_values(key, row_data[:values], has_type_column, original_row)

          if has_type_column
            ["-", path_name] + key_values
          else
            [path_name] + key_values
          end
        end

        def process_key_values(key, values, has_type_column, original_row)
          values.map.with_index do |value, index|
            if value.is_a?(Hash)
              extract_hash_value(value, key)
            else
              handle_non_hash_value(original_row, index, has_type_column)
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

        def handle_non_hash_value(original_row, index, has_type_column)
          original_value = original_row[has_type_column ? (index + 2) : (index + 1)]
          if original_value.to_s.include?("🚫")
            "🚫 Not defined"
          else
            "—" # Non-hash values don't have this key
          end
        end

        def calculate_column_widths(headers, rows)
          col_count = headers.length
          widths = initialize_column_widths(col_count, headers)

          update_widths_from_rows(widths, rows, col_count)
          apply_minimum_widths(widths)
        end

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
