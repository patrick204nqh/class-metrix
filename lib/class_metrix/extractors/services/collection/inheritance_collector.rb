# frozen_string_literal: true

module ClassMetrix
  module Extractors
    module Services
      module Collection
        # Handles inheritance-based method collection
        class InheritanceCollector
          def collect(klass)
            methods = Set.new
            traverse_parent_chain(klass) { |parent| methods.merge(parent.singleton_methods(false)) }
            methods
          end

          private

          def traverse_parent_chain(klass)
            parent = klass.superclass
            while parent && !core_class?(parent)
              yield parent
              parent = parent.superclass
            end
          end

          def core_class?(klass)
            [Object, BasicObject].include?(klass)
          end
        end
      end
    end
  end
end
