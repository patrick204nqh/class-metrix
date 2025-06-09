# ClassMetrix

[![Gem Version](https://badge.fury.io/rb/class-metrix.svg)](https://badge.fury.io/rb/class-metrix)
[![CI](https://github.com/patrick204nqh/class-metrix/actions/workflows/main.yml/badge.svg)](https://github.com/patrick204nqh/class-metrix/actions/workflows/main.yml)
[![Documentation](https://img.shields.io/badge/docs-rubydoc.info-blue.svg)](https://rubydoc.info/gems/class-metrix)
[![Code Coverage](https://qlty.sh/badges/df5bf564-68c2-4484-84bd-70f705e58f1b/test_coverage.svg)](https://qlty.sh/gh/patrick204nqh/projects/class-metrix)
[![Maintainability](https://qlty.sh/badges/df5bf564-68c2-4484-84bd-70f705e58f1b/maintainability.svg)](https://qlty.sh/gh/patrick204nqh/projects/class-metrix)

**ClassMetrix** is a Ruby gem that extracts and compares class behaviors (constants, class methods, and more) across multiple classes, generating clean markdown reports for analysis, documentation, and compliance auditing.

> **Why "Metrix"?** Short for "metrics" - measuring and analyzing class behaviors.

## ✨ Features

- **🔍 Multi-Type Extraction**: Constants, class methods, and more
- **🏗️ Comprehensive by Default**: Includes inheritance and modules automatically
- **🎯 Flexible Scanning**: Use `strict()` for class-only or `with_private()` for private members
- **📊 Hash Expansion**: Expand hash values into readable sub-rows
- **📝 Rich Reports**: Professional markdown and CSV output with full configuration
- **🔒 Type Safe**: Full RBS type annotations with Steep type checking

## 🚀 Quick Start

### Installation

```ruby
gem 'class-metrix'
```

### Basic Usage

```ruby
# Extract constants from multiple classes (comprehensive by default)
ClassMetrix.extract(:constants)
  .from([User, Admin, Guest])
  .to_markdown

# Class-only scanning (exclude inheritance & modules)
ClassMetrix.extract(:constants)
  .from([User, Admin, Guest])
  .strict
  .to_markdown

# Advanced example with multiple features
ClassMetrix.extract(:constants, :class_methods)
  .from([DatabaseConfig, RedisConfig, S3Config])
  .with_private
  .filter(/config$/)
  .expand_hashes
  .handle_errors
  .to_markdown("audit_report.md",
    title: "Service Configuration Audit",
    show_missing_summary: true
  )
```

## 📖 API Reference

### Core Methods

- **`.extract(types)`** - Extract constants, class_methods, or both
- **`.from(classes)`** - Specify which classes to analyze
- **`.strict`** - Class-only scanning (exclude inheritance & modules)
- **`.with_private`** - Include private methods and constants
- **`.filter(patterns)`** - Filter behaviors by regex patterns
- **`.expand_hashes`** - Expand hash values into sub-rows
- **`.handle_errors`** - Graceful error handling
- **`.debug(level)`** - Enable debug logging (`:basic`, `:detailed`, `:verbose`)

### Output Formats

```ruby
# Markdown output
.to_markdown("report.md", title: "Custom Title", footer_style: :detailed)

# CSV output
.to_csv("data.csv", flatten_hashes: true, separator: ";")
```

## 🎯 Common Use Cases

### Configuration Audit

```ruby
# Compare configuration across microservices
services = [DatabaseService, RedisService, S3Service]

ClassMetrix.extract(:constants, :class_methods)
  .from(services)
  .filter(/CONFIG/, /timeout/)
  .expand_hashes
  .to_markdown("microservices_audit.md")
```

### API Compatibility Check

```ruby
# Check API compatibility across versions
apis = [V1::UsersAPI, V2::UsersAPI, V3::UsersAPI]

ClassMetrix.extract(:class_methods)
  .from(apis)
  .filter(/^endpoint_/, /^validate_/)
  .handle_errors
  .to_markdown("api_compatibility.md", show_missing_summary: true)
```

### Policy Comparison

```ruby
# Compare authorization policies
ClassMetrix.extract(:constants)
  .from([UserPolicy, AdminPolicy, ModeratorPolicy])
  .filter(/^PERMISSION_/, /^ROLE_/)
  .to_markdown("policy_comparison.md")
```

## 📚 Documentation

- **[Examples](examples/)** - Comprehensive usage examples
- **[Configuration Guide](docs/CONFIGURATION.md)** - Detailed configuration options
- **[Architecture](docs/ARCHITECTURE.md)** - Technical architecture overview
- **[Changelog](CHANGELOG.md)** - Version history and changes

## 🧪 Development

```bash
# Clone and setup
git clone https://github.com/patrick204nqh/class-metrix.git
cd class-metrix
bundle install

# Run tests and type checking
bundle exec rspec
bundle exec steep check
bundle exec rubocop
```

## 📋 Requirements

- **Ruby 3.1+** (Required for full RBS and Steep support)
- **No runtime dependencies** (Pure Ruby implementation)

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -am 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This gem is available as open source under the terms of the [MIT License](LICENSE.txt).
