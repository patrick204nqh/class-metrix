# frozen_string_literal: true

require_relative "../processors/value_processor"
require_relative "../utils/debug_logger"

module ClassMetrix
  module Extractors
    class ConstantsExtractor
      def initialize(classes, filters, handle_errors, options = {})
        @classes = classes
        @filters = filters
        @handle_errors = handle_errors
        @options = default_options.merge(options)
        @debug_level = @options[:debug_level] || :basic
        @logger = Utils::DebugLogger.new("ConstantsExtractor", @options[:debug_mode], @debug_level)
      end

      def extract
        return { headers: [], rows: [] } if @classes.empty?

        constant_names = get_all_constant_names
        constant_names = apply_filters(constant_names)
        headers = build_headers
        rows = build_rows(constant_names)

        { headers: headers, rows: rows }
      end

      private

      def default_options
        {
          include_inherited: false,
          include_modules: false,
          include_private: false,
          show_source: false
        }
      end

      def build_headers
        if @options[:show_source]
          ["Constant (Source)"] + @classes.map(&:name)
        else
          ["Constant"] + @classes.map(&:name)
        end
      end

      def build_rows(constant_names)
        constant_names.map do |const_name|
          row = [const_name]
          @classes.each do |klass|
            value = extract_constant_value(klass, const_name)
            row << value
          end
          row
        end
      end

      def get_all_constant_names
        all_constants = Set.new

        @classes.each do |klass|
          constants = if inheritance_or_modules_enabled? || @options[:include_private]
                        get_comprehensive_constants(klass)
                      else
                        klass.constants(false)
                      end
          all_constants.merge(constants.map(&:to_s))
        end

        all_constants.to_a.sort
      end

      def inheritance_or_modules_enabled?
        @options[:include_inherited] || @options[:include_modules]
      end

      def get_comprehensive_constants(klass)
        constants = Set.new
        constants.merge(klass.constants(false))

        constants.merge(get_inherited_constants(klass)) if @options[:include_inherited]

        constants.merge(get_module_constants(klass)) if @options[:include_modules]

        constants.merge(get_private_constants(klass)) if @options[:include_private]

        constants.to_a
      end

      def get_inherited_constants(klass)
        constants = Set.new
        parent = klass.superclass

        while parent && !core_class?(parent)
          constants.merge(parent.constants(false))
          parent = parent.superclass
        end

        constants
      end

      def get_module_constants(klass)
        constants = Set.new
        all_modules = get_all_included_modules(klass)

        all_modules.each do |mod|
          constants.merge(mod.constants(false))
        end

        constants
      end

      def get_private_constants(klass)
        constants = Set.new

        # Strategy: Try to find private constants by testing common naming patterns
        # and checking if they're defined but not in the public constants list
        public_constants = klass.constants(false)

        # Try common constant naming patterns
        candidate_names = generate_candidate_constant_names(klass)

        candidate_names.each do |name|
          next if public_constants.include?(name)

          if klass.const_defined?(name, false)
            constants.add(name)
            debug_log("Found private constant: #{name}")
          end
        end

        constants
      end

      def generate_candidate_constant_names(klass)
        candidates = Set.new

        # Add alphabet-based constants (A-Z, AA-ZZ, etc.)
        ("A".."Z").each { |letter| candidates.add(letter.to_sym) }

        # Add common constant patterns
        %w[
          VERSION AUTHOR AUTHORS
          CONFIG CONFIGURATION SETTINGS OPTIONS
          DEFAULT DEFAULTS DEFAULT_OPTIONS
          API_KEY SECRET TOKEN SECRET_KEY
          HOST PORT URL URI
          DEBUG VERBOSE QUIET
          TIMEOUT RETRIES MAX_RETRIES
          CACHE BUFFER SIZE LIMIT
          ENABLED DISABLED
          PUBLIC PRIVATE PROTECTED PRIVATE_CONSTANT
          TEST TESTING DEVELOPMENT PRODUCTION
          TRUE FALSE
        ].each { |name| candidates.add(name.to_sym) }

        # Add class name variations
        class_name = klass.name.split("::").last
        if class_name
          candidates.add(:"#{class_name.upcase}_CONFIG")
          candidates.add(:"#{class_name.upcase}_OPTIONS")
          candidates.add(:"#{class_name.upcase}_SETTINGS")
        end

        candidates.to_a
      end

      def get_all_included_modules(klass)
        modules = [] # : Array[Module]
        modules.concat(klass.included_modules)

        if @options[:include_inherited]
          parent = klass.superclass
          while parent && !core_class?(parent)
            modules.concat(parent.included_modules)
            parent = parent.superclass
          end
        end

        modules
      end

      def core_class?(klass)
        [Object, BasicObject].include?(klass)
      end

      def apply_filters(constant_names)
        return constant_names if @filters.empty?

        @filters.each do |filter|
          constant_names = constant_names.select do |name|
            case filter
            when Regexp
              name.match?(filter)
            when String
              name.include?(filter)
            else
              false
            end
          end
        end

        constant_names
      end

      def extract_constant_value(klass, const_name)
        constant_info = find_constant_source(klass, const_name)

        if constant_info
          value = constant_info[:value]
          debug_log("Extracted constant '#{const_name}' from #{klass.name}: #{@logger.safe_inspect(value)} (#{@logger.safe_class(value)})")
          value
        else
          debug_log("Constant '#{const_name}' not found in #{klass.name}")
          @handle_errors ? ValueProcessor.missing_constant : nil
        end
      rescue NameError => e
        debug_log("NameError extracting constant '#{const_name}' from #{klass.name}: #{e.message}")
        @handle_errors ? ValueProcessor.handle_extraction_error(e) : (raise e)
      rescue StandardError => e
        debug_log("Error extracting constant '#{const_name}' from #{klass.name}: #{e.message}")
        @handle_errors ? ValueProcessor.handle_extraction_error(e) : (raise e)
      end

      def find_constant_source(klass, const_name)
        # Check own constants first
        return build_constant_info(klass.const_get(const_name), klass.name, :own) if klass.const_defined?(const_name, false)

        # Check inherited constants
        if @options[:include_inherited]
          inherited_info = find_inherited_constant(klass, const_name)
          return inherited_info if inherited_info
        end

        # Check module constants
        if @options[:include_modules]
          module_info = find_module_constant(klass, const_name)
          return module_info if module_info
        end

        # Fallback check with inheritance
        return build_constant_info(klass.const_get(const_name), "inherited", :unknown) if klass.const_defined?(const_name, true)

        nil
      end

      def find_inherited_constant(klass, const_name)
        parent = klass.superclass
        while parent && !core_class?(parent)
          return build_constant_info(parent.const_get(const_name), parent.name, :inherited) if parent.const_defined?(const_name, false)

          parent = parent.superclass
        end
        nil
      end

      def find_module_constant(klass, const_name)
        all_modules = get_all_included_modules(klass)

        all_modules.each do |mod|
          return build_constant_info(mod.const_get(const_name), mod.name, :module) if mod.const_defined?(const_name, false)
        end

        nil
      end

      def build_constant_info(value, source, type)
        {
          value: value,
          source: source,
          type: type
        }
      end

      def debug_log(message)
        @logger.log(message)
      end
    end
  end
end
