# frozen_string_literal: true

require_relative "csv_components/csv_header_component"
require_relative "csv_components/csv_table_component"

module ClassMetrix
  class CsvFormatter
    def initialize(data, expand_hashes = false, options = {})
      @data = data
      @expand_hashes = expand_hashes
      @options = options.merge(expand_hashes: expand_hashes)

      # Initialize components
      @header_component = Formatters::CsvComponents::CsvHeaderComponent.new(data, @options)
      @table_component = Formatters::CsvComponents::CsvTableComponent.new(data, @options)
    end

    def format
      return "" if @data[:headers].empty? || @data[:rows].empty?

      output = []

      # Add header comments (if enabled)
      header_lines = @header_component.generate
      output.concat(header_lines) unless header_lines.empty?

      # Add main CSV table
      table_output = @table_component.generate
      output << table_output unless table_output.empty?

      # Join with newlines
      output.join("\n")
    end
  end
end
