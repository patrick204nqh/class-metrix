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
    sh "brakeman --force --format json --output tmp/brakeman.json --exit-on-warn"
    puts "✅ Brakeman security scan completed successfully"
  end

  desc "Run Brakeman security scanner with HTML output"
  task :brakeman_html do
    sh "brakeman --force --format html --output tmp/brakeman.html"
    puts "✅ Brakeman HTML report generated: tmp/brakeman.html"
  end
rescue LoadError
  # Brakeman not available
end

task default: %i[spec rubocop]
