# frozen_string_literal: true

require "simplecov"
require "simplecov_json_formatter"

SimpleCov.start do
  # Use both HTML and JSON formatters for better CI integration
  if ENV["COVERAGE"]
    formatter SimpleCov::Formatter::MultiFormatter.new([
                                                         SimpleCov::Formatter::HTMLFormatter,
                                                         SimpleCov::Formatter::JSONFormatter
                                                       ])
  else
    formatter SimpleCov::Formatter::HTMLFormatter
  end

  add_filter "/spec/"
  add_filter "/examples/"
  add_filter "/bin/"
  add_filter "/docs/"
  add_filter "/tmp/"
  add_filter "/coverage/"

  # Coverage thresholds
  minimum_coverage 85
  minimum_coverage_by_file 70

  # Track branches for more accurate coverage
  enable_coverage :branch
end

require "class_metrix"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
