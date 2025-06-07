# frozen_string_literal: true

# Steepfile for ClassMetrix gem
D = Steep::Diagnostic

target :lib do
  signature "sig"

  check "lib"

  # Configure libraries
  library "pathname"
  library "csv"
  library "json"
  library "fileutils"

  # Configure typing options
  configure_code_diagnostics(D::Ruby.default)

  # Disable some noisy diagnostics for better development experience
  configure_code_diagnostics do |hash|
    hash[D::Ruby::UnresolvedOverloading] = :information
    hash[D::Ruby::FallbackAny] = :information
    hash[D::Ruby::ImplicitBreakValueMismatch] = :hint
  end
end
