# frozen_string_literal: true

module ClassMetrix
  module Extractors
    module Services
      module Resolution
        # Resolves module methods
        class ModuleMethodResolver
          def initialize(options = {})
            @options = options
          end

          def resolve(klass, method_sym, method_name)
            get_singleton_modules(klass).each do |mod|
              method_info = process_module(klass, mod, method_sym, method_name)
              return method_info if method_info
            end
            nil
          end

          private

          def process_module(klass, mod, method_sym, method_name)
            return nil if core_module?(mod)
            return nil unless mod.instance_methods(false).include?(method_sym)

            callable = create_callable(klass, method_name)
            source = determine_source(klass, mod)
            create_method_info(source, :module, callable)
          end

          def get_singleton_modules(klass)
            klass.singleton_class.included_modules
          end

          def create_callable(klass, method_name)
            -> { klass.public_send(method_name) }
          end

          def determine_source(klass, mod)
            if @options[:include_inherited] && !klass.singleton_class.included_modules.include?(mod)
              "#{mod.name} (via parent)"
            else
              mod.name
            end
          end

          def create_method_info(source, type, callable)
            {
              source: source,
              type: type,
              callable: callable
            }
          end

          def core_module?(mod)
            # @type var core_modules: Array[Module]
            core_modules = [Kernel, Module, Class]
            core_modules.include?(mod)
          end
        end
      end
    end
  end
end
