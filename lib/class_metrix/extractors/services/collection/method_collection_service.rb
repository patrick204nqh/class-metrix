# frozen_string_literal: true

require_relative "private_inheritance_collector"
require_relative "private_module_collector"

module ClassMetrix
  module Extractors
    module Services
      module Collection
        # Service responsible for collecting method names from classes
        class MethodCollectionService
          def initialize(options = {})
            @options = options
          end

          def collect_from_classes(classes)
            all_methods = Set.new

            classes.each do |klass|
              methods = collect_from_single_class(klass)
              all_methods.merge(methods.map(&:to_s))
            end

            all_methods.to_a.sort
          end

          private

          def collect_from_single_class(klass)
            return klass.singleton_methods(false) unless inheritance_or_modules_or_private_enabled?

            collect_comprehensive_methods(klass)
          end

          def collect_comprehensive_methods(klass)
            methods = Set.new(klass.singleton_methods(false))
            methods.merge(InheritanceCollector.new.collect(klass)) if include_inherited?
            methods.merge(ModuleCollector.new.collect(klass)) if include_modules?
            methods.merge(collect_private_methods(klass)) if include_private?
            methods.to_a
          end

          def inheritance_or_modules_or_private_enabled?
            include_inherited? || include_modules? || include_private?
          end

          def include_inherited?
            @options[:include_inherited]
          end

          def include_modules?
            @options[:include_modules]
          end

          def include_private?
            @options[:include_private]
          end

          def collect_private_methods(klass)
            methods = Set.new

            # Get private singleton methods from the class itself
            methods.merge(klass.singleton_class.private_instance_methods(false))

            # Get private methods from inheritance chain if include_inherited is enabled
            methods.merge(PrivateInheritanceCollector.new.collect(klass)) if include_inherited?

            # Get private methods from included modules if include_modules is enabled
            methods.merge(PrivateModuleCollector.new.collect(klass)) if include_modules?

            methods
          end
        end
      end
    end
  end
end
