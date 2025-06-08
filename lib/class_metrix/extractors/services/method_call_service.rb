# frozen_string_literal: true

require_relative "../../processors/value_processor"

module ClassMetrix
  module Extractors
    module Services
      # Handles method calling and result processing
      class MethodCallService
        def initialize(handle_errors, options = {})
          @handle_errors = handle_errors
          @options = options
        end

        def call_method(klass, method_name)
          method_resolver = Resolution::MethodResolver.new(@options)
          method_info = method_resolver.resolve(klass, method_name)

          return handle_missing_method unless method_info

          execute_method(method_info, klass, method_name)
        rescue StandardError => e
          handle_error(e)
        end

        private

        def execute_method(method_info, klass, method_name)
          if method_info[:callable]
            method_info[:callable].call
          else
            klass.public_send(method_name)
          end
        end

        def handle_missing_method
          @handle_errors ? ClassMetrix::ValueProcessor.missing_method : nil
        end

        def handle_error(error)
          @handle_errors ? ClassMetrix::ValueProcessor.handle_extraction_error(error) : (raise error)
        end
      end
    end
  end
end
