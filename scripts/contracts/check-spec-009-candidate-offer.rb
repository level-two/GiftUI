#!/usr/bin/env ruby
# frozen_string_literal: true

require "pathname"

ROOT = Pathname.new(File.expand_path("../..", __dir__))
SOURCE = ROOT.join("Sources/GiftUIExecution/RecordingCandidateOfferCoordinator.swift")
TEST = ROOT.join("Tests/GiftUIExecutionTests/RecordingCandidateOfferCoordinatorTests.swift")

def fail_check(message)
  warn "SPEC-009 candidate offer check failed: #{message}"
  exit 1
end

source = SOURCE.read
tests = TEST.read

fail_check("candidate offer imports differ") unless source.scan(/^import (\S+)/).flatten == ["GiftUI"]
fail_check("candidate offer fixture must remain internal") if source.match?(
  /\b(?:package|public|open) (?:struct|enum|protocol) Recording(?:CandidateOrigin|PreOfferCondition|CandidateReservation|CandidateOfferOutcome|CandidateOfferCoordinator)/
)

%w[
  newPublication
  unchangedRecovery
  publishing
  deriving
  facilityUnavailableBeforeCandidate
  facilityUnavailableAfterCandidate
  directContractFailure
  candidates.reserve
  presentations.reserve
  requiredFacilityUnavailable
  identityExhausted
  endpointFailure
  offerCallCount
  endpoint.offer
].each do |fragment|
  fail_check("candidate offer fixture lacks #{fragment}") unless source.include?(fragment)
end

candidate_index = source.index("candidates.reserve")
presentation_index = source.index("presentations.reserve")
offer_index = source.index("endpoint.offer")
unless candidate_index && presentation_index && offer_index &&
    candidate_index < presentation_index && presentation_index < offer_index
  fail_check("candidate, presentation, or offer order differs")
end

%w[
  candidateAllocationUsesExactPublicationAndRecoveryPhases
  candidateAndPresentationExhaustionFailBeforeOfferAtExactPhase
  facilityAndDirectContractFailuresNeverEnterOfferBody
  invalidEnvelopeEntersOfferOnceButNeverCallsBody
  oneCandidateCanNeverInvokeOfferMoreThanOnce
].each do |name|
  fail_check("candidate offer tests lack #{name}") unless tests.include?(name)
end

forbidden = /\b(?:String|Array|ContiguousArray|Dictionary|Set|Any|any|Mirror|Task|actor|async|await|throw|fatalError|GiftUISemanticCore|GiftUILayout|GiftUIObservableState|GiftUIInteraction|GiftUIRenderCore|GiftUIRuntime|GiftUIBackend|GiftUIPlatform|GiftUIFailureCore)\b/
fail_check("candidate offer fixture selects dynamic storage or a prohibited owner") if source.match?(forbidden)

puts "SPEC-009 candidate offer passed: exact allocation phases, reservation order, pre-offer failures, invalid-envelope handling, and one-shot offer are covered."
