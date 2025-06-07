# frozen_string_literal: true

module ClassMetrix
  class ValueProcessor
    def self.process(value, expand_hashes: false)
      case value
      when Hash
        expand_hashes ? expand_hash(value) : format_hash(value)
      when Array
        value.map(&:to_s).join(", ")
      when true
        "✅"
      when false
        "❌"
      when nil
        "❌"
      when String, Numeric
        value.to_s
      else
        value.inspect
      end
    rescue StandardError => e
      "⚠️ #{e.class.name}"
    end

    def self.format_hash(hash)
      hash.inspect
    end

    def self.expand_hash(hash)
      # Return an array of key-value pairs for expansion
      hash.map { |k, v| { key: k.to_s, value: process(v, expand_hashes: false) } }
    end

    def self.handle_extraction_error(error)
      case error
      when NameError
        "🚫 Not defined"
      when NoMethodError
        "🚫 No method"
      when StandardError
        "⚠️ Error: #{error.message.split.first(3).join(" ")}"
      else
        "⚠️ #{error.class.name}"
      end
    end

    def self.missing_constant
      "🚫 Not defined"
    end

    def self.missing_method
      "🚫 No method"
    end
  end
end
