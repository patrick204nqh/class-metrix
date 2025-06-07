#!/usr/bin/env ruby
# frozen_string_literal: true

# Debug Mode Demonstration
# Shows how ClassMetrix handles problematic objects safely

require_relative '../lib/class_metrix'

# Example classes with different types of values
class SafeService
  CONFIG = { host: 'localhost', port: 3000 }
  
  def self.timeout_config
    { connect: 30, read: 60 }
  end
end

class ProblematicService
  # This constant is a Class object (not a Hash)
  CONFIG_CLASS = SafeService
  
  def self.service_config
    SafeService::CONFIG
  end
end

# Mock object that has problematic method behavior
class ProblematicObject
  def inspect
    raise "Inspect not allowed!"
  end
  
  def to_s
    raise "To_s not allowed!"
  end
  
  def class
    raise "Class not allowed!"
  end
end

class WeirdService
  BROKEN_OBJECT = ProblematicObject.new
  
  def self.get_config
    { normal: 'value', broken: ProblematicObject.new }
  end
end

puts "=== ClassMetrix Debug Mode Demo ==="
puts

puts "This demo shows how ClassMetrix safely handles:"
puts "1. Class objects in constants"
puts "2. Objects with broken inspect/to_s methods"
puts "3. Hash expansion with mixed value types"
puts

begin
  result = ClassMetrix.extract(:constants, :class_methods)
    .from([SafeService, ProblematicService, WeirdService])
    .expand_hashes
    .handle_errors
    .debug  # Enable debug mode
    .to_markdown
    
  puts "\n=== Generated Report ==="
  puts result[0..500] + "..." if result.length > 500
  puts "\nReport generated successfully! ✅"
  puts "Note: Debug output above shows how problematic objects were handled safely."
  
rescue => e
  puts "Error: #{e.class}: #{e.message}"
  puts "This should not happen with the safety improvements!"
end 