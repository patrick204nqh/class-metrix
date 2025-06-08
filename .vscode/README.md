# VS Code Development Environment for ClassMetrix

## 🎯 Overview

This directory contains a comprehensive VS Code development environment for the ClassMetrix Ruby gem, featuring modern Ruby development practices with full type safety through RBS and Steep integration.

## 🌟 Key Features

- **🔧 Complete Ruby LSP Integration** - Full language support with intelligent code completion
- **🔍 Real-time Type Checking** - Steep integration with live error detection
- **📝 RBS Type Annotations** - Full support for Ruby signature files
- **🚀 Auto-formatting** - RuboCop integration with format-on-save
- **⌨️ Custom Keyboard Shortcuts** - Optimized development workflow
- **🧪 Integrated Testing** - One-click RSpec test execution
- **🛠️ Smart Problem Matching** - VS Code integration for all tools

## 📦 Extensions Configuration

### Required Extensions (Auto-installed)

Our `extensions.json` automatically recommends these essential extensions:

- **Ruby LSP** (`shopify.ruby-lsp`) - Primary Ruby language server
- **Steep VS Code** (`soutaro.steep-vscode`) - Real-time type checking
- **Ruby Debugger** (`koichisasada.vscode-rdbg`) - Advanced debugging support

### Productivity Extensions

- **Prettier** (`esbenp.prettier-vscode`) - Markdown and JSON formatting
- **GitLens** (`eamodio.gitlens`) - Enhanced Git integration
- **YAML Support** (`redhat.vscode-yaml`) - YAML file support
- **EditorConfig** (`editorconfig.editorconfig`) - Consistent editor settings

## ⚙️ Intelligent Settings Configuration

### Ruby Language Support

Our settings provide optimal Ruby development experience:

```json
{
  "ruby.format": "rubocop", // Use RuboCop for formatting
  "ruby.useLanguageServer": true, // Enable Ruby LSP
  "ruby.intellisense": "rubyLsp", // Intelligent code completion
  "editor.formatOnSave": true, // Auto-format on save
  "editor.semanticHighlighting.enabled": true // Enhanced syntax highlighting
}
```

### File-Specific Configurations

#### Ruby Files (`.rb`, `.gemspec`, `Rakefile`)

- **Formatter**: Ruby LSP with RuboCop
- **Tab Size**: 2 spaces
- **Line Length**: 140 characters
- **Auto-fix**: RuboCop issues on save

#### RBS Files (`.rbs`)

- **Formatter**: RBS syntax formatter
- **Tab Size**: 2 spaces
- **Line Length**: 120 characters
- **Semantic Highlighting**: Enabled

#### Markdown Files (`.md`)

- **Formatter**: Prettier
- **Word Wrap**: Enabled
- **Tab Size**: 2 spaces

### Type Checking Integration

- **Steep**: Real-time type checking with diagnostics
- **RBS Validation**: Automatic signature file validation
- **Error Integration**: Problems panel integration

## 🛠️ Available Tasks

Access tasks via `Ctrl+Shift+P` → "Tasks: Run Task" or use keyboard shortcuts:

### Ruby Development Tasks

| Task                          | Description                               | Group |
| ----------------------------- | ----------------------------------------- | ----- |
| **Rubocop: Check**            | Lint all Ruby files with problem matching | Test  |
| **Rubocop: Fix**              | Auto-fix all RuboCop issues               | Build |
| **Rubocop: Fix Current File** | Fix only the current file                 | Build |
| **RSpec: Run All Tests**      | Execute entire test suite                 | Test  |
| **RSpec: Run Current File**   | Run tests for current file only           | Test  |
| **Bundle Install**            | Install gem dependencies                  | Build |

### Type Checking & RBS Tasks

| Task                         | Description                              | Group |
| ---------------------------- | ---------------------------------------- | ----- |
| **RBS: Validate**            | Validate RBS syntax with error detection | Test  |
| **RBS: Generate Prototypes** | Generate RBS from Ruby code              | Build |
| **Steep: Type Check**        | Run one-time type checking               | Test  |
| **Steep: Watch Mode**        | Continuous type checking (background)    | Build |
| **Steep: Watch All Targets** | Watch all configured targets             | Build |

### Problem Matchers

All tasks include intelligent problem matchers that integrate errors directly into VS Code's Problems panel:

- **RuboCop**: File/line/column error positioning
- **RSpec**: Test failure integration
- **Steep**: Type error reporting with severity levels
- **RBS**: Syntax validation errors

## ⌨️ Custom Keyboard Shortcuts

Our workflow uses a two-key chord system starting with `Ctrl+Shift+R`:

### Primary Shortcuts

