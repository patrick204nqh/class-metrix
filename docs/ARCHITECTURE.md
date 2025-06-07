# ClassMetrix Architecture

This document provides an overview of ClassMetrix's architecture, component relationships, and code flow. It will be updated whenever the architecture changes to help developers quickly understand the codebase.

## 🏗️ High-Level Architecture

ClassMetrix follows a **modular, layered architecture** with clear separation of concerns:

```mermaid
graph TD
    subgraph "Public API Layer"
        API["ClassMetrix.extract(:constants, :class_methods)<br/>.from([Class1, Class2])<br/>.include_inherited<br/>.expand_hashes<br/>.to_markdown()"]
    end
    
    subgraph "Core Extraction Layer"
        Extractor["Extractor<br/>(Coordinator)"]
        ClassResolver["Class Resolver<br/>(Utilities)"]
        ValueProcessor["Value Processor<br/>(Utilities)"]
    end
    
    subgraph "Specialized Extractors"
        ConstantsExtractor["Constants<br/>Extractor"]
        MethodsExtractor["Methods<br/>Extractor"]
        MultiTypeExtractor["Multi-Type<br/>Extractor"]
    end
    
    subgraph "Formatting Layer"
        MarkdownFormatter["Markdown<br/>Formatter"]
        CsvFormatter["CSV<br/>Formatter"]
    end
    
    subgraph "Component Layer"
        subgraph "Report Components"
            HeaderComponent["Header<br/>Component"]
            TableComponent["Table<br/>Component"]
            FooterComponent["Footer<br/>Component"]
        end
        
        subgraph "Table Sub-Components"
            TableDataExtractor["Table Data<br/>Extractor"]
            RowProcessor["Row<br/>Processor"]
            ColumnWidthCalculator["Column Width<br/>Calculator"]
            TableRenderer["Table<br/>Renderer"]
        end
    end
    
    API --> Extractor
    Extractor --> ClassResolver
    Extractor --> ValueProcessor
    Extractor --> ConstantsExtractor
    Extractor --> MethodsExtractor
    Extractor --> MultiTypeExtractor
    
    ConstantsExtractor --> MarkdownFormatter
    MethodsExtractor --> MarkdownFormatter
    MultiTypeExtractor --> MarkdownFormatter
    
    ConstantsExtractor --> CsvFormatter
    MethodsExtractor --> CsvFormatter
    MultiTypeExtractor --> CsvFormatter
    
    MarkdownFormatter --> HeaderComponent
    MarkdownFormatter --> TableComponent
    MarkdownFormatter --> FooterComponent
    
    TableComponent --> TableDataExtractor
    TableComponent --> RowProcessor
    TableComponent --> ColumnWidthCalculator
    TableComponent --> TableRenderer
    
    style API fill:#e1f5fe
    style Extractor fill:#f3e5f5
    style MarkdownFormatter fill:#e8f5e8
    style TableComponent fill:#fff3e0
```

## 📁 Directory Structure

```
lib/class_metrix/
├── class_metrix.rb                    # Main entry point
├── version.rb                         # Version information
├── extractor.rb                       # Core coordinator class
├── extractors/                        # Specialized extraction logic
│   ├── constants_extractor.rb         # Constants extraction & inheritance
│   ├── methods_extractor.rb           # Methods extraction & inheritance
│   └── multi_type_extractor.rb        # Multi-type combining logic
├── formatters/                        # Output formatting
│   ├── base/
│   │   ├── base_formatter.rb          # Base formatter class
│   │   └── base_component.rb          # Base component class
│   ├── shared/                        # Shared formatting utilities
│   │   ├── table_builder.rb           # Table building base class
│   │   ├── markdown_table_builder.rb  # Markdown table implementation
│   │   ├── csv_table_builder.rb       # CSV table implementation
│   │   └── value_processor.rb         # Value processing utilities
│   ├── components/                    # Modular components
│   │   ├── table_component/           # Refactored table components
│   │   │   ├── table_data_extractor.rb    # Data extraction logic
│   │   │   ├── row_processor.rb            # Row processing & hash expansion
│   │   │   ├── column_width_calculator.rb  # Column width calculation
│   │   │   └── table_renderer.rb           # Table rendering & formatting
│   │   ├── table_component.rb         # Main table component coordinator
│   │   ├── header_component.rb        # Report headers
│   │   ├── generic_header_component.rb # Multi-format headers
│   │   ├── missing_behaviors_component.rb # Missing behavior analysis
│   │   └── footer_component.rb        # Report footers
│   ├── markdown_formatter.rb          # Markdown output formatter
│   └── csv_formatter.rb               # CSV output formatter
├── processors/                        # Value processing utilities
│   └── value_processor.rb             # Handle all Ruby value types
└── utils/                            # General utilities
    └── class_resolver.rb              # Class name resolution
```

