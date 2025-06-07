# frozen_string_literal: true

require "set"
require_relative "../processors/value_processor"

module ClassMetrix
  class MethodsExtractor
    def initialize(classes, filters, handle_errors)
      @classes = classes
      @filters = filters
      @handle_errors = handle_errors
    end

    def extract
      return { headers: [], rows: [] } if @classes.empty?

      # Get all class method names across all classes
      method_names = get_all_class_method_names

      # Apply filters
      method_names = apply_filters(method_names)

      # Build headers: ["Method", "Class1", "Class2", ...]
      headers = ["Method"] + @classes.map { |klass| klass.name }

      # Build rows: each row represents one method across all classes
      rows = method_names.map do |method_name|
        row = [method_name]

        @classes.each do |klass|
          value = call_class_method(klass, method_name)
          # Pass the raw value for hash expansion to work properly
          row << value
        end

        row
      end

      { headers: headers, rows: rows }
    end

    private

    def get_all_class_method_names
      all_methods = Set.new

      @classes.each do |klass|
        # Get class methods (singleton methods)
        class_methods = klass.singleton_methods(false)
        all_methods.merge(class_methods.map(&:to_s))
      end

      all_methods.to_a.sort
    end

    def apply_filters(method_names)
      return method_names if @filters.empty?

      @filters.each do |filter|
        method_names = method_names.select do |name|
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

      method_names
    end

    def call_class_method(klass, method_name)
      # Check if the method exists and is callable
      if klass.respond_to?(method_name, true)
        klass.public_send(method_name)
      else
        @handle_errors ? ValueProcessor.missing_method : nil
      end
    rescue NoMethodError => e
      @handle_errors ? ValueProcessor.handle_extraction_error(e) : (raise e)
    rescue StandardError => e
      @handle_errors ? ValueProcessor.handle_extraction_error(e) : (raise e)
    end
  end
end
