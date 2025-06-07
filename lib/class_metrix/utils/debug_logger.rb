# frozen_string_literal: true

module ClassMetrix
  module Utils
    # Debug logging utility for ClassMetrix
    # Provides safe, consistent debug output across all components
    class DebugLogger
      # Debug levels: :basic, :detailed, :verbose
      LEVELS = { basic: 1, detailed: 2, verbose: 3 }.freeze

      def initialize(component_name, debug_mode = false, level = :basic)
        @component_name = component_name
        @debug_mode = debug_mode
        @level = LEVELS[level] || LEVELS[:basic]
      end

      def log(message, level = :basic)
        return unless @debug_mode && LEVELS[level] <= @level

        puts "[DEBUG #{@component_name}] #{message}"
      end

      def log_safe_operation(operation_name, level = :detailed, &block)
        log("Starting #{operation_name}", level)
        result = block.call
        log("Completed #{operation_name} successfully", level)
        result
      rescue StandardError => e
        log("Error in #{operation_name}: #{e.class.name}: #{e.message}")
        raise
      end

      # Summary logging for groups of similar operations
      def log_summary(operation, items, &block)
        return unless @debug_mode

        if @level >= LEVELS[:detailed]
          log("#{operation} (#{items.length} items)")
          items.each_with_index { |item, i| block.call(item, i) } if block_given?
        else
          log("#{operation} (#{items.length} items)")
        end
      end

      def log_decision(decision, reason, level = :basic)
        log("Decision: #{decision} - #{reason}", level)
      end

      def log_anomaly(description)
        log("⚠️ Anomaly: #{description}")
      end

      # Safe inspection methods to handle problematic objects
      def safe_inspect(value)
        value.inspect
      rescue StandardError => e
        "[inspect failed: #{e.class.name}]"
      end

      def safe_class(value)
        value.class
      rescue StandardError => e
        "[class failed: #{e.class.name}]"
      end

      def safe_keys(value)
        value.keys
      rescue StandardError => e
        "[keys failed: #{e.class.name}]"
      end

      def safe_length(value)
        value.length
      rescue StandardError
        "[length failed]"
      end

      def safe_truncate(str, max_length)
        return str unless str.respond_to?(:length) && str.respond_to?(:[])

        str.length > max_length ? "#{str[0...max_length]}..." : str
      rescue StandardError => e
        "[truncate failed: #{e.class.name}]"
      end

      def safe_to_s(value)
        value.to_s
      rescue StandardError => e
        begin
          value.class.name
        rescue StandardError => e2
          "[to_s failed: #{e.class.name}, class failed: #{e2.class.name}]"
        end
      end

      def log_value_details(value, index = nil, level = :verbose)
        return unless @debug_mode && @level >= LEVELS[level]

        prefix = index ? "Value #{index}" : "Value"
        log("#{prefix}: #{safe_inspect(value)} (#{safe_class(value)})", level)
      end

      def log_hash_detection(value, index = nil, level = :detailed)
        return unless @debug_mode && @level >= LEVELS[level]

        prefix = index ? "Value #{index}" : "Value"
        is_hash = value.is_a?(Hash)
        is_real_hash = value.is_a?(Hash) && value.instance_of?(Hash)

        return unless is_hash

        log("#{prefix} hash detection:")
        log("  is_a?(Hash): #{is_hash}, class == Hash: #{is_real_hash}")
        log("  respond_to?(:keys): #{value.respond_to?(:keys)}")

        if is_hash && is_real_hash
          log("  keys: #{safe_keys(value)}")
        elsif is_hash
          log_anomaly("Hash-like object (#{safe_class(value)}) but not real Hash - will be skipped")
        end
      end

      # Smart hash detection summary
      def log_hash_detection_summary(values)
        return unless @debug_mode

        hash_count = 0
        real_hash_count = 0
        anomaly_count = 0

        values.each do |value|
          next unless value.is_a?(Hash)

          hash_count += 1
          if value.instance_of?(Hash)
            real_hash_count += 1
          else
            anomaly_count += 1
          end
        end

        return unless hash_count.positive?

        log("Hash detection summary: #{real_hash_count} real hashes, #{anomaly_count} hash-like objects")
        log_anomaly("Found #{anomaly_count} hash-like proxy objects") if anomaly_count.positive?
      end

      def enabled?
        @debug_mode
      end

      attr_reader :level

      def set_level(level)
        @level = LEVELS[level] || LEVELS[:basic]
      end
    end
  end
end
