#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "../../lib/class_metrix"

puts "=== Basic Example 3: Multi-Type Extraction ==="
puts

# Define classes with both constants and methods
class EmailService
  # Constants
  PROVIDER_NAME = "smtp"
  DEFAULT_PORT = 587
  ENCRYPTION_ENABLED = true

  # Class methods
  def self.provider_name
    "SMTP Service"
  end

  def self.default_port
    587
  end

  def self.encryption_enabled?
    true
  end

  def self.rate_limit
    100
  end
end

class SendGridService
  # Constants
  PROVIDER_NAME = "sendgrid"
  DEFAULT_PORT = 443
  ENCRYPTION_ENABLED = true
  API_VERSION = "v3"

  # Class methods
  def self.provider_name
    "SendGrid API"
  end

  def self.default_port
    443
  end

  def self.encryption_enabled?
    true
  end

  def self.rate_limit
    1000
  end

  def self.api_version
    "v3"
  end
end

class MailgunService
  # Constants
  PROVIDER_NAME = "mailgun"
  DEFAULT_PORT = 443
  ENCRYPTION_ENABLED = true

  # Class methods
  def self.provider_name
    "Mailgun API"
  end

  def self.default_port
    443
  end

  def self.encryption_enabled?
    true
  end

  def self.rate_limit
    500
  end
end

puts "Classes defined: EmailService, SendGridService, MailgunService"
puts "Each has constants AND class methods with similar names"
puts

# Compare constants vs methods
puts "📊 Multi-Type Extraction (Constants + Methods):"
puts ClassMetrix.extract(:constants, :class_methods)
                .from([EmailService, SendGridService, MailgunService])
                .filter(/provider_name|default_port|encryption/)
                .to_markdown
puts

# Compare specific behaviors
puts "🎯 Rate Limiting Comparison:"
puts ClassMetrix.extract(:constants, :class_methods)
                .from([EmailService, SendGridService, MailgunService])
                .filter(/rate_limit/)
                .to_markdown
puts

# API-specific features
puts "🔌 API Features:"
puts ClassMetrix.extract(:constants, :class_methods)
                .from([EmailService, SendGridService, MailgunService])
                .filter(/API|version/)
                .to_markdown
puts

puts "✨ This example shows how to compare both constants and methods in one table!"
puts "Notice how the 'Type' column distinguishes between constants and methods."
