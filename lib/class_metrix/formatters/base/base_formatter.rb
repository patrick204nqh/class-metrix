# frozen_string_literal: true

require_relative "../shared/value_processor"

module ClassMetrix
  module Formatters
    module Base
      class BaseFormatter
        attr_reader :data, :expand_hashes, :options

        def initialize(data, expand_hashes = false, options = {})
          @data = data
          @expand_hashes = expand_hashes
          @options = default_options.merge(options)
          @value_processor = Shared::ValueProcessor
        end

        def format
          raise NotImplementedError, "Subclasses must implement #format method"
        end

        protected

        def default_options
          {
            # Common options for all formatters
            title: nil,
            show_metadata: true,
            extraction_types: [] # : Array[Symbol]
          }
        end

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

        def collect_all_hash_keys(rows, _headers)
          value_start_idx = value_start_index
          all_keys = {} # : Hash[String, Set[String]] # behavior_name => Set of keys

          rows.each do |row|
            behavior_name = row[behavior_column_index]
            values = row[value_start_idx..] || []

            values.each do |value|
              if value.is_a?(Hash)
                all_keys[behavior_name] ||= Set.new
                all_keys[behavior_name].merge(value.keys.map(&:to_s))
              end
            end
          end

          all_keys
        end

        def process_value(value, format = :markdown)
          case format
          when :markdown
            @value_processor.process_for_markdown(value)
          when :csv
            @value_processor.process_for_csv(value, @options)
          else
            raise ArgumentError, "Unknown format: #{format}"
          end
        end

        def safe_hash_lookup(hash, key)
          @value_processor.safe_hash_lookup(hash, key)
        end

        def has_hash_key?(hash, key)
          @value_processor.has_hash_key?(hash, key)
        end
      end
    end
  end
end
