# ClassMetrix

Simple extraction and comparison of Ruby class behaviors (constants and class methods) with clean markdown table output.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'class-metrix'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install class-metrix

## Usage

ClassMetrix provides a simple, chainable API for extracting and comparing class behaviors:

### Basic Usage

```ruby
require 'class_metrix'

# Extract constants from multiple classes
ClassMetrix.extract(:constants)
  .from([User, Admin, Guest])
  .to_markdown

# Extract class methods
ClassMetrix.extract(:class_methods)
  .from([User, Admin, Guest])
  .to_markdown
```

### Filtering

```ruby
# Filter constants by pattern
ClassMetrix.extract(:constants)
  .from([User, Admin, Guest])
  .filter(/^ROLE/)
  .to_markdown

# Filter methods by pattern
ClassMetrix.extract(:class_methods)
  .from([User, Admin, Guest])
  .filter(/config$/)
  .to_markdown
```

### Multi-Type Extraction

```ruby
# Extract multiple behavior types in one table
ClassMetrix.extract(:constants, :class_methods)
  .from([User, Admin, Guest])
  .filter(/ROLE|authenticate/)
  .to_markdown
```

### Error Handling

```ruby
# Handle extraction errors gracefully
ClassMetrix.extract(:class_methods)
  .from([User, Admin, Guest])
  .handle_errors
  .to_markdown
```

### Save to File

```ruby
# Save output to file
ClassMetrix.extract(:constants)
  .from([User, Admin, Guest])
  .to_markdown('class_comparison.md')
```

## Example Output

### Constants Extraction
```markdown
| Constant            | User | Admin              | Guest |
|---------------------|------|--------------------|-------|
| ROLE_NAME           | user | admin              | guest |
| DEFAULT_PERMISSIONS | read | read, write, admin |       |
| MAX_LOGIN_ATTEMPTS  | 3    | ❌                  | ❌     |
```

### Class Methods Extraction
```markdown
| Method              | User  | Admin      | Guest |
|---------------------|-------|------------|-------|
| authenticate_method | basic | two_factor | none  |
| session_timeout     | 3600  | 7200       | 1800  |
```

### Multi-Type Extraction
```markdown
| Type         | Behavior            | User  | Admin      | Guest |
|--------------|---------------------|-------|------------|-------|
| Constant     | ROLE_NAME           | user  | admin      | guest |
| Class Method | authenticate_method | basic | two_factor | none  |
```

## Value Types

ClassMetrix handles all Ruby value types with visual indicators:

- **Strings/Numbers**: Displayed as-is
- **Arrays**: Joined with commas
- **Hashes**: Displayed as hash notation
- **true**: Displayed as ✅
- **false**: Displayed as ❌
- **nil**: Displayed as ❌
- **Errors**: Displayed as ⚠️ with error type

## API Reference

### ClassMetrix.extract(*types)

Creates a new extractor for the specified behavior types.

**Parameters:**
- `types` - One or more extraction types (`:constants`, `:class_methods`)

**Returns:** `ClassMetrix::Extractor` instance

### Extractor Methods

#### #from(classes)
Specifies the classes to extract behaviors from.

**Parameters:**
- `classes` - Array of Class objects or class name strings

**Returns:** Self (chainable)

#### #filter(pattern)
Filters behaviors by name pattern.

**Parameters:**
- `pattern` - Regex or String pattern to match behavior names

**Returns:** Self (chainable)

#### #handle_errors
Enables graceful error handling for failed extractions.

**Returns:** Self (chainable)

#### #expand_hashes
Enables hash value expansion into sub-rows (future feature).

**Returns:** Self (chainable)

#### #to_markdown(filename = nil)
Generates markdown table output.

**Parameters:**
- `filename` - Optional file path to save output

**Returns:** String containing markdown table

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/class-metrix.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
