#!/usr/bin/env ruby
# frozen_string_literal: true

require "pathname"

ROOT = Pathname.new(File.expand_path("../..", __dir__))
SOURCE = ROOT.join("Sources/GiftUIObservableState/ObservableStateMutationResultSlot.swift")
TEST = ROOT.join("Tests/GiftUIObservableStateTests/ObservableStateMutationResultSlotTests.swift")

def fail_check(message)
  warn "SPEC-010 mutation result slot check failed: #{message}"
  exit 1
end

source = SOURCE.read
tests = TEST.read

fail_check("mutation slot imports differ") unless source.scan(/^import (\S+)/).flatten == ["GiftUIExecution"]
fail_check("mutation slot must remain internal") if source.match?(
  /\b(?:package|public|open) (?:struct|enum|protocol) ObservableStateMutation/
)

%w[
  cycleActive
  firstFailure
  pendingFailure
  beginCycle
  cycleLocal
  ownerAdapter
  recordReportDisposition
  consumeAfterOperation
  prepareForDerivation
].each do |fragment|
  fail_check("mutation slot lacks #{fragment}") unless source.include?(fragment)
end

first_index = source.index("if firstFailure == nil")
consume_index = source.index("let failure = firstFailure")
clear_index = source.index("firstFailure = nil", consume_index || 0)
derive_index = source.index("guard firstFailure == nil else")
unless first_index && consume_index && clear_index && derive_index &&
    first_index < consume_index && consume_index < clear_index && clear_index < derive_index
  fail_check("first-failure retention, consumption, or derivation order differs")
end

%w[
  firstFailureSurvivesLaterFailureAndSuccessUntilConsumed
  eachEnclosingOperationConsumesAndClearsBeforeDerivation
  boundSetterStoresExactFirstFailureForCoordinatorConsumption
  sinkFailureStoresSamePackageFailureBeforeReturning
  failureOutsideCycleRoutesDirectlyToOwnerAdapter
  mutationResultSlotIsBoundedInlineStateOnly
].each do |name|
  fail_check("mutation slot fixture lacks #{name}") unless tests.include?(name)
end

forbidden = /\b(?:Model|Fact|Candidate|String|Array|ContiguousArray|Dictionary|Set|Any|any|Mirror|Task|actor|async|await|throw|fatalError|GiftUISemanticCore|GiftUILayout|GiftUIInteraction|GiftUIRenderCore|GiftUIRuntime|GiftUIBackend|GiftUIPlatform|GiftUIFailureCore)\b/
fail_check("mutation slot retains a payload, history, or prohibited owner") if source.match?(forbidden)

puts "SPEC-010 mutation result slot passed: bound setters and sink failures retain the first exact cycle-local error through synchronous consumption, with direct inactive-cycle routing."
