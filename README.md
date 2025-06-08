# ClassMetrix

[![Gem Version](https://badge.fury.io/rb/class-metrix.svg)](https://badge.fury.io/rb/class-metrix)
[![CI](https://github.com/patrick204nqh/class-metrix/actions/workflows/main.yml/badge.svg)](https://github.com/patrick204nqh/class-metrix/actions/workflows/main.yml)
[![Maintainability](https://qlty.sh/badges/df5bf564-68c2-4484-84bd-70f705e58f1b/maintainability.svg)](https://qlty.sh/gh/patrick204nqh/projects/class-metrix)

**ClassMetrix** is a Ruby gem that extracts and compares class behaviors (constants, class methods, and more) across multiple classes, generating clean markdown reports for analysis, documentation, and compliance auditing.

> **Why "Metrix"?** Short for "metrics" - measuring and analyzing class behaviors.

## ✨ Features

- **🔍 Multi-Type Extraction**: Constants, class methods, and more
- **📊 Hash Expansion**: Expand hash values into readable sub-rows
- **🛡️ Error Handling**: Graceful handling of missing methods and constants
- **🐛 Debug Mode**: Detailed logging for troubleshooting and analysis
- **📝 Rich Markdown Reports**: Professional reports with configurable components
- **📄 CSV Export**: Data analysis-friendly CSV output with hash flattening
- **⚙️ Highly Configurable**: Customize every aspect of the output
- **🚀 Simple API**: Chainable, intuitive interface
- **🔒 Type Safe**: Full RBS type annotations with Steep type checking

## 🚀 Quick Start

```ruby
# Basic usage
ClassMetrix.extract(:constants)
  .from([User, Admin, Guest])
  .to_markdown

# Advanced usage with configuration
ClassMetrix.extract(:constants, :class_methods)
  .from([DatabaseConfig, RedisConfig, S3Config])
  .filter(/config$/)
  .expand_hashes
  .handle_errors
  .to_markdown("audit_report.md",
    title: "Service Configuration Audit",
    footer_style: :detailed,
    show_missing_summary: true
  )

# CSV output with hash flattening
ClassMetrix.extract(:constants)
  .from([DatabaseConfig, RedisConfig])
  .expand_hashes
  .to_csv("config_analysis.csv",
    title: "Configuration Analysis",
    flatten_hashes: true
  )
```

## 📦 Installation

Add to your Gemfile:

```ruby
gem 'class-metrix'
```

Or install directly:

```bash
gem install class-metrix
```

## 📖 Usage Guide

### Basic Extraction

#### Constants

```ruby
# Extract constants from multiple classes
ClassMetrix.extract(:constants)
  .from([User, Admin, Guest])
  .to_markdown

# Output:
# | Constant   | User     | Admin    | Guest    |
# |------------|----------|----------|----------|
# | ROLE_NAME  | 'user'   | 'admin'  | 'guest'  |
# | PERMISSION | 'read'   | 'write'  | 'read'   |
```

#### Class Methods

```ruby
# Extract class method results
ClassMetrix.extract(:class_methods)
  .from([DatabaseConfig, RedisConfig])
  .filter(/config$/)
  .to_markdown

# Output:
# | Method        | DatabaseConfig           | RedisConfig              |
# |---------------|--------------------------|--------------------------|
# | db_config     | {:host=>"localhost"}     | 🚫 Not defined           |
# | cache_config  | 🚫 Not defined           | {:host=>"redis.local"}   |
```

#### Multi-Type Extraction

```ruby
# Combine multiple extraction types in one table
ClassMetrix.extract(:constants, :class_methods)
  .from([User, Admin])
  .to_markdown

# Output:
# | Type         | Behavior    | User     | Admin    |
# |--------------|-------------|----------|----------|
# | Constant     | ROLE_NAME   | 'user'   | 'admin'  |
# | Class Method | permissions | ['read'] | ['read', 'write'] |
```

### Advanced Features

#### Hash Expansion

```ruby
# Expand hash values into readable sub-rows
ClassMetrix.extract(:constants)
  .from([DatabaseConfig, RedisConfig])
  .expand_hashes
  .to_markdown

# Output:
# | Constant    | DatabaseConfig           | RedisConfig              |
# |-------------|--------------------------|--------------------------|
# | DB_CONFIG   | {:host=>"localhost"}     | {:host=>"redis.local"}   |
# | .host       | localhost                | redis.local              |
# | .port       | 5432                     | — (missing key)          |
# | .timeout    | — (missing key)          | 30                       |
```

#### Error Handling

```ruby
# Handle missing methods and constants gracefully
ClassMetrix.extract(:class_methods)
  .from([ServiceA, ServiceB])
  .handle_errors
  .to_markdown

# Error indicators:
# 🚫 Not defined  - Constant/method doesn't exist
# 🚫 No method    - Method doesn't exist
# ⚠️ Error: msg   - Runtime error with context
# ❌              - nil or false values
# ✅              - true values
# —               - Missing hash key
```

#### Filtering

```ruby
# Filter behaviors by pattern
ClassMetrix.extract(:constants)
  .from([User, Admin, Guest])
  .filter(/^ROLE_/, /^PERMISSION_/)
  .to_markdown

# Multiple filters (OR logic)
ClassMetrix.extract(:class_methods)
  .from([ConfigA, ConfigB])
  .filter(/config$/, /setup$/)
  .to_markdown
```

#### Debug Mode

```ruby
# Enable detailed logging for troubleshooting
ClassMetrix.extract(:constants, :class_methods)
  .from([ServiceA, ServiceB])
  .expand_hashes
  .debug  # Enable debug mode (basic level)
  .to_markdown("debug_report.md")

# Different debug levels for different needs
ClassMetrix.extract(:constants)
  .from([ServiceA, ServiceB])
  .debug(:basic)    # Key decisions and summaries only
  .to_markdown

ClassMetrix.extract(:constants)
  .from([ServiceA, ServiceB])
  .debug(:detailed) # More context and intermediate steps
  .to_markdown

ClassMetrix.extract(:constants)
  .from([ServiceA, ServiceB])
  .debug(:verbose)  # Full details including individual value processing
  .to_markdown
```

**Debug Levels:**

- **`:basic`** (default) - Key decisions and summaries only
- **`:detailed`** - More context and intermediate steps
- **`:verbose`** - Full details including individual value processing

**Debug Features:**

- **Safe Object Inspection**: Handles objects with problematic `inspect`/`to_s` methods
- **Hash Detection Analysis**: Shows why objects are/aren't treated as expandable hashes
- **Smart Logging**: Reduces spam by grouping related operations and focusing on key decisions
- **Error Diagnostics**: Detailed error context for troubleshooting

#### CSV Output

```ruby
# Basic CSV output
ClassMetrix.extract(:constants)
  .from([DatabaseConfig, RedisConfig])
  .to_csv("config.csv")

# CSV with hash flattening (separate columns for each hash key)
ClassMetrix.extract(:constants)
  .from([DatabaseConfig, RedisConfig])
  .expand_hashes
  .to_csv("config_flat.csv", flatten_hashes: true)

# CSV with hash expansion (sub-rows for hash keys)
ClassMetrix.extract(:constants)
  .from([DatabaseConfig, RedisConfig])
  .expand_hashes
  .to_csv("config_expanded.csv", flatten_hashes: false)

# Custom CSV options
ClassMetrix.extract(:class_methods)
  .from([ServiceA, ServiceB])
  .to_csv(
    separator: ";",           # Use semicolon separator
    null_value: "N/A",       # Custom null value
    show_metadata: false     # No comment headers
  )
```

## ⚙️ Configuration Options

ClassMetrix offers extensive configuration options for customizing report generation:

### Markdown Report Options

```ruby
ClassMetrix.extract(:constants)
  .from([User, Admin])
  .to_markdown(
    # File and title
    "report.md",
    title: "Custom Report Title",

    # Content sections
    show_metadata: true,          # Show title and report info
    show_classes: true,           # Show "Classes Analyzed" section
    show_extraction_info: true,   # Show "Extraction Types" section
    show_missing_summary: false,  # Show missing behaviors summary

    # Footer configuration
    show_footer: true,            # Show footer
    footer_style: :detailed,      # :default, :minimal, :detailed
    show_timestamp: true,         # Include generation timestamp
    custom_footer: "Custom note", # Custom footer message

    # Table formatting
    table_style: :standard,       # :standard, :compact, :wide
    min_column_width: 3,          # Minimum column width
    max_column_width: 50,         # Maximum column width (for :compact style)

    # Missing behaviors analysis
    summary_style: :grouped       # :grouped, :flat, :detailed
  )
```

### CSV Output Options

```ruby
ClassMetrix.extract(:constants)
  .from([User, Admin])
  .to_csv(
    # File and title
    "report.csv",
    title: "Custom CSV Report",

    # Content options
    show_metadata: true,          # Show comment headers
    comment_char: "#",            # Comment character for metadata

    # CSV formatting
    separator: ",",               # Column separator (comma, semicolon, tab)
    quote_char: '"',              # Quote character
    null_value: "",               # Value for nil/missing data

    # Hash handling
    flatten_hashes: true,         # Flatten hashes into separate columns
                                  # false = expand into sub-rows
  )
```

### Footer Styles

#### Default Footer

```markdown
---

_Report generated by ClassMetrix gem_
```

#### Minimal Footer

```markdown
---

_Generated by ClassMetrix_
```

#### Detailed Footer

```markdown
---

## Report Information

- **Generated by**: [ClassMetrix gem](https://github.com/patrick204nqh/class-metrix)
- **Generated at**: 2024-01-15 14:30:25 UTC
- **Ruby version**: 3.2.0
```

### Missing Behaviors Styles

#### Grouped (Default)

```markdown
## Missing Behaviors Summary

### DatabaseConfig

- `redis_config` - 🚫 Not defined
- `cache_timeout` - 🚫 No method

### RedisConfig

- `db_config` - 🚫 Not defined
```

#### Flat

```markdown
## Missing Behaviors

- **DatabaseConfig**: `redis_config` - 🚫 Not defined
- **DatabaseConfig**: `cache_timeout` - 🚫 No method
- **RedisConfig**: `db_config` - 🚫 Not defined
```

#### Detailed

```markdown
## Missing Behaviors Analysis

**Summary**: 3 missing behaviors across 2 classes

### 🚫 Not (2 items)

- **DatabaseConfig**: `redis_config` - 🚫 Not defined
- **RedisConfig**: `db_config` - 🚫 Not defined

### 🚫 No (1 items)

- **DatabaseConfig**: `cache_timeout` - 🚫 No method
```

## 🎯 Real-World Examples

### Microservices Configuration Audit

```ruby
# Audit configuration consistency across services
services = [DatabaseService, RedisService, S3Service, AuthService]

ClassMetrix.extract(:constants, :class_methods)
  .from(services)
  .filter(/CONFIG/, /timeout/, /pool/)
  .expand_hashes
  .handle_errors
  .to_markdown("microservices_audit.md",
    title: "Microservices Configuration Audit",
    show_missing_summary: true,
    summary_style: :detailed,
    footer_style: :detailed
  )
```

### Policy Classes Comparison

```ruby
# Compare authorization policies
policies = [UserPolicy, AdminPolicy, ModeratorPolicy]

ClassMetrix.extract(:constants)
  .from(policies)
  .filter(/^PERMISSION_/, /^ROLE_/)
  .to_markdown("policy_comparison.md",
    title: "Authorization Policy Analysis",
    show_timestamp: true
  )
```

### API Version Compatibility

```ruby
# Check API compatibility across versions
apis = [V1::UsersAPI, V2::UsersAPI, V3::UsersAPI]

ClassMetrix.extract(:class_methods)
  .from(apis)
  .filter(/^endpoint_/, /^validate_/)
  .handle_errors
  .to_markdown("api_compatibility.md",
    title: "API Version Compatibility Report",
    show_missing_summary: true,
    summary_style: :flat
  )
```

## 🏗️ Architecture

ClassMetrix uses a modular component architecture for maximum flexibility:

```
MarkdownFormatter
├── HeaderComponent           # Title, classes, extraction info
├── TableComponent            # Table formatting and hash expansion
├── MissingBehaviorsComponent # Missing behavior analysis
└── FooterComponent           # Footer with various styles
```

### Key Design Principles

- **Type Safety**: All components have complete RBS type annotations
- **Modularity**: Each component is independently configurable
- **Extensibility**: Easy to add new extractors and formatters
- **Error Resilience**: Graceful handling of edge cases and errors
- **Performance**: Optimized for processing large class hierarchies

### Type System

The entire codebase is fully typed using RBS (Ruby Signature) format:

- **Public APIs**: Complete type contracts for all user-facing methods
- **Internal Components**: Type safety for all internal class interactions
- **Error Handling**: Typed exception handling with specific error types
- **Configuration**: Strongly typed configuration objects

This ensures reliability and provides excellent IDE support with autocompletion and type checking.

## 🧪 Development

ClassMetrix uses modern Ruby development practices with comprehensive type checking and VS Code integration.

### Quick Setup

```bash
# Clone the repository
git clone https://github.com/patrick204nqh/class-metrix.git
cd class-metrix

# Install dependencies
bundle install

# Run tests
bundle exec rspec

# Run type checking
bundle exec steep check

# Run linting
bundle exec rubocop

# Run examples
ruby examples/basic/01_simple_constants.rb
ruby examples/advanced/hash_expansion.rb
```

### Type Safety

ClassMetrix maintains **100% type coverage** using:

- **RBS Type Annotations**: Complete type signatures for all public APIs
- **Steep Type Checking**: Static analysis for type correctness
- **Comprehensive Type Tests**: Ensuring type safety across all components

```bash
# Check type coverage
bundle exec steep stats

# Watch mode for development
bundle exec steep watch

# Validate RBS files
bundle exec rbs validate
```

### Code Quality

- **RuboCop**: Enforced code style and best practices
- **RSpec**: Comprehensive test suite with >95% coverage
- **CI/CD**: Automated testing across Ruby 3.2+ versions

## 📋 Requirements

- **Ruby 3.1+** (Required for full RBS and Steep support)
- **No runtime dependencies** (Pure Ruby implementation)
- **Development dependencies**: RBS (~> 3.0), Steep (~> 1.0), RuboCop (~> 1.0)

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -am 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This gem is available as open source under the terms of the [MIT License](LICENSE).

## 🔗 Links

- [Documentation](https://github.com/patrick204nqh/class-metrix/wiki)
- [Examples](examples/)
- [Build Guide](BUILD_GUIDE.md)
- [VS Code Setup](.vscode/README.md) - Complete development environment setup
- [Changelog](CHANGELOG.md)
- [Release Guide](RELEASE_GUIDE.md)
