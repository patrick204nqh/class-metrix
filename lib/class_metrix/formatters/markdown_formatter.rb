# frozen_string_literal: true

require_relative "base/base_formatter"
require_relative "shared/markdown_table_builder"
require_relative "components/generic_header_component"
require_relative "components/missing_behaviors_component"
require_relative "components/footer_component"

module ClassMetrix
  class MarkdownFormatter < Formatters::Base::BaseFormatter
    def initialize(data, expand_hashes = false, options = {})
      super
      @table_builder = Formatters::Shared::MarkdownTableBuilder.new(data, expand_hashes, @options)
    end

    def format
      return "" if @data[:headers].empty? || @data[:rows].empty?

      output = [] # : Array[String]

      # Add header sections (title, classes, extraction info)
      if @options.fetch(:show_metadata, true)
        header_component = Formatters::Components::GenericHeaderComponent.new(@data, @options.merge(format: :markdown))
        header_output = header_component.generate
        output.concat(header_output) unless header_output.empty?
      end

      # Add main table
      table_data = @expand_hashes ? @table_builder.build_expanded_table : @table_builder.build_simple_table
      table_output = render_markdown_table(table_data)
      unless table_output.empty?
        # Join table rows with single newlines, then add as one section
        output << table_output.join("\n")
      end

      # Add missing behaviors summary
      if @options.fetch(:show_missing_summary, false)
        missing_component = Formatters::Components::MissingBehaviorsComponent.new(@data, @options)
        missing_output = missing_component.generate
        output.concat(missing_output) unless missing_output.empty?
      end

      # Add footer
      if @options.fetch(:show_footer, true)
        footer_component = Formatters::Components::FooterComponent.new(@options)
        footer_output = footer_component.generate
        output.concat(footer_output) unless footer_output.empty?
      end

      # Join with newlines, filtering out empty sections
      output.reject { |section| section.nil? || section == "" }.join("\n\n")
    end

    protected

    def default_options
      super.merge({
                    show_footer: true,
                    footer_style: :default,
                    show_timestamp: false,
                    show_classes: true,
                    show_extraction_info: true,
                    table_style: :standard,
                    summary_style: :grouped,
                    min_column_width: 3,
                    max_column_width: 20
                  })
    end

    private

    def render_markdown_table(table_data)
      headers = table_data[:headers]
      rows = table_data[:rows]

      return [] if headers.empty? || rows.empty?

      widths = calculate_column_widths(headers, rows)

      output = [] # : Array[String]
      output << build_header_row(headers, widths)
      output << build_separator_row(widths)
      output.concat(build_data_rows(rows, headers, widths))

      output
    end

    def build_header_row(headers, widths)
      "| " + headers.map.with_index { |header, i| header.ljust(widths[i]) }.join(" | ") + " |"
    end

    def build_separator_row(widths)
      "|" + widths.map { |width| "-" * (width + 2) }.join("|") + "|"
    end

    def build_data_rows(rows, headers, widths)
      rows.map do |row|
        build_single_data_row(row, headers, widths)
      end
    end

    def build_single_data_row(row, headers, widths)
      padded_row = pad_row_to_header_length(row, headers.length)
      formatted_cells = format_row_cells(padded_row, widths)
      "| " + formatted_cells.join(" | ") + " |"
    end

    def pad_row_to_header_length(row, header_length)
      padding_needed = [0, header_length - row.length].max
      row + Array.new(padding_needed, "")
    end

    def format_row_cells(row, widths)
      row.map.with_index do |cell, i|
        cell_str = truncate_cell(cell.to_s, widths[i])
        cell_str.ljust(widths[i])
      end
    end

    def calculate_column_widths(headers, rows)
      table_style = @options.fetch(:table_style, :standard)
      min_width = @options.fetch(:min_column_width, 3)
      max_width = @options.fetch(:max_column_width, 30)

      # Calculate the maximum width needed for each column
      widths = headers.map(&:length)

      rows.each do |row|
        row.each_with_index do |cell, i|
          next if i >= widths.length

          cell_length = cell.to_s.length

          # Apply max width limit for readability (like the old component did)
          cell_length = [max_width, cell_length].min if %i[compact standard].include?(table_style)

          widths[i] = [widths[i], cell_length].max
        end
      end

      # Apply minimum width and final constraints
      case table_style
      when :compact
        widths.map { |w| [[w, min_width].max, max_width].min }
      when :wide
        widths.map { |w| [w, min_width].max } # No max limit for wide style
      else # :standard
        widths.map { |w| [[w, min_width].max, max_width].min } # Apply max limit for standard too
      end
    end

    def truncate_cell(text, max_width)
      return text if text.length <= max_width
      return text if max_width < 4

      # Smart truncation for hash-like structures
      if text.start_with?("{") && text.include?("=>")
        # For hash representations, create a valid truncated version
        truncate_hash_representation(text, max_width)
      else
        # Standard truncation for other values
        "#{text[0..max_width - 4]}..."
      end
    end

    def truncate_hash_representation(text, max_width)
      return text if max_width < 6 # Need space for "{...}"

      # Try to fit at least the first key-value pair
      if max_width >= 15
        # Look for the first complete key-value pair (handle :symbol=>value format)
        match = text.match(/\{(:[^,}]+=>[^,}]+)/)
        if match && (first_pair = match[1])
          needed_length = first_pair.length + 6 # For "{", ", ...}"
          return "{#{first_pair}, ...}" if needed_length <= max_width
        end
      end

      # Fallback to simple hash indicator
      "{...}"
    end
  end
end
