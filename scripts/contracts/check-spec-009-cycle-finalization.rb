#!/usr/bin/env ruby
# frozen_string_literal: true

require "pathname"

ROOT = Pathname.new(File.expand_path("../..", __dir__))
SOURCE = ROOT.join("Sources/GiftUIExecution/RecordingCycleFinalizer.swift")
TEST = ROOT.join("Tests/GiftUIExecutionTests/RecordingCycleFinalizerTests.swift")

def fail_check(message)
  warn "SPEC-009 cycle finalization check failed: #{message}"
  exit 1
end

source = SOURCE.read
tests = TEST.read

fail_check("cycle finalizer must import no owner") unless source.scan(/^import /).empty?
fail_check("cycle finalizer must remain internal") if source.match?(
  /\b(?:package|public|open) (?:struct|enum|protocol) Recording(?:SelectedFailure|CycleFinalizer)/
)

%w[
  operationalEvents
  selectedFailure
  scratchHeld
  borrowHeld
  finalizingCount
  finalContext
  didFinalize
  recordOperational
  captureFirstFailure
  primaryOperationalEvent
  retryableRefusal
  backpressured
  superseded
  deferredToLaterAdmission
  noChange
].each do |fragment|
  fail_check("cycle finalizer lacks #{fragment}") unless source.include?(fragment)
end

failure_index = source.index("if let selectedFailure")
retry_index = source.index("operationalEvents.contains(.retryableRefusal)")
backpressure_index = source.index("operationalEvents.contains(.backpressured)")
superseded_index = source.index("operationalEvents.contains(.superseded)")
deferred_index = source.index("operationalEvents.contains(.deferredToLaterAdmission)")
no_change_index = source.index("operationalEvents.contains(.noChange)")
unless [failure_index, retry_index, backpressure_index, superseded_index,
        deferred_index, no_change_index].all? &&
    failure_index < retry_index && retry_index < backpressure_index &&
    backpressure_index < superseded_index && superseded_index < deferred_index &&
    deferred_index < no_change_index
  fail_check("result precedence differs")
end

release_index = source.index("scratchHeld = false")
idle_index = source.index("phases.transition(to: .idle)")
unless release_index && idle_index && release_index < idle_index
  fail_check("resources are not released before idle authority")
end

%w[
  everyLegalOperationalEventSetRetainsAllEventsAndExactPrimary
  failureAlwaysPrecedesOperationalAndRetainsCompleteSummary
  everyActiveExitFinalizesOnceReleasesResourcesAndReturnsIdle
].each do |name|
  fail_check("cycle finalizer tests lack #{name}") unless tests.include?(name)
end

forbidden = /\b(?:String|Array|ContiguousArray|Dictionary|Set|Any|any|Mirror|Task|actor|async|await|throw|fatalError|GiftUISemanticCore|GiftUILayout|GiftUIObservableState|GiftUIInteraction|GiftUIRenderCore|GiftUIRuntime|GiftUIBackend|GiftUIPlatform)\b/
fail_check("cycle finalizer uses a prohibited carrier or owner") if source.match?(forbidden)

puts "SPEC-009 cycle finalization passed: failure precedence, complete operational events, one finalization, resource release, and idle restoration are covered."
