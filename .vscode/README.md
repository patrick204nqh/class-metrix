# VS Code Configuration for ClassMetrix

## 🎯 Overview

This directory contains comprehensive VS Code configuration for the ClassMetrix Ruby gem development with full RBS (Ruby Signature) and Steep type checking integration.

## 📦 Extensions

### Required Extensions

- **Ruby LSP** (`shopify.ruby-lsp`) - Primary Ruby language support
- **RBS Syntax** (`soutaro.rbs-syntax`) - RBS file syntax highlighting
- **Steep VS Code** (`soutaro.steep-vscode`) - Type checking integration
- **RBS Snippets** (`mateuszdrewniak.rbs-snippets`) - Code snippets for RBS

### Optional Extensions

- **Ruby Debugger** (`koichisasada.vscode-rdbg`) - Debugging support
- **GitLens** (`eamodio.gitlens`) - Enhanced Git integration
- **Markdown All in One** (`yzhang.markdown-all-in-one`) - Documentation support

## ⚙️ Settings Configuration

### Ruby Language Support

- **Format on Save**: Enabled with RuboCop
- **Ruby LSP**: Full feature set enabled
- **Semantic Highlighting**: Enabled for both Ruby and RBS files

### RBS Type Checking

- **Steep Integration**: Real-time type checking
- **Diagnostics**: Enabled for immediate feedback
- **File Associations**: `.rbs` files properly recognized

### Code Quality

- **RuboCop**: Integrated for code formatting and linting
- **Auto-fix on Save**: Automatic code corrections

## 🛠️ Available Tasks

### Ruby Development Tasks

- **`Ctrl+Shift+P` → "Tasks: Run Task"**

| Task                        | Description                 | Shortcut               |
| --------------------------- | --------------------------- | ---------------------- |
| `Rubocop: Check`            | Lint all Ruby files         | -                      |
| `Rubocop: Fix`              | Auto-fix all RuboCop issues | `Ctrl+Shift+R, Ctrl+R` |
| `Rubocop: Fix Current File` | Fix current file only       | -                      |
| `RSpec: Run All Tests`      | Run entire test suite       | -                      |
| `RSpec: Run Current File`   | Run tests for current file  | -                      |

### Type Checking Tasks

| Task                       | Description                 | Shortcut               |
| -------------------------- | --------------------------- | ---------------------- |
| `RBS: Validate`            | Validate RBS syntax         | `Ctrl+Shift+R, Ctrl+V` |
| `RBS: Generate Prototypes` | Generate RBS from Ruby code | -                      |
| `Steep: Type Check`        | Run type checking           | `Ctrl+Shift+R, Ctrl+S` |
| `Steep: Watch Mode`        | Continuous type checking    | `Ctrl+Shift+R, Ctrl+W` |

### Build Tasks

| Task             | Description              |
| ---------------- | ------------------------ |
| `Bundle Install` | Install gem dependencies |

## ⌨️ Keyboard Shortcuts

### Custom Shortcuts

- **`Ctrl+Shift+R, Ctrl+V`**: RBS Validate
- **`Ctrl+Shift+R, Ctrl+S`**: Steep Type Check
- **`Ctrl+Shift+R, Ctrl+W`**: Steep Watch Mode
- **`Ctrl+Shift+R, Ctrl+R`**: RuboCop Fix

### Usage Pattern

1. Press `Ctrl+Shift+R` to enter "Ruby mode"
2. Press the second key for the specific action

## 📝 Code Snippets

### RBS Snippets

- **`rbsclass`**: Complete RBS class template
- **`rbsmodule`**: RBS module template
- **`rbsmethod`**: Method signature
- **`rbsattr_reader`**: Attribute reader
- **`rbsattr_writer`**: Attribute writer
- **`rbsattr_accessor`**: Attribute accessor

### Usage

1. Type snippet prefix in `.rbs` file
2. Press `Tab` to expand
3. Use `Tab` to navigate through placeholders

## 🚀 Getting Started

### 1. Install Extensions

VS Code will prompt to install recommended extensions when you open the workspace.

### 2. Verify Setup

1. Open any `.rb` file - should have Ruby LSP support
2. Open any `.rbs` file - should have syntax highlighting
3. Run `Ctrl+Shift+R, Ctrl+S` - should type check without errors

### 3. Start Development

1. Use `Ctrl+Shift+R, Ctrl+W` to start watch mode
2. Edit Ruby files - see real-time type checking
3. Use code snippets for rapid RBS development

## 📊 Current Status

✅ **Type Safety**: 100% (0 Steep errors)
✅ **RBS Coverage**: Complete for all extractors
✅ **VS Code Integration**: Fully configured
✅ **Development Workflow**: Optimized

---

This VS Code setup provides a complete Ruby development environment with modern type checking capabilities.
