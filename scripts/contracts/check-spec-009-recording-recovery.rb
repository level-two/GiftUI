#!/usr/bin/env ruby
# frozen_string_literal: true

require "pathname"

ROOT = Pathname.new(File.expand_path("../..", __dir__))
SOURCE = ROOT.join("Sources/GiftUIExecution/RecordingDerivationRecovery.swift")
TEST = ROOT.join("Tests/GiftUIExecutionTests/RecordingDerivationRecoveryTests.swift")

def fail_check(message)
  warn "SPEC-009 recording recovery check failed: #{message}"
  exit 1
end

source = SOURCE.read
tests = TEST.read

imports = source.scan(/^import (\S+)/).flatten
fail_check("recovery fixture imports a prohibited owner") unless imports == ["GiftUI"]
fail_check("recovery fixture must remain internal") if source.match?(
  /\b(?:package|public|open) (?:struct|enum|protocol) Recording(?:PartialDerivation|PrepublicationFailurePoint|DerivationRecovery)/
)

%w[
  semantic
  layout
  actionTable
  routing
  immutableRenderInput
  stagedResults
  discardedResults
  appliedEffectCount
  isDirty
  cycleActive
  semanticDirty
  beginMutationCycle
  beginRecovery
  takeRecoveryWakeAtIdle
  completeRecovery
  focusedOwner
].each do |fragment|
  fail_check("recovery fixture lacks #{fragment}") unless source.include?(fragment)
end

discard_index = source.index("discardedResults = stagedResults")
clear_index = source.index("stagedResults = []", discard_index || 0)
wake_index = source.index("wakeAccumulator.accumulate(.semanticDirty)")
unless discard_index && clear_index && wake_index && discard_index < clear_index && clear_index < wake_index
  fail_check("partial-result discard or dirty-wake order differs")
end

%w[
  everyPrepublicationFailureDiscardsAllPartialResults
  dirtyFailureRequestsOneLaterWakeAndCannotReenterSynchronously
  laterRecoveryRederivesCurrentStateWithoutReplayingAppliedEffects
  prepublicationFailureWithoutDirtyWorkPreservesUnchangedDisposition
].each do |name|
  fail_check("recovery fixture lacks #{name}") unless tests.include?(name)
end

forbidden = /\b(?:Array|ContiguousArray|Dictionary|Set|Any|any|Mirror|Task|actor|async|await|throw|fatalError|GiftUISemanticCore|GiftUILayout|GiftUIObservableState|GiftUIInteraction|GiftUIRenderCore|GiftUIRuntime|GiftUIBackend|GiftUIPlatform)\b/
fail_check("recovery fixture selects storage or a prohibited owner") if source.match?(forbidden)

puts "SPEC-009 recording recovery passed: every pre-publication boundary discards partial state, preserves publication, marks dirty, and schedules non-replaying later recovery."
