# frozen_string_literal: true

require_relative "extractors/constants_extractor"
require_relative "extractors/methods_extractor"
require_relative "extractors/multi_type_extractor"
require_relative "formatters/markdown_formatter"
require_relative "utils/class_resolver"

module ClassMetrix
  class Extractor
    def initialize(*types)
      @types = types.flatten
      @classes = []
      @filters = []
      @expand_hashes = false
      @handle_errors = false
      @modules = []
    end

    def from(classes)
      @classes = ClassResolver.normalize_classes(classes)
      self
    end

    def filter(pattern)
      @filters << pattern
      self
    end

    def expand_hashes
      @expand_hashes = true
      self
    end

    def handle_errors
      @handle_errors = true
      self
    end

    def modules(module_list)
      @modules = module_list
      self
    end

    def to_markdown(filename = nil, title: nil, show_missing_summary: false)
      data = extract_all_data
      options = {
        title: title,
        extraction_types: @types,
        show_missing_summary: show_missing_summary
      }
      formatted = MarkdownFormatter.new(data, @expand_hashes, options).format

      if filename
        File.write(filename, formatted)
        formatted
      else
        formatted
      end
    end

    private

    def extract_all_data
      # Handle single or multiple extraction types
      if @types.size == 1
        extract_single_type(@types.first)
      else
        extract_multiple_types
      end
    end

    def extract_single_type(type)
      extractor = get_extractor(type)
      extractor.extract
    end

    def extract_multiple_types
      # Combine multiple extraction types into one table
      MultiTypeExtractor.new(@classes, @types, @filters, @modules, @handle_errors).extract
    end

    def get_extractor(type)
      case type
      when :constants
        ConstantsExtractor.new(@classes, @filters, @handle_errors)
      when :class_methods
        MethodsExtractor.new(@classes, @filters, @handle_errors)
      else
        raise ArgumentError, "Unknown extraction type: #{type}"
      end
    end
  end
end
