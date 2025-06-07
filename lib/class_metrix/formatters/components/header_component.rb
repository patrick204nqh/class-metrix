# frozen_string_literal: true

module ClassMetrix
  module Formatters
    module Components
      class HeaderComponent
        def initialize(data, options = {})
          @data = data
          @options = options
          @title = options[:title]
          @extraction_types = options[:extraction_types] || []
          @show_metadata = options.fetch(:show_metadata, true)
          @show_classes = options.fetch(:show_classes, true)
          @show_extraction_info = options.fetch(:show_extraction_info, true)
        end

        def generate
          output = [] # : Array[String]

          # Add title
          output.concat(generate_title) if @title || @show_metadata

          # Add classes being analyzed
          output.concat(generate_classes_section) if @show_classes

          # Add extraction types info
          output.concat(generate_extraction_info) if @show_extraction_info && !@extraction_types.empty?

          output
        end

        private

        def generate_title
          output = [] # : Array[String]

          if @title
            output << "# #{@title}"
          else
            extraction_label = @extraction_types.empty? ? "Class Analysis" : @extraction_types.map(&:to_s).map(&:capitalize).join(" and ")
            output << "# #{extraction_label} Report"
          end

          output << ""
          output
        end

        def generate_classes_section
          output = [] # : Array[String]

          has_type_column = @data[:headers].first == "Type"
          class_headers = if has_type_column
                            @data[:headers][2..] # Skip "Type" and "Behavior"
                          else
                            @data[:headers][1..] # Skip first column (behavior name)
                          end

          output << "## Classes Analyzed"
          output << ""
          class_headers.each do |class_name|
            output << "- **#{class_name}**"
          end
          output << ""

          output
        end

        def generate_extraction_info
          output = [] # : Array[String]

          output << "## Extraction Types"
          output << ""
          @extraction_types.each do |type|
            output << case type
                      when :constants
                        "- **Constants**: Class constants and their values"
                      when :class_methods
                        "- **Class Methods**: Class method results and return values"
                      when :module_methods
                        "- **Module Methods**: Methods from included modules"
                      else
                        "- **#{type.to_s.split("_").map(&:capitalize).join(" ")}**"
                      end
          end
          output << ""

          output
        end
      end
    end
  end
end
