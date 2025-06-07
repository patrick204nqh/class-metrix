# frozen_string_literal: true

require_relative "lib/class_metrix/version"

Gem::Specification.new do |spec|
  spec.name = "class-metrix"
  spec.version = ClassMetrix::VERSION
  spec.authors = ["Huy Nguyen"]
  spec.email = ["patrick204nqh@gmail.com"]

  spec.summary = "Simple extraction and comparison of Ruby class behaviors with clean markdown output"
  spec.description = "ClassMetrix allows you to easily extract and compare constants and class " \
                     "methods across multiple Ruby classes, generating clean markdown tables " \
                     "for analysis and documentation."
  spec.homepage = "https://github.com/patrick204nqh/class-metrix"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.1.0"

  spec.metadata["allowed_push_host"] = "https://rubygems.org"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/patrick204nqh/class-metrix"
  spec.metadata["changelog_uri"] = "https://github.com/patrick204nqh/class-metrix/blob/master/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .github appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Development dependencies
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "rubocop", "~> 1.0"
  spec.add_development_dependency "steep", "~> 1.0"
  spec.add_development_dependency "rbs", "~> 3.0"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
  spec.metadata["rubygems_mfa_required"] = "true"
end
