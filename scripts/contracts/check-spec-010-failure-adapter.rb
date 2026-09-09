#!/usr/bin/env ruby
# frozen_string_literal: true

require "pathname"

ROOT = Pathname.new(File.expand_path("../..", __dir__))
SOURCE = ROOT.join("Sources/GiftUIObservableStateFailureAdapterFixture/ObservableStateFailureAdapter.swift")
TEST = ROOT.join("Tests/GiftUIObservableStateFailureAdapterTests/ObservableStateFailureAdapterTests.swift")

def fail_check(message)
  warn "SPEC-010 failure adapter check failed: #{message}"
  exit 1
end

source = SOURCE.read
tests = TEST.read
fail_check("adapter imports differ") unless source.scan(/^import (\w+)/).flatten == %w[GiftUIFailureCore GiftUIObservableState]
%w[
  locationCapacityExhausted registrationCapacityExhausted associationStagingCapacityExhausted
  replacementStagingCapacityExhausted registrationGenerationExhausted duplicateOwner
  incompatibleAssociation staleAttachment invalidPhaseContained invalidPhaseSafetyNotProven
  reentrancyViolation invariantViolation mandatoryEffectsComplete localError detectionContext
].each do |fragment|
  fail_check("adapter lacks #{fragment}") unless source.include?(fragment)
end
%w[capacityExhausted invalidIdentity invalidPhase observableState activeCycle component operation runtime contained safetyNotProven].each do |fragment|
  fail_check("adapter mapping lacks #{fragment}") unless source.include?(fragment)
end
%w[everyObservableStateFailureContextMapsExactlyAfterEffects mappingRejectsIncompleteEffectsAndEveryInvalidContextPair].each do |name|
  fail_check("adapter tests lack #{name}") unless tests.include?(name)
end
forbidden = /\b(?:String|Array|Dictionary|Set|Any|Mirror|Task|actor|async|await|throw|fatalError|Diagnostic|GiftUIExecution|GiftUIRuntime|GiftUIBackend|GiftUIPlatform)\b/
fail_check("adapter contains a prohibited carrier or owner") if source.match?(forbidden)

puts "SPEC-010 failure adapter passed: all 16 context rows map exactly after mandatory effects, and every invalid context pair is rejected."
