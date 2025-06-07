# frozen_string_literal: true

require_relative "constants_extractor"
require_relative "methods_extractor"

module ClassMetrix
  class MultiTypeExtractor
    def initialize(classes, types, filters, modules, handle_errors)
      @classes = classes
      @types = types
      @filters = filters
      @modules = modules
      @handle_errors = handle_errors
    end

    def extract
      return { headers: [], rows: [] } if @classes.empty? || @types.empty?

      # Build headers: ["Type", "Behavior", "Class1", "Class2", ...]
      headers = %w[Type Behavior] + @classes.map { |klass| klass.name }

      all_rows = []

      @types.each do |type|
        type_data = extract_single_type(type)

        # Add rows with type prefix
        type_data[:rows].each do |row|
          behavior_name = row[0]
          values = row[1..-1]

          new_row = [type_label(type), behavior_name] + values
          all_rows << new_row
        end
      end

      { headers: headers, rows: all_rows }
    end

    private

    def extract_single_type(type)
      case type
      when :constants
        ConstantsExtractor.new(@classes, @filters, @handle_errors).extract
      when :class_methods
        MethodsExtractor.new(@classes, @filters, @handle_errors).extract
      else
        { headers: [], rows: [] }
      end
    end

    def type_label(type)
      case type
      when :constants
        "Constant"
      when :class_methods
        "Class Method"
      when :module_methods
        "Module Method"
      else
        type.to_s.split("_").map(&:capitalize).join(" ")
      end
    end
  end
end