| Shortcut               | Task                  | Description                    |
| ---------------------- | --------------------- | ------------------------------ |
| `Ctrl+Shift+R, Ctrl+V` | **RBS: Validate**     | Validate type signatures       |
| `Ctrl+Shift+R, Ctrl+S` | **Steep: Type Check** | Run type checking              |
| `Ctrl+Shift+R, Ctrl+W` | **Steep: Watch Mode** | Start continuous type checking |
| `Ctrl+Shift+R, Ctrl+R` | **Rubocop: Fix**      | Auto-fix code style issues     |

### Usage Pattern

1. **Press `Ctrl+Shift+R`** to enter "Ruby development mode"
2. **Press the second key** for the specific action
3. **View results** in the integrated terminal or Problems panel

## 🚀 Getting Started

### 1. Automatic Extension Installation

When you open this workspace in VS Code, you'll be prompted to:

- Install recommended extensions
- Enable workspace settings
- Configure the development environment

### 2. Verify Your Setup

#### Basic Functionality Check

1. **Open any `.rb` file** → Should show Ruby LSP features (autocompletion, hover info)
2. **Open any `.rbs` file** → Should have syntax highlighting and validation
3. **Save a Ruby file** → Should auto-format with RuboCop

#### Test Keyboard Shortcuts

1. **Press `Ctrl+Shift+R, Ctrl+S`** → Should run type checking
2. **Press `Ctrl+Shift+R, Ctrl+W`** → Should start watch mode
3. **Press `Ctrl+Shift+R, Ctrl+V`** → Should validate RBS files

### 3. Development Workflow

#### For Active Development

```bash
# Start continuous type checking
Ctrl+Shift+R, Ctrl+W

# Make your changes...
# Files auto-format on save
# See real-time type checking feedback
```

#### For Code Review

```bash
# Check all types
Ctrl+Shift+R, Ctrl+S

# Fix all style issues
Ctrl+Shift+R, Ctrl+R

# Validate RBS signatures
Ctrl+Shift+R, Ctrl+V
```

## 🔧 Advanced Configuration

### Debug Configuration

The included `launch.json` provides Ruby debugging setup:

- **Ruby Debug** - Full debugging support with breakpoints
- **RSpec Debug** - Debug individual test files
- **Integration** with `vscode-rdbg` extension

### Workspace Settings

Key workspace-specific settings:

```json
{
  "files.autoSave": "onFocusChange", // Save when switching files
  "files.trimTrailingWhitespace": true, // Clean trailing spaces
  "files.insertFinalNewline": true, // Ensure final newline
  "breadcrumbs.enabled": true, // Show code breadcrumbs
  "workbench.editor.enablePreview": false // Always open new tabs
}
```

### File Associations

Automatic recognition for Ruby ecosystem files:

- `*.gemspec` → Ruby
- `Gemfile` → Ruby
- `Rakefile` → Ruby
- `Steepfile` → Ruby
- `*.rbs` → RBS
- `.rubocop.yml` → YAML

## 📊 Development Status

### Type Safety Status

✅ **RBS Coverage**: Complete type annotations for all public APIs
✅ **Steep Integration**: Real-time type checking with zero errors
✅ **Problem Matching**: All type errors appear in VS Code Problems panel

### Code Quality Status

✅ **RuboCop Integration**: Auto-formatting and linting on save
✅ **Test Integration**: One-click RSpec execution with results
✅ **Git Integration**: GitLens for enhanced version control

### Workflow Optimization

✅ **Keyboard Shortcuts**: Efficient two-key chord system
✅ **Background Tasks**: Watch mode for continuous feedback
✅ **Smart Defaults**: Optimized settings for Ruby development

## 🛠️ Troubleshooting

### Common Issues

#### Extensions Not Loading

- Ensure you've accepted the workspace extension recommendations
- Restart VS Code after installing extensions
- Check VS Code version compatibility

#### Type Checking Not Working

- Verify Steep is in your Gemfile: `gem 'steep', '~> 1.0'`
- Run `bundle install` to ensure dependencies
- Check that `Steepfile` exists in project root

#### RuboCop Not Formatting

- Ensure `.rubocop.yml` configuration exists
- Install RuboCop: `gem install rubocop`
- Check Ruby LSP is using RuboCop formatter

### Debug Commands

```bash
# Check Ruby LSP status
Ruby LSP: Show Output Channel

# Verify Steep configuration
bundle exec steep check --debug

# Test RuboCop configuration
bundle exec rubocop --version
```

## 📚 Additional Resources

- **[Ruby LSP Documentation](https://shopify.github.io/ruby-lsp/)**
- **[Steep Type Checker](https://github.com/soutaro/steep)**
- **[RBS Documentation](https://github.com/ruby/rbs)**
- **[RuboCop Configuration](https://docs.rubocop.org/)**

---

This VS Code setup provides a modern, type-safe Ruby development environment optimized for the ClassMetrix gem development workflow.
