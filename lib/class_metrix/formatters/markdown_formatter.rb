# frozen_string_literal: true

require "set"
require_relative "../processors/value_processor"
require_relative "components/header_component"
require_relative "components/table_component"
require_relative "components/missing_behaviors_component"
require_relative "components/footer_component"

module ClassMetrix
  class MarkdownFormatter
    def initialize(data, expand_hashes = false, options = {})
      @data = data
      @expand_hashes = expand_hashes
      @options = options.merge(expand_hashes: expand_hashes)

      # Initialize components
      @header_component = Formatters::Components::HeaderComponent.new(data, @options)
      @table_component = Formatters::Components::TableComponent.new(data, @options)
      @missing_behaviors_component = Formatters::Components::MissingBehaviorsComponent.new(data, @options)
      @footer_component = Formatters::Components::FooterComponent.new(@options)
    end

    def format
      return "" if @data[:headers].empty? || @data[:rows].empty?

      output = []

      # Add header (title, classes, extraction info)
      output.concat(@header_component.generate)

      # Add main table
      table_output = @table_component.generate
      output << table_output unless table_output.empty?

      # Add missing behaviors summary
      output.concat(@missing_behaviors_component.generate)

      # Add footer
      output.concat(@footer_component.generate)

      # Join with appropriate spacing, filtering out empty sections
      output.reject { |section| section.nil? || section == "" }.join("\n\n")
    end

    # The MarkdownFormatter now uses modular components for better maintainability.
    # All formatting logic has been moved to dedicated component classes:
    # - HeaderComponent: Handles title, class list, and extraction info
    # - TableComponent: Handles table formatting and hash expansion
    # - MissingBehaviorsComponent: Handles missing behavior analysis
    # - FooterComponent: Handles footer generation with various styles
  end
end
