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
end
