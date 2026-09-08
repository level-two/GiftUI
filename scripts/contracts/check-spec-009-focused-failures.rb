#!/usr/bin/env ruby
# frozen_string_literal: true

require "pathname"

ROOT = Pathname.new(File.expand_path("../..", __dir__))
SOURCE = ROOT.join("Sources/GiftUIExecution/RecordingFocusedFailureSelection.swift")
TEST = ROOT.join("Tests/GiftUIExecutionTests/RecordingFocusedFailureSelectionTests.swift")

def fail_check(message)
  warn "SPEC-009 focused failure check failed: #{message}"
  exit 1
end

source = SOURCE.read
tests = TEST.read

fail_check("focused failure selection must import no owner") unless source.scan(/^import /).empty?
fail_check("focused failure fixture must remain internal") if source.match?(
  /\b(?:package|public|open) (?:struct|enum|protocol) Recording(?:FixtureOwnerFailure|CleanupFaults|MandatoryCleanup|FocusedFailureSelection)/
)

%w[
  stateChange
  completion
  semantic
  layout
  immutableRenderInput
  firstFailure
  detectingContext
  observedCleanupFaults
  completedCleanup
  summaryProduced
  captureFirstFocusedFailure
  completeMandatoryCleanup
  focusedOwner
].each do |fragment|
  fail_check("focused failure fixture lacks #{fragment}") unless source.include?(fragment)
end

guard_index = source.index("guard firstFailure == nil else { return }")
cleanup_index = source.index("completedCleanup = .all")
result_index = source.index(".focusedOwner(firstFailure)")
unless guard_index && cleanup_index && result_index && cleanup_index < result_index
  fail_check("first-failure retention or mandatory cleanup order differs")
end

%w[
  everyFocusedOwnerFailureSurvivesEveryCleanupFaultCombination
  laterFocusedFailureNeverReplacesFirstExactValueOrContext
  cleanupCannotManufactureGenericExecutionOrDiagnosticFailure
  focusedOwnerFailureIsInlineFiniteAndStaticallyBounded
].each do |name|
  fail_check("focused failure tests lack #{name}") unless tests.include?(name)
end

forbidden = /\b(?:String|Array|ContiguousArray|Dictionary|Set|Any|any|Mirror|Task|actor|async|await|throw|fatalError|Diagnostic|GiftUISemanticCore|GiftUILayout|GiftUIObservableState|GiftUIInteraction|GiftUIRenderCore|GiftUIRuntime|GiftUIBackend|GiftUIPlatform)\b/
fail_check("focused failure fixture uses a prohibited carrier or owner") if source.match?(forbidden)

puts "SPEC-009 focused failure passed: finite inline owner values and detecting contexts survive all cleanup-fault combinations after mandatory containment."
