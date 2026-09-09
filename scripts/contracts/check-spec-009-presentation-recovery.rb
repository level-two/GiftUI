#!/usr/bin/env ruby
# frozen_string_literal: true

require "pathname"

ROOT = Pathname.new(File.expand_path("../..", __dir__))
PENDING_SOURCE = ROOT.join("Sources/GiftUIExecution/RecordingPresentationPendingCoordinator.swift")
TERMINAL_SOURCE = ROOT.join("Sources/GiftUIExecution/RecordingPresentationTerminalRecovery.swift")
TEST = ROOT.join("Tests/GiftUIExecutionTests/RecordingPresentationRecoveryMatrixTests.swift")

def fail_check(message)
  warn "SPEC-009 presentation recovery check failed: #{message}"
  exit 1
end

pending_source = PENDING_SOURCE.read
terminal_source = TERMINAL_SOURCE.read
tests = TEST.read

fail_check("terminal recovery imports differ") unless terminal_source.scan(/^import (\S+)/).flatten == ["GiftUI"]

%w[
  retryableRefusalExhausted
  nonRetryableRefusal
  requiredFacilityLost
  pendingIntent
  capturedAction
  presentationInputQuiescent
  requiredFacilityAvailable
  reassemblyRequired
  requiredFacilityUnavailable
  residualAllowsPacedRetry
  reassembleRequiredFacility
].each do |fragment|
  fail_check("terminal recovery lacks #{fragment}") unless terminal_source.include?(fragment)
end

fail_check("pending recovery lacks checked increment") unless pending_source.include?("addingReportingOverflow")
fail_check("pending recovery accepts a zero maximum") unless pending_source.include?("maximumRetryableRefusals > 0")

%w[
  everyConfiguredMaximumRetainsBelowAndExhaustsAtExactLimit
  checkedIncrementFailureNeverWrapsOrRequestsRetry
  terminalReasonsClearPendingCaptureAndQuiesceInput
  facilityLossDistinguishesBeforeAndAfterCandidateAllocation
  onlyExplicitReassemblyReopensPresentationAdmission
  UInt16(255)
  renderProducer
  endpoint
].each do |fragment|
  fail_check("presentation recovery matrix lacks #{fragment}") unless tests.include?(fragment)
end

forbidden = /\b(?:String|Array|ContiguousArray|Dictionary|Set|Any|any|Mirror|Task|actor|async|await|throw|fatalError|GiftUISemanticCore|GiftUILayout|GiftUIObservableState|GiftUIInteraction|GiftUIRenderCore|GiftUIRuntime|GiftUIBackend|GiftUIPlatform|GiftUIFailureCore)\b/
fail_check("terminal recovery selects dynamic storage or a prohibited owner") if terminal_source.match?(forbidden)

puts "SPEC-009 presentation recovery passed: all maxima, exact exhaustion, overflow, terminal refusal/facility behavior, capture quiescence, residual exclusion, and reassembly are covered."
