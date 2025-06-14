# frozen_string_literal: true

module ClassMetrix
  module Formatters
    module Components
      class FooterComponent
        def initialize(options = {})
          @options = options
          @show_footer = options.fetch(:show_footer, true)
          @custom_footer = options[:custom_footer]
          @show_timestamp = options.fetch(:show_timestamp, false)
          @show_separator = options.fetch(:show_separator, true)
          @footer_style = options.fetch(:footer_style, :default) # :default, :minimal, :detailed
        end

        def generate
          return [] unless @show_footer

          output = [] # : Array[String]

          # Add separator line
          output << "---" if @show_separator

          case @footer_style
          when :minimal
            output << "*Generated by ClassMetrix*"
          when :detailed
            output.concat(generate_detailed_footer)
          else
            output.concat(generate_default_footer)
          end

          output
        end

        private

        def generate_default_footer
          output = [] # : Array[String]

          output << (@custom_footer || "*Report generated by ClassMetrix gem*")

          if @show_timestamp
            output << ""
            output << "*Generated at: #{Time.now.strftime("%Y-%m-%d %H:%M:%S %Z")}*"
          end

          output
        end

        def generate_detailed_footer
          output = [] # : Array[String]

          output << "## Report Information"
          output << ""
          output << "- **Generated by**: [ClassMetrix gem](https://github.com/patrick204nqh/class-metrix)"
          output << "- **Generated at**: #{Time.now.strftime("%Y-%m-%d %H:%M:%S %Z")}"
          output << "- **Ruby version**: #{RUBY_VERSION}"

          output << "- **Note**: #{@custom_footer}" if @custom_footer

          output
        end
      end
    end
  end
end
