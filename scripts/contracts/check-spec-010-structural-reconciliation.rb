#!/usr/bin/env ruby
# frozen_string_literal: true

require "pathname"

ROOT = Pathname.new(File.expand_path("../..", __dir__))
SOURCE = ROOT.join(
  "Sources/GiftUIObservableState/ObservableStateAssociationLifecycle.swift"
)
TEST = ROOT.join(
  "Tests/GiftUIObservableStateTests/ObservableStateAssociationLifecycleTests.swift"
)

def fail_check(message)
  warn "SPEC-010 structural reconciliation check failed: #{message}"
  exit 1
end

source = SOURCE.read
tests = TEST.read

fail_check("association lifecycle must remain internal") if source.match?(
  /\b(?:package|public|open) (?:struct|enum|protocol) ObservableStateAssociationLifecycle\b/
)
fail_check("association lifecycle must not import another owner") unless source.scan(/^import /).empty?

required_source = [
  "case vacant",
  "case live(StructuralIdentity, UInt16, ModelDiscriminator)",
  "case retired",
  "case shutdown",
  "case preserved",
  "case materialized(StructuralIdentity, UInt16, ModelDiscriminator)",
  "case removalStaged",
  "case detachCandidate",
  "case detachLive",
  "return .failure(.duplicateOwner)",
  "return .failure(.incompatibleAssociation)",
  "return .failure(.invalidPhaseSafetyNotProven)",
]
required_source.each do |fragment|
  fail_check("association lifecycle lacks #{fragment}") unless source.include?(fragment)
end

forbidden = /\b(?:Array|ContiguousArray|Dictionary|Set|Any|any|Mirror|Task|actor|async|await|throw|fatalError|GiftUIFailureCore|GiftUIRuntime|GiftUIBackend|GiftUIPlatform)\b/
fail_check("association lifecycle selects dynamic storage or a prohibited owner") if source.match?(forbidden)

required_tests = [
  "firstEncounterMaterializesAndPublishedEncounterPreservesIdentity",
  "declarationOrdinalDistinguishesLocationsAndIncompatibleTypeFailsClosed",
  "duplicateOwnershipFailsBeforeAttachmentAndPreservesOriginalOwner",
  "removalPublishesRetirementAndReinsertionCreatesFreshState",
  "discardedDerivationPreservesLiveAndDetachesCandidateOnlyState",
  "shutdownDetachesInstalledSinkOnceAndPermanentlyClosesTheSlot",
  "#expect(repeatedInitializer.attachCount == 0)",
  "#expect(model.detachCount == 1)",
  "#expect(model.applicationStartCount == 0)",
  "#expect(model.applicationStopCount == 0)",
]
required_tests.each do |fragment|
  fail_check("structural fixture lacks #{fragment}") unless tests.include?(fragment)
end

puts "SPEC-010 structural reconciliation passed: bounded association transitions, removal, discard, reinsertion, and shutdown are covered."