## 🔄 Data Flow

### 1. **API Entry Point**
```ruby
ClassMetrix.extract(:constants, :class_methods)
           .from([DatabaseService, CacheService])
           .include_inherited
           .expand_hashes
           .to_markdown()
```

### 2. **Request Processing Flow**

```mermaid
graph TD
    UserRequest["User Request<br/>ClassMetrix.extract()"] 
    
    ClassMetrix["ClassMetrix<br/>.extract()"]
    Extractor["Extractor<br/>(Main Coordinator)"]
    ClassResolver["ClassResolver<br/>.normalize()"]
    
    Router["Route to<br/>Appropriate<br/>Extractor"]
    
    ConstantsExtractor["Constants<br/>Extractor"]
    MethodsExtractor["Methods<br/>Extractor"] 
    MultiTypeExtractor["Multi-Type<br/>Extractor"]
    
    RawTableData["Raw Table Data<br/>{headers:[], rows:[]}"]
    
    Formatter["Formatter<br/>(Markdown/CSV)"]
    
    FormattedOutput["Formatted Output<br/>(String)"]
    
    UserRequest --> ClassMetrix
    ClassMetrix --> Extractor
    Extractor --> ClassResolver
    Extractor --> Router
    
    Router --> ConstantsExtractor
    Router --> MethodsExtractor
    Router --> MultiTypeExtractor
    
    ConstantsExtractor --> RawTableData
    MethodsExtractor --> RawTableData
    MultiTypeExtractor --> RawTableData
    
    RawTableData --> Formatter
    Formatter --> FormattedOutput
    
    style UserRequest fill:#e3f2fd
    style Extractor fill:#f3e5f5
    style Router fill:#fff3e0
    style RawTableData fill:#e8f5e8
    style FormattedOutput fill:#e1f5fe
```

### 3. **Table Component Data Flow** (After Refactoring)

```mermaid
graph TD
    TableDataInput["Table Data Input<br/>{headers:[], rows:[]}"]
    
    TableComponent["TableComponent<br/>(Main Coordinator)<br/>- Orchestrates<br/>- Delegates"]
    
    TableDataExtractor["TableDataExtractor<br/>• has_type_column?()<br/>• extract_row_data()<br/>• collect_hash_keys()"]
    
    RowProcessor["RowProcessor<br/>• process_simple_rows()<br/>• process_expanded_rows()<br/>• expand_row() (hash expansion)"]
    
    ColumnWidthCalculator["ColumnWidthCalculator<br/>• calculate_widths()<br/>• initialize_column_widths()<br/>• apply_minimum_widths()"]
    
    TableRenderer["TableRenderer<br/>• render_table()<br/>• build_row()<br/>• format_cells()"]
    
    FinalRenderedTable["Final Rendered Table<br/>(Markdown/CSV String)"]
    
    TableDataInput --> TableComponent
    
    TableComponent --> TableDataExtractor
    TableComponent --> RowProcessor
    TableComponent --> ColumnWidthCalculator
    TableComponent --> TableRenderer
    
    TableDataExtractor --> RowProcessor
    RowProcessor --> ColumnWidthCalculator
    ColumnWidthCalculator --> TableRenderer
    
    TableRenderer --> FinalRenderedTable
    
    style TableDataInput fill:#e3f2fd
    style TableComponent fill:#fff3e0
    style TableDataExtractor fill:#e8f5e8
    style RowProcessor fill:#f3e5f5
    style ColumnWidthCalculator fill:#e1f5fe
    style TableRenderer fill:#fce4ec
    style FinalRenderedTable fill:#e8f5e8
```

## 🧩 Core Components

