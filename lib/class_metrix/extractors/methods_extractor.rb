# frozen_string_literal: true

require_relative "services/collection"
require_relative "services/filtering"
require_relative "services/resolution"
require_relative "services/method_call_service"

module ClassMetrix
  module Extractors
    # Main extractor for class methods with clean separation of concerns
    class MethodsExtractor
      def initialize(classes, filters, handle_errors, options = {})
        @classes = classes
        @filters = filters
        @handle_errors = handle_errors
        @options = default_options.merge(options)
        @method_collection_service = Services::Collection::MethodCollectionService.new(@options)
        @method_filter_service = Services::Filtering::MethodFilterService.new(@filters)
        @method_call_service = Services::MethodCallService.new(@handle_errors, @options)
      end

      def extract
        return empty_result if @classes.empty?

        method_names = collect_and_filter_methods
        { headers: build_headers, rows: build_rows(method_names) }
      end

      private

      def empty_result
        { headers: [], rows: [] }
      end

      def collect_and_filter_methods
        method_names = @method_collection_service.collect_from_classes(@classes)
        @method_filter_service.apply(method_names)
      end

      def default_options
        {
          include_inherited: false,
          include_modules: false,
          include_private: false,
          show_source: false
        }
      end

      def build_headers
        method_label = @options[:show_source] ? "Method (Source)" : "Method"
        [method_label] + @classes.map(&:name)
      end

      def build_rows(method_names)
        method_names.map { |method_name| build_row(method_name) }
      end

      def build_row(method_name)
        row = [method_name]
        @classes.each { |klass| row << @method_call_service.call_method(klass, method_name) }
        row
      end
    end
  end
end
