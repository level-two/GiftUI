#!/usr/bin/env ruby
# frozen_string_literal: true

require "pathname"

ROOT = Pathname.new(File.expand_path("../..", __dir__))
SOURCE = ROOT.join("Sources/GiftUIObservableState/ObservableStateDirtyDerivation.swift")
TEST = ROOT.join("Tests/GiftUIObservableStateTests/ObservableStateDirtyDerivationTests.swift")

def fail_check(message)
  warn "SPEC-010 dirty derivation check failed: #{message}"
  exit 1
end

source = SOURCE.read
tests = TEST.read

fail_check("dirty derivation imports differ") unless source.scan(/^import (\S+)/).flatten == ["GiftUIExecution"]
fail_check("dirty derivation must remain internal") if source.match?(
  /\b(?:package|public|open) (?:struct|enum|protocol) ObservableStateDirty/
)

%w[
  dirtyLocations
  representedDirtyLocations
  mutationFrozen
  completeRootDerivationCount
  lastDerivedLocationCount
  appliedMutationCount
  semanticWakeOutstanding
  recordChangedMutation
  takeWakeAtIdle
  freezeAndDeriveCompleteRoot
  finishDerivation
  finishFrame
  requestSemanticWakeIfNeeded
  semanticDirty
].each do |fragment|
  fail_check("dirty derivation lacks #{fragment}") unless source.include?(fragment)
end

freeze_index = source.index("mutationFrozen = true")
snapshot_index = source.index("representedDirtyLocations = dirtyLocations")
clear_index = source.index("dirtyLocations.subtract(representedDirtyLocations)")
unless freeze_index && snapshot_index && clear_index &&
    freeze_index < snapshot_index && snapshot_index < clear_index
  fail_check("freeze, represented epoch, or publication clearing order differs")
end

%w[
  dirtyLocationsShareOneWakeAndTriggerCompleteRootDerivation
  successfulPublicationClearsExactlyRepresentedDirtiness
  frameRefusalDoesNotRestoreDirtinessAfterPublication
  derivationFailureRetainsDirtyAndSchedulesRecoveryWithoutReplay
  mutationFreezeRejectsFurtherMutationAndRepeatedFreeze
].each do |name|
  fail_check("dirty derivation fixture lacks #{name}") unless tests.include?(name)
end

forbidden = /\b(?:String|Array|ContiguousArray|Dictionary|Set|Any|any|Mirror|Task|actor|async|await|throw|fatalError|GiftUISemanticCore|GiftUILayout|GiftUIInteraction|GiftUIRenderCore|GiftUIRuntime|GiftUIBackend|GiftUIPlatform)\b/
fail_check("dirty derivation selects dynamic storage or a prohibited owner") if source.match?(forbidden)

puts "SPEC-010 dirty derivation passed: one wake, complete-root freeze, publication clearing, refusal independence, and non-replaying failure recovery are covered."
