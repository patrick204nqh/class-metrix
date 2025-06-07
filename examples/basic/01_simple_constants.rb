#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "../../lib/class_metrix"

puts "=== Basic Example 1: Simple Constants ==="
puts

# Define some simple classes with constants
class User
  ROLE_NAME = "user"
  MAX_LOGIN_ATTEMPTS = 3
  ACCOUNT_TYPE = "standard"
end

class Admin
  ROLE_NAME = "admin"
  MAX_LOGIN_ATTEMPTS = 5
  ACCOUNT_TYPE = "premium"
  ADMIN_LEVEL = 10
end

class Guest
  ROLE_NAME = "guest"
  MAX_LOGIN_ATTEMPTS = 1
  ACCOUNT_TYPE = "basic"
end

puts "Classes defined: User, Admin, Guest"
puts "Constants: ROLE_NAME, MAX_LOGIN_ATTEMPTS, ACCOUNT_TYPE, ADMIN_LEVEL"
puts

# Extract all constants
puts "📋 All Constants:"
puts ClassMetrix.extract(:constants)
                .from([User, Admin, Guest])
                .to_markdown
puts

# Extract filtered constants
puts "🔍 Filtered Constants (ROLE and MAX):"
puts ClassMetrix.extract(:constants)
                .from([User, Admin, Guest])
                .filter(/ROLE|MAX/)
                .to_markdown
puts

# Extract with regex filter
puts "🎯 Regex Filter (starting with ACCOUNT):"
puts ClassMetrix.extract(:constants)
                .from([User, Admin, Guest])
                .filter(/^ACCOUNT/)
                .to_markdown
puts

puts "✨ This example shows basic constant extraction and filtering!"
