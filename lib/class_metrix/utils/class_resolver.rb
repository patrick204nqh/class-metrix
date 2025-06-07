# frozen_string_literal: true

module ClassMetrix
  class ClassResolver
    def self.normalize_classes(classes)
      classes.map do |klass|
        case klass
        when String
          Object.const_get(klass)
        when Class
          klass
        else
          raise ArgumentError, "Invalid class: #{klass.inspect}"
        end
      end
    rescue NameError => e
      raise ArgumentError, "Class not found: #{e.message}"
    end
  end
end
