# frozen_string_literal: true

require_relative "../../utils/debug_logger"

module ClassMetrix
  module Formatters
    module Shared
      class ValueProcessor
        def self.process_for_markdown(value, debug_mode: false, debug_level: :basic)
          logger = Utils::DebugLogger.new("ValueProcessor", debug_mode, debug_level)
          logger.log_value_details(value)

          case value
          when Hash
            logger.log("Processing Hash with keys: #{logger.safe_keys(value)}", :detailed)
            logger.safe_inspect(value)
          when Array
            logger.log("Processing Array with #{logger.safe_length(value)} elements", :detailed)
            value.join(", ")
          when true
            "✅"
          when false
            "❌"
          when nil
            "❌"
          when String
            logger.log("Processing String: #{logger.safe_truncate(value, 50)}", :verbose)
            value
          else
            logger.log("Processing other type (#{logger.safe_class(value)}): #{logger.safe_truncate(logger.safe_inspect(value), 100)}",
                       :detailed)
            logger.safe_to_s(value)
          end
        end

        def self.process_for_csv(value, options = {}, debug_mode: false, debug_level: :basic)
          debug_mode = options.fetch(:debug_mode, false) if options.is_a?(Hash)
          debug_level = options.fetch(:debug_level, :basic) if options.is_a?(Hash)
          null_value = options.fetch(:null_value, "") if options.is_a?(Hash)

          logger = Utils::DebugLogger.new("ValueProcessor", debug_mode, debug_level)
          logger.log_value_details(value)

          case value
          when Hash
            logger.log("Processing Hash for CSV with keys: #{logger.safe_keys(value)}", :detailed)
            # For non-flattened CSV, represent hash as JSON-like string
            logger.safe_inspect(value)
          when Array
            logger.log("Processing Array for CSV with #{logger.safe_length(value)} elements", :detailed)
            value.join("; ") # Use semicolon to avoid CSV comma conflicts
          when true
            "TRUE"
          when false
            "FALSE"
          when nil
            null_value
          when String
            # Clean up emoji for CSV compatibility
            clean_value = value.gsub(/🚫|⚠️|✅|❌/, "").strip
            clean_value.empty? ? null_value : clean_value
          else
            logger.log(
              "Processing other type for CSV (#{logger.safe_class(value)}): #{logger.safe_truncate(logger.safe_inspect(value),
                                                                                                   100)}", :detailed
            )
            logger.safe_to_s(value)
          end
        end

        def self.safe_hash_lookup(hash, key, debug_mode: false, debug_level: :basic)
          logger = Utils::DebugLogger.new("ValueProcessor", debug_mode, debug_level)
          logger.log("Hash lookup for key '#{key}' in hash with keys: #{logger.safe_keys(hash)}", :verbose)

          # Properly handle false values in hash lookup
          begin
            hash.key?(key.to_sym) ? hash[key.to_sym] : hash[key.to_s]
          rescue StandardError => e
            logger.log("Error during hash lookup: #{e.class.name}: #{e.message}")
            nil
          end
        end

        def self.has_hash_key?(hash, key, debug_mode: false, debug_level: :basic)
          logger = Utils::DebugLogger.new("ValueProcessor", debug_mode, debug_level)

          begin
            result = hash.key?(key.to_sym) || hash.key?(key.to_s)
            logger.log("Checking if hash has key '#{key}': #{result} (hash keys: #{logger.safe_keys(hash)})", :verbose)
            result
          rescue StandardError => e
            logger.log("Error checking hash key: #{e.class.name}: #{e.message}")
            false
          end
        end

        # Error message generators
        def self.missing_constant
          "🚫 Not defined"
        end

        def self.missing_method
          "🚫 No method"
        end

        def self.handle_extraction_error(error)
          "⚠️ Error: #{error.message}"
        end

        def self.missing_hash_key
          "—"
        end
      end
    end
  end
end
