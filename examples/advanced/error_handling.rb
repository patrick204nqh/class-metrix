#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "../../lib/class_metrix"

puts "=== Advanced Example: Error Handling ==="
puts

# Classes that demonstrate various error scenarios
class WorkingService
  # Working constants
  SERVICE_NAME = "working"
  VERSION = "1.0.0"
  ENABLED = true

  # Working methods
  def self.status
    "healthy"
  end

  def self.version
    "1.0.0"
  end

  def self.health_check
    { status: "ok", uptime: 12_345 }
  end

  def self.enabled?
    true
  end
end

class PartiallyBrokenService
  # Working constants
  SERVICE_NAME = "partially_broken"
  VERSION = "0.9.0"
  # Missing ENABLED constant

  # Working methods
  def self.status
    "degraded"
  end

  def self.version
    "0.9.0"
  end

  # Broken method that raises an error
  def self.health_check
    raise StandardError, "Health check failed!"
  end

  def self.enabled?
    false
  end

  # Method that returns nil
  def self.uptime
    nil
  end

  # Method with complex error
  def self.database_connection
    raise ActiveRecord::ConnectionNotEstablished, "Database unavailable"
  rescue NameError
    # If ActiveRecord is not available, raise a different error
    raise "Connection library not available"
  end
end

class CompletelyBrokenService
  # Has some constants
  SERVICE_NAME = "broken"
  # Missing VERSION and ENABLED

  # Has working method
  def self.status
    "down"
  end

  # Missing version method

  # Broken health_check
  def self.health_check
    raise NoMethodError, "Health monitoring not implemented"
  end

  # Method that raises during execution
  def self.enabled?
    some_undefined_variable.call
  end

  # Method that returns false
  def self.deprecated?
    true
  end
end

puts "=== Service Classes Defined ==="
puts "WorkingService: All methods work"
puts "PartiallyBrokenService: Some methods fail"
puts "CompletelyBrokenService: Most methods fail"
puts

# 1. Extract without error handling (will raise errors)
puts "💥 1. WITHOUT ERROR HANDLING (This will show errors)"
puts "-" * 60

begin
  result = ClassMetrix.extract(:class_methods)
                      .from([WorkingService, PartiallyBrokenService])
                      .filter(/health_check/)
                      .to_markdown
  puts result
rescue StandardError => e
  puts "❌ Error occurred: #{e.class.name}: #{e.message}"
end
puts

# 2. Extract with error handling
puts "🛡️ 2. WITH ERROR HANDLING (Graceful failure)"
puts "-" * 60
result = ClassMetrix.extract(:class_methods)
                    .from([WorkingService, PartiallyBrokenService, CompletelyBrokenService])
                    .handle_errors
                    .to_markdown

puts result
puts

# 3. Constants with missing values
puts "📋 3. CONSTANTS WITH MISSING VALUES"
puts "-" * 60
result = ClassMetrix.extract(:constants)
                    .from([WorkingService, PartiallyBrokenService, CompletelyBrokenService])
                    .handle_errors
                    .to_markdown

puts result
puts

# 4. Multi-type extraction with errors
puts "📊 4. MULTI-TYPE WITH ERROR HANDLING"
puts "-" * 60
result = ClassMetrix.extract(:constants, :class_methods)
                    .from([WorkingService, PartiallyBrokenService, CompletelyBrokenService])
                    .filter(/SERVICE_NAME|status|enabled/)
                    .handle_errors
                    .to_markdown

puts result
puts

# 5. Focus on problematic methods
puts "🔍 5. PROBLEMATIC METHODS ANALYSIS"
puts "-" * 60
result = ClassMetrix.extract(:class_methods)
                    .from([WorkingService, PartiallyBrokenService, CompletelyBrokenService])
                    .filter(/health_check|database|uptime/)
                    .handle_errors
                    .to_markdown

puts result
puts

# 6. Boolean and nil value handling
puts "✅ 6. BOOLEAN AND NIL VALUE HANDLING"
puts "-" * 60
result = ClassMetrix.extract(:class_methods)
                    .from([WorkingService, PartiallyBrokenService, CompletelyBrokenService])
                    .filter(/enabled\?|deprecated\?|uptime/)
                    .handle_errors
                    .to_markdown

puts result
puts

# 7. Save comprehensive error analysis report
puts "💾 7. SAVING COMPREHENSIVE ERROR ANALYSIS REPORT"
puts "-" * 60
report = ClassMetrix.extract(:constants, :class_methods)
                    .from([WorkingService, PartiallyBrokenService, CompletelyBrokenService])
                    .handle_errors
                    .to_markdown("error_analysis_report.md", title: "Service Health Analysis Report")

puts "✅ Comprehensive error analysis saved to: error_analysis_report.md"
puts "📊 Report contains #{report.lines.count} lines with rich metadata"
puts

puts "🛡️ Enhanced Error Handling Features Demonstrated:"
puts "• 🚫 Missing constants: '🚫 Not defined'"
puts "• 🚫 Missing methods: '🚫 No method'"
puts "• ⚠️ Runtime errors: '⚠️ Error: [descriptive message]'"
puts "• ❌ Boolean false and nil values: '❌'"
puts "• ✅ Boolean true values: '✅'"
puts "• 📊 Rich markdown reports with titles and metadata"
puts "• 📋 Missing behaviors summary per class"
puts "• 🛡️ handle_errors flag enables graceful degradation"
