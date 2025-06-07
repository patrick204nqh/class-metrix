# VS Code Works### Ruby Support

- **Ruby LSP** (`shopify.ruby-lsp`) - Primary Ruby language server with Rubocop formatting
- **Solargraph** (`castwide.solargraph`) - Alternative Ruby IntelliSense

### Markdown Support

- **Prettier** (`esbenp.prettier-vscode`) - Primary Markdown formatter
- **Markdown All in One** (`yzhang.markdown-all-in-one`) - Comprehensive Markdown support
- **markdownlint** (`davidanson.vscode-markdownlint`) - Markdown lintingnfiguration

This folder contains VS Code workspace configuration files that help maintain consistent development environment across team members.

## Files Overview

- **settings.json**: Workspace-specific settings for Ruby and Markdown formatting
- **extensions.json**: Recommended extensions for this project
- **tasks.json**: Predefined tasks for common operations (Rubocop, RSpec)
- **launch.json**: Debug configurations for Ruby files and tests

## Required Extensions

To get the best development experience, install these recommended extensions:

### Ruby Support

- **Ruby LSP** (`shopify.ruby-lsp`) - Primary Ruby language server
- **Solargraph** (`castwide.solargraph`) - Alternative Ruby IntelliSense

### Markdown Support

- **Markdown All in One** (`yzhang.markdown-all-in-one`) - Comprehensive Markdown support
- **markdownlint** (`davidanson.vscode-markdownlint`) - Markdown linting

### General

- **EditorConfig** (`editorconfig.editorconfig`) - Consistent coding styles
- **GitLens** (`eamodio.gitlens`) - Enhanced Git capabilities

## Auto-formatting

The configuration enables automatic formatting on save for:

- **Ruby files**: Using Rubocop via Ruby LSP (Shopify.ruby-lsp)
- **Markdown files**: Using Prettier formatter
- **Format on type**: Enabled for Ruby files for real-time formatting

## Available Tasks

Access via `Ctrl+Shift+P` → "Tasks: Run Task":

- **Rubocop: Check** - Run Rubocop linting
- **Rubocop: Fix** - Auto-fix Rubocop violations
- **Rubocop: Fix Current File** - Fix violations in current file only
- **RSpec: Run All Tests** - Run complete test suite
- **RSpec: Run Current File** - Run tests for current file
- **Bundle Install** - Install/update gems

## Debug Configurations

Available debug configurations:

- **Ruby: Run Current File** - Debug the currently open Ruby file
- **RSpec: Debug Current File** - Debug tests in current file
- **RSpec: Debug All Tests** - Debug entire test suite

## Setup Instructions

1. Open this project in VS Code
2. Install recommended extensions (VS Code will prompt you)
3. Run "Bundle Install" task to ensure gems are installed
4. Start coding! Auto-formatting will work on save
