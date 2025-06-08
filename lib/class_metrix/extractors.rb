# frozen_string_literal: true

module ClassMetrix
  # Namespace for all extractors and their services
  module Extractors
    # This module groups all extractors and their related services
  end
end

# Require all extractors
require_relative "extractors/methods_extractor"
require_relative "extractors/constants_extractor"
require_relative "extractors/multi_type_extractor"
