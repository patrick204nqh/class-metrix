# frozen_string_literal: true

require "class_metrix"

RSpec.describe ClassMetrix::MarkdownFormatter do
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

      it "formats simple markdown table" do
        formatter = described_class.new(data, false)
        result = formatter.format

        expect(result).to include("| Method")
        expect(result).to include("| ClassA")
        expect(result).to include("| ClassB")
        expect(result).to include("| method1")
        expect(result).to include("| value1")
        expect(result).to include("| value2")
        expect(result).to include("|-----")
      end
    end

    context "with hash data and expansion disabled" do
      let(:data) do
        {
          headers: %w[Method ClassA ClassB],
          rows: [
            ["config", { timeout: 30, ssl: true }, { timeout: 60, ssl: false }],
            ["simple", "string_value", 123]
          ]
        }
      end

      it "formats hashes as inspect strings when expansion is disabled" do
        formatter = described_class.new(data, false)
        result = formatter.format

        expect(result).to include("{:timeout=>30")
        expect(result).to include("{:timeout=>60")
        expect(result).to include("string_value")
        expect(result).to include("123")
      end
    end

    context "with hash data and expansion enabled" do
      let(:data) do
        {
          headers: %w[Method ClassA ClassB],
          rows: [
            ["config", { timeout: 30, ssl: true }, { timeout: 60, ssl: false, retries: 3 }],
            ["simple", "string_value", 123]
          ]
        }
      end

      it "expands hashes with main row plus sub-rows" do
        formatter = described_class.new(data, true)
        result = formatter.format

        expect(result).to include("config")       # Main hash row
        expect(result).to include(".timeout")     # Sub-row path
        expect(result).to include(".ssl")         # Sub-row path
        expect(result).to include(".retries")     # Sub-row path
        expect(result).to include("30")           # ClassA timeout value
        expect(result).to include("60")           # ClassB timeout value
        expect(result).to include("true")         # ClassA ssl value
        expect(result).to include("❌") # Missing retries value
      end

      it "handles mixed hash and non-hash values correctly" do
        formatter = described_class.new(data, true)
        result = formatter.format

        # Simple row should not be expanded
        expect(result).to include("simple")
        expect(result).to include("string_value")
        expect(result).to include("123")
      end
    end

    context "with complex nested structures" do
      let(:data) do
        {
          headers: %w[Method ServiceA ServiceB],
          rows: [
            ["config",
             { db: { host: "localhost", port: 5432 }, cache: { ttl: 3600 } },
             { db: { host: "prod.db", port: 5433 }, cache: { ttl: 7200 } }]
          ]
        }
      end

      it "handles nested hashes by showing their inspect representation" do
        formatter = described_class.new(data, true)
        result = formatter.format

        expect(result).to include("config")     # Main hash row
        expect(result).to include(".cache")     # Sub-row path
        expect(result).to include(".db")        # Sub-row path
        # Nested hashes should show as inspect strings in the expanded view
        expect(result).to include("{:host=>")
        expect(result).to include("{:ttl=>")
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

    context "with special value types" do
      let(:data) do
        {
          headers: %w[Method ClassA],
          rows: [
            ["boolean_true", true],
            ["boolean_false", false],
            ["nil_value", nil],
            ["array_value", [1, 2, 3]],
            %w[string_value hello]
          ]
        }
      end

      it "processes special value types correctly" do
        formatter = described_class.new(data, false)
        result = formatter.format

        expect(result).to include("✅")         # true
        expect(result).to include("❌")         # false and nil
        expect(result).to include("1, 2, 3")   # array
        expect(result).to include("hello")     # string
      end
    end
  end

  describe "component integration" do
    it "generates reports using modular components" do
      data = {
        headers: %w[Method ClassA ClassB],
        rows: [
          %w[method1 value1 value2],
          %w[method2 value3 value4]
        ]
      }
      formatter = described_class.new(data, false, { title: "Test Report" })
      result = formatter.format

      expect(result).to include("# Test Report")        # Header component
      expect(result).to include("| Method")             # Table component
      expect(result).to include("*Report generated")    # Footer component
    end

    it "supports configurable components" do
      data = {
        headers: %w[Method ClassA ClassB],
        rows: [
          %w[method1 value1 value2]
        ]
      }
      formatter = described_class.new(data, false, {
                                        show_metadata: false,
                                        show_classes: false,
                                        show_footer: false
                                      })
      result = formatter.format

      expect(result).not_to include("# ")               # No title header
      expect(result).not_to include("## Classes")       # No classes section
      expect(result).to include("| Method")             # Still has table
      expect(result).not_to include("*Report generated") # No footer
    end
  end
end
