# frozen_string_literal: true

module ClassMetrix
  module Extractors
    module Services
      module Resolution
        # Resolves method sources and creates method info objects
        class MethodResolver
          def initialize(options = {})
            @options = options
          end

          def resolve(klass, method_name)
            method_sym = method_name.to_sym
            return nil unless klass.respond_to?(method_name, true)

            resolve_method_source(klass, method_sym, method_name)
          end

          private

          def resolve_method_source(klass, method_sym, method_name)
            return create_method_info(klass.name, :own) if own_method?(klass, method_sym)

            inherited_info = resolve_inherited_method(klass, method_sym, method_name)
            return inherited_info if inherited_info

            module_info = resolve_module_method(klass, method_sym, method_name)
            return module_info if module_info

            create_method_info("inherited", :unknown)
          end

          def own_method?(klass, method_sym)
            klass.singleton_methods(false).include?(method_sym)
          end

          def resolve_inherited_method(klass, method_sym, method_name)
            return nil unless @options[:include_inherited]

            InheritedMethodResolver.new.resolve(klass, method_sym, method_name)
          end

          def resolve_module_method(klass, method_sym, method_name)
            return nil unless @options[:include_modules]

            ModuleMethodResolver.new(@options).resolve(klass, method_sym, method_name)
          end

          def create_method_info(source, type, callable = nil)
            {
              source: source,
              type: type,
              callable: callable
            }
          end
        end
      end
    end
  end
end
