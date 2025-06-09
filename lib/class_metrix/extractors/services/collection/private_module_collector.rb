# frozen_string_literal: true

module ClassMetrix
  module Extractors
    module Services
      module Collection
        # Handles module-based private method collection
        class PrivateModuleCollector
          EXCLUDED_METHODS = %w[included extended prepended].freeze

          def collect(klass)
            methods = Set.new
            collect_from_modules(klass).each { |method| methods.add(method) }
            methods
          end

          private

          def collect_from_modules(klass)
            get_relevant_modules(klass)
              .reject { |mod| core_module?(mod) }
              .flat_map { |mod| extract_valid_private_methods(mod) }
          end

          def get_relevant_modules(klass)
            klass.singleton_class.included_modules
          end

          def extract_valid_private_methods(mod)
            # Get private methods from the module's singleton class
            # Since modules are included as singleton methods, we need to check
            # if the module has private methods that are exposed as singleton methods
            private_methods = []

            begin
              # Check if the module has private instance methods that would become
              # private singleton methods when included
              if mod.respond_to?(:private_instance_methods)
                private_methods = mod.private_instance_methods(false)
                                     .map(&:to_s)
                                     .reject { |method| EXCLUDED_METHODS.include?(method) }
              end
            rescue StandardError
              # Some modules might not support this method, so we'll handle gracefully
              private_methods = []
            end

            private_methods
          end

          def core_module?(mod)
            [Kernel, Module, Class].include?(mod)
          end
        end
      end
    end
  end
end
