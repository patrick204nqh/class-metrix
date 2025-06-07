# frozen_string_literal: true

require_relative "table_builder"

module ClassMetrix
  module Formatters
    module Shared
      class CsvTableBuilder < TableBuilder
        private

        def process_value(value)
          @value_processor.process_for_csv(value, @options)
        end

        def get_null_value
          @options.fetch(:null_value, "")
        end
      end
    end
  end
end
