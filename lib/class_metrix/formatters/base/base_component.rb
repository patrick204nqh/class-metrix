# frozen_string_literal: true

require_relative "../shared/value_processor"

module ClassMetrix
  module Formatters
    module Base
      class BaseComponent
        attr_reader :data, :options, :value_processor

        def initialize(data, options = {})
          @data = data
          @options = options
          @value_processor = Shared::ValueProcessor
        end

        def generate
          raise NotImplementedError, "Subclasses must implement #generate method"
        end

        protected

        def has_type_column?
          @data[:headers].first == "Type"
        end

        def behavior_column_index
          has_type_column? ? 1 : 0
        end

        def value_start_index
          has_type_column? ? 2 : 1
        end

        def class_headers
          if has_type_column?
            @data[:headers][2..] # Skip "Type" and "Behavior"
          else
            @data[:headers][1..] # Skip first column (behavior name)
          end
        end

        def extraction_types_description
          return "" if @options[:extraction_types].empty?

          @options[:extraction_types].map do |type|
            case type
            when :constants then "Constants"
            when :class_methods then "Class Methods"
            when :module_methods then "Module Methods"
            else type.to_s.split("_").map(&:capitalize).join(" ")
            end
          end.join(", ")
        end

        def format_timestamp
          Time.now.strftime("%Y-%m-%d %H:%M:%S %Z")
        end
      end
    end
  end
end
