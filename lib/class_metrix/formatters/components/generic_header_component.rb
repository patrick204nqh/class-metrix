# frozen_string_literal: true

require_relative "../base/base_component"

module ClassMetrix
  module Formatters
    module Components
      class GenericHeaderComponent < Base::BaseComponent
        def initialize(data, options = {})
          super
          @format = options.fetch(:format, :markdown)
          @title = options[:title]
          @extraction_types = options[:extraction_types] || []
          @show_metadata = options.fetch(:show_metadata, true)
        end

        def generate
          return [] unless @show_metadata

          case @format
          when :markdown
            generate_markdown_header
          when :csv
            generate_csv_header
          else
            raise ArgumentError, "Unknown format: #{@format}"
          end
        end

        private

        def generate_markdown_header
          output = []

          # Add title
          if @title
            output << "# #{@title}"
            output << ""
          end

          # Add classes analyzed
          output << "## Classes Analyzed"
          output << ""
          class_headers.each do |class_name|
            output << "- **#{class_name}**"
          end
          output << ""

          # Add extraction types
          unless @extraction_types.empty?
            output << "## Extraction Types"
            output << ""
            output << extraction_types_description
            output << ""
          end

          output
        end

        def generate_csv_header
          output = []
          comment_char = @options.fetch(:comment_char, "#")

          # Add title as comment
          if @title
            output << "#{comment_char} #{@title}"
          else
            extraction_label = @extraction_types.empty? ? "Class Analysis" : @extraction_types.map(&:to_s).map(&:capitalize).join(" and ")
            output << "#{comment_char} #{extraction_label} Report"
          end

          # Add classes analyzed
          output << "#{comment_char} Classes: #{class_headers.join(", ")}"

          # Add extraction types
          output << "#{comment_char} Extraction Types: #{extraction_types_description}" unless @extraction_types.empty?

          # Add generation timestamp
          output << "#{comment_char} Generated: #{format_timestamp}"
          output << comment_char.to_s # Empty comment line for separation

          output
        end
      end
    end
  end
end
