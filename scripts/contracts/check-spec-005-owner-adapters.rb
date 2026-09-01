#!/usr/bin/env ruby
# frozen_string_literal: true

root = File.expand_path("../..", __dir__)
source_path = File.join(
  root,
  "Sources/GiftUITextResourceFailureAdapterFixture/GiftUITextResourceFailureAdapterFixture.swift"
)
test_path = File.join(
  root,
  "Tests/GiftUITextResourceOwnerAdapterTests/GiftUITextResourceOwnerAdapterTests.swift"
)

def fail_check(message)
  warn "SPEC-005 owner adapter check failed: #{message}"
  exit 1
end

source = File.read(source_path)
tests = File.read(test_path)
imports = source.scan(/^import (\w+)$/).flatten
fail_check("adapter imports differ") unless imports == %w[GiftUIFailureCore GiftUITextResources]
fail_check("diagnostics leaked into adapter") if source.include?("GiftUIFailureDiagnostics")

%w[
  unsupportedSchema invalidCount malformedMetrics malformedMapping
  malformedRasterRecord invalidIdentity incompatibleViews integrityMismatch
  capacityExceeded invalidValue invalidIdentity capacityExhausted
  hostComposition runtime contained invariantViolation layout rendering
  candidateFrame safetyNotProven arithmeticOverflow foundation operation
  requiredFacilityUnavailable
].each do |fragment|
  fail_check("adapter lacks #{fragment}") unless source.include?(fragment)
end
fail_check("adapter tests do not exercise diagnostics") unless tests.include?("GiftUIFixedDiagnosticBuffer")
fail_check("adapter tests do not enumerate all nine local errors") unless
  tests.scan(/^\s*\.\w+,?$/).map(&:strip).uniq.length >= 9

puts "SPEC-005 owner adapter check passed: exact imports, nine local mappings, owner facts, and diagnostic independence."
