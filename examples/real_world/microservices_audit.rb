#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "../../lib/class_metrix"

puts "=== Real-World Example: Microservices Configuration Audit ==="
puts

# Realistic microservice configuration classes
class UserService
  # Service metadata
  SERVICE_NAME = "user-service"
  VERSION = "2.1.0"
  PORT = 8001
  ENVIRONMENT = "production"

  # Feature flags
  ENABLE_CACHING = true
  ENABLE_METRICS = true
  ENABLE_TRACING = false
  RATE_LIMITING_ENABLED = true

  # Configuration methods
  def self.database_config
    {
      host: "user-db.internal",
      port: 5432,
      database: "users_production",
      pool_size: 20,
      timeout: 30,
      ssl: true,
      backup_enabled: true
    }
  end

  def self.redis_config
    {
      host: "user-redis.internal",
      port: 6379,
      database: 0,
      timeout: 5,
      max_connections: 50
    }
  end

  def self.rate_limit_config
    {
      requests_per_minute: 1000,
      burst_size: 100,
      enabled: true
    }
  end

  def self.health_status
    "healthy"
  end

  def self.memory_usage_mb
    512
  end

  def self.active_connections
    45
  end
end

class OrderService
  # Service metadata
  SERVICE_NAME = "order-service"
  VERSION = "1.8.5"
  PORT = 8002
  ENVIRONMENT = "production"

  # Feature flags
  ENABLE_CACHING = true
  ENABLE_METRICS = true
  ENABLE_TRACING = true
  RATE_LIMITING_ENABLED = true

  # Configuration methods
  def self.database_config
    {
      host: "order-db.internal",
      port: 5432,
      database: "orders_production",
      pool_size: 30,
      timeout: 45,
      ssl: true,
      backup_enabled: true,
      read_replicas: 2
    }
  end

  def self.redis_config
    {
      host: "order-redis.internal",
      port: 6379,
      database: 1,
      timeout: 3,
      max_connections: 100,
      cluster_enabled: true
    }
  end

  def self.rate_limit_config
    {
      requests_per_minute: 500,
      burst_size: 50,
      enabled: true,
      premium_multiplier: 2.0
    }
  end

  def self.health_status
    "healthy"
  end

  def self.memory_usage_mb
    768
  end

  def self.active_connections
    127
  end

  def self.queue_size
    42
  end
end

class PaymentService
  # Service metadata
  SERVICE_NAME = "payment-service"
  VERSION = "3.0.1"
  PORT = 8003
  ENVIRONMENT = "production"

  # Feature flags
  ENABLE_CACHING = false # Disabled for security
  ENABLE_METRICS = true
  ENABLE_TRACING = true
  RATE_LIMITING_ENABLED = true

  # Configuration methods
  def self.database_config
    {
      host: "payment-db.internal",
      port: 5432,
      database: "payments_production",
      pool_size: 15,
      timeout: 60,
      ssl: true,
      backup_enabled: true,
      encryption: "AES-256"
    }
  end

  def self.redis_config
    {
      host: "payment-redis.internal",
      port: 6379,
      database: 2,
      timeout: 2,
      max_connections: 25,
      ssl: true
    }
  end

  def self.rate_limit_config
    {
      requests_per_minute: 100,
      burst_size: 10,
      enabled: true,
      strict_mode: true
    }
  end

  def self.health_status
    "healthy"
  end

  def self.memory_usage_mb
    256
  end

  def self.active_connections
    12
  end

  def self.encryption_status
    "AES-256-GCM"
  end
end

puts "=== Microservices Defined ==="
puts "UserService, OrderService, PaymentService"
puts "Each service has metadata, feature flags, and configuration methods"
puts

# 1. Service Overview
puts "🏢 1. SERVICE OVERVIEW"
puts "=" * 70
result = ClassMetrix.extract(:constants)
                    .from([UserService, OrderService, PaymentService])
                    .filter(/SERVICE_NAME|VERSION|PORT|ENVIRONMENT/)
                    .to_markdown

puts result
puts

# 2. Feature Flags Comparison
puts "🚩 2. FEATURE FLAGS COMPARISON"
puts "=" * 70
result = ClassMetrix.extract(:constants)
                    .from([UserService, OrderService, PaymentService])
                    .filter(/ENABLE_|RATE_LIMITING/)
                    .to_markdown

puts result
puts

# 3. Database Configuration Analysis
puts "🗄️ 3. DATABASE CONFIGURATION ANALYSIS"
puts "=" * 70
result = ClassMetrix.extract(:class_methods)
                    .from([UserService, OrderService, PaymentService])
                    .filter(/database_config/)
                    .expand_hashes
                    .to_markdown

puts result
puts

# 4. Redis Configuration Comparison
puts "🔴 4. REDIS CONFIGURATION COMPARISON"
puts "=" * 70
result = ClassMetrix.extract(:class_methods)
                    .from([UserService, OrderService, PaymentService])
                    .filter(/redis_config/)
                    .expand_hashes
                    .to_markdown

puts result
puts

# 5. Rate Limiting Configuration
puts "⚡ 5. RATE LIMITING CONFIGURATION"
puts "=" * 70
result = ClassMetrix.extract(:class_methods)
                    .from([UserService, OrderService, PaymentService])
                    .filter(/rate_limit_config/)
                    .expand_hashes
                    .to_markdown

puts result
puts

# 6. Service Health & Performance
puts "📊 6. SERVICE HEALTH & PERFORMANCE METRICS"
puts "=" * 70
result = ClassMetrix.extract(:class_methods)
                    .from([UserService, OrderService, PaymentService])
                    .filter(/health_status|memory_usage|active_connections/)
                    .to_markdown

puts result
puts

# 7. Security Features
puts "🔒 7. SECURITY FEATURES ANALYSIS"
puts "=" * 70
result = ClassMetrix.extract(:constants, :class_methods)
                    .from([UserService, OrderService, PaymentService])
                    .filter(/CACHING|ssl|encryption/)
                    .to_markdown

puts result
puts

# 8. Complete Configuration Audit
puts "📋 8. COMPLETE CONFIGURATION AUDIT"
puts "=" * 70
result = ClassMetrix.extract(:constants, :class_methods)
                    .from([UserService, OrderService, PaymentService])
                    .handle_errors
                    .expand_hashes
                    .to_markdown

puts "Full audit contains #{result.lines.count} lines"
puts "Saving to microservices_audit_report.md..."

# Save comprehensive report
ClassMetrix.extract(:constants, :class_methods)
           .from([UserService, OrderService, PaymentService])
           .handle_errors
           .expand_hashes
           .to_markdown("microservices_audit_report.md")

puts "✅ Complete audit saved to: microservices_audit_report.md"
puts

puts "🎯 Real-World Use Cases Demonstrated:"
puts "• Service metadata comparison across microservices"
puts "• Feature flag consistency analysis"
puts "• Database configuration standardization check"
puts "• Cache configuration comparison"
puts "• Rate limiting policy analysis"
puts "• Performance metrics monitoring"
puts "• Security configuration audit"
puts "• Complete infrastructure overview"
puts "• Configuration drift detection"
puts "• Compliance reporting"
