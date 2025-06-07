# frozen_string_literal: true

require "class_metrix"

RSpec.describe ClassMetrix do
  it "has a version number" do
    expect(ClassMetrix::VERSION).not_to be nil
  end

  describe ".extract" do
    it "returns an Extractor instance" do
      extractor = ClassMetrix.extract(:constants)
      expect(extractor).to be_a(ClassMetrix::Extractor)
    end

    it "accepts multiple extraction types" do
      extractor = ClassMetrix.extract(:constants, :class_methods)
      expect(extractor).to be_a(ClassMetrix::Extractor)
    end
  end
end
