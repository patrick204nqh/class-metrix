# frozen_string_literal: true

require "set"
require_relative "../processors/value_processor"

module ClassMetrix
  class MarkdownFormatter
    def initialize(data, expand_hashes = false, options = {})
      @data = data
      @expand_hashes = expand_hashes
      @title = options[:title]
      @extraction_types = options[:extraction_types] || []
      @show_missing_summary = options.fetch(:show_missing_summary, false)
      @missing_behaviors = {} # Track missing behaviors per class
    end

    def format
      return "" if @data[:headers].empty? || @data[:rows].empty?

      # Track missing behaviors during formatting
      track_missing_behaviors

      output = []

      # Add title and metadata
      output.concat(generate_header)

      # Add main table
      output << if @expand_hashes
                  format_with_hash_expansion
                else
                  format_simple_table
                end

      # Add missing behaviors summary (if enabled)
      output.concat(generate_missing_behaviors_summary) if @show_missing_summary

      output.join("\n\n")
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

          widths[i] = [widths[i], cell.to_s.length].max
        end
      end

      # Minimum width of 3 for readability
      widths.map { |w| [w, 3].max }
    end

    def build_row(cells, col_widths)
      formatted_cells = cells.each_with_index.map do |cell, i|
        width = col_widths[i] || 10
        " #{cell.to_s.ljust(width)} "
      end

      "|" + formatted_cells.join("|") + "|"
    end

    def build_separator(col_widths)
      separators = col_widths.map { |width| "-" * (width + 2) }
      "|" + separators.join("|") + "|"
    end

    def generate_header
      output = []

      # Add title
      if @title
        output << "# #{@title}"
      else
        extraction_label = @extraction_types.empty? ? "Class Analysis" : @extraction_types.map(&:to_s).map(&:capitalize).join(" and ")
        output << "# #{extraction_label} Report"
      end

      # Add classes being analyzed
      has_type_column = @data[:headers].first == "Type"
      class_headers = if has_type_column
                        @data[:headers][2..-1] # Skip "Type" and "Behavior"
                      else
                        @data[:headers][1..-1] # Skip first column (behavior name)
                      end

      output << "## Classes Analyzed"
      output << ""
      class_headers.each do |class_name|
        output << "- **#{class_name}**"
      end
      output << ""

      # Add extraction info
      unless @extraction_types.empty?
        output << "## Extraction Types"
        output << ""
        @extraction_types.each do |type|
          output << case type
                    when :constants
                      "- **Constants**: Class constants and their values"
                    when :class_methods
                      "- **Class Methods**: Class method results and return values"
                    else
                      "- **#{type.to_s.split("_").map(&:capitalize).join(" ")}**"
                    end
        end
        output << ""
      end

      output
    end

    def track_missing_behaviors
      has_type_column = @data[:headers].first == "Type"
      class_headers = if has_type_column
                        @data[:headers][2..-1]
                      else
                        @data[:headers][1..-1]
                      end

      # Initialize missing behaviors tracking with hash to store behavior name and error message
      class_headers.each { |class_name| @missing_behaviors[class_name] = {} }

      @data[:rows].each do |row|
        behavior_name = has_type_column ? row[1] : row[0]
        values = has_type_column ? row[2..-1] : row[1..-1]

        values.each_with_index do |value, index|
          class_name = class_headers[index]
          next unless value.to_s.include?("🚫") || value.nil?

          # Store the actual error message from the table
          error_message = value.to_s.include?("🚫") ? value.to_s : "🚫 Not defined"
          @missing_behaviors[class_name][behavior_name] = error_message
        end
      end
    end

    def generate_missing_behaviors_summary
      output = []

      # Only show summary if there are missing behaviors
      total_missing = @missing_behaviors.values.map(&:size).sum
      return output if total_missing == 0

      output << "## Missing Behaviors Summary"
      output << ""
      output << "The following behaviors are not defined in some classes:"
      output << ""

      @missing_behaviors.each do |class_name, behaviors_hash|
        next if behaviors_hash.empty?

        output << "### #{class_name}"
        behaviors_hash.each do |behavior_name, error_message|
          output << "- `#{behavior_name}` - #{error_message}"
        end
        output << ""
      end

      output << "---"
      output << "*Report generated by ClassMetrix gem*"

      output
    end
  end
end
