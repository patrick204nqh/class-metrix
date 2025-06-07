#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "../../lib/class_metrix"

# Example classes for demonstration
class DatabaseService
  DEFAULT_CONFIG = { host: "localhost", port: 5432, ssl: true }
  TIMEOUT_CONFIG = { connect: 30, read: 60, write: 30 }

  def self.connection_timeout
    30
  end

  def self.pool_size
    10
  end
end

class RedisService
  DEFAULT_CONFIG = { host: "redis.local", port: 6379, ssl: false }
  CLUSTER_CONFIG = { nodes: 3, replication: true, sharding: "consistent" }

  def self.connection_timeout
    5
  end

  def self.pool_size
    20
  end
end

class S3Service
  DEFAULT_CONFIG = { region: "us-east-1", bucket: "my-bucket" }

  def self.connection_timeout
    60
  end
end

puts "=" * 80
puts "ClassMetrix v2.0 - Configurable Component Examples"
puts "=" * 80

# Example 1: Minimal Report (table only)
puts "\n1. MINIMAL REPORT (table only)"
puts "-" * 40

minimal = ClassMetrix.extract(:constants)
                     .from([DatabaseService, RedisService, S3Service])
                     .filter(/DEFAULT_CONFIG/)
                     .to_markdown(
                       show_metadata: false,
                       show_classes: false,
                       show_extraction_info: false,
                       show_footer: false
                     )

puts minimal

# Example 2: Standard Report with Custom Title
puts "\n2. STANDARD REPORT with custom title"
puts "-" * 40

standard = ClassMetrix.extract(:constants, :class_methods)
                      .from([DatabaseService, RedisService, S3Service])
                      .filter(/CONFIG|timeout/)
                      .expand_hashes
                      .handle_errors
                      .to_markdown(
                        title: "Microservices Configuration Analysis"
                      )

puts standard

# Example 3: Detailed Report with All Features
puts "\n3. DETAILED REPORT with all features"
puts "-" * 40

detailed = ClassMetrix.extract(:constants, :class_methods)
                      .from([DatabaseService, RedisService, S3Service])
                      .filter(/CONFIG|timeout|pool/)
                      .expand_hashes
                      .handle_errors
                      .to_markdown(
                        title: "Complete Service Analysis",
                        show_missing_summary: true,
                        summary_style: :detailed,
                        footer_style: :detailed,
                        show_timestamp: true,
                        custom_footer: "Generated for production deployment review"
                      )

puts detailed

# Example 4: Compact Table Style
puts "\n4. COMPACT TABLE STYLE"
puts "-" * 40

compact = ClassMetrix.extract(:class_methods)
                     .from([DatabaseService, RedisService, S3Service])
                     .filter(/timeout|pool/)
                     .to_markdown(
                       title: "Service Performance Settings",
                       table_style: :compact,
                       max_column_width: 20,
                       footer_style: :minimal
                     )

puts compact

# Example 5: Different Summary Styles
puts "\n5. DIFFERENT SUMMARY STYLES"
puts "-" * 40

# Flat summary style
flat_summary = ClassMetrix.extract(:constants)
                          .from([DatabaseService, RedisService, S3Service])
                          .filter(/CLUSTER|TIMEOUT/)
                          .handle_errors
                          .to_markdown(
                            title: "Missing Configurations (Flat Style)",
                            show_missing_summary: true,
                            summary_style: :flat,
                            show_classes: false,
                            show_extraction_info: false
                          )

puts flat_summary

# Example 6: Save Different Formats to Files
puts "\n6. SAVING REPORTS TO FILES"
puts "-" * 40

# Save minimal report
ClassMetrix.extract(:constants)
           .from([DatabaseService, RedisService, S3Service])
           .filter(/DEFAULT_CONFIG/)
           .expand_hashes
           .to_markdown("reports/minimal_config.md",
                        title: "Service Default Configurations",
                        show_missing_summary: false,
                        footer_style: :minimal)

# Save detailed audit report
ClassMetrix.extract(:constants, :class_methods)
           .from([DatabaseService, RedisService, S3Service])
           .filter(/CONFIG|timeout|pool/)
           .expand_hashes
           .handle_errors
           .to_markdown("reports/detailed_audit.md",
                        title: "Complete Microservices Audit",
                        show_missing_summary: true,
                        summary_style: :detailed,
                        footer_style: :detailed,
                        show_timestamp: true,
                        custom_footer: "Audit performed for compliance review")

# Save compact performance report
ClassMetrix.extract(:class_methods)
           .from([DatabaseService, RedisService, S3Service])
           .filter(/timeout|pool/)
           .to_markdown("reports/performance_settings.md",
                        title: "Service Performance Configuration",
                        table_style: :compact,
                        max_column_width: 25,
                        show_classes: true,
                        show_extraction_info: false,
                        footer_style: :default)

puts "✅ Reports saved to:"
puts "   - reports/minimal_config.md"
puts "   - reports/detailed_audit.md"
puts "   - reports/performance_settings.md"

puts "\n" + "=" * 80
puts "Component Configuration Summary:"
puts "=" * 80
puts "✨ Header Component Options:"
puts "   - title: Custom report title"
puts "   - show_metadata: Show/hide title section"
puts "   - show_classes: Show/hide classes analyzed section"
puts "   - show_extraction_info: Show/hide extraction types section"
puts ""
puts "📊 Table Component Options:"
puts "   - table_style: :standard, :compact, :wide"
puts "   - min_column_width: Minimum column width"
puts "   - max_column_width: Maximum column width (for compact style)"
puts ""
puts "📋 Missing Behaviors Component Options:"
puts "   - show_missing_summary: Show/hide missing behaviors analysis"
puts "   - summary_style: :grouped, :flat, :detailed"
puts ""
puts "📄 Footer Component Options:"
puts "   - show_footer: Show/hide footer"
puts "   - footer_style: :default, :minimal, :detailed"
puts "   - show_timestamp: Include generation timestamp"
puts "   - custom_footer: Custom footer message"
puts ""
puts "🎯 All components are independently configurable!"
puts "=" * 80
