#!/usr/bin/env ruby
# frozen_string_literal: true

require "pathname"

ROOT = Pathname.new(File.expand_path("../..", __dir__))
SOURCE = ROOT.join("Sources/GiftUIExecution/ExecutionAdmissionController.swift")
TEST = ROOT.join("Tests/GiftUIExecutionTests/ExecutionAdmissionControllerTests.swift")

def fail_check(message)
  warn "SPEC-009 admission controller check failed: #{message}"
  exit 1
end

source = SOURCE.read
tests = TEST.read
fail_check("admission controller imports differ") unless source.scan(/^import (\w+)$/).flatten == %w[GiftUI]
fail_check("fixture controller must remain internal") if source.match?(
  /\b(?:package|public|open) (?:struct|protocol) (?:SingleSourceExecutionAdmissionController|ExecutionPendingAdmissionStorage)\b/
)

required = [
  "ExecutionAdmissionSink",
  "ExecutionPendingAdmissionStorage",
  "pointer.presentationRevision == committedPresentationRevision",
  "trackedSource == nil || trackedSource == pointer.source",
  "sourceSequence.cancelCurrentSequence()",
  "storage.cancelPointerSequence(",
  "storage.pointerCount < limits.maximumInputEvents",
  "storage.stateChangeCount < limits.maximumStateChangeFacts",
  "limits.maximumCompletionFacts > 0",
  "storage.completionCount < limits.maximumCompletionFacts",
  "wakeAccumulator.accumulate(.admittedWork)",
  "ExecutionAdmissionOutcome(result: result, context: context)",
]
required.each do |fragment|
  fail_check("admission controller lacks #{fragment}") unless source.include?(fragment)
end

%w[
  queuedSubmissionsCopyCompleteValuesAndRequestOneWake
  everyOutcomePreservesTheExactCurrentContext
  invalidAndDisabledFactsRetainNoCopyAndRequestNoWake
  categoryCapacityRefusalRetainsNoRejectedCopyOrExtraWake
  pointerProvenanceAndSequenceFailureCancelWithoutQueuing
  pointerCapacityAndNewSourceRefusalPerformMandatoryCancellation
  quiescenceRefusesEveryFamilyAndPointerCancellationIsMandatory
  submissionNeverAppliesFactsOrPromisesCurrentCycleMembership
].each do |name|
  fail_check("admission fixture lacks #{name}") unless tests.include?(name)
end

forbidden = /\b(?:Any|any|Task|actor|async|await|throw|apply|dispatch|handler|model|GiftUISemanticCore|GiftUILayout|GiftUIObservableState|Backend|Platform)\b/
fail_check("admission controller applies work or imports prohibited authority") if source.match?(forbidden)

puts "SPEC-009 admission controller passed: pointer, state, and completion ownership/refusal paths are bounded and non-applying."
