#!/usr/bin/env ruby
# frozen_string_literal: true

require "pathname"

ROOT = Pathname.new(File.expand_path("../..", __dir__))
SOURCE = ROOT.join("Sources/GiftUIExecution/RecordingFrameCommitTransaction.swift")
TEST = ROOT.join("Tests/GiftUIExecutionTests/RecordingFrameCommitTransactionTests.swift")

def fail_check(message)
  warn "SPEC-009 frame commit check failed: #{message}"
  exit 1
end

source = SOURCE.read
tests = TEST.read

fail_check("frame commit imports differ") unless source.scan(/^import (\S+)/).flatten == ["GiftUI"]
fail_check("frame commit fixture must remain internal") if source.match?(
  /\b(?:package|public|open) (?:struct|enum|protocol) Recording(?:PresentationState|EndpointHealth|FrameCommitOutcome|FrameCommitTransaction)/
)

%w[
  presentationRevision
  logicalFrameToken
  hitGeometryToken
  actionTableToken
  routingToken
  publishedSemanticRevision
  committedState
  stagedState
  stagedCandidate
  candidateAborted
  completeConsumptionAndReservation
  irreversibleOutputObserved
  abortStagedState
].each do |fragment|
  fail_check("frame commit fixture lacks #{fragment}") unless source.include?(fragment)
end

%w[
  acceptedOfferCommitsEveryCoupledFieldAtomically
  everyNonacceptedResultAbortsAllStagedStateAndPreservesPriorRouting
  incompleteAcceptedOfferCannotPublishAnyCoupledField
  irreversibleOutputCanFinishOnlyAsAcceptedEndpointHealth
  transactionStagesAndFinishesExactlyOnce
].each do |name|
  fail_check("frame commit tests lack #{name}") unless tests.include?(name)
end

forbidden = /\b(?:String|Array|ContiguousArray|Dictionary|Set|Any|any|Mirror|Task|actor|async|await|throw|fatalError|GiftUISemanticCore|GiftUILayout|GiftUIObservableState|GiftUIInteraction|GiftUIRenderCore|GiftUIRuntime|GiftUIBackend|GiftUIPlatform|GiftUIFailureCore)\b/
fail_check("frame commit fixture selects dynamic storage or a prohibited owner") if source.match?(forbidden)

puts "SPEC-009 frame commit passed: complete atomic acceptance, universal candidate abort, prior routing and semantic preservation, and irreversible-output health are covered."
