#!/usr/bin/env ruby
# frozen_string_literal: true

# Debug Levels Demonstration
# Shows the different levels of debug output

require_relative '../lib/class_metrix'

# Example classes
class ServiceA
  CONFIG = { host: 'localhost', port: 3000, timeout: 30 }

  def self.get_settings
    { cache: true, retries: 3 }
  end
end

class ServiceB
  CONFIG = { host: 'remote', port: 8080 }

  def self.get_settings
    { cache: false, retries: 1 }
  end
end

puts "=== ClassMetrix Debug Levels Demo ==="
puts

# Test different debug levels
levels = [:basic, :detailed, :verbose]

levels.each do |level|
  puts "\n" + "=" * 50
  puts "DEBUG LEVEL: #{level.upcase}"
  puts "=" * 50

  begin
    result = ClassMetrix.extract(:constants, :class_methods)
                        .from([ServiceA, ServiceB])
                        .expand_hashes
                        .debug(level) # Set debug level
                        .to_markdown

    puts "\n--- Result Summary ---"
    puts "Report generated successfully! ✅"
    puts "Lines in output: #{result.lines.count}"
  rescue => e
    puts "Error: #{e.class}: #{e.message}"
  end

  puts "\n"
end

puts "\n" + "=" * 50
puts "DEBUG LEVEL SUMMARY"
puts "=" * 50
puts
puts ":basic    - Key decisions and summaries only"
puts ":detailed - More context and intermediate steps"
puts ":verbose  - Full details including individual value processing"
puts
puts "Use :basic for general troubleshooting"
puts "Use :detailed for understanding data flow"
puts "Use :verbose for deep debugging of specific values"
