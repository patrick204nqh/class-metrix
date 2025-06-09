# ClassMetrix Examples

This directory contains examples demonstrating ClassMetrix features, from basic usage to advanced inheritance and module analysis.

## 🎯 Quick Start

New to ClassMetrix? Start with these examples:

```bash
ruby examples/basic_usage.rb              # Basic constants and methods
ruby examples/inheritance_and_modules.rb  # Inheritance and module analysis
```

## 📁 Available Examples

### Core Examples

- **`basic_usage.rb`** - Basic constant and method extraction

  - Simple class comparison
  - Filtering and multi-type extraction
  - Hash expansion basics

- **`inheritance_and_modules.rb`** - Inheritance and module analysis
  - Class inheritance support
  - Module inclusion analysis
  - Combined inheritance and module extraction

### Advanced Examples

- **`csv_output_demo.rb`** - CSV output format demonstration
- **`/advanced/`** - Complex hash expansion scenarios
- **`/basic/`** - Step-by-step learning examples
- **`/real_world/`** - Production use case examples

## 🚀 Core Functionality

### Basic Extraction

```ruby
require_relative "../lib/class_metrix"

# Extract constants from multiple classes (comprehensive by default)
ClassMetrix.extract(:constants)
           .from([User, Admin])
           .to_markdown

# Class-only extraction (excludes inheritance & modules)
ClassMetrix.extract(:constants)
           .from([User, Admin])
           .strict
           .to_markdown

# Extract class methods (comprehensive by default)
ClassMetrix.extract(:class_methods)
           .from([DatabaseService, CacheService])
           .to_markdown

# Combined extraction with filtering
ClassMetrix.extract(:constants, :class_methods)
           .from([Class1, Class2])
           .filter(/config/)
           .to_markdown
```

### Inheritance & Module Analysis

```ruby
# Include inherited constants and methods
ClassMetrix.extract(:constants, :class_methods)
           .from([ChildClass])
           .include_inherited
           .to_markdown

# Include module constants and methods
ClassMetrix.extract(:constants, :class_methods)
           .from([ClassWithModules])
           .include_modules
           .to_markdown

# Complete analysis: own + inherited + modules
ClassMetrix.extract(:constants, :class_methods)
           .from([ComplexClass])
           .include_all
           .to_markdown
```

### Advanced Features

```ruby
# Hash expansion for detailed analysis
ClassMetrix.extract(:constants, :class_methods)
           .from([ConfigClass])
           .expand_hashes
           .to_markdown

# Hash expansion (main rows only - default)
ClassMetrix.extract(:class_methods)
           .from([ServiceClass])
           .expand_hashes
           .to_markdown

# Show only key rows (detailed view)
ClassMetrix.extract(:class_methods)
           .from([ServiceClass])
           .expand_hashes
           .show_only_keys
           .to_markdown

# Show both main and key rows
ClassMetrix.extract(:class_methods)
           .from([ServiceClass])
           .expand_hashes
           .show_expanded_details
           .to_markdown

# Error handling for robust extraction
ClassMetrix.extract(:class_methods)
           .from([ClassWithErrors])
           .handle_errors
           .to_markdown

# Save to file
ClassMetrix.extract(:constants)
           .from([Class1, Class2])
           .to_markdown("analysis.md")
```

## 📊 Example Output

### Basic Comparison

```markdown
| Constant | User | Admin |
| -------- | ---- | ----- |
| ROLE     | user | admin |
| TIMEOUT  | 3600 | 7200  |
```

### With Inheritance

```markdown
| Constant        | DatabaseService | CacheService |
| --------------- | --------------- | ------------ |
| SERVICE_NAME    | database        | cache        |
| SERVICE_VERSION | 1.0             | 1.0          |
| DEFAULT_TIMEOUT | 30              | 30           |
```

### Hash Expansion

```markdown
| Method      | Service1  | Service2       |
| ----------- | --------- | -------------- |
| config      | {...}     | {...}          |
| config.host | localhost | production.com |
| config.port | 3000      | 443            |
| config.ssl  | ❌        | ✅             |
```

## 🛠️ API Reference

### Extraction Types

- `:constants` - Class constants
- `:class_methods` - Class methods

### Options

- `.from(classes)` - Classes to analyze (array)
- `.filter(pattern)` - Filter by name (regex or string)
- `.include_inherited` - Include parent class behaviors
- `.include_modules` - Include module behaviors
- `.include_all` - Include inherited + modules
- `.expand_hashes` - Expand hash values (shows main rows by default)
- `.show_only_main` - Show only main rows (collapsed hashes) - **Default**
- `.show_only_keys` - Show only key rows (expanded details)
- `.show_expanded_details` - Show both main and key rows
- `.handle_errors` - Graceful error handling
- `.to_markdown(file)` - Generate markdown output
- `.to_csv(file)` - Generate CSV output

## 💡 Common Use Cases

- **Configuration Analysis** - Compare settings across classes
- **Inheritance Review** - Analyze class hierarchies
- **Module Usage Audit** - Track module inclusion patterns
- **API Comparison** - Compare method signatures
- **Feature Flag Analysis** - Ensure consistency
- **Service Configuration** - Microservices governance

## 🎓 Learning Path

1. Run `basic_usage.rb` to understand core concepts
2. Try `inheritance_and_modules.rb` for advanced features
3. Explore `/basic/` examples for step-by-step learning
4. Check `/real_world/` for production scenarios
5. Build custom analysis for your use cases

## 📝 Running Examples

```bash
# Basic functionality
ruby examples/basic_usage.rb

# Inheritance and modules
ruby examples/inheritance_and_modules.rb

# Advanced features
ruby examples/advanced/hash_expansion.rb

# Real-world scenarios
ruby examples/real_world/microservices_audit.rb
```
