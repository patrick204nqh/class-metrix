# frozen_string_literal: true

require_relative "extractors/constants_extractor"
require_relative "extractors/methods_extractor"
require_relative "extractors/multi_type_extractor"
require_relative "formatters/markdown_formatter"
require_relative "formatters/csv_formatter"
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
      @include_inherited = false
      @include_modules = false
      @show_source = false
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

    # Inheritance and module inclusion options
    def include_inherited
      @include_inherited = true
      self
    end

    def include_modules
      @include_modules = true
      self
    end

    def show_source
      @show_source = true
      self
    end

    def include_all
      @include_inherited = true
      @include_modules = true
      self
    end

    def to_markdown(filename = nil, **options)
      data = extract_all_data

      format_options = {
        extraction_types: @types,
        show_missing_summary: false,
        show_footer: true,
        footer_style: :default,
        show_timestamp: false,
        show_metadata: true,
        show_classes: true,
        show_extraction_info: true,
        table_style: :standard,
        summary_style: :grouped
      }.merge(options)

      formatted = MarkdownFormatter.new(data, @expand_hashes, format_options).format

      File.write(filename, formatted) if filename
      formatted
    end

    def to_csv(filename = nil, **options)
      data = extract_all_data

      format_options = {
        extraction_types: @types,
        show_metadata: true,
        separator: ",",
        quote_char: '"',
        flatten_hashes: true,
        null_value: "",
        comment_char: "#"
      }.merge(options)

      formatted = CsvFormatter.new(data, @expand_hashes, format_options).format

      File.write(filename, formatted) if filename
      formatted
    end

    private

    def extract_all_data
      if @types.size == 1
        extract_single_type(@types.first)
      else
        extract_multiple_types
      end
    end

    def extract_single_type(type)
      get_extractor(type).extract
    end

    def extract_multiple_types
      MultiTypeExtractor.new(@classes, @types, @filters, @modules, @handle_errors, extraction_options).extract
    end

    def get_extractor(type)
      case type
      when :constants
        ConstantsExtractor.new(@classes, @filters, @handle_errors, extraction_options)
      when :class_methods
        MethodsExtractor.new(@classes, @filters, @handle_errors, extraction_options)
      else
        raise ArgumentError, "Unknown extraction type: #{type}"
      end
    end

    def extraction_options
      {
        include_inherited: @include_inherited,
        include_modules: @include_modules,
        show_source: @show_source
      }
    end
  end
end
