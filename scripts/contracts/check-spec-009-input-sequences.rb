#!/usr/bin/env ruby
# frozen_string_literal: true

require "pathname"

ROOT = Pathname.new(File.expand_path("../..", __dir__))
SOURCE = ROOT.join("Sources/GiftUIExecution/InputSourceSequenceState.swift")
TEST = ROOT.join("Tests/GiftUIExecutionTests/InputSourceSequenceStateTests.swift")

def fail_check(message)
  warn "SPEC-009 input sequence check failed: #{message}"
  exit 1
end

source = SOURCE.read
tests = TEST.read
fail_check("input sequence owner imports differ") unless source.scan(/^import (\w+)$/).flatten == %w[GiftUI]

required = [
  "case synchronized = 0",
  "case active = 1",
  "case cancelled = ",
  "case quiescent = 3",
  "nextSubmittedSequenceRaw: UInt32? = 0",
  "addingReportingOverflow(1)",
  "targetGateAllowsResynchronization",
  "return .invalidProvenance",
  "return .unavailable",
  ".consumedWhileCancelled",
]
required.each do |fragment|
  fail_check("input sequence state lacks #{fragment}") unless source.include?(fragment)
end

%w[
  targetGateConsumesOnlySubmittedDownSequences
  targetGateReservesMaximumThenPermanentlyExhausts
  firstDownAndLaterPhasesUseExactZeroAndSuccessors
  gapsDuplicatesDecreasesAndWrongSequencesCancelWithoutBaselineAdvance
  cancelledSequenceConsumesExactSuffixWithoutDispatch
  replacementDownRequiresIndependentTargetProofAndExactRuntimeSequence
  ordinalExhaustionCancelsAndSequenceExhaustionQuiesces
  boundedSourcesMaintainIndependentSequenceAndOrdinalState
].each do |name|
  fail_check("input sequence fixture lacks #{name}") unless tests.include?(name)
end

forbidden = /\b(?:Array|ContiguousArray|Dictionary|Set|Any|any|Task|actor|async|await|throw|Action|handler|model|GiftUISemanticCore|GiftUILayout|GiftUIObservableState|Backend|Platform)\b/
fail_check("input sequence owner retains payload or prohibited authority") if source.match?(forbidden)

puts "SPEC-009 input sequences passed: target allocation and independent runtime sequence/ordinal validation are bounded."
