# frozen_string_literal: true

module ClassMetrix
  module Extractors
    module Services
      module Filtering
        # Handles filtering of method names
        class MethodFilterService
          def initialize(filters)
            @filters = filters || []
          end

          def apply(method_names)
            return method_names if @filters.empty?

            @filters.reduce(method_names) { |names, filter| apply_single_filter(names, filter) }
          end

          private

          def apply_single_filter(method_names, filter)
            method_names.select { |name| matches_filter?(name, filter) }
          end

          def matches_filter?(name, filter)
            case filter
            when Regexp then name.match?(filter)
            when String then name.include?(filter)
            else false
            end
          end
        end
      end
    end
  end
end
