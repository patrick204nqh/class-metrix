# frozen_string_literal: true

require_relative "../formatters/shared/value_processor"

module ClassMetrix
  # Legacy value processor - now delegates to the new shared processor
  # Maintained for backward compatibility with existing code
  class ValueProcessor
    def self.process(value, expand_hashes: false)
      if expand_hashes && value.is_a?(Hash)
        expand_hash(value)
      else
        Formatters::Shared::ValueProcessor.process_for_markdown(value)
      end
    rescue StandardError => e
      "⚠️ #{e.class.name}"
    end

    def self.format_hash(hash)
      Formatters::Shared::ValueProcessor.process_for_markdown(hash)
    end

    def self.expand_hash(hash)
      # Return an array of key-value pairs for expansion
      hash.map { |k, v| { key: k.to_s, value: process(v, expand_hashes: false) } }
    end

    def self.handle_extraction_error(error)
      Formatters::Shared::ValueProcessor.handle_extraction_error(error)
    end

    def self.missing_constant
      Formatters::Shared::ValueProcessor.missing_constant
    end

    def self.missing_method
      Formatters::Shared::ValueProcessor.missing_method
    end
  end
end
