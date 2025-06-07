# frozen_string_literal: true

module ClassMetrix
  module Formatters
    module CsvComponents
      class CsvHeaderComponent
        def initialize(data, options = {})
          @data = data
          @options = options
          @title = options[:title]
          @extraction_types = options[:extraction_types] || []
          @show_metadata = options.fetch(:show_metadata, true)
          @comment_char = options.fetch(:comment_char, "#")
        end

        def generate
          return [] unless @show_metadata

          output = []

          # Add title as comment
          if @title
            output << "#{@comment_char} #{@title}"
          else
            extraction_label = @extraction_types.empty? ? "Class Analysis" : @extraction_types.map(&:to_s).map(&:capitalize).join(" and ")
            output << "#{@comment_char} #{extraction_label} Report"
          end

          # Add classes analyzed
          has_type_column = @data[:headers].first == "Type"
          class_headers = if has_type_column
                            @data[:headers][2..-1] # Skip "Type" and "Behavior"
                          else
                            @data[:headers][1..-1] # Skip first column (behavior name)
                          end

          output << "#{@comment_char} Classes: #{class_headers.join(", ")}"

          # Add extraction types
          unless @extraction_types.empty?
            types_description = @extraction_types.map do |type|
              case type
              when :constants then "Constants"
              when :class_methods then "Class Methods"
              when :module_methods then "Module Methods"
              else type.to_s.split("_").map(&:capitalize).join(" ")
              end
            end.join(", ")
            output << "#{@comment_char} Extraction Types: #{types_description}"
          end

          # Add generation timestamp
          output << "#{@comment_char} Generated: #{Time.now.strftime("%Y-%m-%d %H:%M:%S %Z")}"
          output << "#{@comment_char}" # Empty comment line for separation

          output
        end
      end
    end
  end
end
