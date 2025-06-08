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

puts "\n1. Basic Analysis (Own Constants Only)"
puts "-" * 40
result = ClassMetrix.extract(:constants)
                    .from(services)
                    .to_markdown
puts result

puts "\n2. With Inheritance (Own + Parent Constants)"
puts "-" * 40
result = ClassMetrix.extract(:constants)
                    .from(services)
                    .include_inherited
                    .to_markdown
puts result

puts "\n3. With Modules (Own + Module Constants)"
puts "-" * 40
result = ClassMetrix.extract(:constants)
                    .from(services)
                    .include_modules
                    .to_markdown
puts result

puts "\n4. Complete Analysis (Own + Inherited + Modules)"
puts "-" * 40
result = ClassMetrix.extract(:constants, :class_methods)
                    .from(services)
                    .include_all
                    .handle_errors
                    .to_markdown
puts result

puts "\n5. Filtered Configuration Analysis"
puts "-" * 40
result = ClassMetrix.extract(:constants, :class_methods)
                    .from(services)
                    .include_all
                    .filter(/config|timeout|service/i)
                    .expand_hashes
                    .to_markdown
puts result

puts "\n6. Hash Expansion Modes"
puts "-" * 40

puts "\n6a. Default: Show Only Main Rows (Collapsed Hashes)"
result = ClassMetrix.extract(:class_methods)
                    .from([CacheService])
                    .filter(/config/)
                    .expand_hashes
                    .to_markdown
puts result

puts "\n6b. Show Only Key Rows (Expanded Details)"
result = ClassMetrix.extract(:class_methods)
                    .from([CacheService])
                    .filter(/config/)
                    .expand_hashes
                    .show_only_keys
                    .to_markdown
puts result

puts "\n6c. Show Both Main and Key Rows"
result = ClassMetrix.extract(:class_methods)
                    .from([CacheService])
                    .filter(/config/)
                    .expand_hashes
                    .show_expanded_details
                    .to_markdown
puts result
