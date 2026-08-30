#!/usr/bin/env ruby
# frozen_string_literal: true

require "pathname"

root = Pathname.new(File.expand_path("../..", __dir__))
default_path = root.join("demo/SignalAnalyzer/Sources/SignalAnalyzerPresentation")
path = Pathname.new(ARGV.fetch(0, default_path.to_s))

def fail_check(message)
  warn "SPEC-004 portable source check failed: #{message}"
  exit 1
end

fail_check("unexpected arguments") if ARGV.length > 1
fail_check("portable source path is missing: #{path}") unless path.exist?

files = path.file? ? [path] : path.glob("**/*.swift").sort
fail_check("portable source set is empty") if files.empty?

forbidden_modules = %w[
  GiftUICapabilities
  GiftUIBackend
  GiftUIPlatform
  GiftUIDriver
  GiftUIHost
].freeze
identity_tokens = %w[
  platform
  backend
  board
  driver
  controller
  transport
  device
].freeze

violations = []
files.each do |file|
  file.each_line.with_index(1) do |line, line_number|
    code = line.sub(%r{//.*\z}, "")
    imported = code[/^\s*import\s+([A-Za-z0-9_]+)/, 1]
    if imported && forbidden_modules.include?(imported)
      violations << "#{file}:#{line_number}: forbidden import #{imported}"
    end
    identity_tokens.each do |token|
      if code.match?(/\b#{Regexp.escape(token)}(?:Name|ID|Type|Kind)?\b/i)
        violations << "#{file}:#{line_number}: concrete identity token #{token}"
      end
    end
  end
end

fail_check(violations.join("; ")) unless violations.empty?
puts "SPEC-004 portable source check passed: #{files.length} presentation source files, " \
     "zero capability or concrete-identity branches."
