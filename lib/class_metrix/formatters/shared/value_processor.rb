# frozen_string_literal: true

module ClassMetrix
  module Formatters
    module Shared
      class ValueProcessor
        def self.process_for_markdown(value)
          case value
          when Hash
            value.inspect
          when Array
            value.join(", ")
          when true
            "✅"
          when false
            "❌"
          when nil
            "❌"
          when String
            value
          else
            value.to_s
          end
        end

        def self.process_for_csv(value, options = {})
          null_value = options.fetch(:null_value, "")

          case value
          when Hash
            # For non-flattened CSV, represent hash as JSON-like string
            value.inspect
          when Array
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
            value.to_s
          end
        end

        def self.safe_hash_lookup(hash, key)
          # Properly handle false values in hash lookup
          hash.key?(key.to_sym) ? hash[key.to_sym] : hash[key.to_s]
        end

        def self.has_hash_key?(hash, key)
          hash.key?(key.to_sym) || hash.key?(key.to_s)
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
