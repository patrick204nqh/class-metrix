# frozen_string_literal: true

require_relative "../processors/value_processor"

module ClassMetrix
  class MethodsExtractor
    def initialize(classes, filters, handle_errors, options = {})
      @classes = classes
      @filters = filters
      @handle_errors = handle_errors
      @options = default_options.merge(options)
    end

    def extract
      return { headers: [], rows: [] } if @classes.empty?

      method_names = get_all_class_method_names
      method_names = apply_filters(method_names)
      headers = build_headers
      rows = build_rows(method_names)

      { headers: headers, rows: rows }
    end

    private

    def default_options
      {
        include_inherited: false,
        include_modules: false,
        show_source: false
      }
    end

    def build_headers
      if @options[:show_source]
        ["Method (Source)"] + @classes.map(&:name)
      else
        ["Method"] + @classes.map(&:name)
      end
    end

    def build_rows(method_names)
      method_names.map do |method_name|
        row = [method_name]
        @classes.each do |klass|
          value = call_class_method(klass, method_name)
          row << value
        end
        row
      end
    end

    def get_all_class_method_names
      all_methods = Set.new

      @classes.each do |klass|
        methods = if inheritance_or_modules_enabled?
                    get_comprehensive_methods(klass)
                  else
                    klass.singleton_methods(false)
                  end
        all_methods.merge(methods.map(&:to_s))
      end

      all_methods.to_a.sort
    end

    def inheritance_or_modules_enabled?
      @options[:include_inherited] || @options[:include_modules]
    end

    def get_comprehensive_methods(klass)
      methods = Set.new
      methods.merge(klass.singleton_methods(false))

      methods.merge(get_inherited_methods(klass)) if @options[:include_inherited]

      methods.merge(get_module_methods(klass)) if @options[:include_modules]

      methods.to_a
    end

    def get_inherited_methods(klass)
      methods = Set.new
      parent = klass.superclass

      while parent && !core_class?(parent)
        methods.merge(parent.singleton_methods(false))
        parent = parent.superclass
      end

      methods
    end

    def get_module_methods(klass)
      methods = Set.new
      all_singleton_modules = get_all_singleton_modules(klass)

      all_singleton_modules.each do |mod|
        next if core_module?(mod)

        module_methods = mod.instance_methods(false).map(&:to_s)
        # Filter out methods that shouldn't be called directly
        module_methods = module_methods.reject { |method| excluded_module_method?(method) }
        methods.merge(module_methods)
      end

      methods
    end

    def excluded_module_method?(method_name)
      # Methods that require arguments or shouldn't be called directly
      %w[included extended prepended].include?(method_name)
    end

    def get_all_singleton_modules(klass)
      modules = [] # : Array[Module]
      modules.concat(klass.singleton_class.included_modules)

      if @options[:include_inherited]
        parent = klass.superclass
        while parent && !core_class?(parent)
          modules.concat(parent.singleton_class.included_modules)
          parent = parent.superclass
        end
      end

      modules
    end

    def core_class?(klass)
      [Object, BasicObject].include?(klass)
    end

    def core_module?(mod)
      [Kernel, Module, Class].include?(mod)
    end

    def apply_filters(method_names)
      return method_names if @filters.empty?

      @filters.each do |filter|
        method_names = method_names.select do |name|
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

      method_names
    end

    def call_class_method(klass, method_name)
      method_info = find_method_source(klass, method_name)

      if method_info
        call_method(method_info, klass, method_name)
      else
        @handle_errors ? ValueProcessor.missing_method : nil
      end
    rescue NoMethodError => e
      @handle_errors ? ValueProcessor.handle_extraction_error(e) : (raise e)
    rescue StandardError => e
      @handle_errors ? ValueProcessor.handle_extraction_error(e) : (raise e)
    end

    def call_method(method_info, klass, method_name)
      if method_info[:callable]
        method_info[:callable].call
      else
        klass.public_send(method_name)
      end
    end

    def find_method_source(klass, method_name)
      method_sym = method_name.to_sym

      return nil unless klass.respond_to?(method_name, true)

      # Check own methods first
      return build_method_info(klass.name, :own, nil) if klass.singleton_methods(false).include?(method_sym)

      # Check inherited methods
      if @options[:include_inherited]
        inherited_info = find_inherited_method(klass, method_sym, method_name)
        return inherited_info if inherited_info
      end

      # Check module methods
      if @options[:include_modules]
        module_info = find_module_method(klass, method_sym, method_name)
        return module_info if module_info
      end

      # Fallback for unknown source
      build_method_info("inherited", :unknown, nil)
    end

    def find_inherited_method(klass, method_sym, method_name)
      parent = klass.superclass
      while parent && !core_class?(parent)
        if parent.singleton_methods(false).include?(method_sym)
          parent_class = parent
          method_to_call = method_name
          callable = -> { parent_class.public_send(method_to_call) }
          return build_method_info(parent.name, :inherited, callable)
        end
        parent = parent.superclass
      end
      nil
    end

    def find_module_method(klass, method_sym, method_name)
      all_singleton_modules = get_all_singleton_modules(klass)

      all_singleton_modules.each do |mod|
        next if core_module?(mod)

        next unless mod.instance_methods(false).include?(method_sym)

        method_to_call = method_name
        callable = -> { klass.public_send(method_to_call) }
        source = determine_module_source(klass, mod)
        return build_method_info(source, :module, callable)
      end

      nil
    end

    def determine_module_source(klass, mod)
      if @options[:include_inherited] && !klass.singleton_class.included_modules.include?(mod)
        "#{mod.name} (via parent)"
      else
        mod.name
      end
    end

    def build_method_info(source, type, callable)
      {
        source: source,
        type: type,
        callable: callable
      }
    end
  end
end
