#!/usr/bin/env ruby
# frozen_string_literal: true

require "pathname"

ROOT = Pathname.new(File.expand_path("../..", __dir__))
TRANSACTION = ROOT.join("Sources/GiftUIExecution/ExecutionAdmissionSealTransaction.swift")
TRANSACTION_TEST = ROOT.join("Tests/GiftUIExecutionTests/ExecutionAdmissionSealTransactionTests.swift")
CONTROLLER_TEST = ROOT.join("Tests/GiftUIExecutionTests/ExecutionAdmissionControllerTests.swift")

def fail_check(message)
  warn "SPEC-009 admission seal fault check failed: #{message}"
  exit 1
end

transaction = TRANSACTION.read
transaction_tests = TRANSACTION_TEST.read
controller_tests = CONTROLLER_TEST.read

imports = transaction.scan(/^import (\S+)/).flatten
fail_check("seal transaction must import only GiftUI") unless imports == ["GiftUI"]

%w[
  ExecutionAdmissionSealFailureResult
  CancelledInputSequence
  transitionReservationAvailable
  batchReservationAvailable
  invalidProvenance
  capacityExhausted
  stagedInputCount
  stagedActivationCount
  firstFailure
  zeroSummary
  defer
  reset
].each do |fragment|
  fail_check("seal transaction lacks #{fragment}") unless transaction.include?(fragment)
end

%w[
  everySealReservationFailureHasZeroCountsAndCancelsNothing
  staleOrMalformedPointerCancelsOnlyItsCompleteSequence
  semanticActionOverflowCancelsAffectedSequenceAndNoActivationEscapes
  firstSealFailureIsStickyAcrossLaterFaults
  finalizationMakesFailedWorkspaceCleanlyReusable
].each do |name|
  fail_check("seal fault fixture lacks #{name}") unless transaction_tests.include?(name)
end

%w[
  pointerCapacityAndNewSourceRefusalPerformMandatoryCancellation
  workArrivingAfterSealIsDeferredAndRequestsFreshWake
].each do |name|
  fail_check("queue boundary fixture lacks #{name}") unless controller_tests.include?(name)
end

forbidden = /\b(?:Any|any|Task|actor|async|await|handler|model|GiftUISemanticCore|GiftUILayout|GiftUIObservableState|Backend|Platform)\b/
fail_check("seal transaction retains payload or prohibited authority") if transaction.match?(forbidden)

puts "SPEC-009 admission seal faults passed: reservations, provenance, capacity, cancellation, rollback, and reuse are covered."
