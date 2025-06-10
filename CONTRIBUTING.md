# Contributing to ClassMetrix

Thank you for your interest in contributing to ClassMetrix! 🎉

## 📋 Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Setup](#development-setup)
- [Making Changes](#making-changes)
- [Testing](#testing)
- [Code Style](#code-style)
- [Submitting Changes](#submitting-changes)
- [Release Process](#release-process)

## 📜 Code of Conduct

This project follows a code of conduct. By participating, you agree to uphold this code. Please report unacceptable behavior to patrick204nqh@gmail.com.

## 🚀 Getting Started

1. Fork the repository
2. Clone your fork: `git clone https://github.com/YOUR_USERNAME/class-metrix.git`
3. Set up the development environment (see below)

## 🛠️ Development Setup

### Prerequisites

- Ruby 3.2+
- Bundler

### Setup Steps

```bash
# Clone and navigate
git clone https://github.com/YOUR_USERNAME/class-metrix.git
cd class-metrix

# Install dependencies
bundle install

# Run setup script
bin/setup

# Verify installation
bundle exec rspec
bundle exec rubocop
bundle exec steep check
```

### Available Commands

```bash
# Testing
bundle exec rspec                    # Run all tests
bundle exec rspec spec/specific_test # Run specific test

# Code Quality
bundle exec rubocop                  # Check style
bundle exec rubocop -A               # Auto-fix style issues

# Type Checking
bundle exec rbs validate             # Validate RBS files
bundle exec steep check              # Type check with Steep

# Interactive Console
bin/console                          # Start IRB with gem loaded
```

## 🔄 Making Changes

### Branching Strategy

- `master` - Stable release branch
- `develop` - Main development branch (if used)
- Feature branches: `feature/your-feature-name`
- Bug fixes: `fix/issue-description`
- Documentation: `docs/topic-name`

### Commit Messages

Use conventional commits format:

```
type(scope): description

[optional body]

[optional footer]
```

Types:

- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation
- `style`: Code style changes
- `refactor`: Code refactoring
- `test`: Test changes
- `chore`: Build/tooling changes

Examples:

```
feat(extractors): add private method extraction support
fix(formatters): resolve markdown table alignment issue
docs(readme): update installation instructions
```

## 🧪 Testing

### Running Tests

```bash
# All tests
bundle exec rspec

# Specific file
bundle exec rspec spec/extractor_spec.rb

# With coverage
COVERAGE=true bundle exec rspec
```

### Writing Tests

- Write tests for all new functionality
- Maintain or improve test coverage
- Use descriptive test names
- Follow existing test patterns
- Test edge cases and error conditions

### Test Structure

```ruby
RSpec.describe ClassMetrix::SomeClass do
  describe '#method_name' do
    context 'when condition is met' do
      it 'performs expected behavior' do
        # Test implementation
      end
    end

    context 'when invalid input provided' do
      it 'raises appropriate error' do
        # Error testing
      end
    end
  end
end
```

## 🎨 Code Style

### Ruby Style Guide

- Follow [RuboCop](https://rubocop.org/) rules (configuration in `.rubocop.yml`)
- Use 2 spaces for indentation
- Keep lines under 120 characters
- Use descriptive variable names
- Write clear, self-documenting code

### Type Annotations

- Add RBS type signatures for new methods
- Update existing RBS files when modifying interfaces
- Ensure Steep type checking passes

### Documentation

- Document public APIs with YARD comments
- Include usage examples for complex features
- Update README.md for new functionality

## 📤 Submitting Changes

### Pull Request Process

1. **Create Feature Branch**

   ```bash
   git checkout -b feature/your-feature-name
   ```

2. **Make Changes**

   - Write code following style guidelines
   - Add comprehensive tests
   - Update documentation

3. **Validate Changes**

   ```bash
   bundle exec rspec      # All tests pass
   bundle exec rubocop    # Style checks pass
   bundle exec steep check # Type checks pass
   ```

4. **Commit Changes**

   ```bash
   git add .
   git commit -m "feat(scope): descriptive message"
   ```

5. **Push and Create PR**
   ```bash
   git push origin feature/your-feature-name
   ```
   Then create a pull request on GitHub.

### Pull Request Requirements

- [ ] All tests pass
- [ ] Code follows style guidelines
- [ ] Type checking passes
- [ ] Documentation updated
- [ ] CHANGELOG.md updated (for notable changes)
- [ ] PR template completed

### Review Process

1. Automated checks run (CI)
2. Code review by maintainers
3. Address feedback if needed
4. Approval and merge

## 🚢 Release Process

Releases are handled by maintainers:

1. Version bump in `lib/class_metrix/version.rb`
2. Update CHANGELOG.md
3. Create release PR
4. Tag and release via GitHub Actions

## 🤝 Getting Help

- 📖 Check existing documentation
- 🐛 Search existing issues
- 💬 Create a new issue for bugs/features
- 📧 Email patrick204nqh@gmail.com for sensitive matters

## 🎯 Areas for Contribution

Looking for ways to contribute? Check out:

- 🐛 [Bug reports](https://github.com/patrick204nqh/class-metrix/labels/bug)
- ✨ [Feature requests](https://github.com/patrick204nqh/class-metrix/labels/enhancement)
- 📖 [Documentation improvements](https://github.com/patrick204nqh/class-metrix/labels/documentation)
- 🧪 Test coverage improvements
- 🔧 Performance optimizations

Thank you for contributing! 🙏
