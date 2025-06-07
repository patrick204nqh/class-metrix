# frozen_string_literal: true

require "csv"
require_relative "base/base_formatter"
require_relative "shared/csv_table_builder"
require_relative "components/generic_header_component"

module ClassMetrix
  class CsvFormatter < Formatters::Base::BaseFormatter
    def initialize(data, expand_hashes = false, options = {})
      super
      @table_builder = Formatters::Shared::CsvTableBuilder.new(data, expand_hashes, @options)
    end

    def format
      return "" if @data[:headers].empty? || @data[:rows].empty?

      output_lines = [] #: Array[String]

      # Add CSV header comments
      if @options.fetch(:show_metadata, true)
        header_component = Formatters::Components::GenericHeaderComponent.new(@data, @options.merge(format: :csv))
        header_lines = header_component.generate
        output_lines.concat(header_lines)
      end

      # Generate table data based on hash handling mode
      table_data = determine_table_data

      # Convert to CSV format
      csv_output = render_csv_table(table_data)
      output_lines.concat(csv_output)

      output_lines.join("\n")
    end

    protected

    def default_options
      super.merge({
                    separator: ",",
                    quote_char: '"',
                    flatten_hashes: false,
                    null_value: "",
                    comment_char: "#",
                    show_metadata: true
                  })
    end

    private

    def determine_table_data
      if @options[:flatten_hashes]
        @table_builder.build_flattened_table
      elsif @expand_hashes
        @table_builder.build_expanded_table
      else
        @table_builder.build_simple_table
      end
    end

    def render_csv_table(table_data)
      headers = table_data[:headers]
      rows = table_data[:rows]

      return [] if headers.empty?

      output = [] #: Array[String]
      separator = @options.fetch(:separator, ",")
      quote_char = @options.fetch(:quote_char, '"')

      # Generate CSV rows
      csv_rows = [headers] + rows

      csv_rows.each do |row|
        # Ensure all row values are strings and properly quoted
        formatted_row = row.map { |cell| format_csv_cell(cell) }
        csv_line = CSV.generate(col_sep: separator, quote_char: quote_char) { |csv| csv << formatted_row }.chomp
        output << csv_line
      end

      output
    end

    def format_csv_cell(value)
      case value
      when nil
        @options.fetch(:null_value, "")
      when String
        # Clean up emoji and special characters for CSV compatibility
        clean_value = value.gsub(/[🚫⚠️✅❌]/, "").strip
        clean_value.empty? ? @options.fetch(:null_value, "") : clean_value
      else
        value.to_s
      end
    end
  end
end
