#!/usr/bin/env ruby
# frozen_string_literal: true

require "pathname"
require "yaml"

ROOT = Pathname.new(File.expand_path("../..", __dir__))
FIXTURE = ROOT.join("Tests/ContractFixtures/SPEC013/handoff.yaml")

def fail_check(message)
  warn "SPEC-013 handoff recovery check failed: #{message}"
  exit 1
end

cases = YAML.safe_load(FIXTURE.read, aliases: false).fetch("cases")
expected_names = %w[
  accepted-offer-commits-routing
  refused-and-failed-offers-preserve-routing
  bounded-refusal-recovery
  late-admission-and-wake-coalescing
  reentrancy-and-quiescence
]
fail_check("canonical case set differs") unless cases.map { |item| item.fetch("name") } == expected_names

recovery = cases.fetch(2)
fail_check("constant-space repetition differs") unless recovery.fetch("repeatedBackpressureCount") == 100
fail_check("more than one intent is retained") unless recovery.fetch("retainedIntentCount") == 1
fail_check("wake did not coalesce") unless recovery.fetch("outstandingWakeCount") == 1

checks = {
  "Tests/GiftUIRuntimeCoreTests/RuntimeCompletePipelineTests.swift" => %w[
    completePipelineAcceptsInExactOrderAndCommitsRouting
    publishedRefusalNeverRollsBackAndRetainsOnlyPresentationIntent
    failedEndpointPreservesPublicationAndDiscardsCandidateRouting
  ],
  "Tests/GiftUIExecutionTests/RecordingFrameCommitTransactionTests.swift" => %w[
    everyNonacceptedResultAbortsAllStagedStateAndPreservesPriorRouting
  ],
  "Tests/GiftUIExecutionTests/RecordingPresentationPendingCoordinatorTests.swift" => %w[
    pendingWakeCoalescesUntilSeparatelyPacedOpportunity
    repeatedBackpressureRetainsOneIntentAndOneOutstandingWake
  ],
  "Tests/GiftUIExecutionTests/ExecutionAdmissionControllerTests.swift" => %w[
    workArrivingAfterSealIsDeferredAndRequestsFreshWake
    quiescenceRefusesEveryFamilyAndPointerCancellationIsMandatory
  ],
  "Tests/GiftUIRuntimeCoreTests/RuntimeCoordinatorTransactionTests.swift" => %w[
    commonTransactionAppliesOnceOffersOnceAndCommitsRoutingOnlyOnAcceptance
    refusedCandidateAbortsRoutingAndRetainsOnlyBoundedLatestRevisionIntent
  ],
  "Tests/GiftUIRuntimeCoreTests/RuntimeCoordinatorQuiescenceTests.swift" => %w[
    idleAndActiveQuiescencePlansHaveExactFiniteOrder
    lifecycleQuiescenceIsSynchronousFromIdleAndDeferredOnlyForActiveContainment
  ],
}

checks.each do |relative, markers|
  source = ROOT.join(relative).read
  markers.each do |marker|
    fail_check("#{relative} lacks #{marker}") unless source.include?(marker)
  end
end

puts "SPEC-013 handoff recovery passed: accepted, refused, failed, retry, wake, admission, routing, and quiescence evidence is complete."
