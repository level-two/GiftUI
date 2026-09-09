#!/usr/bin/env ruby
# frozen_string_literal: true

require "pathname"

ROOT = Pathname.new(File.expand_path("../..", __dir__))
SOURCE = ROOT.join("Sources/GiftUIExecution/RecordingPresentationPendingCoordinator.swift")
TEST = ROOT.join("Tests/GiftUIExecutionTests/RecordingPresentationPendingCoordinatorTests.swift")

def fail_check(message)
  warn "SPEC-009 presentation pending check failed: #{message}"
  exit 1
end

source = SOURCE.read
tests = TEST.read

fail_check("pending coordinator imports differ") unless source.scan(/^import (\S+)/).flatten == ["GiftUI"]
fail_check("pending coordinator fixture must remain internal") if source.match?(
  /\b(?:package|public|open) (?:struct|enum|protocol) Recording(?:PendingTransition|PresentationPendingCoordinator)/
)

%w[
  maximumRetryableRefusals
  pendingIntent
  recordBackpressure
  recordRetryableRefusal
  addingReportingOverflow
  superseded
  presentationPending
  clearPending
  acknowledgeWakeAtIdleOpportunity
].each do |fragment|
  fail_check("pending coordinator lacks #{fragment}") unless source.include?(fragment)
end

%w[
  backpressurePreservesSameRevisionCountWithoutConsumingBudget
  newerBackpressureSupersedesOlderIntentAndStartsAtZero
  retryableRefusalStartsAtOneAndCheckedIncrements
  newerRetryableRefusalSupersedesAndRestartsAtOne
  pendingWakeCoalescesUntilSeparatelyPacedOpportunity
  clearingOnlyMatchingRevisionCannotDiscardNewerIntent
].each do |name|
  fail_check("pending coordinator tests lack #{name}") unless tests.include?(name)
end

forbidden = /\b(?:String|Array|ContiguousArray|Dictionary|Set|Any|any|Mirror|Task|actor|async|await|throw|fatalError|root|graph|frame|stream|operation|action|model|borrow|GiftUISemanticCore|GiftUILayout|GiftUIObservableState|GiftUIInteraction|GiftUIRenderCore|GiftUIRuntime|GiftUIBackend|GiftUIPlatform|GiftUIFailureCore)\b/
fail_check("pending coordinator retains forbidden payload or selects a prohibited owner") if source.match?(forbidden)

puts "SPEC-009 presentation pending passed: latest-only constant-space intent, distinct counters, supersession, clearing, and paced wake coalescing are covered."
