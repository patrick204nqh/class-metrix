#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "../../lib/class_metrix"

puts "=== Basic Example 2: Simple Class Methods ==="
puts

# Define some simple classes with class methods
class PaymentProcessor
  def self.supported_currencies
    %w[USD EUR GBP]
  end

  def self.max_amount
    10_000
  end

  def self.requires_verification?
    false
  end

  def self.processing_fee
    2.5
  end
end

class StripeProcessor
  def self.supported_currencies
    %w[USD EUR GBP CAD AUD]
  end

  def self.max_amount
    50_000
  end

  def self.requires_verification?
    true
  end

  def self.processing_fee
    2.9
  end

  def self.supports_recurring?
    true
  end
end

class PayPalProcessor
  def self.supported_currencies
    %w[USD EUR]
  end

  def self.max_amount
    25_000
  end

  def self.requires_verification?
    true
  end

  def self.processing_fee
    3.4
  end

  def self.instant_transfer?
    false
  end
end

puts "Classes defined: PaymentProcessor, StripeProcessor, PayPalProcessor"
puts "Methods: supported_currencies, max_amount, requires_verification?, processing_fee, etc."
puts

# Extract all class methods
puts "📋 All Class Methods:"
puts ClassMetrix.extract(:class_methods)
                .from([PaymentProcessor, StripeProcessor, PayPalProcessor])
                .to_markdown
puts

# Extract boolean methods only
puts "✅ Boolean Methods (ending with ?):"
puts ClassMetrix.extract(:class_methods)
                .from([PaymentProcessor, StripeProcessor, PayPalProcessor])
                .filter(/\?$/)
                .to_markdown
puts

# Extract configuration methods
puts "⚙️ Configuration Methods (max, fee, supported):"
puts ClassMetrix.extract(:class_methods)
                .from([PaymentProcessor, StripeProcessor, PayPalProcessor])
                .filter(/max|fee|supported/)
                .to_markdown
puts

puts "✨ This example shows class method extraction with different return types!"
