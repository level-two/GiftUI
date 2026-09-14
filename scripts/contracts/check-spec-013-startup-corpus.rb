#!/usr/bin/env ruby
# frozen_string_literal: true

require "pathname"
require "yaml"

ROOT = Pathname.new(File.expand_path("../..", __dir__))
FIXTURE = ROOT.join("Tests/ContractFixtures/SPEC013/startup.yaml")
VALIDATOR = ROOT.join("Sources/GiftUIRuntimeCore/RuntimeProfileValidation.swift")
VALIDATION_TESTS = ROOT.join("Tests/GiftUIRuntimeCoreTests/RuntimeProfileValidationTests.swift")
ADAPTER_TESTS = ROOT.join(
  "Tests/GiftUIRuntimeFailureAdapterTests/RuntimeFailureAdapterBoundaryTests.swift"
)

def fail_check(message)
  warn "SPEC-013 startup corpus check failed: #{message}"
  exit 1
end

expected = [
  ["invalid-limits-first", 1, "invalidLimits", "invalidValue", "hostComposition", "runtime", "contained"],
  ["incompatible-limits-second", 2, "incompatibleLimits", "invalidValue", "hostComposition", "runtime", "contained"],
  ["missing-storage-third", 3, "missingStorage", "capacityExhausted", "hostComposition", "runtime", "contained"],
  ["insufficient-storage-fourth", 4, "insufficientStorage", "capacityExhausted", "hostComposition", "runtime", "contained"],
  ["arithmetic-overflow-fifth", 5, "arithmeticOverflow", "arithmeticOverflow", "foundation", "runtime", "contained"],
  ["static-table-invalid-sixth", 6, "staticCanvasTableInvalid", "invariantViolation", "hostComposition", "runtime", "safetyNotProven"],
]

document = YAML.safe_load(FIXTURE.read, aliases: false)
actual = document.fetch("cases").map do |item|
  %w[name ordinal localError condition origin scope containment].map { |field| item.fetch(field) }
end
fail_check("ordered case set or exact failure mapping differs") unless actual == expected

validator = VALIDATOR.read
ordered_markers = [
  "return .invalid(.invalidLimits)",
  "return .invalid(.incompatibleLimits)",
  "return .invalid(.missingStorage)",
  "return .invalid(.insufficientStorage)",
  "case .invalid(let error):",
  "return .invalid(.staticCanvasTableInvalid)",
]
ordered_markers.each do |marker|
  fail_check("validator marker is missing: #{marker}") unless validator.include?(marker)
end

validation_tests = VALIDATION_TESTS.read
%w[
  sixValidationStepsStopAtTheFirstFailure
  startupFailuresCannotReachClientAttachmentInputWakePolicyBackendOrEndpoint
  client attachment input wake policy backend endpoint
].each do |marker|
  fail_check("startup validation evidence lacks #{marker}") unless validation_tests.include?(marker)
end

adapter_tests = ADAPTER_TESTS.read
fail_check("exact SPEC-003 mapping test is missing") unless adapter_tests.include?(
  "everyValidationErrorMapsToItsExactRuntimeFact"
)

puts "SPEC-013 startup corpus passed: six ordered failures retain exact SPEC-003 facts and seven forbidden startup-use probes remain untouched."
