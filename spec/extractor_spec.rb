# frozen_string_literal: true

require "class_metrix"

RSpec.describe ClassMetrix::Extractor do
  # Test classes for extraction
  class TestUser
    ROLE_NAME = "user"
    DEFAULT_PERMISSIONS = ["read"]
    MAX_LOGIN_ATTEMPTS = 3
    CONFIG_HASH = { timeout: 30, retries: 3 }

    def self.authenticate_method
      "basic"
    end

    def self.session_timeout
      3600
    end

    def self.config
      { timeout: 30, retries: 3, ssl: true }
    end

    def self.boolean_true
      true
    end

    def self.boolean_false
      false
    end

    def self.nil_value
      nil
    end
  end

  class TestAdmin
    ROLE_NAME = "admin"
    DEFAULT_PERMISSIONS = %w[read write admin]
    ADMIN_LEVEL = 10
    CONFIG_HASH = { timeout: 60, retries: 5, admin: true }

    def self.authenticate_method
      "two_factor"
    end

    def self.session_timeout
      7200
    end

    def self.admin_config
      { timeout: 60, retries: 5, admin: true }
    end

    def self.boolean_true
      true
    end

    def self.boolean_false
      false
    end

    def self.nil_value
      nil
    end
  end

  describe "#from" do
    it "accepts array of classes" do
      extractor = ClassMetrix.extract(:constants).from([TestUser, TestAdmin])
      expect(extractor.instance_variable_get(:@classes)).to eq([TestUser, TestAdmin])
    end

    it "accepts array of class names as strings" do
      # For now, skip this test as it requires more complex class resolution
      # This can be enhanced later to support nested class name resolution
      skip "Complex class name resolution not yet implemented"
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
        expect(result).not_to include("DEFAULT_PERMISSIONS")
        expect(result).not_to include("MAX_LOGIN_ATTEMPTS")
      end

      it "handles hash constants without expansion" do
        result = ClassMetrix.extract(:constants)
                            .from([TestUser, TestAdmin])
                            .filter(/CONFIG_HASH/)
                            .to_markdown

        expect(result).to include("CONFIG_HASH")
        expect(result).to include("{:timeout=>30")
        expect(result).to include("{:timeout=>60")
      end

      it "expands hash constants when expand_hashes is enabled" do
        result = ClassMetrix.extract(:constants)
                            .from([TestUser, TestAdmin])
                            .filter(/CONFIG_HASH/)
                            .expand_hashes
                            .to_markdown

        expect(result).to include("CONFIG_HASH")  # Main hash row
        expect(result).to include(".timeout")     # Sub-row
        expect(result).to include(".retries")     # Sub-row
        expect(result).to include("30")           # Value
        expect(result).to include("60")           # Value
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
                            .filter(/boolean|nil/)
                            .to_markdown

        expect(result).to include("✅")  # true values
        expect(result).to include("❌")  # false and nil values
      end

      it "expands hash method results when expand_hashes is enabled" do
        result = ClassMetrix.extract(:class_methods)
                            .from([TestUser, TestAdmin])
                            .filter(/^config$|admin_config/)
                            .expand_hashes
                            .handle_errors
                            .to_markdown

        expect(result).to include("config")      # Main hash row
        expect(result).to include(".timeout")    # Sub-row
        expect(result).to include(".retries")    # Sub-row
        expect(result).to include(".ssl")        # Sub-row
        expect(result).to include(".admin")      # Sub-row
      end
    end

    context "when extracting multiple types" do
      it "combines constants and methods in one table" do
        result = ClassMetrix.extract(:constants, :class_methods)
                            .from([TestUser, TestAdmin])
                            .filter(/ROLE|authenticate/)
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
                            .filter(/CONFIG_HASH|^config$/)
                            .expand_hashes
                            .handle_errors
                            .to_markdown

        expect(result).to include("| Type")       # Multi-type header
        expect(result).to include("| Behavior")   # Multi-type header
        expect(result).to include("Constant")     # Type value
        expect(result).to include("Class Method") # Type value
        expect(result).to include("| -")          # Sub-row type indicator (simplified check)
        expect(result).to include(".timeout")     # Sub-row behavior
        expect(result).to include(".retries")     # Sub-row behavior
      end
    end

    context "file output" do
      let(:temp_md_file) { "test_output.md" }
      let(:temp_csv_file) { "test_output.csv" }

      after do
        File.delete(temp_md_file) if File.exist?(temp_md_file)
        File.delete(temp_csv_file) if File.exist?(temp_csv_file)
      end

      it "saves markdown output to file when filename is provided" do
        result = ClassMetrix.extract(:constants)
                            .from([TestUser, TestAdmin])
                            .filter(/^ROLE/)
                            .to_markdown(temp_md_file)

        expect(File.exist?(temp_md_file)).to be true
        file_content = File.read(temp_md_file)
        expect(file_content).to eq(result)
        expect(file_content).to include("ROLE_NAME")
      end

      it "saves CSV output to file when filename is provided" do
        result = ClassMetrix.extract(:constants)
                            .from([TestUser, TestAdmin])
                            .filter(/^ROLE/)
                            .to_csv(temp_csv_file)

        expect(File.exist?(temp_csv_file)).to be true
        file_content = File.read(temp_csv_file)
        expect(file_content).to eq(result)
        expect(file_content).to include("ROLE_NAME")
        expect(file_content).to include(",") # CSV format
      end
    end
  end

  describe "error handling" do
    class TestBrokenClass
      VALID_CONSTANT = "valid"

      def self.working_method
        "works"
      end

      def self.broken_method
        raise StandardError, "This method is broken"
      end
    end

    it "handles method errors gracefully when handle_errors is enabled" do
      result = ClassMetrix.extract(:class_methods)
                          .from([TestBrokenClass])
                          .handle_errors
                          .to_markdown

      expect(result).to include("working_method")
      expect(result).to include("works")
      expect(result).to include("broken_method")
      expect(result).to include("⚠️")
    end

    it "raises errors when handle_errors is not enabled" do
      expect do
        ClassMetrix.extract(:class_methods)
                   .from([TestBrokenClass])
                   .filter(/broken/)
                   .to_markdown
      end.to raise_error(StandardError, "This method is broken")
    end
  end

  describe "CSV output" do
    it "generates CSV format" do
      result = ClassMetrix.extract(:constants)
                          .from([TestUser, TestAdmin])
                          .filter(/^ROLE/)
                          .to_csv(show_metadata: false)

      expect(result).to include("Constant,TestUser,TestAdmin")
      expect(result).to include("ROLE_NAME,user,admin")
      expect(result).not_to include("|")  # No markdown table syntax
      expect(result).not_to include("#")  # No metadata
    end

    it "supports CSV with metadata" do
      result = ClassMetrix.extract(:constants)
                          .from([TestUser, TestAdmin])
                          .filter(/^ROLE/)
                          .to_csv(title: "CSV Test Report")

      expect(result).to include("# CSV Test Report")
      expect(result).to include("# Classes: TestUser, TestAdmin")
      expect(result).to include("Constant,TestUser,TestAdmin")
      expect(result).to include("ROLE_NAME,user,admin")
    end

    it "supports hash flattening in CSV" do
      result = ClassMetrix.extract(:constants)
                          .from([TestUser, TestAdmin])
                          .filter(/CONFIG_HASH/)
                          .expand_hashes
                          .to_csv(show_metadata: false, flatten_hashes: true)

      expect(result).to include("CONFIG_HASH.timeout")
      expect(result).to include("CONFIG_HASH.retries")
      expect(result).to include("30")  # TestUser timeout
      expect(result).to include("60")  # TestAdmin timeout
    end

    it "supports expanded rows in CSV" do
      result = ClassMetrix.extract(:constants)
                          .from([TestUser, TestAdmin])
                          .filter(/CONFIG_HASH/)
                          .expand_hashes
                          .to_csv(show_metadata: false, flatten_hashes: false)

      expect(result).to include("CONFIG_HASH")
      expect(result).to include(".timeout")
      expect(result).to include(".retries")
      expect(result).to include("30")
      expect(result).to include("60")
    end

    it "supports different CSV separators" do
      result = ClassMetrix.extract(:constants)
                          .from([TestUser, TestAdmin])
                          .filter(/^ROLE/)
                          .to_csv(show_metadata: false, separator: ";")

      expect(result).to include("Constant;TestUser;TestAdmin")
      expect(result).to include("ROLE_NAME;user;admin")
    end
  end

  describe "value processing" do
    class TestValueTypes
      STRING_CONST = "hello"
      NUMBER_CONST = 42
      BOOLEAN_TRUE_CONST = true
      BOOLEAN_FALSE_CONST = false
      NIL_CONST = nil
      ARRAY_CONST = [1, 2, 3]
      HASH_CONST = { key: "value", number: 123 }

      def self.string_method
        "world"
      end

      def self.number_method
        99
      end

      def self.array_method
        %w[a b c]
      end

      def self.hash_method
        { foo: "bar", baz: 456 }
      end
    end

    it "handles all value types correctly" do
      result = ClassMetrix.extract(:constants)
                          .from([TestValueTypes])
                          .to_markdown

      expect(result).to include("hello")       # string
      expect(result).to include("42")          # number
      expect(result).to include("✅")          # true
      expect(result).to include("❌")          # false and nil
      expect(result).to include("1, 2, 3")    # array
      expect(result).to include("{:key=>")    # hash
    end

    it "expands arrays correctly" do
      result = ClassMetrix.extract(:constants)
                          .from([TestValueTypes])
                          .filter(/ARRAY/)
                          .to_markdown

      expect(result).to include("1, 2, 3")
    end
  end
end
