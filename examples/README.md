# ClassMetrix Examples

This directory contains comprehensive examples demonstrating all features of the ClassMetrix gem, organized from basic to advanced real-world scenarios.

## 🎯 Quick Start

If you're new to ClassMetrix, start with the basic examples:

```bash
# Run basic examples in order
ruby examples/basic/01_simple_constants.rb
ruby examples/basic/02_simple_methods.rb
ruby examples/basic/03_multi_type_extraction.rb
```

## 📁 Directory Structure

### `/basic/` - Getting Started
Perfect for learning the core concepts and API.

- **`01_simple_constants.rb`** - Extract and compare constants across classes
  - Basic constant extraction
  - Filtering with regex and strings
  - Understanding the output format

- **`02_simple_methods.rb`** - Extract and compare class methods
  - Class method extraction
  - Handling different return types (strings, numbers, booleans, arrays)
  - Method filtering techniques

- **`03_multi_type_extraction.rb`** - Combine constants and methods in one table
  - Multi-type extraction with Type column
  - Comparing constants vs methods with similar names
  - Understanding behavior differences

### `/advanced/` - Powerful Features
Advanced features for complex scenarios.

- **`hash_expansion.rb`** - Hash value expansion into sub-rows
  - Normal vs expanded hash display
  - Hash key comparison across classes
  - Mixed data type handling
  - Multi-type extraction with expansion

- **`error_handling.rb`** - Graceful error handling
  - Methods that raise exceptions
  - Missing constants and methods
  - Boolean and nil value processing
  - Error indicators and recovery

### `/real_world/` - Production Examples
Real-world scenarios you might encounter.

- **`microservices_audit.rb`** - Complete microservices configuration audit
  - Service metadata comparison
  - Feature flag consistency analysis
  - Database and cache configuration audits
  - Performance metrics comparison
  - Security configuration analysis

## 🚀 Running Examples

Each example is self-contained and can be run independently:

```bash
# Run any example directly
ruby examples/basic/01_simple_constants.rb
ruby examples/advanced/hash_expansion.rb
ruby examples/real_world/microservices_audit.rb
```

## 📊 Example Output

All examples generate markdown tables that look like this:

```markdown
| Constant     | UserService | OrderService | PaymentService |
|--------------|-------------|--------------|----------------|
| SERVICE_NAME | user-service| order-service| payment-service|
| VERSION      | 2.1.0       | 1.8.5        | 3.0.1          |
| PORT         | 8001        | 8002         | 8003           |
```

With hash expansion:
```markdown
| Method         | UserService | OrderService | PaymentService |
|----------------|-------------|--------------|----------------|
| database_config| 📋 7 keys   | 📋 8 keys    | 📋 8 keys      |
|   └─ host      | user-db...  | order-db...  | payment-db...  |
|   └─ port      | 5432        | 5432         | 5432           |
|   └─ ssl       | true        | true         | true           |
```

## 🛠️ Building Your Own Examples

Use these examples as templates for your own analysis:

```ruby
require_relative "../lib/class_metrix"

# Define your classes...
class MyService
  CONFIG_SETTING = "value"
  
  def self.some_method
    "result"
  end
end

# Extract and compare
result = ClassMetrix.extract(:constants, :class_methods)
  .from([MyService, AnotherService])
  .filter(/CONFIG|method/)
  .expand_hashes
  .handle_errors
  .to_markdown("my_analysis.md")

puts result
```

## 📝 Generated Reports

Many examples save their output to markdown files:

- `config_analysis_expanded.md` - Hash expansion demo output
- `error_analysis_report.md` - Error handling demo output  
- `microservices_audit_report.md` - Complete microservices audit
- `service_analysis_report.md` - Service comparison report

## 🎓 Learning Path

1. **Start with Basic Examples** - Learn the core API and concepts
2. **Try Advanced Features** - Explore hash expansion and error handling
3. **Study Real-World Examples** - See practical applications
4. **Build Your Own** - Apply ClassMetrix to your specific use cases

## 💡 Use Case Ideas

- **Configuration Management**: Compare settings across environments
- **API Analysis**: Compare method signatures and return types
- **Feature Flag Audits**: Ensure consistency across services
- **Class Architecture Review**: Compare similar classes for consistency
- **Microservices Governance**: Standardize configurations across services
- **Legacy Code Analysis**: Understand differences between old and new implementations

## 🤝 Contributing Examples

Have a great ClassMetrix use case? Consider contributing an example!

1. Create a new file in the appropriate directory
2. Follow the existing example structure
3. Include clear comments and output explanations
4. Add an entry to this README

Happy analyzing! 🎉 