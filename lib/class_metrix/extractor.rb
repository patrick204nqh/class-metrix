# frozen_string_literal: true

require_relative "extractors/constants_extractor"
require_relative "extractors/methods_extractor"
require_relative "extractors/multi_type_extractor"
require_relative "formatters/markdown_formatter"
require_relative "formatters/csv_formatter"
require_relative "utils/class_resolver"
require_relative "utils/debug_logger"

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
      @hide_main_row = false
      @hide_key_rows = true # Default: show only main rows
      @debug_mode = false
      @debug_level = :basic
      @logger = nil # Will be initialized when debug mode is enabled
    end

    def from(classes)
      @classes = ClassResolver.normalize_classes(classes)
      @logger&.log("Normalized classes: #{@classes.map(&:name)}")
      self
    end

    def filter(pattern)
      @filters << pattern
      self
    end

    def expand_hashes
      @expand_hashes = true
      @logger&.log("Hash expansion enabled")
      self
    end

    def debug(level = :basic)
      @debug_mode = true
      @debug_level = level
      @logger = Utils::DebugLogger.new("Extractor", @debug_mode, level)
      @logger.log("Debug mode enabled (level: #{level})")
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

    # Hash expansion display options
    def show_only_main
      @hide_main_row = false
      @hide_key_rows = true
      self
    end

    def show_only_keys
      @hide_main_row = true
      @hide_key_rows = false
      self
    end

    def show_expanded_details
      @hide_main_row = false
      @hide_key_rows = false
      self
    end

    # Lower-level options (for advanced usage)
    def hide_main_row
      @hide_main_row = true
      self
    end

    def hide_key_rows
      @hide_key_rows = true
      self
    end

    def to_markdown(filename = nil, **options)
      @logger&.log("Starting markdown generation...")
      data = extract_all_data
      @logger&.log("Extracted data structure with #{data[:rows]&.length || 0} rows")

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
        summary_style: :grouped,
        hide_main_row: @hide_main_row,
        hide_key_rows: @hide_key_rows,
        debug_mode: @debug_mode,
        debug_level: @debug_level
      }.merge(options)

      formatted = MarkdownFormatter.new(data, @expand_hashes, format_options).format

      File.write(filename, formatted) if filename
      formatted
    end

    def to_csv(filename = nil, **options)
      @logger&.log("Starting CSV generation...")
      data = extract_all_data

      format_options = {
        extraction_types: @types,
        show_metadata: true,
        separator: ",",
        quote_char: '"',
        flatten_hashes: true,
        null_value: "",
        comment_char: "#",
        hide_main_row: @hide_main_row,
        hide_key_rows: @hide_key_rows,
        debug_mode: @debug_mode,
        debug_level: @debug_level
      }.merge(options)

      formatted = CsvFormatter.new(data, @expand_hashes, format_options).format

      File.write(filename, formatted) if filename
      formatted
    end

    private

    def extract_all_data
      @logger&.log("Extracting data for types: #{@types}")
      if @types.size == 1
        extract_single_type(@types.first)
      else
        extract_multiple_types
      end
    end

    def extract_single_type(type)
      @logger&.log("Extracting single type: #{type}")
      get_extractor(type).extract
    end

    def extract_multiple_types
      @logger&.log("Extracting multiple types: #{@types}")
      extraction_config = {
        modules: @modules,
        handle_errors: @handle_errors,
        options: extraction_options
      }
      MultiTypeExtractor.new(@classes, @types, @filters, extraction_config).extract
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
        show_source: @show_source,
        debug_mode: @debug_mode,
        debug_level: @debug_level
      }
    end
  end
end
