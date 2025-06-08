# frozen_string_literal: true

module ClassMetrix
  module Extractors
    module Services
      module Resolution
        # Resolves inherited methods
        class InheritedMethodResolver
          def resolve(klass, method_sym, method_name)
            traverse_parent_chain(klass) do |parent|
              next unless parent.singleton_methods(false).include?(method_sym)

              callable = create_callable(parent, method_name)
              return create_method_info(parent.name, :inherited, callable)
            end
            nil
          end

          private

          def traverse_parent_chain(klass)
            parent = klass.superclass
            while parent && !core_class?(parent)
              yield parent
              parent = parent.superclass
            end
          end

          def create_callable(parent_class, method_name)
            -> { parent_class.public_send(method_name) }
          end

          def create_method_info(source, type, callable)
            {
              source: source,
              type: type,
              callable: callable
            }
          end

          def core_class?(klass)
            [Object, BasicObject].include?(klass)
          end
        end
      end
    end
  end
end
