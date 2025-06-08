# frozen_string_literal: true

require_relative "class_metrix/version"
require_relative "class_metrix/extractors"
require_relative "class_metrix/extractor"

module ClassMetrix
  class Error < StandardError; end

  def self.extract(*types)
    Extractor.new(*types)
  end
end
