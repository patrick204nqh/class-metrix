# frozen_string_literal: true

require "class_metrix"

RSpec.describe ClassMetrix::CsvFormatter do
  describe "#format" do
    context "with simple data" do
      let(:data) do
        {
          headers: %w[Method ClassA ClassB],
          rows: [
            %w[method1 value1 value2],
            %w[method2 value3 value4]
          ]
        }
      end

      it "formats simple CSV table" do
        formatter = described_class.new(data, false, { show_metadata: false })
        result = formatter.format

        expect(result).to include("Method,ClassA,ClassB")
        expect(result).to include("method1,value1,value2")
        expect(result).to include("method2,value3,value4")
        expect(result).not_to include("#") # No metadata
      end

      it "includes metadata when enabled" do
        formatter = described_class.new(data, false, {
                                          show_metadata: true,
                                          title: "Test CSV Report",
                                          extraction_types: [:constants]
                                        })
        result = formatter.format

        expect(result).to include("# Test CSV Report")
        expect(result).to include("# Classes: ClassA, ClassB")
        expect(result).to include("# Extraction Types: Constants")
        expect(result).to include("# Generated:")
      end
    end

    context "with different separators" do
      let(:data) do
        {
          headers: %w[Method ClassA ClassB],
          rows: [
            %w[method1 value1 value2]
          ]
        }
      end

      it "supports semicolon separator" do
        formatter = described_class.new(data, false, {
                                          show_metadata: false,
                                          separator: ";"
                                        })
        result = formatter.format

        expect(result).to include("Method;ClassA;ClassB")
        expect(result).to include("method1;value1;value2")
      end

      it "supports tab separator" do
        formatter = described_class.new(data, false, {
                                          show_metadata: false,
                                          separator: "\t"
                                        })
        result = formatter.format

        expect(result).to include("Method\tClassA\tClassB")
        expect(result).to include("method1\tvalue1\tvalue2")
      end
    end

    context "with special value types" do
      let(:data) do
        {
          headers: %w[Method ClassA],
          rows: [
            ["boolean_true", true],
            ["boolean_false", false],
            ["nil_value", nil],
            ["array_value", [1, 2, 3]],
            ["hash_value", { key: "value" }],
            %w[string_value hello]
          ]
        }
      end

      it "processes special value types for CSV" do
        formatter = described_class.new(data, false, { show_metadata: false })
        result = formatter.format

        expect(result).to include("TRUE")         # true
        expect(result).to include("FALSE")        # false
        expect(result).to include("1; 2; 3")     # array
        expect(result).to include("{:key=>")     # hash
        expect(result).to include("hello")       # string
        # nil should result in empty value (default null_value)
      end

      it "uses custom null value" do
        formatter = described_class.new(data, false, {
                                          show_metadata: false,
                                          null_value: "NULL"
                                        })
        result = formatter.format

        expect(result).to include("NULL") # nil value
      end
    end

    context "with hash expansion and flattening" do
      let(:data) do
        {
          headers: %w[Method ClassA ClassB],
          rows: [
            ["config", { timeout: 30, ssl: true }, { timeout: 60, ssl: false, retries: 3 }],
            ["simple", "string_value", 123]
          ]
        }
      end

      it "flattens hashes into separate columns" do
        formatter = described_class.new(data, true, {
                                          show_metadata: false,
                                          flatten_hashes: true
                                        })
        result = formatter.format

        # Should include flattened columns
        expect(result).to include("config.ssl")
        expect(result).to include("config.timeout")
        expect(result).to include("config.retries")

        # Should include flattened values
        expect(result).to include("30")    # ClassA timeout
        expect(result).to include("60")    # ClassB timeout
        expect(result).to include("TRUE")  # ClassA ssl
        expect(result).to include("FALSE") # ClassB ssl
        expect(result).to include("3")     # ClassB retries
      end

      it "expands hashes into sub-rows when not flattening" do
        formatter = described_class.new(data, true, {
                                          show_metadata: false,
                                          flatten_hashes: false
                                        })
        result = formatter.format

        # Should include main rows
        expect(result).to include("config")

        # Should include sub-rows
        expect(result).to include(".timeout")
        expect(result).to include(".ssl")
        expect(result).to include(".retries")

        # Should include values
        expect(result).to include("30")
        expect(result).to include("60")
        expect(result).to include("TRUE")
        expect(result).to include("FALSE")
      end
    end

    context "with error values" do
      let(:data) do
        {
          headers: %w[Method ClassA ClassB],
          rows: [
            ["test_method", "🚫 Not defined", "✅ working"],
            ["other_method", "⚠️ Error: broken", "normal_value"]
          ]
        }
      end

      it "cleans up emoji for CSV compatibility" do
        formatter = described_class.new(data, false, { show_metadata: false })
        result = formatter.format

        expect(result).to include("Not defined")  # Cleaned up
        expect(result).to include("working")      # Cleaned up
        expect(result).to include("Error: broken") # Cleaned up
        expect(result).to include("normal_value") # Unchanged

        # Should not contain emoji
        expect(result).not_to include("🚫")
        expect(result).not_to include("✅")
        expect(result).not_to include("⚠️")
      end
    end

    context "with multi-type data" do
      let(:data) do
        {
          headers: %w[Type Behavior ClassA ClassB],
          rows: [
            ["Constant", "CONFIG", { host: "localhost" }, { host: "remote" }],
            ["Class Method", "timeout", 30, 60]
          ]
        }
      end

      it "handles multi-type extraction with hash flattening" do
        formatter = described_class.new(data, true, {
                                          show_metadata: false,
                                          flatten_hashes: true
                                        })
        result = formatter.format

        expect(result).to include("Type,Behavior,ClassA,ClassB")
        expect(result).to include("CONFIG.host") # Flattened column
        expect(result).to include("Constant")
        expect(result).to include("Class Method")
        expect(result).to include("localhost")
        expect(result).to include("remote")
        expect(result).to include("30")
        expect(result).to include("60")
      end
    end

    context "with empty data" do
      let(:empty_data) do
        {
          headers: [],
          rows: []
        }
      end

      it "returns empty string for empty data" do
        formatter = described_class.new(empty_data, false)
        result = formatter.format

        expect(result).to eq("")
      end
    end
  end
end
