# frozen_string_literal: true

module ClassMetrix
  module Services
    # Determines what should be scanned based on extraction config
    class ScopeResolver
      def initialize(config)
        @config = config
      end

      def resolve_method_scope(klass)
        methods = Set.new

        # Always include the class's own methods
        methods.merge(klass.singleton_methods(false))

        methods.merge(collect_inherited_methods(klass)) if @config.include_inheritance?

        methods.merge(collect_module_methods(klass)) if @config.include_modules?

        methods.merge(collect_private_methods(klass)) if @config.include_private?

        methods.to_a.sort
      end

      def resolve_constant_scope(klass)
        constants = {}

        # Always include the class's own constants
        constants.merge!(collect_own_constants(klass))

        constants.merge!(collect_inherited_constants(klass)) if @config.include_inheritance?

        constants.merge!(collect_module_constants(klass)) if @config.include_modules?

        constants.merge!(collect_private_constants(klass)) if @config.include_private?

        constants
      end

      private

      def collect_inherited_methods(klass)
        # Traverse inheritance chain
        methods = Set.new
        current = klass.superclass

        while current && current != Object
          methods.merge(current.singleton_methods(false))
          current = current.superclass
        end

        methods
      end

      def collect_module_methods(klass)
        # Collect from included modules
        methods = Set.new
        klass.singleton_class.included_modules.each do |mod|
          next if [Kernel].include?(mod)

          methods.merge(mod.singleton_methods(false)) if mod.respond_to?(:singleton_methods)
        end
        methods
      end

      def collect_private_methods(klass)
        methods = Set.new

        # Own private methods
        methods.merge(klass.singleton_class.private_instance_methods(false))

        methods.merge(collect_private_inherited_methods(klass)) if @config.include_inheritance?

        methods.merge(collect_private_module_methods(klass)) if @config.include_modules?

        methods
      end

      def collect_private_inherited_methods(klass)
        methods = Set.new
        current = klass.superclass

        while current && current != Object
          methods.merge(current.singleton_class.private_instance_methods(false))
          current = current.superclass
        end

        methods
      end

      def collect_private_module_methods(klass)
        methods = Set.new
        klass.singleton_class.included_modules.each do |mod|
          next if [Kernel].include?(mod)

          methods.merge(mod.private_instance_methods(false)) if mod.respond_to?(:private_instance_methods)
        end
        methods
      end

      def collect_own_constants(klass)
        constants = {}
        klass.constants(false).each do |const_name|
          constants[const_name.to_s] = klass.const_get(const_name)
        end
        constants
      end

      def collect_inherited_constants(klass)
        constants = {}
        current = klass.superclass

        while current && current != Object
          current.constants(false).each do |const_name|
            next if constants.key?(const_name.to_s) # Don't override

            constants[const_name.to_s] = current.const_get(const_name)
          end
          current = current.superclass
        end

        constants
      end

      def collect_module_constants(klass)
        constants = {}
        klass.included_modules.each do |mod|
          next if [Kernel].include?(mod)

          mod.constants(false).each do |const_name|
            next if constants.key?(const_name.to_s) # Don't override

            constants[const_name.to_s] = mod.const_get(const_name)
          end
        end
        constants
      end

      def collect_private_constants(klass)
        # This is tricky - Ruby doesn't have a direct way to get private constants
        # We can try some heuristics or use reflection techniques
        constants = {}

        # Try common private constant patterns
        candidate_names = generate_candidate_constant_names

        candidate_names.each do |name|
          if klass.const_defined?(name, false) &&
             !klass.constants(false).include?(name.to_sym)
            constants[name] = klass.const_get(name)
          end
        rescue StandardError
          # Constant doesn't exist or isn't accessible
        end

        constants
      end

      def generate_candidate_constant_names
        # Common patterns for private constants
        %w[
          A B C D E F G H I J K L M N O P Q R S T U V W X Y Z
          VERSION CONFIG SECRET_KEY API_KEY TOKEN PRIVATE_KEY
          INTERNAL_CONFIG DEBUG_MODE DEVELOPMENT_MODE
          CACHE_TTL TIMEOUT RETRY_COUNT MAX_RETRIES
          DEFAULT_OPTIONS INTERNAL_OPTIONS
        ]
      end
    end
  end
end
