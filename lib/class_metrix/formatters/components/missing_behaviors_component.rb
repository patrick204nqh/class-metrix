# frozen_string_literal: true

module ClassMetrix
  module Formatters
    module Components
      class MissingBehaviorsComponent
        def initialize(data, options = {})
          @data = data
          @options = options
          @show_missing_summary = options.fetch(:show_missing_summary, false)
          @summary_style = options.fetch(:summary_style, :grouped) # :grouped, :flat, :detailed
          @missing_behaviors = {} # : Hash[String, Hash[String, String]]
        end

        def generate
          return [] unless @show_missing_summary

          track_missing_behaviors
          generate_missing_behaviors_summary
        end

        private

        def track_missing_behaviors
          has_type_column = @data[:headers].first == "Type"
          class_headers = if has_type_column
                            @data[:headers][2..]
                          else
                            @data[:headers][1..]
                          end

          # Initialize missing behaviors tracking with hash to store behavior name and error message
          class_headers.each { |class_name| @missing_behaviors[class_name] = {} } # : Hash[String, Hash[String, String]]

          @data[:rows].each do |row|
            behavior_name = has_type_column ? row[1] : row[0]
            values = has_type_column ? row[2..] : row[1..]

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
          # Only show summary if there are missing behaviors
          total_missing = @missing_behaviors.values.map(&:size).sum
          return [] if total_missing.zero?

          case @summary_style
          when :flat
            generate_flat_summary
          when :detailed
            generate_detailed_summary
          else
            generate_grouped_summary
          end
        end

        def generate_grouped_summary
          output = [] # : Array[String]

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

          output
        end

        def generate_flat_summary
          output = [] # : Array[String]

          output << "## Missing Behaviors"
          output << ""

          all_missing = [] # : Array[String]
          @missing_behaviors.each do |class_name, behaviors_hash|
            behaviors_hash.each do |behavior_name, error_message|
              all_missing << "- **#{class_name}**: `#{behavior_name}` - #{error_message}"
            end
          end

          output.concat(all_missing.sort)
          output << ""

          output
        end

        def generate_detailed_summary
          output = [] # : Array[String]

          total_missing = @missing_behaviors.values.map(&:size).sum
          total_classes = @missing_behaviors.keys.size

          output << "## Missing Behaviors Analysis"
          output << ""
          output << "**Summary**: #{total_missing} missing behaviors across #{total_classes} classes"
          output << ""

          # Group by error type
          by_error_type = {} # : Hash[String, Array[Hash[Symbol, String]]]
          @missing_behaviors.each do |class_name, behaviors_hash|
            behaviors_hash.each do |behavior_name, error_message|
              error_type = error_message.split.first(2).join(" ") # e.g., "🚫 Not", "⚠️ Error:"
              by_error_type[error_type] ||= []
              by_error_type[error_type] << { class: class_name, behavior: behavior_name, message: error_message }
            end
          end

          by_error_type.each do |error_type, items|
            output << "### #{error_type} (#{items.size} items)"
            output << ""
            items.each do |item|
              output << "- **#{item[:class]}**: `#{item[:behavior]}` - #{item[:message]}"
            end
            output << ""
          end

          output
        end
      end
    end
  end
end
