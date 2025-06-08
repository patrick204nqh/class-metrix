#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "../lib/class_metrix"

# Basic Usage Example
puts "ClassMetrix Basic Usage"
puts "=" * 30

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

# 1. Extract constants
puts "\n1. Constants Comparison"
puts "-" * 25
result = ClassMetrix.extract(:constants)
                    .from(classes)
                    .to_markdown
puts result

# 2. Extract class methods
puts "\n2. Class Methods Comparison"
puts "-" * 25
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
