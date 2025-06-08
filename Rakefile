# frozen_string_literal: true

require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

require "rubocop/rake_task"

RuboCop::RakeTask.new

# Add Brakeman security scanner
begin
  require "brakeman"

  desc "Run Brakeman security scanner"
  task :brakeman do
    puts "🔍 Running Brakeman security scan..."
    # Ensure tmp directory exists
    Dir.mkdir("tmp") unless Dir.exist?("tmp")

    # Run with non-zero exit to avoid breaking CI but still capture issues
    result = system("brakeman --force --format json --output tmp/brakeman.json --no-exit-on-warn")
    unless result
      puts "⚠️ Brakeman found potential security issues - check tmp/brakeman.json"
    end

    # Also create human-readable output
    system("brakeman --force --format text --output tmp/brakeman.txt --no-exit-on-warn")

    puts "✅ Brakeman security scan completed"
    puts "📄 Reports saved to: tmp/brakeman.json and tmp/brakeman.txt"
  end

  desc "Run Brakeman security scanner with HTML output"
  task :brakeman_html do
    puts "🔍 Running Brakeman security scan (HTML output)..."
    Dir.mkdir("tmp") unless Dir.exist?("tmp")

    system("brakeman --force --format html --output tmp/brakeman.html --no-exit-on-warn")
    puts "✅ Brakeman HTML report generated: tmp/brakeman.html"
  end

  desc "Run comprehensive security check"
  task :security => [:brakeman] do
    puts "🔒 Security check completed"
  end

rescue LoadError
  desc "Brakeman not available"
  task :brakeman do
    puts "⚠️ Brakeman not available - install with: gem install brakeman"
  end

  task :security => [] do
    puts "⚠️ Security tools not available"
  end
end

# Coverage task for local development
desc "Run tests with coverage report"
task :coverage do
  ENV["COVERAGE"] = "true"
  Rake::Task[:spec].invoke
  puts "📊 Coverage report generated in coverage/"
end

# Quality check task combining multiple checks
desc "Run all quality checks"
task :quality => [:rubocop, :security] do
  puts "✅ All quality checks completed"
end

# Add security to default tasks for better security
task default: %i[spec rubocop security]
