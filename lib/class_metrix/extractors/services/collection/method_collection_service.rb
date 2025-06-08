# frozen_string_literal: true

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
            return klass.singleton_methods(false) unless inheritance_or_modules_enabled?

            collect_comprehensive_methods(klass)
          end

          def collect_comprehensive_methods(klass)
            methods = Set.new(klass.singleton_methods(false))
            methods.merge(InheritanceCollector.new.collect(klass)) if include_inherited?
            methods.merge(ModuleCollector.new.collect(klass)) if include_modules?
            methods.to_a
          end

          def inheritance_or_modules_enabled?
            include_inherited? || include_modules?
          end

          def include_inherited?
            @options[:include_inherited]
          end

          def include_modules?
            @options[:include_modules]
          end
        end
      end
    end
  end
end
