#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "../lib/class_metrix"

# Basic Usage Example
puts "ClassMetrix Basic Usage (New Simplified API)"
puts "=" * 45

# Define some simple classes for comparison
class User
  ROLE = "user"
  MAX_LOGIN_ATTEMPTS = 3

  def self.permissions
    ["read"]
  end

  def self.session_timeout
    3600
  end
end

class Admin
  ROLE = "admin"
  MAX_LOGIN_ATTEMPTS = 5

  def self.permissions
    ["read", "write", "admin"]
  end

  def self.session_timeout
    7200
  end
end

classes = [User, Admin]

# 1. Extract constants (inheritance & modules included by default)
puts "\n1. Constants Comparison (Comprehensive by Default)"
puts "-" * 50
result = ClassMetrix.extract(:constants)
                    .from(classes)
                    .to_markdown
puts result

# 2. Extract class methods (inheritance & modules included by default)
puts "\n2. Class Methods Comparison (Comprehensive by Default)"
puts "-" * 55
result = ClassMetrix.extract(:class_methods)
                    .from(classes)
                    .to_markdown
puts result

# 3. Combined extraction
puts "\n3. Combined Analysis"
puts "-" * 25
result = ClassMetrix.extract(:constants, :class_methods)
                    .from(classes)
                    .to_markdown
puts result

# 4. Filtered analysis
puts "\n4. Filtered Analysis (ROLE and permissions only)"
puts "-" * 25
result = ClassMetrix.extract(:constants, :class_methods)
                    .from(classes)
                    .filter(/ROLE|permissions/)
                    .to_markdown
puts result

# 5. Hash expansion
puts "\n5. Hash Expansion Example"
puts "-" * 25

class ConfigExample
  SETTINGS = { timeout: 30, retries: 3, ssl: true }.freeze

  def self.database_config
    { host: "localhost", port: 5432, pool_size: 5 }
  end
end

result = ClassMetrix.extract(:constants, :class_methods)
                    .from([ConfigExample])
                    .expand_hashes
                    .to_markdown
puts result

# 6. New API Features Demo
puts "\n6. New API Features"
puts "-" * 20

# Create a class with inheritance and modules for demo
module Trackable
  TRACK_ENABLED = true

  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    def track_events
      "enabled"
    end

    private

    def private_tracker
      "internal"
    end
  end
end

class BaseEntity
  ENTITY_VERSION = "1.0"

  def self.base_method
    "base"
  end

  private_class_method def self.private_base
    "secret"
  end
end

class TrackedEntity < BaseEntity
  include Trackable

  ENTITY_TYPE = "tracked"

  def self.entity_method
    "tracked_entity"
  end

  private_class_method def self.private_entity
    "entity_secret"
  end
end

puts "\n6a. Default behavior (comprehensive - inheritance & modules included):"
puts "ClassMetrix.extract(:constants).from([TrackedEntity]).to_markdown"
result = ClassMetrix.extract(:constants).from([TrackedEntity]).to_markdown
puts result

puts "\n6b. Strict mode (class only):"
puts "ClassMetrix.extract(:constants).from([TrackedEntity]).strict.to_markdown"
result = ClassMetrix.extract(:constants).from([TrackedEntity]).strict.to_markdown
puts result

puts "\n6c. With private methods:"
puts "ClassMetrix.extract(:class_methods).from([TrackedEntity]).with_private.to_markdown"
result = ClassMetrix.extract(:class_methods).from([TrackedEntity]).with_private.to_markdown
puts result

puts "\n6d. Strict + private (class only + private methods):"
puts "ClassMetrix.extract(:class_methods).from([TrackedEntity]).strict.with_private.to_markdown"
result = ClassMetrix.extract(:class_methods).from([TrackedEntity]).strict.with_private.to_markdown
puts result

puts "\n" + "=" * 45
puts "✨ API IMPROVEMENTS:"
puts "• Inheritance & modules enabled BY DEFAULT"
puts "• Use .strict() for class-only scanning"
puts "• Use .with_private() for private methods"
puts "• Much cleaner and more intuitive!"
puts "=" * 45
