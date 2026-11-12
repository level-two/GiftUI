#!/usr/bin/env ruby
# frozen_string_literal: true

require "pathname"

ROOT = Pathname.new(File.expand_path("../..", __dir__))
SOURCE = ROOT.join("Sources/GiftUISemanticCore/GiftUISemanticCore.swift")
TEST = ROOT.join("Tests/GiftUISemanticCoreTests/SemanticExpansionTraversalTests.swift")

def fail_check(message)
  warn "SPEC-006 stateful binding failure check failed: #{message}"
  exit 1
end

source = SOURCE.read
tests = TEST.read

errors = %w[
  locationCapacityExhausted registrationCapacityExhausted
  associationStagingCapacityExhausted replacementStagingCapacityExhausted
  registrationGenerationExhausted duplicateOwner incompatibleAssociation
  staleAttachment invalidPhaseContained invalidPhaseSafetyNotProven
  reentrancyViolation invariantViolation
]
errors.each do |error|
  fail_check("fixture lacks #{error}") unless tests.include?(".#{error}")
end

required = [
  "let failureOrdinal = UInt16(index % 2)",
  "XCTAssertEqual(result, .bindingFailure(error))",
  'XCTAssertFalse(trace.events.contains("body"))',
  "XCTAssertEqual(sink.bodyEvaluationStageCount, 0)",
  "XCTAssertTrue(sink.committedEvents.isEmpty)",
  "XCTAssertTrue(sink.stagedEvents.isEmpty)",
  "XCTAssertEqual(sink.publishCount, 0)",
  "XCTAssertEqual(sink.discardCount, 1)",
  "XCTAssertFalse(workspace.isExpanding)",
]
required.each do |fragment|
  fail_check("failure matrix lacks #{fragment}") unless tests.include?(fragment)
end

finish_body = source[/package mutating func finishBody<.*?^    }/m]
fail_check("body finish does not preserve binding failures") unless finish_body&.include?("case .bindingFailure(let error): bindingFailure = error")
fail_check("owner failure is converted to semantic failure") if finish_body&.include?("case .bindingFailure(let error): stop(")
finalize = source[/package mutating func finalizeExpansion\(\).*?^    }/m]
fail_check("owner failure does not discard the staged candidate") unless finalize&.include?("discardTraversalForOwnerFailure()")
fail_check("owner failure does not remain a typed binding failure") unless finalize&.include?("return .bindingFailure(failure)")

puts "SPEC-006 stateful binding failures passed: 12 exact owner errors, early/late injection, atomic discard, and no semantic substitution."
