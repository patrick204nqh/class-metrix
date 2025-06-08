# frozen_string_literal: true

module ClassMetrix
  module Extractors
    module Services
      module Collection
        # Handles module-based method collection
        class ModuleCollector
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
              .flat_map { |mod| extract_valid_methods(mod) }
          end

          def get_relevant_modules(klass)
            klass.singleton_class.included_modules
          end

          def extract_valid_methods(mod)
            mod.instance_methods(false)
               .map(&:to_s)
               .reject { |method| EXCLUDED_METHODS.include?(method) }
          end

          def core_module?(mod)
            [Kernel, Module, Class].include?(mod)
          end
        end
      end
    end
  end
end