### **1. Extractor (Coordinator)**
- **Purpose**: Main API interface and request coordination
- **Responsibilities**:
  - Parse user configuration
  - Route to appropriate extractors
  - Apply global filters and options
  - Coordinate inheritance/module options
- **Key Methods**: `from()`, `filter()`, `include_inherited()`, `to_markdown()`

### **2. Specialized Extractors**

#### **ConstantsExtractor**
- **Purpose**: Extract constants with inheritance/module support
- **Key Features**:
  - Own constants: `Class.constants(false)`
  - Inherited constants: Walk superclass chain
  - Module constants: Scan `included_modules`
  - Source tracking for debugging

#### **MethodsExtractor** 
- **Purpose**: Extract class methods with inheritance/module support
- **Key Features**:
  - Own methods: `Class.singleton_methods(false)`
  - Inherited methods: Walk superclass chain
  - Module methods: Scan `singleton_class.included_modules`
  - Method resolution order handling

#### **MultiTypeExtractor**
- **Purpose**: Combine multiple extraction types into unified table
- **Key Features**:
  - Add "Type" column to distinguish behavior types
  - Merge different extractor results
  - Maintain consistent table structure

### **3. Table Component Architecture** (Refactored)

The table component was recently refactored from a monolithic 269-line class into focused, reusable components:

#### **TableComponent** (Main Coordinator - 42 lines)
- **Purpose**: Orchestrate table generation process
- **Responsibilities**: Initialize sub-components, coordinate data flow
- **Pattern**: Composition over inheritance

#### **TableDataExtractor** (55 lines)
- **Purpose**: Data structure analysis and extraction utilities
- **Key Methods**: `has_type_column?()`, `extract_row_data()`, `collect_hash_keys()`
- **Responsibility**: Understand table structure and extract metadata

#### **RowProcessor** (125 lines)
- **Purpose**: Process table rows and handle hash expansion
- **Key Methods**: `process_simple_rows()`, `process_expanded_rows()`, `expand_row()`
- **Responsibility**: Transform raw data into renderable format

#### **ColumnWidthCalculator** (57 lines)
- **Purpose**: Calculate optimal column widths for table rendering
- **Key Methods**: `calculate_widths()`, `apply_minimum_widths()`
- **Responsibility**: Ensure proper table formatting

#### **TableRenderer** (56 lines)
- **Purpose**: Render final table with proper formatting
- **Key Methods**: `render_table()`, `build_row()`, `format_cells()`
- **Responsibility**: Generate final markdown table output

### **4. Formatters**

#### **MarkdownFormatter**
- **Purpose**: Generate rich markdown reports
- **Key Features**:
  - Modular component architecture
  - Professional report structure
  - Hash expansion support
  - Missing behavior analysis

#### **CsvFormatter**
- **Purpose**: Generate CSV output for data analysis
- **Key Features**:
  - Clean CSV structure
  - Configurable separators and quotes
  - Hash flattening options

### **5. Support Components**

#### **ValueProcessor**
- **Purpose**: Process all Ruby value types consistently
- **Handles**: Strings, numbers, booleans, arrays, hashes, nil, errors
- **Visual Indicators**: ✅ (true), ❌ (false/nil), 🚫 (errors), ⚠️ (warnings)

#### **ClassResolver**
- **Purpose**: Normalize class inputs (strings vs class objects)
- **Handles**: Class objects, string class names, error cases

## 🔧 Key Design Patterns

### **1. Fluent Interface**
```ruby
ClassMetrix.extract(:constants)
           .from([Class1, Class2])
           .include_inherited
           .filter(/config/)
           .expand_hashes
           .to_markdown()
```

### **2. Strategy Pattern**
- Different extractors for different extraction types
- Different formatters for different output formats
- Pluggable components for different behaviors

### **3. Composition Pattern**
- Table component composed of focused sub-components
- Formatters composed of reusable components
- Modular architecture throughout

### **4. Template Method Pattern**
- Base classes define structure
- Subclasses implement specific behaviors
- Consistent interfaces across components

## 🚀 Extension Points

### **Adding New Extraction Types**
1. Create new extractor in `extractors/`
2. Implement standard interface (`extract` method)
3. Add type routing in `MultiTypeExtractor`
4. Add API method in `Extractor`

