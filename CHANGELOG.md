# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.0.1] - 2025-06-08

## [1.0.0] - 2025-06-07

### 🎉 Major Release - Production Ready

This marks the first stable release of ClassMetrix with a comprehensive feature set and robust architecture.

### Added

- **🐛 Advanced Debug System**: Comprehensive debug logging with three levels (`:basic`, `:detailed`, `:verbose`)
  - Safe object inspection for problematic objects with broken `inspect`/`to_s` methods
  - Smart hash detection to prevent issues with proxy objects
  - Component-specific debug loggers for targeted troubleshooting
  - Error-resistant operations with graceful degradation
- **📊 Enhanced Hash Expansion**: Multiple hash expansion modes for different analysis needs
  - `show_only_main`: Show collapsed hash representations (default)
  - `show_only_keys`: Show only expanded key rows for detailed analysis
  - `show_expanded_details`: Show both main and expanded rows
  - Support for nested hash structures with proper truncation
- **🏗️ Refactored Architecture**: Clean separation of concerns and improved maintainability
  - Modular extractor system with dedicated extractors for each type
  - Shared table builders for consistent formatting across output formats
  - Centralized value processor for robust value handling
  - Component-based formatter architecture
- **⚙️ Enhanced Configuration**: More granular control over extraction and formatting
  - Hash expansion display options (`hide_main_row`, `hide_key_rows`)
  - Improved inheritance and module inclusion handling
  - Better error handling and recovery mechanisms
- **🔧 VS Code Integration**: Complete development environment setup
  - Auto-formatting with Rubocop integration
  - Task definitions for common operations
  - Debug configurations for Ruby and RSpec
  - Recommended extensions for optimal development experience

### Enhanced

- **Hash Processing**: Robust handling of complex nested structures and edge cases
- **CSV Export**: Improved hash flattening with better column organization
- **Error Handling**: More resilient extraction with detailed error reporting
- **Performance**: Optimized table building and value processing
- **Documentation**: Comprehensive examples and architecture documentation

### Fixed

- Parameter list optimization in `MultiTypeExtractor` (reduced from 6 to 5 parameters)
- Method length optimization in `ValueProcessor.process_for_csv` (reduced from 28 to 25 lines)
- Improved hash detection to prevent issues with ActiveRecord and other proxy objects
- Better handling of objects with problematic method behaviors

### Technical Improvements

- **Safety-First Design**: All operations wrapped with exception handling
- **Debug Integration**: Every component includes comprehensive debug logging
- **Type Safety**: Strict hash detection prevents issues with duck-typed objects
- **Modular Design**: Easy to extend with new extraction types and formatters
- **Test Coverage**: Extensive test suite covering edge cases and error conditions

### Breaking Changes

- Hash expansion now defaults to `show_only_main` (was `show_expanded_details`)
- Some internal API changes for better consistency (affects custom extensions)

## [0.1.2] - 2025-06-07

### Added

- GitHub Actions CI/CD workflow for automated releases
- Multi-version Ruby testing (3.1, 3.2, 3.3)
- Automated gem publishing to RubyGems
- Version consistency checking

### Changed

- Improved CI workflow with better test coverage

## [0.1.0] - 2025-06-07

### Added

- Initial release of ClassMetrix
- Constants extraction from Ruby classes
- Class methods extraction and comparison
- Multi-type extraction support
- Hash expansion functionality
- Error handling for missing methods/constants
- Markdown report generation
- CSV export with hash flattening
- Filtering capabilities
- Comprehensive test suite
- RuboCop integration

### Features

- 🔍 Multi-Type Extraction: Constants, class methods, and more
- 📊 Hash Expansion: Expand hash values into readable sub-rows
- 🛡️ Error Handling: Graceful handling of missing methods and constants
- 📝 Rich Markdown Reports: Professional reports with configurable components
- 📄 CSV Export: Data analysis-friendly CSV output with hash flattening
- ⚙️ Highly Configurable: Customize every aspect of the output
- 🚀 Simple API: Chainable, intuitive interface
