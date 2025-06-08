# frozen_string_literal: true

require_relative "extractors/services/collection"
require_relative "extractors/services/filtering"
require_relative "extractors/services/resolution"
require_relative "extractors/services/method_call_service"

module ClassMetrix
  module Services
    # This module provides access to all service classes used by extractors
    # Services are organized into logical namespaces:
    # - Collection: Data gathering services
    # - Filtering: Method name filtering services
    # - Resolution: Method source resolution services
    # - MethodCallService: Method execution service
  end
end