### **Adding New Output Formats**
1. Create new formatter in `formatters/`
2. Extend base formatter class
3. Implement format-specific logic
4. Add API method in `Extractor`

### **Adding New Components**
1. Create component in `formatters/components/`
2. Extend `BaseComponent`
3. Implement `generate` method
4. Integrate into formatters

## 🧪 Testing Architecture

### **Test Structure**

```mermaid
graph TD
    subgraph "Test Structure"
        APITests["API Integration Tests<br/>class_metrix_spec.rb"]
        ExtractorTests["Core Coordinator Tests<br/>extractor_spec.rb"]
        
        subgraph "Unit Tests"
            ExtractorUnitTests["Extractor Unit Tests<br/>extractors/"]
            FormatterUnitTests["Formatter Tests<br/>formatters/"]
            ProcessorUnitTests["Processor Tests<br/>processors/"]
            UtilsUnitTests["Utility Tests<br/>utils/"]
        end
    end
    
    subgraph "Test Classes Hierarchy"
        TestParent["TestParent<br/>PARENT_CONSTANT<br/>parent_method()"]
        TestChild["TestChild<br/>CHILD_CONSTANT<br/>child_method()"]
        TestGrandchild["TestGrandchild<br/>GRANDCHILD_CONSTANT<br/>grandchild_method()"]
        
        TestParent --> TestChild
        TestChild --> TestGrandchild
    end
    
    subgraph "Test Modules"
        TestModule["TestModule<br/>TEST_MODULE_CONSTANT<br/>module_method()"]
        AnotherTestModule["AnotherTestModule<br/>ANOTHER_CONSTANT<br/>another_module_method()"]
    end
    
    subgraph "Realistic Examples"
        TestUser["TestUser<br/>ROLE_NAME = 'user'<br/>config()"]
        TestAdmin["TestAdmin<br/>ROLE_NAME = 'admin'<br/>admin_config()"]
    end
    
    TestChild -.->|includes| TestModule
    TestGrandchild -.->|includes| AnotherTestModule
    
    APITests --> ExtractorTests
    ExtractorTests --> ExtractorUnitTests
    ExtractorTests --> FormatterUnitTests
    
    ExtractorUnitTests -.->|uses| TestParent
    ExtractorUnitTests -.->|uses| TestChild
    ExtractorUnitTests -.->|uses| TestGrandchild
    ExtractorUnitTests -.->|uses| TestModule
    ExtractorUnitTests -.->|uses| AnotherTestModule
    ExtractorUnitTests -.->|uses| TestUser
    ExtractorUnitTests -.->|uses| TestAdmin
    
    style APITests fill:#e3f2fd
    style ExtractorTests fill:#f3e5f5
    style TestParent fill:#e8f5e8
    style TestChild fill:#fff3e0
    style TestGrandchild fill:#fce4ec
    style TestModule fill:#e1f5fe
    style AnotherTestModule fill:#e1f5fe
```

### **Test Coverage**
- ✅ **Basic Extraction**: Constants and methods from simple classes
- ✅ **Inheritance**: Multi-level inheritance chains
- ✅ **Modules**: Module inclusion and method resolution
- ✅ **Error Handling**: Missing methods, constants, class resolution failures
- ✅ **Value Types**: All Ruby value types and edge cases
- ✅ **Integration**: End-to-end functionality with real-world scenarios

## 📈 Performance Considerations

### **Lazy Evaluation**
- Extractors only process data when `to_markdown()`/`to_csv()` is called
- Filters applied efficiently during extraction
- Minimal memory usage for large class sets

### **Inheritance Optimization**
- Superclass chain traversal is optimized
- Core Ruby classes (`Object`, `BasicObject`) are skipped
- Module resolution uses efficient set operations

### **Table Rendering Optimization**
- Column width calculation is performed once
- Row processing is streamlined
- String operations are minimized

## 🔄 Future Architecture Plans

### **Plugin System**
- Plugin architecture for custom extractors
- Extension points for custom components
- Configuration system for plugin management

### **Caching Layer**
- Cache class metadata for performance
- Invalidation strategies for development
- Configurable caching backends

### **Parallel Processing**
- Parallel extraction for large class sets
- Worker pool for I/O operations
- Memory-efficient streaming for large datasets

---

*This architecture document is maintained alongside code changes.* 