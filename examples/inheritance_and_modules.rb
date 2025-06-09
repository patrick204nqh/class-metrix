#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "../lib/class_metrix"

puts "ClassMetrix: Inheritance & Module Analysis"
puts "=" * 50

# Example: Service Configuration Analysis
# This demonstrates analyzing service classes that use inheritance and modules

module Configurable
  DEFAULT_TIMEOUT = 30

  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    def configuration
      { timeout: DEFAULT_TIMEOUT, enabled: true }
    end
  end
end

module Cacheable
  CACHE_TTL = 3600

  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    def cache_config
      { ttl: CACHE_TTL, enabled: true }
    end
  end
end

class BaseService
  SERVICE_VERSION = "1.0"

  def self.service_type
    "base"
  end

  def self.health_check
    { status: "ok", version: SERVICE_VERSION }
  end
end

class DatabaseService < BaseService
  include Configurable

  SERVICE_NAME = "database"
  CONNECTION_POOL_SIZE = 5

  def self.service_type
    "database"
  end

  def self.connection_config
    { pool_size: CONNECTION_POOL_SIZE, timeout: 60 }
  end
end

class CacheService < BaseService
  include Configurable
  include Cacheable

  SERVICE_NAME = "cache"
  MAX_MEMORY = "512MB"

  def self.service_type
    "cache"
  end

  def self.memory_config
    { max_memory: MAX_MEMORY, eviction_policy: "lru" }
  end
end

# Demo the functionality
services = [DatabaseService, CacheService]

puts "\n1. Class-Only Analysis (Using .strict())"
puts "-" * 40
result = ClassMetrix.extract(:constants)
                    .from(services)
                    .strict
                    .to_markdown
puts result

puts "\n2. Default Comprehensive Analysis (Inheritance + Modules Enabled)"
puts "-" * 40
result = ClassMetrix.extract(:constants)
                    .from(services)
                    .to_markdown
puts result

puts "\n3. Complete Analysis with Methods (Comprehensive by Default)"
puts "-" * 40
result = ClassMetrix.extract(:constants, :class_methods)
                    .from(services)
                    .handle_errors
                    .to_markdown
puts result

puts "\n4. Filtered Configuration Analysis"
puts "-" * 40
result = ClassMetrix.extract(:constants, :class_methods)
                    .from(services)
                    .filter(/config|timeout|service/i)
                    .expand_hashes
                    .to_markdown
puts result

puts "\n5. Hash Expansion Modes"
puts "-" * 40

puts "\n5a. Default: Show Only Main Rows (Collapsed Hashes)"
result = ClassMetrix.extract(:class_methods)
                    .from([CacheService])
                    .filter(/config/)
                    .expand_hashes
                    .to_markdown
puts result

puts "\n5b. Show Only Key Rows (Expanded Details)"
result = ClassMetrix.extract(:class_methods)
                    .from([CacheService])
                    .filter(/config/)
                    .expand_hashes
                    .show_only_keys
                    .to_markdown
puts result

puts "\n5c. Show Both Main and Key Rows"
result = ClassMetrix.extract(:class_methods)
                    .from([CacheService])
                    .filter(/config/)
                    .expand_hashes
                    .show_expanded_details
                    .to_markdown
puts result

puts "\n" + "=" * 50
puts "✨ CLEAN API HIGHLIGHTS:"
puts "• Inheritance & modules enabled BY DEFAULT (comprehensive)"
puts "• Use .strict() when you want class-only analysis"
puts "• Much more intuitive and less verbose than before!"
puts "=" * 50
