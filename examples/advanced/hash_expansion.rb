#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "../../lib/class_metrix"

puts "=== Advanced Example: Hash Expansion ==="
puts

# Configuration classes with complex hash structures
class DatabaseConfig
  # Hash constants
  DEFAULT_CONFIG = {
    host: "localhost",
    port: 5432,
    ssl: true,
    pool_size: 5
  }

  CONNECTION_POOLS = {
    read: { size: 10, timeout: 30 },
    write: { size: 5, timeout: 15 },
    admin: { size: 2, timeout: 60 }
  }

  # Hash methods
  def self.production_config
    {
      host: "db.production.com",
      port: 5432,
      database: "myapp_production",
      ssl: true,
      pool_size: 20,
      timeout: 30,
      backup_enabled: true
    }
  end

  def self.development_config
    {
      host: "localhost",
      port: 5432,
      database: "myapp_development",
      ssl: false,
      pool_size: 5,
      timeout: 10
    }
  end

  def self.simple_value
    "not a hash"
  end
end

class RedisConfig
  # Hash constants
  DEFAULT_CONFIG = {
    host: "localhost",
    port: 6379,
    ssl: false,
    timeout: 5
  }

  CLUSTER_CONFIG = {
    nodes: 3,
    replication: true,
    failover: "auto"
  }

  # Hash methods
  def self.production_config
    {
      host: "redis.internal",
      port: 6379,
      database: 0,
      ssl: false,
      max_connections: 100,
      cluster_enabled: true
    }
  end

  def self.development_config
    {
      host: "localhost",
      port: 6379,
      database: 1,
      ssl: false,
      max_connections: 10
    }
  end

  def self.simple_value
    42
  end
end

puts "=== Configuration Classes Defined ==="
puts "DatabaseConfig and RedisConfig with hash constants and methods"
puts

# 1. Normal output (without expansion)
puts "📋 1. NORMAL OUTPUT (Hashes as inspect strings)"
puts "-" * 60
result = ClassMetrix.extract(:class_methods)
                    .from([DatabaseConfig, RedisConfig])
                    .filter(/config$/)
                    .to_markdown

puts result
puts

# 2. Expanded output
puts "🔍 2. EXPANDED OUTPUT (Hash keys as sub-rows)"
puts "-" * 60
result = ClassMetrix.extract(:class_methods)
                    .from([DatabaseConfig, RedisConfig])
                    .filter(/config$/)
                    .expand_hashes
                    .to_markdown

puts result
puts

# 3. Constants with expansion
puts "📊 3. CONSTANTS WITH HASH EXPANSION"
puts "-" * 60
result = ClassMetrix.extract(:constants)
                    .from([DatabaseConfig, RedisConfig])
                    .filter(/CONFIG/)
                    .expand_hashes
                    .handle_errors
                    .to_markdown

puts result
puts

# 4. Mixed data types with expansion
puts "🔧 4. MIXED DATA TYPES WITH EXPANSION"
puts "-" * 60
result = ClassMetrix.extract(:class_methods)
                    .from([DatabaseConfig, RedisConfig])
                    .expand_hashes
                    .to_markdown

puts result
puts

# 5. Multi-type extraction with expansion
puts "🚀 5. MULTI-TYPE WITH HASH EXPANSION"
puts "-" * 60
result = ClassMetrix.extract(:constants, :class_methods)
                    .from([DatabaseConfig, RedisConfig])
                    .filter(/DEFAULT_CONFIG|production_config/)
                    .expand_hashes
                    .handle_errors
                    .to_markdown

puts result
puts

# 6. Save expanded report
puts "💾 6. SAVING EXPANDED REPORT"
puts "-" * 60
report = ClassMetrix.extract(:constants, :class_methods)
                    .from([DatabaseConfig, RedisConfig])
                    .expand_hashes
                    .handle_errors
                    .to_markdown("config_analysis_expanded.md")

puts "✅ Expanded report saved to: config_analysis_expanded.md"
puts "📊 Report contains #{report.lines.count} lines"
puts

puts "✨ Hash Expansion Features Demonstrated:"
puts "• 📋 Hash indicators show number of keys"
puts "• └─ Sub-rows show individual key-value pairs"
puts "• ❌ Missing keys shown clearly"
puts "• — Non-hash values shown with dash"
puts "• Mixed data types handled properly"
puts "• Works with both constants and methods"
puts "• Compatible with multi-type extraction"
