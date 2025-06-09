# frozen_string_literal: true

require "class_metrix"

# Test classes for inheritance and module functionality
module TestModule
  TEST_MODULE_CONSTANT = "module_value"

  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    def module_method
      "from_module"
    end

    def overridable_method
      "module_default"
    end

    private

    def private_module_method
      "private_from_module"
    end
  end
end

module AnotherTestModule
  ANOTHER_CONSTANT = "another_value"

  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    def another_module_method
      "another_module"
    end

    private

    def another_private_method
      "another_private"
    end
  end
end

class TestParent
  PARENT_CONSTANT = "parent_value"
  SHARED_CONSTANT = "from_parent"

  def self.parent_method
    "from_parent"
  end

  def self.overridable_method
    "parent_default"
  end

  def self.private_parent_method
    "private_from_parent"
  end
  private_class_method :private_parent_method
end

class TestChild < TestParent
  include TestModule

  CHILD_CONSTANT = "child_value"
  SHARED_CONSTANT = "from_child" # Override parent

  def self.child_method
    "from_child"
  end

  def self.overridable_method
    "child_override" # Override both parent and module
  end

  def self.private_child_method
    "private_from_child"
  end
  private_class_method :private_child_method
end

class TestGrandchild < TestChild
  include AnotherTestModule

  GRANDCHILD_CONSTANT = "grandchild_value"

  def self.grandchild_method
    "from_grandchild"
  end
end

# Original test classes
class TestUser
  ROLE_NAME = "user"
  CONFIG_HASH = { timeout: 30, retries: 3 }.freeze

  def self.authenticate_method
    "basic"
  end

  def self.session_timeout
    3600
  end

  def self.config
    { user_type: "standard", permissions: ["read"] }
  end
end

class TestAdmin
  ROLE_NAME = "admin"
  CONFIG_HASH = { timeout: 60, retries: 5 }.freeze

  def self.authenticate_method
    "two_factor"
  end

  def self.session_timeout
    7200
  end

  def self.admin_config
    { admin_level: "super", permissions: %w[read write delete] }
  end
end

# Test class for private features
class TestPrivateFeatures
  # Public constants and methods
  PUBLIC_CONSTANT = "public_value"

  def self.public_method
    "public_result"
  end

  # Private constants and methods
  PRIVATE_CONSTANT = "private_value"
  SECRET_KEY = "secret123"
  private_constant :PRIVATE_CONSTANT, :SECRET_KEY

  def self.private_method
    "private_result"
  end

  def self.secret_method
    "secret_result"
  end

  private_class_method :private_method, :secret_method
end

