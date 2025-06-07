# frozen_string_literal: true

require "set"
require_relative "../processors/value_processor"

module ClassMetrix
  class ConstantsExtractor
    def initialize(classes, filters, handle_errors)
      @classes = classes
      @filters = filters
      @handle_errors = handle_errors
    end

    def extract
      return { headers: [], rows: [] } if @classes.empty?

      # Get all constant names across all classes
      constant_names = get_all_constant_names

      # Apply filters
      constant_names = apply_filters(constant_names)

      # Build headers: ["Constant", "Class1", "Class2", ...]
      headers = ["Constant"] + @classes.map { |klass| klass.name }

      # Build rows: each row represents one constant across all classes
      rows = constant_names.map do |const_name|
        row = [const_name]

        @classes.each do |klass|
          value = extract_constant_value(klass, const_name)
          # Pass the raw value for hash expansion to work properly
          row << value
        end

        row
      end

      { headers: headers, rows: rows }
    end

    private

    def get_all_constant_names
      all_constants = Set.new

      @classes.each do |klass|
        # Get constants defined directly in this class (not inherited)
        class_constants = klass.constants(false)
        all_constants.merge(class_constants.map(&:to_s))
      end

      all_constants.to_a.sort
    end

    def apply_filters(constant_names)
      return constant_names if @filters.empty?

      @filters.each do |filter|
        constant_names = constant_names.select do |name|
          case filter
          when Regexp
            name.match?(filter)
          when String
            name.include?(filter)
          else
            false
          end
        end
      end

      constant_names
    end

    def extract_constant_value(klass, const_name)
      # Check if constant exists before trying to get it
      if klass.const_defined?(const_name, false)
        klass.const_get(const_name)
      else
        @handle_errors ? ValueProcessor.missing_constant : nil
      end
    rescue NameError => e
      @handle_errors ? ValueProcessor.handle_extraction_error(e) : (raise e)
    rescue StandardError => e
      @handle_errors ? ValueProcessor.handle_extraction_error(e) : (raise e)
    end
  end
end
