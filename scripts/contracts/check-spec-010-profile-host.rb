#!/usr/bin/env ruby
# frozen_string_literal: true

require "digest"
require "pathname"

root = Pathname.new(File.expand_path("../..", __dir__))
fixture_root = root.join("Tests/ContractFixtures/SPEC010/MacroExpansion")
source = fixture_root.join("Sources/portable-profile.swift")
expanded = fixture_root.join("Expected/portable-profile.swift")

def fail_check(message)
  warn "SPEC-010 profile host check failed: #{message}"
  exit 1
end

fail_check("annotated portable source is missing") unless source.file?
fail_check("expanded portable source is missing") unless expanded.file?

source_text = source.read
expanded_text = expanded.read
fail_check("portable input lacks @ObservableStateHost") unless
  source_text.include?("@ObservableStateHost\npublic struct PortableProfileHost: View")
fail_check("portable expansion retained the macro attribute") if
  expanded_text.include?("@ObservableStateHost")

required_expansion = [
  "public struct PortableProfileModel: _GiftUIObservableReference",
  "@State private var primary = PortableProfileModel()",
  "@GiftUI.State private var secondary = PortableProfileModel()",
  "visitor.visit(&_primary, declarationOrdinal: 0)",
  "visitor.visit(&_secondary, declarationOrdinal: 1)",
  "visitor.visitStatefulCustomView(self)",
  "extension PortableProfileHost: _GiftUIObservableStateHost",
]
missing = required_expansion.reject { |fragment| expanded_text.include?(fragment) }
fail_check("portable expansion differs: #{missing.inspect}") unless missing.empty?

digest = Digest::SHA256.file(expanded).hexdigest
fail_check("generated source digest is invalid") unless digest.match?(/\A[0-9a-f]{64}\z/)

unless ARGV.empty?
  fail_check("expected one symbol-closure path") unless ARGV.length == 1
  symbols = Pathname.new(ARGV.first)
  fail_check("symbol closure is missing") unless symbols.file?
  forbidden = /GiftUIMacros|Swift(?:CompilerPlugin|Syntax|Diagnostics)|ObservableStateHostMacro/
  fail_check("target image retained macro/compiler support: #{symbols.read.lines.grep(forbidden).join}") if
    symbols.read.match?(forbidden)
end

puts "SPEC-010 portable profile host passed: generated SHA-256 #{digest}; no macro/compiler-support linkage."
