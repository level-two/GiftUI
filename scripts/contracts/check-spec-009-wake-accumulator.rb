#!/usr/bin/env ruby
# frozen_string_literal: true

require "pathname"

ROOT = Pathname.new(File.expand_path("../..", __dir__))
SOURCE = ROOT.join("Sources/GiftUIExecution/ExecutionWakeAccumulator.swift")
TEST = ROOT.join("Tests/GiftUIExecutionTests/ExecutionWakeAccumulatorTests.swift")

def fail_check(message)
  warn "SPEC-009 wake accumulator check failed: #{message}"
  exit 1
end

source = SOURCE.read
tests = TEST.read

fail_check("wake accumulator must not import another owner") unless source.scan(/^import /).empty?
fail_check("wake accumulator must remain internal") if source.match?(
  /\b(?:package|public|open) (?:struct|enum|protocol) ExecutionWakeAccumulator\b/
)

required = [
  "private(set) var accumulatedReasons: ExecutionWakeReasons",
  "private(set) var wakeOutstanding: Bool",
  "ExecutionWakeReasons(rawValue: reasons.rawValue)",
  "guard !normalized.isEmpty else { return }",
  "accumulatedReasons.formUnion(normalized)",
  "guard !wakeOutstanding else { return }",
  "requester.requestWake(for: accumulatedReasons)",
  "guard phase == .idle else { return nil }",
  "accumulatedReasons = []",
  "wakeOutstanding = false",
]
required.each do |fragment|
  fail_check("wake accumulator lacks #{fragment}") unless source.include?(fragment)
end

%w[
  emptyToNonemptyRequestsOnceAndDuplicatesCoalesce
  rawReasonsAreMaskedBeforeAccumulationAndForwarding
  idleTakeAtomicallyAcknowledgesReasonsBeforeLaterWake
  laterReasonCreatesOneTransitionDuringEveryActivePhase
  nonidleTakeCannotAcknowledgeOutstandingWake
  redundantIdleOpportunityTakesEmptyWithoutRequest
].each do |name|
  fail_check("wake fixture lacks #{name}") unless tests.include?(name)
end

forbidden = /\b(?:Array|ContiguousArray|Dictionary|Set|Any|any|Task|actor|async|await|throw|scheduler|schedule|runCycle|GiftUISemanticCore|GiftUILayout|GiftUIObservableState|Interaction|Backend|Platform)\b/
fail_check("wake accumulator retains a payload or prohibited authority") if source.match?(forbidden)

puts "SPEC-009 wake accumulator passed: masking, coalescing, atomic take, later transitions, and redundant opportunities are covered."
