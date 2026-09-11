#!/usr/bin/env ruby
# frozen_string_literal: true

require "pathname"

ROOT = Pathname.new(File.expand_path("../..", __dir__))
ADAPTER = ROOT.join("Sources/GiftUIRenderFailureAdapterFixture/RenderFailureAdapter.swift")
TEST = ROOT.join("Tests/GiftUIRenderFailureAdapterTests/RenderFailureAdapterTests.swift")
LOWERING = ROOT.join("Sources/GiftUIRenderLowering")
PACKAGE = ROOT.join("Package.swift")

def fail_check(message)
  warn "SPEC-008 render failure adapter check failed: #{message}"
  exit 1
end

adapter = ADAPTER.read
test = TEST.read
package = PACKAGE.read
lowering_sources = Dir[LOWERING.join("**/*.swift")].sort.map { |path| File.read(path) }.join("\n")

fail_check("adapter imports differ") unless
  adapter.scan(/^import (\w+)$/).flatten == %w[GiftUIFailureCore GiftUIRenderLowering]
fail_check("lowering imports failure core") if lowering_sources.match?(/^import GiftUIFailureCore$/)
fail_check("lowering imports diagnostics") if lowering_sources.match?(/^import GiftUIFailureDiagnostics$/)

adapter_target = package[/\.target\(\s*name: "GiftUIRenderFailureAdapterFixture".*?\n\s*\),/m]
test_target = package[/\.testTarget\(\s*name: "GiftUIRenderFailureAdapterTests".*?\n\s*\),/m]
fail_check("adapter target is missing") unless adapter_target
fail_check("adapter target dependencies differ") unless
  adapter_target.scan(/"(GiftUI\w+)"/).flatten.sort ==
    %w[GiftUIFailureCore GiftUIRenderFailureAdapterFixture GiftUIRenderLowering].sort
fail_check("focused test target is missing") unless test_target

expected_rows = {
  "invalidInput" => %w[invalidValue rendering candidateFrame contained],
  "arithmeticOverflow" => %w[arithmeticOverflow foundation operation contained],
  "capacityExhausted" => %w[capacityExhausted rendering candidateFrame contained],
  "incompatibleTextResource" => %w[invalidValue rendering candidateFrame contained],
  "sinkRefused" => %w[nonRetryableRefusal rendering candidateFrame contained],
  "reentrancyViolation" => %w[reentrancyViolation rendering activeCycle safetyNotProven],
  "invariantViolation" => %w[invariantViolation rendering runtime safetyNotProven],
}
expected_rows.each do |error, values|
  body = adapter[/case \.#{error}:(.*?)(?=\n\s*case |\n\s*})/m]
  fail_check("adapter lacks #{error}") unless body
  values.each do |value|
    fail_check("#{error} mapping lacks #{value}") unless body.include?(".#{value}")
  end
  fail_check("focused test lacks #{error}") unless test.include?(".failure(.#{error})")
end

forbidden = /\b(?:allocate|malloc|calloc|realloc|Diagnostic|produce\s*\()/
fail_check("adapter contains allocation, diagnostics, or a production attempt") if adapter.match?(forbidden)
fail_check("adapter must be a pure result-to-fact mapping") unless
  adapter.include?("package static func fact(for result: RenderProductionResult) -> GiftUIFailureFact?")

puts "SPEC-008 render failure adapter passed: seven exact facts and an isolated pure owner boundary."
