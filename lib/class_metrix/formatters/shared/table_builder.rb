# frozen_string_literal: true

require_relative "value_processor"
require_relative "../../utils/debug_logger"

module ClassMetrix
  module Formatters
    module Shared
      class TableBuilder
        attr_reader :data, :expand_hashes, :options

        def initialize(data, expand_hashes = false, options = {})
          @data = data
          @expand_hashes = expand_hashes
          @options = options
          @value_processor = ValueProcessor
          @debug_mode = options.fetch(:debug_mode, false)
          @debug_level = options.fetch(:debug_level, :basic)
          @logger = Utils::DebugLogger.new("TableBuilder", @debug_mode, @debug_level)

          @logger.log("TableBuilder initialized with expand_hashes: #{expand_hashes}")
          @logger.log("Data headers: #{@data[:headers]}", :detailed)
          @logger.log("Number of rows: #{@data[:rows]&.length || 0}")
        end

        def build_simple_table
          {
            headers: @data[:headers],
            rows: @data[:rows].map { |row| process_row(row) }
          }
        end

        def build_expanded_table
          return build_simple_table unless @expand_hashes

          @logger.log("Building expanded table with hash expansion")
          headers = @data[:headers]
          rows = process_rows_for_expansion(headers)

          {
            headers: headers,
            rows: rows
          }
        end

        def build_flattened_table
          return build_simple_table unless @expand_hashes

          @logger.log("Building flattened table with hash expansion")
          headers = @data[:headers]
          all_hash_keys = collect_all_hash_keys(@data[:rows], headers)
          @logger.log("Collected hash keys: #{all_hash_keys}")

          flattened_headers = create_flattened_headers(headers, all_hash_keys)
          flattened_rows = create_flattened_rows(@data[:rows], headers, all_hash_keys)

          {
            headers: flattened_headers,
            rows: flattened_rows
          }
        end

        private

        def process_rows_for_expansion(headers)
          expanded_rows = []
          expandable_count = 0

          @data[:rows].each_with_index do |row, index|
            if row_has_expandable_hash?(row)
              expandable_count += 1
              @logger.log("Row #{index} has expandable hashes", :detailed)
              expanded_rows.concat(expand_row(row, headers))
            else
              @logger.log("Row #{index} has no expandable hashes", :verbose)
              expanded_rows << process_row(row)
            end
          end

          @logger.log("Processed #{@data[:rows].length} rows, #{expandable_count} had expandable hashes")
          expanded_rows
        end

        def row_has_expandable_hash?(row)
          values = row[value_start_index..]

          # Use summary logging instead of per-value logging
          @logger.log_hash_detection_summary(values)

          # Only consider real Hash objects as expandable
          result = values.any? { |cell| cell.is_a?(Hash) && cell.instance_of?(Hash) }
          @logger.log_decision("Row expandable", "#{result ? "Has" : "No"} real Hash objects", :detailed)
          result
        end

        def create_flattened_rows(rows, headers, all_hash_keys)
          rows.map do |row|
            flatten_row(row, headers, all_hash_keys)
          end
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

        def process_row(row)
          row.map { |value| process_value(value) }
        end

        def process_value(value)
          # This will be overridden by subclasses
          value
        end

        def expand_row(row, _headers)
          behavior_name = row[behavior_column_index]
          values = row[value_start_index..]

          @logger.log("Expanding row for behavior '#{behavior_name}'")

          all_hash_keys = collect_hash_keys_from_values(values)
          return [process_row(row)] if all_hash_keys.empty?

          build_expanded_row_set(row, behavior_name, values, all_hash_keys)
        end

        def collect_hash_keys_from_values(values)
          all_hash_keys = Set.new
          hash_count = 0

          values.each_with_index do |value, index|
            # Be more strict about what we consider a "hash"
            if value.is_a?(Hash) && value.instance_of?(Hash) && value.respond_to?(:keys)
              hash_count += 1
              keys = @logger.safe_keys(value)
              @logger.log("Value #{index} is a real Hash with keys: #{keys}", :detailed)
              all_hash_keys.merge(keys.map(&:to_s))
            elsif value.is_a?(Hash)
              @logger.log_anomaly("Hash-like object at index #{index} (#{@logger.safe_class(value)}) skipped")
            end
          end

          @logger.log("Collected hash keys from #{hash_count} real hashes: #{all_hash_keys.to_a}")
          all_hash_keys
        end

        def build_expanded_row_set(row, behavior_name, values, all_hash_keys)
          expanded_rows = []

          # Add main row if configured to show
          expanded_rows << build_main_row(row, behavior_name, values) if should_show_main_row?

          # Add sub rows if configured to show
          expanded_rows.concat(build_sub_rows(all_hash_keys, values)) if should_show_key_rows?

          expanded_rows
        end

        def should_show_main_row?
          !@options.fetch(:hide_main_row, false)
        end

        def should_show_key_rows?
          !@options.fetch(:hide_key_rows, true) # Default: hide key rows
        end

        def build_main_row(row, behavior_name, values)
          processed_values = values.map { |value| process_value(value) }

          if has_type_column?
            [row[0], behavior_name] + processed_values
          else
            [behavior_name] + processed_values
          end
        end

        def build_sub_rows(all_hash_keys, values)
          all_hash_keys.to_a.sort.map do |key|
            build_single_sub_row(key, values)
          end
        end

        def build_single_sub_row(key, values)
          path_name = ".#{key}"
          key_values = extract_key_values(values, key)

          if has_type_column?
            ["", path_name] + key_values # Empty type for sub-rows
          else
            [path_name] + key_values
          end
        end

        def extract_key_values(values, key)
          values.map do |value|
            extract_single_key_value(value, key)
          end
        end

        def extract_single_key_value(value, key)
          if value.is_a?(Hash)
            extract_hash_value_for_key(value, key)
          else
            get_null_value
          end
        end

        def extract_hash_value_for_key(hash, key)
          if @value_processor.has_hash_key?(hash, key, debug_mode: @debug_mode)
            hash_value = @value_processor.safe_hash_lookup(hash, key, debug_mode: @debug_mode)
            process_value(hash_value)
          else
            get_null_value
          end
        end

        def collect_all_hash_keys(rows, _headers)
          value_start_idx = value_start_index
          all_keys = {} # behavior_name => Set of keys
          total_hash_count = 0

          rows.each_with_index do |row, index|
            hash_count = collect_hash_keys_for_row(row, value_start_idx, all_keys)
            total_hash_count += hash_count
            @logger.log("Row #{index}: #{hash_count} hashes found", :detailed)
          end

          @logger.log("Final hash key collection: #{total_hash_count} total hashes, #{all_keys.keys.length} behaviors with hashes")
          all_keys
        end

        def collect_hash_keys_for_row(row, value_start_idx, all_keys)
          behavior_name = row[behavior_column_index]
          values = row[value_start_idx..]
          hash_count = 0

          values.each_with_index do |value, index|
            # Be more strict about what we consider a "hash"
            if value.is_a?(Hash) && value.instance_of?(Hash) && value.respond_to?(:keys)
              hash_count += 1
              keys = @logger.safe_keys(value)
              @logger.log("Behavior '#{behavior_name}' value #{index}: Hash with keys #{keys}", :verbose)
              all_keys[behavior_name] ||= Set.new
              all_keys[behavior_name].merge(keys.map(&:to_s))
            elsif value.is_a?(Hash)
              @logger.log_anomaly("Hash-like object in '#{behavior_name}' at index #{index} (#{@logger.safe_class(value)}) skipped")
            end
          end

          hash_count
        end

        def create_flattened_headers(headers, all_hash_keys)
          flattened = headers.dup
          class_hdrs = class_headers

          add_hash_key_headers(flattened, all_hash_keys, class_hdrs)
          flattened
        end

        def add_hash_key_headers(flattened, all_hash_keys, class_hdrs)
          all_hash_keys.each do |behavior_name, keys|
            add_behavior_key_headers(flattened, behavior_name, keys, class_hdrs)
          end
        end

        def add_behavior_key_headers(flattened, behavior_name, keys, class_hdrs)
          keys.to_a.sort.each do |key|
            class_hdrs.each do |class_name|
              flattened << "#{behavior_name}.#{key}.#{class_name}"
            end
          end
        end

        def flatten_row(row, _headers, all_hash_keys)
          behavior_name = row[behavior_column_index]
          flattened = process_row(row)

          add_flattened_hash_values(flattened, row, behavior_name, all_hash_keys)
          flattened
        end

        def add_flattened_hash_values(flattened, row, behavior_name, all_hash_keys)
          return unless all_hash_keys[behavior_name]

          values = row[value_start_index..]

          all_hash_keys[behavior_name].to_a.sort.each do |key|
            add_flattened_values_for_key(flattened, values, key)
          end
        end

        def add_flattened_values_for_key(flattened, values, key)
          values.each do |value|
            flattened << extract_flattened_value(value, key)
          end
        end

        def extract_flattened_value(value, key)
          if value.is_a?(Hash)
            extract_hash_value_for_key(value, key)
          else
            get_null_value
          end
        end

        def get_null_value
          # Override in subclasses
          ""
        end
      end
    end
  end
end
