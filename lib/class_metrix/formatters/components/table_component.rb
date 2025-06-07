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

          # Process values for display
          processed_rows = rows.map do |row|
            processed_row = [row[0]] # Keep the behavior name as-is
            row[1..-1].each do |value|
              processed_row << ValueProcessor.process(value)
            end
            processed_row
          end

          # Calculate column widths
          col_widths = calculate_column_widths(headers, processed_rows)

          # Build the table
          output = []

          # Header row
          header_row = build_row(headers, col_widths)
          output << header_row

          # Separator row
          separator = build_separator(col_widths)
          output << separator

          # Data rows
          processed_rows.each do |row|
            data_row = build_row(row, col_widths)
            output << data_row
          end

          output.join("\n")
        end

        def format_with_hash_expansion
          headers = @data[:headers]
          rows = @data[:rows]
          expanded_rows = []

          rows.each do |row|
            # Check if any cell contains a hash that needs expansion
            # For multi-type extraction, values start at index 2, for single-type at index 1
            has_type_column = headers.first == "Type"
            value_start_index = has_type_column ? 2 : 1
            has_expandable_hash = row[value_start_index..-1].any? { |cell| cell.is_a?(Hash) }

            if has_expandable_hash
              # Expand this row into multiple sub-rows
              expanded_rows.concat(expand_row(row, headers))
            else
              # Process the row values for display
              processed_row = if has_type_column
                                [row[0], row[1]] + row[2..-1].map { |value| ValueProcessor.process(value) }
                              else
                                [row[0]] + row[1..-1].map { |value| ValueProcessor.process(value) }
                              end
              expanded_rows << processed_row
            end
          end

          # Build the table with expanded rows
          col_widths = calculate_column_widths(headers, expanded_rows)

          output = []

          # Header row
          header_row = build_row(headers, col_widths)
          output << header_row

          # Separator row
          separator = build_separator(col_widths)
          output << separator

          # Data rows
          expanded_rows.each do |row|
            data_row = build_row(row, col_widths)
            output << data_row
          end

          output.join("\n")
        end

        def expand_row(row, headers)
          # Determine if this is multi-type extraction (has Type column)
          has_type_column = headers.first == "Type"

          if has_type_column
            # Multi-type format: [Type, Behavior, Value1, Value2, ...]
            type_value = row[0]
            behavior_name = row[1]
            values = row[2..-1]
          else
            # Single-type format: [Behavior, Value1, Value2, ...]
            behavior_name = row[0]
            values = row[1..-1]
          end

          # Find all unique hash keys across all hash values in this row
          all_hash_keys = Set.new
          values.each_with_index do |value, i|
            all_hash_keys.merge(value.keys.map(&:to_s)) if value.is_a?(Hash)
          end

          return [row] if all_hash_keys.empty?

          # Create expanded rows
          expanded_rows = []

          # First, add the main row with processed hash values (showing inspect or summary)
          main_row = if has_type_column
                       [type_value, behavior_name] + values.map { |value| ValueProcessor.process(value) }
                     else
                       [behavior_name] + values.map { |value| ValueProcessor.process(value) }
                     end
          expanded_rows << main_row

          # Then add expanded key rows
          all_hash_keys.to_a.sort.each do |key|
            path_name = ".#{key}"

            key_values = values.map.with_index do |value, index|
              if value.is_a?(Hash)
                # Check if key exists (need to check both string and symbol versions)
                has_key = value.key?(key.to_sym) || value.key?(key.to_s)
                if has_key
                  hash_value = value[key.to_sym] || value[key.to_s]
                  ValueProcessor.process(hash_value)
                else
                  "—" # Missing hash key (different from false value)
                end
              else
                # Check if the original value was an error (from the main row)
                original_value = row[has_type_column ? (index + 2) : (index + 1)]
                if original_value.to_s.include?("🚫")
                  "🚫 Not defined"
                else
                  "—" # Non-hash values don't have this key (different from false value)
                end
              end
            end

            key_row = if has_type_column
                        ["-", path_name] + key_values
                      else
                        [path_name] + key_values
                      end

            expanded_rows << key_row
          end

          expanded_rows
        end

        def calculate_column_widths(headers, rows)
          col_count = headers.length
          widths = Array.new(col_count, 0)

          # Check header widths
          headers.each_with_index do |header, i|
            widths[i] = [widths[i], header.to_s.length].max
          end

          # Check data row widths
          rows.each do |row|
            row.each_with_index do |cell, i|
              next if i >= col_count

              cell_width = cell.to_s.length
              # Apply max width limit for readability
              cell_width = [@max_column_width, cell_width].min if @table_style == :compact
              widths[i] = [widths[i], cell_width].max
            end
          end

          # Apply minimum width
          widths.map { |w| [w, @min_column_width].max }
        end

        def build_row(cells, col_widths)
          formatted_cells = cells.each_with_index.map do |cell, i|
            width = col_widths[i] || 10
            cell_str = cell.to_s

            # Truncate if needed for compact style
            if @table_style == :compact && cell_str.length > @max_column_width
              cell_str = "#{cell_str[0...(@max_column_width - 3)]}..."
            end

            " #{cell_str.ljust(width)} "
          end

          "|" + formatted_cells.join("|") + "|"
        end

        def build_separator(col_widths)
          separators = col_widths.map { |width| "-" * (width + 2) }
          "|" + separators.join("|") + "|"
        end
      end
    end
  end
end