RSpec.describe ClassMetrix::Extractor do
  describe "#from" do
    it "accepts array of classes" do
      extractor = ClassMetrix.extract(:constants).from([TestUser, TestAdmin])
      expect(extractor.instance_variable_get(:@classes)).to eq([TestUser, TestAdmin])
    end

    it "accepts array of class names as strings" do
      extractor = ClassMetrix.extract(:constants).from(%w[TestUser TestAdmin])
      expect(extractor.instance_variable_get(:@classes)).to eq([TestUser, TestAdmin])
    end

    it "works end-to-end with string class names" do
      result = ClassMetrix.extract(:constants)
                          .from(%w[TestUser TestAdmin])
                          .filter(/^ROLE/)
                          .to_markdown

      expect(result).to include("| Constant")
      expect(result).to include("| TestUser")
      expect(result).to include("| TestAdmin")
      expect(result).to include("ROLE_NAME")
      expect(result).to include("user")
      expect(result).to include("admin")
    end

    it "handles invalid class names gracefully" do
      expect do
        ClassMetrix.extract(:constants).from(["NonExistentClass"])
      end.to raise_error(ArgumentError, /Class not found/)
    end
  end

  describe "#filter" do
    it "accepts regex patterns" do
      extractor = ClassMetrix.extract(:constants).from([TestUser]).filter(/^ROLE/)
      expect(extractor.instance_variable_get(:@filters)).to include(/^ROLE/)
    end

    it "accepts string patterns" do
      extractor = ClassMetrix.extract(:constants).from([TestUser]).filter("ROLE")
      expect(extractor.instance_variable_get(:@filters)).to include("ROLE")
    end
  end

  describe "#expand_hashes" do
    it "sets the expand_hashes flag" do
      extractor = ClassMetrix.extract(:constants).from([TestUser]).expand_hashes
      expect(extractor.instance_variable_get(:@expand_hashes)).to be true
    end
  end

  describe "#handle_errors" do
    it "sets the handle_errors flag" do
      extractor = ClassMetrix.extract(:constants).from([TestUser]).handle_errors
      expect(extractor.instance_variable_get(:@handle_errors)).to be true
    end
  end

  describe "clean modern API" do
    describe "#strict" do
      it "disables inheritance and modules (class-only scanning)" do
        extractor = ClassMetrix.extract(:constants).from([TestChild]).strict
        expect(extractor.instance_variable_get(:@include_inherited)).to be false
        expect(extractor.instance_variable_get(:@include_modules)).to be false
      end
    end

    describe "#with_private" do
      it "enables private methods/constants scanning" do
        extractor = ClassMetrix.extract(:constants).from([TestPrivateFeatures]).with_private
        expect(extractor.instance_variable_get(:@include_private)).to be true
      end
    end

    describe "default behavior" do
      it "has inheritance and modules enabled by default" do
        extractor = ClassMetrix.extract(:constants).from([TestChild])
        expect(extractor.instance_variable_get(:@include_inherited)).to be true
        expect(extractor.instance_variable_get(:@include_modules)).to be true
        expect(extractor.instance_variable_get(:@include_private)).to be false
      end
    end

    describe "#show_source" do
      it "sets the show_source flag" do
        extractor = ClassMetrix.extract(:constants).from([TestChild]).show_source
        expect(extractor.instance_variable_get(:@show_source)).to be true
      end
    end
  end

  describe "#to_markdown" do
    context "when extracting constants" do
      it "returns markdown table" do
        result = ClassMetrix.extract(:constants)
                            .from([TestUser, TestAdmin])
                            .to_markdown

        expect(result).to include("| Constant")
        expect(result).to include("| TestUser")
        expect(result).to include("| TestAdmin")
        expect(result).to include("ROLE_NAME")
        expect(result).to include("user")
        expect(result).to include("admin")
      end

      it "applies filters correctly" do
        result = ClassMetrix.extract(:constants)
                            .from([TestUser, TestAdmin])
                            .filter(/^ROLE/)
                            .to_markdown

        expect(result).to include("ROLE_NAME")
        expect(result).not_to include("CONFIG_HASH")
      end

      it "handles hash constants without expansion" do
        result = ClassMetrix.extract(:constants)
                            .from([TestUser, TestAdmin])
                            .filter(/CONFIG_HASH/)
                            .to_markdown

        expect(result).to include("CONFIG_HASH")
        expect(result).to include("{:timeout=>30")
        expect(result).not_to include(".timeout") # No expansion
      end

      it "expands hash constants when expand_hashes is enabled" do
        result = ClassMetrix.extract(:constants)
                            .from([TestUser, TestAdmin])
                            .filter(/CONFIG_HASH/)
                            .expand_hashes
                            .show_expanded_details
                            .to_markdown

        expect(result).to include("CONFIG_HASH")  # Main hash row
        expect(result).to include(".timeout")     # Sub-row
        expect(result).to include(".retries")     # Sub-row
        expect(result).to include("30")           # Value
        expect(result).to include("60")           # Value
      end

      context "with inheritance (default behavior)" do
        it "includes inherited constants by default" do
          result = ClassMetrix.extract(:constants)
                              .from([TestChild])
                              .to_markdown

          expect(result).to include("CHILD_CONSTANT")   # Own constant
          expect(result).to include("PARENT_CONSTANT")  # Inherited constant
          expect(result).to include("child_value")
          expect(result).to include("parent_value")
        end

        it "shows constant overrides correctly" do
          result = ClassMetrix.extract(:constants)
                              .from([TestChild])
                              .filter(/SHARED_CONSTANT/)
                              .to_markdown

          expect(result).to include("SHARED_CONSTANT")
          expect(result).to include("from_child") # Override wins
        end

        it "works with grandchild inheritance" do
          result = ClassMetrix.extract(:constants)
                              .from([TestGrandchild])
                              .to_markdown

          expect(result).to include("GRANDCHILD_CONSTANT")  # Own
          expect(result).to include("CHILD_CONSTANT")       # From parent
          expect(result).to include("PARENT_CONSTANT")      # From grandparent
        end
      end

      context "with modules (default behavior)" do
        it "includes module constants by default" do
          result = ClassMetrix.extract(:constants)
                              .from([TestChild])
                              .to_markdown

          expect(result).to include("CHILD_CONSTANT")        # Own constant
          expect(result).to include("TEST_MODULE_CONSTANT")  # Module constant
          expect(result).to include("child_value")
          expect(result).to include("module_value")
        end

        it "includes modules from inheritance chain by default" do
          result = ClassMetrix.extract(:constants)
                              .from([TestGrandchild])
                              .to_markdown

          expect(result).to include("GRANDCHILD_CONSTANT")   # Own
          expect(result).to include("ANOTHER_CONSTANT")      # Own module
          expect(result).to include("TEST_MODULE_CONSTANT")  # Parent's module
        end
      end

      context "comprehensive scanning (default behavior)" do
        it "includes everything by default: own, inherited, and modules" do
          result = ClassMetrix.extract(:constants)
                              .from([TestChild])
                              .to_markdown

          expect(result).to include("CHILD_CONSTANT")        # Own
          expect(result).to include("PARENT_CONSTANT")       # Inherited
          expect(result).to include("TEST_MODULE_CONSTANT")  # Module
        end
      end

      context "with private features" do
        it "excludes private constants by default" do
          result = ClassMetrix.extract(:constants)
                              .from([TestPrivateFeatures])
                              .to_markdown

          expect(result).to include("PUBLIC_CONSTANT")
          expect(result).not_to include("PRIVATE_CONSTANT")
          expect(result).not_to include("SECRET_KEY")
        end

        it "includes private constants when with_private is enabled" do
          result = ClassMetrix.extract(:constants)
                              .from([TestPrivateFeatures])
                              .with_private
                              .to_markdown

          expect(result).to include("PUBLIC_CONSTANT")
          expect(result).to include("PRIVATE_CONSTANT")
          expect(result).to include("SECRET_KEY")
          expect(result).to include("public_value")
          expect(result).to include("private_value")
          expect(result).to include("secret123")
        end
      end
    end

    context "when extracting class methods" do
      it "returns markdown table with method results" do
        result = ClassMetrix.extract(:class_methods)
                            .from([TestUser, TestAdmin])
                            .handle_errors
                            .to_markdown

        expect(result).to include("| Method")
        expect(result).to include("authenticate_method")
        expect(result).to include("basic")
        expect(result).to include("two_factor")
        expect(result).to include("session_timeout")
        expect(result).to include("3600")
        expect(result).to include("7200")
      end

      it "applies filters to methods" do
        result = ClassMetrix.extract(:class_methods)
                            .from([TestUser, TestAdmin])
                            .filter(/config$/)
                            .handle_errors
                            .to_markdown

        expect(result).to include("config")
        expect(result).to include("admin_config")
        expect(result).not_to include("authenticate_method")
        expect(result).not_to include("session_timeout")
      end

      it "handles boolean and nil values correctly" do
        result = ClassMetrix.extract(:class_methods)
                            .from([TestUser, TestAdmin])
                            .handle_errors
                            .to_markdown

        expect(result).to include("basic")
        expect(result).to include("two_factor")
      end

      it "expands hash method results when expand_hashes is enabled" do
        result = ClassMetrix.extract(:class_methods)
                            .from([TestUser, TestAdmin])
                            .filter(/config$/)
                            .expand_hashes
                            .show_expanded_details
                            .handle_errors
                            .to_markdown

        expect(result).to include("config")
        expect(result).to include(".user_type")     # Hash expansion
        expect(result).to include(".permissions")   # Hash expansion
        expect(result).to include("standard")
      end

      context "with inheritance (default behavior)" do
        it "includes inherited methods by default" do
          result = ClassMetrix.extract(:class_methods)
                              .from([TestChild])
                              .to_markdown

          expect(result).to include("child_method")    # Own method
          expect(result).to include("parent_method")   # Inherited method
          expect(result).to include("from_child")
          expect(result).to include("from_parent")
        end

        it "shows method overrides correctly" do
          result = ClassMetrix.extract(:class_methods)
                              .from([TestChild])
                              .filter(/overridable_method/)
                              .to_markdown

          expect(result).to include("overridable_method")
          expect(result).to include("child_override")  # Override wins
        end
      end

      context "with modules (default behavior)" do
        it "includes module methods by default" do
          result = ClassMetrix.extract(:class_methods)
                              .from([TestChild])
                              .to_markdown

          expect(result).to include("child_method")    # Own method
          expect(result).to include("module_method")   # Module method
          expect(result).to include("from_child")
          expect(result).to include("from_module")
        end

        it "handles method overrides from modules" do
          result = ClassMetrix.extract(:class_methods)
                              .from([TestChild])
                              .filter(/overridable_method/)
                              .to_markdown

          expect(result).to include("overridable_method")
          expect(result).to include("child_override")  # Class override wins over module
        end
      end

      context "comprehensive scanning (default behavior)" do
        it "includes everything by default: own, inherited, and module methods" do
          result = ClassMetrix.extract(:class_methods)
                              .from([TestChild])
                              .to_markdown

          expect(result).to include("child_method")    # Own
          expect(result).to include("parent_method")   # Inherited
          expect(result).to include("module_method")   # Module
        end

        it "shows complex inheritance with modules correctly" do
          result = ClassMetrix.extract(:class_methods)
                              .from([TestGrandchild])
                              .to_markdown

          expect(result).to include("grandchild_method")     # Own
          expect(result).to include("another_module_me...")  # Own module (truncated in table)
          expect(result).to include("child_method")          # Parent
          expect(result).to include("module_method")         # Parent's module
          expect(result).to include("parent_method")         # Grandparent
        end
      end

      context "with private features" do
        it "excludes private methods by default" do
          result = ClassMetrix.extract(:class_methods)
                              .from([TestPrivateFeatures])
                              .to_markdown

          expect(result).to include("public_method")
          expect(result).not_to include("private_method")
          expect(result).not_to include("secret_method")
        end

        it "includes private methods when with_private is enabled" do
          result = ClassMetrix.extract(:class_methods)
                              .from([TestPrivateFeatures])
                              .with_private
                              .handle_errors
                              .to_markdown

          expect(result).to include("public_method")
          expect(result).to include("private_method")
          expect(result).to include("secret_method")
          expect(result).to include("public_result")
          expect(result).to include("private_result")
          expect(result).to include("secret_result")
        end

        it "includes private methods from inheritance when with_private is enabled (default includes inheritance)" do
          result = ClassMetrix.extract(:class_methods)
                              .from([TestChild])
                              .with_private
                              .to_markdown(max_column_width: 50)

          # Should include both public and private methods from child and parent (inheritance is default)
          expect(result).to include("child_method")          # Own public
          expect(result).to include("parent_method")         # Inherited public
          expect(result).to include("overridable_method")    # Overridden method
          expect(result).to include("private_child_method")  # Own private
          expect(result).to include("private_parent_method") # Inherited private
        end

        it "includes private methods from modules when with_private is enabled (default includes modules)" do
          result = ClassMetrix.extract(:class_methods)
                              .from([TestChild])
                              .with_private
                              .to_markdown(max_column_width: 50)

          # Should include both public and private methods from own class and modules (modules are default)
          expect(result).to include("child_method")           # Own public
          expect(result).to include("module_method")          # Module public
          expect(result).to include("private_child_method")   # Own private
          expect(result).to include("private_module_method")  # Module private
        end

        it "includes private methods comprehensively when with_private is enabled (default behavior includes inheritance and modules)" do
          result = ClassMetrix.extract(:class_methods)
                              .from([TestChild])
                              .with_private
                              .to_markdown(max_column_width: 50)

          # Should include everything: own, inherited, module methods (both public and private) - comprehensive by default
          expect(result).to include("child_method")           # Own public
          expect(result).to include("parent_method")          # Inherited public
          expect(result).to include("module_method")          # Module public
          expect(result).to include("overridable_method")     # Overridden method
          expect(result).to include("private_child_method")   # Own private
          expect(result).to include("private_parent_method")  # Inherited private
          expect(result).to include("private_module_method")  # Module private
        end
      end
    end

    context "when extracting multiple types" do
      it "combines constants and methods in one table" do
        result = ClassMetrix.extract(:constants, :class_methods)
                            .from([TestUser, TestAdmin])
                            .handle_errors
                            .to_markdown

        expect(result).to include("| Type")
        expect(result).to include("| Behavior")
        expect(result).to include("Constant")
        expect(result).to include("Class Method")
        expect(result).to include("ROLE_NAME")
        expect(result).to include("authenticate_method")
      end

      it "supports hash expansion in multi-type extraction" do
        result = ClassMetrix.extract(:constants, :class_methods)
                            .from([TestUser, TestAdmin])
                            .filter(/config/)
                            .expand_hashes
                            .show_expanded_details
                            .handle_errors
                            .to_markdown

        expect(result).to include("Constant")
        expect(result).to include("Class Method")
        expect(result).to include("admin_config")      # Method that matches filter
        expect(result).to include("config")            # Method that matches filter
        expect(result).to include("config.permissions") # Hash expansion from config method
      end

      context "with inheritance and modules (default behavior)" do
        it "combines all extraction types with comprehensive scanning by default" do
          result = ClassMetrix.extract(:constants, :class_methods)
                              .from([TestChild])
                              .to_markdown(max_column_width: 50)

          expect(result).to include("Constant")
          expect(result).to include("Class Method")
          expect(result).to include("CHILD_CONSTANT")        # Own constant
          expect(result).to include("PARENT_CONSTANT")       # Inherited constant
          expect(result).to include("TEST_MODULE_CONSTANT")  # Module constant
          expect(result).to include("child_method")          # Own method
          expect(result).to include("parent_method")         # Inherited method
          expect(result).to include("module_method")         # Module method
        end
      end
    end

    context "hash expansion modes" do
      class HashTestClass
        CONFIG = { timeout: 30, ssl: true, retries: 3 }.freeze

        def self.database_config
          { host: "localhost", port: 5432, ssl: true }
        end
      end

      it "shows only main rows by default (new default behavior)" do
        result = ClassMetrix.extract(:constants, :class_methods)
                            .from([HashTestClass])
                            .expand_hashes
                            .to_markdown

        # Should contain main rows
        expect(result).to include("CONFIG")
        expect(result).to include("database_config")
        expect(result).to include("{:timeout=>30, ...}")

        # Should NOT contain key rows by default
        expect(result).not_to include("CONFIG.timeout")
        expect(result).not_to include("CONFIG.ssl")
        expect(result).not_to include("CONFIG.retries")
        expect(result).not_to include("database_config.host")
        expect(result).not_to include("database_config.port")
      end

      it "shows both main and key rows when explicitly requested" do
        result = ClassMetrix.extract(:constants, :class_methods)
                            .from([HashTestClass])
                            .expand_hashes
                            .show_expanded_details
                            .to_markdown

        # Should contain main rows
        expect(result).to include("CONFIG")
        expect(result).to include("database_config")
        expect(result).to include("{:timeout=>30, ...}")

        # Should contain key rows
        expect(result).to include("CONFIG.timeout")
        expect(result).to include("CONFIG.ssl")
        expect(result).to include("CONFIG.retries")
        expect(result).to include("database_config.host")
        expect(result).to include("database_config.port")
        expect(result).to include("database_config.ssl")
      end

      it "shows only main rows when using show_only_main" do
        result = ClassMetrix.extract(:constants, :class_methods)
                            .from([HashTestClass])
                            .expand_hashes
                            .show_only_main
                            .to_markdown

        # Should contain main rows
        expect(result).to include("CONFIG")
        expect(result).to include("database_config")
        expect(result).to include("{:timeout=>30, ...}")

        # Should not contain key rows
        expect(result).not_to include("CONFIG.timeout")
        expect(result).not_to include("CONFIG.ssl")
        expect(result).not_to include("CONFIG.retries")
        expect(result).not_to include("database_config.host")
        expect(result).not_to include("database_config.port")
      end

      it "shows only key rows when using show_only_keys" do
        result = ClassMetrix.extract(:constants, :class_methods)
                            .from([HashTestClass])
                            .expand_hashes
                            .show_only_keys
                            .to_markdown

        # Should not contain main rows with full hash display
        expect(result).not_to include("{:timeout=>30, ...}")
        expect(result).not_to include("{...}")

        # Should contain key rows
        expect(result).to include("CONFIG.timeout")
        expect(result).to include("CONFIG.ssl")
        expect(result).to include("CONFIG.retries")
        expect(result).to include("database_config.host")
        expect(result).to include("database_config.port")
        expect(result).to include("database_config.ssl")
      end

      it "supports hide_main_row option directly" do
        result = ClassMetrix.extract(:constants)
                            .from([HashTestClass])
                            .expand_hashes
                            .show_expanded_details  # First enable both rows
                            .hide_main_row          # Then hide main row
                            .to_markdown

        expect(result).not_to include("{:timeout=>30, ...}")
        expect(result).to include("CONFIG.timeout")
      end

      it "supports hide_key_rows option directly" do
        result = ClassMetrix.extract(:constants)
                            .from([HashTestClass])
                            .expand_hashes
                            .show_expanded_details  # First enable both rows
                            .hide_key_rows          # Then hide key rows (back to default)
                            .to_markdown

        expect(result).to include("{:timeout=>30, ...}")
        expect(result).not_to include("CONFIG.timeout")
      end

      it "doesn't break CSV format when expansion modes are used" do
        result = ClassMetrix.extract(:constants)
                            .from([HashTestClass])
                            .expand_hashes
                            .show_only_keys
                            .to_csv

        # Should still generate valid CSV output
        expect(result).to include("Constant")
        expect(result).to include("HashTestClass")
        expect(result).to include("CONFIG")
      end
    end

    context "file output" do
      let(:temp_file) { "temp_test_output.md" }
      let(:temp_csv_file) { "temp_test_output.csv" }

      after do
        File.delete(temp_file) if File.exist?(temp_file)
        File.delete(temp_csv_file) if File.exist?(temp_csv_file)
      end

      it "saves markdown output to file when filename is provided" do
        ClassMetrix.extract(:constants)
                   .from([TestUser])
                   .to_markdown(temp_file)

        expect(File.exist?(temp_file)).to be true
        content = File.read(temp_file)
        expect(content).to include("| Constant")
        expect(content).to include("ROLE_NAME")
      end

      it "saves CSV output to file when filename is provided" do
        ClassMetrix.extract(:constants)
                   .from([TestUser])
                   .to_csv(temp_csv_file)

        expect(File.exist?(temp_csv_file)).to be true
        content = File.read(temp_csv_file)
        expect(content).to include("Constant,TestUser")
        expect(content).to include("ROLE_NAME,user")
      end
    end
  end

  describe "error handling" do
    class ErrorTestClass
      def self.error_method
        raise StandardError, "Test error"
      end

      def self.no_method_error
        raise NoMethodError, "Test no method error"
      end
    end

    it "handles method errors gracefully when handle_errors is enabled" do
      result = ClassMetrix.extract(:class_methods)
                          .from([ErrorTestClass])
                          .filter(/error_method/)
                          .handle_errors
                          .to_markdown

      expect(result).to include("error_method")
      expect(result).to include("⚠️")
    end

    it "raises errors when handle_errors is not enabled" do
      expect do
        ClassMetrix.extract(:class_methods)
                   .from([ErrorTestClass])
                   .filter(/error_method/)
                   .to_markdown
      end.to raise_error(StandardError, "Test error")
    end
  end

  describe "CSV output" do
    it "generates CSV format" do
      result = ClassMetrix.extract(:constants)
                          .from([TestUser, TestAdmin])
                          .filter(/ROLE_NAME/)
                          .to_csv

      expect(result).to include("Constant,TestUser,TestAdmin")
      expect(result).to include("ROLE_NAME,user,admin")
    end

    it "supports CSV with metadata" do
      result = ClassMetrix.extract(:constants)
                          .from([TestUser])
                          .to_csv(show_metadata: true)

      expect(result).to include("# Constants Report")
      expect(result).to include("# Classes: TestUser")
    end

    it "supports hash flattening in CSV" do
      result = ClassMetrix.extract(:constants)
                          .from([TestUser])
                          .expand_hashes
                          .to_csv(flatten_hashes: true)

      expect(result).to include("CONFIG_HASH.timeout")
      expect(result).to include("CONFIG_HASH.retries")
    end

    it "supports expanded rows in CSV" do
      result = ClassMetrix.extract(:constants)
                          .from([TestUser])
                          .filter(/CONFIG_HASH/)
                          .expand_hashes
                          .show_expanded_details
                          .to_csv(flatten_hashes: false)

      expect(result).to include("CONFIG_HASH")
      expect(result).to include(".timeout")
      expect(result).to include(".retries")
    end

    it "supports different CSV separators" do
      result = ClassMetrix.extract(:constants)
                          .from([TestUser])
                          .filter(/ROLE_NAME/)
                          .to_csv(separator: ";")

      expect(result).to include("Constant;TestUser")
      expect(result).to include("ROLE_NAME;user")
    end
  end

  describe "value processing" do
    class ValueTestClass
      STRING_VALUE = "test"
      NUMBER_VALUE = 42
      BOOLEAN_TRUE = true
      BOOLEAN_FALSE = false
      NIL_VALUE = nil
      ARRAY_VALUE = [1, 2, 3].freeze
      HASH_VALUE = { key: "value" }.freeze

      def self.string_method
        "method_result"
      end

      def self.number_method
        100
      end

      def self.boolean_method
        true
      end

      def self.nil_method
        nil
      end

      def self.array_method
        %w[a b]
      end

      def self.hash_method
        { result: "success" }
      end
    end

    it "handles all value types correctly" do
      result = ClassMetrix.extract(:constants, :class_methods)
                          .from([ValueTestClass])
                          .to_markdown

      expect(result).to include("STRING_VALUE")
      expect(result).to include("test")
      expect(result).to include("NUMBER_VALUE")
      expect(result).to include("42")
      expect(result).to include("BOOLEAN_TRUE")
      expect(result).to include("✅")
      expect(result).to include("BOOLEAN_FALSE")
      expect(result).to include("❌")
      expect(result).to include("string_method")
      expect(result).to include("method_result")
    end

    it "expands arrays correctly" do
      result = ClassMetrix.extract(:constants)
                          .from([ValueTestClass])
                          .filter(/ARRAY_VALUE/)
                          .to_markdown

      expect(result).to include("ARRAY_VALUE")
      expect(result).to include("1, 2, 3") # Arrays are formatted as comma-separated
    end
  end
end
