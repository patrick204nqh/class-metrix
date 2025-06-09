# frozen_string_literal: true

module ClassMetrix
  module Config
    # Centralized configuration for extraction behavior
    class ExtractionConfig
      attr_reader :scope, :include_private, :options

      def initialize(scope: :comprehensive, include_private: false, **options)
        @scope = scope
        @include_private = include_private
        @options = options
      end

      # Scope strategies:
      # :strict - Only the class itself (no inheritance/modules)
      # :comprehensive - Class + inheritance + modules (default)
      def strict?
        @scope == :strict
      end

      def comprehensive?
        @scope == :comprehensive
      end

      def include_private?
        @include_private
      end

      def include_inheritance?
        comprehensive?
      end

      def include_modules?
        comprehensive?
      end

      # Create a new config with modified settings
      def with_private
        self.class.new(
          scope: @scope,
          include_private: true,
          **@options
        )
      end

      def strict
        self.class.new(
          scope: :strict,
          include_private: @include_private,
          **@options
        )
      end

      def comprehensive
        self.class.new(
          scope: :comprehensive,
          include_private: @include_private,
          **@options
        )
      end

      # Convert to options hash for backward compatibility
      def to_extraction_options
        {
          include_inherited: include_inheritance?,
          include_modules: include_modules?,
          include_private: include_private?
        }.merge(@options)
      end
    end
  end
end
