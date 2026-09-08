#!/usr/bin/env ruby
# frozen_string_literal: true

require "pathname"

ROOT = Pathname.new(File.expand_path("../..", __dir__))
SOURCE = ROOT.join("Sources/GiftUIExecution/RecordingDerivationTransaction.swift")
TEST = ROOT.join("Tests/GiftUIExecutionTests/RecordingDerivationTransactionTests.swift")

def fail_check(message)
  warn "SPEC-009 recording derivation check failed: #{message}"
  exit 1
end

source = SOURCE.read
tests = TEST.read

fail_check("derivation transaction must import no other owner") unless source.scan(/^import /).empty?
fail_check("derivation transaction must remain internal") if source.match?(
  /\b(?:package|public|open) (?:struct|enum|protocol) Recording(?:PublishedDerivation|DerivationOutcome|DerivationTransaction)/
)

%w[
  RecordingPublishedDerivation
  RecordingDerivationOutcome
  mutationMembershipFrozen
  needsLaterSemanticWake
  hasAdmittedInvalidation
  freezeMutationMembership
  finishDerivation
  stagedActionCount
  maximumCommittedActions
  actionGenerations.reserve
  semanticRevisions.reserve
  publishedRevision
  presentationRecoveryRequired
  unchanged
].each do |fragment|
  fail_check("derivation transaction lacks #{fragment}") unless source.include?(fragment)
end

action_index = source.index("actionGenerations.reserve")
semantic_index = source.index("semanticRevisions.reserve")
publication_index = source.index("publishedRevision = semanticRevision")
unless action_index && semantic_index && publication_index &&
    action_index < semantic_index && semantic_index < publication_index
  fail_check("reservation or publication order differs")
end

%w[
  mutationMembershipFreezesAndInvalidationsCoalesceByEpoch
  changedDerivationReservesActionsThenPublishesAtomically
  everyPrepublicationReservationFailurePreservesPriorPublication
  unchangedWithoutObligationAllocatesNoCandidateOrFrame
].each do |name|
  fail_check("derivation fixture lacks #{name}") unless tests.include?(name)
end

forbidden = /\b(?:Array|ContiguousArray|Dictionary|Set|Any|any|Mirror|Task|actor|async|await|throw|fatalError|GiftUISemanticCore|GiftUILayout|GiftUIObservableState|GiftUIInteraction|GiftUIRenderCore|GiftUIRuntime|GiftUIBackend|GiftUIPlatform)\b/
fail_check("derivation transaction selects storage or a prohibited owner") if source.match?(forbidden)

puts "SPEC-009 recording derivation passed: frozen membership, epoch invalidation, ordered reservations, atomic publication, and unchanged-cycle elision are covered."
