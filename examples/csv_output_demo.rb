#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "../lib/class_metrix"

# Example classes for demonstration
class DatabaseConfig
  DEFAULT_CONFIG = {
    host: "localhost",
    port: 5432,
    ssl: true,
    timeout: 30
  }.freeze

  CLUSTER_CONFIG = {
    nodes: 3,
    replication: true
  }.freeze

  def self.connection_timeout
    30
  end

  def self.max_connections
    100
  end
end

class RedisConfig
  DEFAULT_CONFIG = {
    host: "redis.local",
    port: 6379,
    ssl: false,
    timeout: 5
  }.freeze

  CACHE_CONFIG = {
    ttl: 3600,
    max_memory: "1GB"
  }.freeze

  def self.connection_timeout
    5
  end

  def self.max_connections
    50
  end
end

class S3Config
  DEFAULT_CONFIG = {
    region: "us-east-1",
    ssl: true,
    timeout: 60
  }.freeze

  BUCKET_CONFIG = {
    versioning: true,
    encryption: "AES256"
  }.freeze

  def self.connection_timeout
    60
  end

  def self.max_connections
    25
  end
end

puts "=" * 80
puts "ClassMetrix CSV Output Examples"
puts "=" * 80

# Example 1: Simple CSV output
puts "\n1. Simple CSV Output (Constants)"
puts "-" * 40

result = ClassMetrix.extract(:constants)
                    .from([DatabaseConfig, RedisConfig, S3Config])
                    .filter(/DEFAULT_CONFIG/)
                    .to_csv(show_metadata: false)

puts result

# Example 2: CSV with metadata
puts "\n\n2. CSV with Metadata and Title"
puts "-" * 40

result = ClassMetrix.extract(:constants)
                    .from([DatabaseConfig, RedisConfig, S3Config])
                    .filter(/DEFAULT_CONFIG/)
                    .to_csv(title: "Service Configuration Comparison")

puts result

# Example 3: Multi-type extraction with hash flattening
puts "\n\n3. Multi-Type with Hash Flattening"
puts "-" * 40

result = ClassMetrix.extract(:constants, :class_methods)
                    .from([DatabaseConfig, RedisConfig, S3Config])
                    .filter(/CONFIG|timeout|connections/)
                    .expand_hashes
                    .handle_errors
                    .to_csv(
                      title: "Complete Service Analysis",
                      flatten_hashes: true,
                      show_metadata: true
                    )

puts result

# Example 4: Hash expansion with sub-rows (non-flattened)
puts "\n\n4. Hash Expansion with Sub-Rows"
puts "-" * 40

result = ClassMetrix.extract(:constants)
                    .from([DatabaseConfig, RedisConfig, S3Config])
                    .filter(/DEFAULT_CONFIG/)
                    .expand_hashes
                    .to_csv(
                      title: "Configuration Details",
                      flatten_hashes: false,
                      show_metadata: false
                    )

puts result

# Example 5: Different CSV separators
puts "\n\n5. Semicolon-Separated Values"
puts "-" * 40

result = ClassMetrix.extract(:class_methods)
                    .from([DatabaseConfig, RedisConfig, S3Config])
                    .filter(/timeout|connections/)
                    .to_csv(
                      separator: ";",
                      show_metadata: false
                    )

puts result

# Example 6: Tab-separated values
puts "\n\n6. Tab-Separated Values"
puts "-" * 40

result = ClassMetrix.extract(:class_methods)
                    .from([DatabaseConfig, RedisConfig, S3Config])
                    .filter(/timeout/)
                    .to_csv(
                      separator: "\t",
                      show_metadata: false
                    )

puts result

# Example 7: Custom null values
puts "\n\n7. Custom Null Values"
puts "-" * 40

result = ClassMetrix.extract(:constants)
                    .from([DatabaseConfig, RedisConfig, S3Config])
                    .filter(/CLUSTER_CONFIG|CACHE_CONFIG|BUCKET_CONFIG/)
                    .handle_errors
                    .to_csv(
                      null_value: "N/A",
                      show_metadata: false
                    )

puts result

# Example 8: Save to file
puts "\n\n8. Saving to File"
puts "-" * 40

filename = "service_analysis.csv"
ClassMetrix.extract(:constants, :class_methods)
           .from([DatabaseConfig, RedisConfig, S3Config])
           .filter(/CONFIG|timeout/)
           .expand_hashes
           .handle_errors
           .to_csv(
             filename,
             title: "Service Configuration Analysis",
             flatten_hashes: true
           )

puts "CSV report saved to: #{filename}"
puts "File size: #{File.size(filename)} bytes"
puts "\nFirst few lines of the file:"
puts File.readlines(filename)[0..5].join

# Example 9: Error handling demonstration
puts "\n\n9. Error Handling in CSV"
puts "-" * 40

class BrokenConfig
  VALID_CONFIG = { host: "localhost" }.freeze

  def self.working_method
    "success"
  end

  def self.broken_method
    raise StandardError, "Something went wrong"
  end
end

result = ClassMetrix.extract(:constants, :class_methods)
                    .from([DatabaseConfig, BrokenConfig])
                    .filter(/CONFIG|method/)
                    .handle_errors
                    .to_csv(show_metadata: false)

puts result

puts "\n#{"=" * 80}"
puts "CSV Output Features Summary:"
puts "=" * 80
puts "✓ Simple CSV tables with comma separation"
puts "✓ Custom separators (semicolon, tab, etc.)"
puts "✓ Metadata headers with comments"
puts "✓ Hash flattening into separate columns"
puts "✓ Hash expansion into sub-rows"
puts "✓ Multi-type extraction support"
puts "✓ Error handling with clean output"
puts "✓ Custom null value representation"
puts "✓ File output capability"
puts "✓ Emoji cleaning for CSV compatibility"
puts "✓ Boolean value conversion (TRUE/FALSE)"
puts "✓ Array value joining with semicolons"
puts "=" * 80

# Clean up
File.delete(filename) if File.exist?(filename)
