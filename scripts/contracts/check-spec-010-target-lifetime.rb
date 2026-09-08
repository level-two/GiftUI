#!/usr/bin/env ruby
# frozen_string_literal: true

require "pathname"

ROOT = Pathname.new(File.expand_path("../..", __dir__))
SOURCE = ROOT.join("Sources/GiftUIObservableState/ObservableStateTargetLifetime.swift")
TEST = ROOT.join("Tests/GiftUIObservableStateTests/ObservableStateTargetLifetimeTests.swift")
REPLACEMENT_TEST = ROOT.join("Tests/GiftUIObservableStateTests/ObservableStateReplacementTransactionTests.swift")

def fail_check(message)
  warn "SPEC-010 target lifetime check failed: #{message}"
  exit 1
end

source = SOURCE.read
tests = TEST.read
replacement_tests = REPLACEMENT_TEST.read

fail_check("target lifetime imports differ") unless source.scan(/^import (\S+)/).flatten == %w[GiftUI GiftUIExecution]
fail_check("target lifetime must remain internal") if source.match?(
  /\b(?:package|public|open) (?:struct|enum|protocol) ObservableStateTargetLifetime/
)

%w[
  ObservableStateInteractionCandidateDiscarder
  ObservableStateTargetLifetimeCleanup
  attachmentToDetach
  retiredGeneration
  recordPreservedEncounter
  recordCandidateOnlyEncounter
  buildInteractionCandidate
  borrowing
  discardInteractionCandidate
  finishCandidate
].each do |fragment|
  fail_check("target lifetime lacks #{fragment}") unless source.include?(fragment)
end
fail_check("target lookup storage must be private") unless source.include?(
  "private var lookup: ObservableStateTargetLookupSlot"
)

%w[
  candidateDiscardDetachesRetiresAndForcesInteractionDiscard
  publishedRemovalRetiresTheLiveAttachmentAndGeneration
  preservedDiscardKeepsLiveAndStillDiscardsInteractionCandidate
  publishedCandidateBecomesLiveWithoutInteractionDiscard
].each do |name|
  fail_check("target lifetime fixture lacks #{name}") unless tests.include?(name)
end
%w[
  everyPrecommitValidationOrReservationFailurePreservesFormerState
  attachmentReturnFailureDiscardsCandidateAndPreservesFormer
].each do |name|
  fail_check("replacement preservation fixture lacks #{name}") unless replacement_tests.include?(name)
end

forbidden = /\b(?:Model|Sink|Handler|Callable|Array|ContiguousArray|Dictionary|Set|Any|any|Mirror|Task|actor|async|await|throw|fatalError|GiftUIInteraction|GiftUIFailureCore|GiftUIRuntime|GiftUIBackend|GiftUIPlatform)\b/
fail_check("target lifetime retains a model or imports a prohibited owner") if source.match?(forbidden)

puts "SPEC-010 target lifetime passed: candidate/removal retirement, mandatory interaction discard, former preservation, and scoped borrowing are covered."
