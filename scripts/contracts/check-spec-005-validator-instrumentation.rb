#!/usr/bin/env ruby
# frozen_string_literal: true

def fail_check(message)
  warn "SPEC-005 validator-instrumentation check failed: #{message}"
  exit 1
end

allocation = File.read(ARGV.fetch(0) { fail_check("expected allocation probe") })
validator_tests = File.read(ARGV.fetch(1) { fail_check("expected validator tests") })
work_tests = File.read(ARGV.fetch(2) { fail_check("expected work-bound tests") })

[
  "TextResourceValidator.validate(",
  "resetAllocationCount()",
  "allocation_count=",
  "allocation_count.validation",
  "allocation_count.mapping",
  "allocation_count.metric_lookup",
  "allocation_count.raster_lookup",
  "allocation_count.payload_borrow",
  "allocation_count.synchronous_offer",
].each do |fragment|
  fail_check("allocation probe lacks #{fragment}") unless allocation.include?(fragment)
end

[
  "testValidatorVisitsCompleteTablesAndEachPayloadByteOncePerDigestPass",
  "XCTAssertEqual(raster.payloadVisits, 1)",
  "XCTAssertEqual(raster.payloadByteVisits, base.raster.payload.count)",
  "testValidatorRunsOnlyAtAssemblyNotPerGlyphOrFrame",
  "XCTAssertEqual(glyphLookups, 256)",
  "XCTAssertEqual(assembly.validationCalls, 1)",
].each do |fragment|
  fail_check("validator tests lack #{fragment}") unless validator_tests.include?(fragment)
end

unless work_tests.include?("testMaximumLinearMappingLookupUsesExactly256Comparisons") &&
       work_tests.include?("XCTAssertEqual(fixture.metrics.mappingVisits, 256)") &&
       work_tests.include?("testCanonicalPathVisitsEveryTableEntryExactlyOnce")
  fail_check("comparison or full-table canonical counters are incomplete")
end

puts "SPEC-005 validator-instrumentation check passed: allocation, traversal, payload, comparison, and call-frequency probes are present."
