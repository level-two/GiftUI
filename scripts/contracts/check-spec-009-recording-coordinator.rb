#!/usr/bin/env ruby
# frozen_string_literal: true

require "pathname"

ROOT = Pathname.new(File.expand_path("../..", __dir__))
SOURCE = ROOT.join("Sources/GiftUIExecution/RecordingCycleCoordinator.swift")
TEST = ROOT.join("Tests/GiftUIExecutionTests/RecordingCycleCoordinatorTests.swift")

def fail_check(message)
  warn "SPEC-009 recording coordinator check failed: #{message}"
  exit 1
end

source = SOURCE.read
tests = TEST.read

fail_check("recording coordinator imports differ") unless source.scan(/^import (\S+)/).flatten == ["GiftUI"]
fail_check("recording coordinator must remain internal") if source.match?(
  /\b(?:package|public|open) (?:struct|enum|protocol) RecordingCycle/
)

%w[
  RecordingCycleEventKind
  wakeTransition
  wakeTaken
  admitting
  mutating
  deriving
  publishing
  offering
  finalizing
  resultSelected
  idleAuthoritativeState
  RecordingCycleEventSink
  ExecutionOpportunityRunner
  ExecutionPhaseMachine
  ExecutionWakeAccumulator
].each do |fragment|
  fail_check("recording coordinator lacks #{fragment}") unless source.include?(fragment)
end

%w[
  unchangedRecordingCycleUsesCanonicalPhaseAndResultEvents
  publishedRecordingCycleCoversPublishingOfferingAndAuthoritativeState
  wakeTransitionsCoalesceAndLaterCyclesUseFreshIdentities
  coordinatorIsDrivenThroughTheOpportunityRunnerProtocol
].each do |name|
  fail_check("recording fixture lacks #{name}") unless tests.include?(name)
end

forbidden = /\b(?:GiftUISemanticCore|GiftUILayout|GiftUIObservableState|GiftUIInteraction|GiftUIRenderCore|GiftUIRuntime|GiftUIBackend|GiftUIPlatform|Any|any|Mirror|Task|actor|async|await|throw|fatalError)\b/
fail_check("recording coordinator creates a downstream contract or prohibited authority") if source.match?(forbidden)

puts "SPEC-009 recording coordinator passed: closed events, canonical phases, wake transitions, authoritative state, and runner conformance are covered."
