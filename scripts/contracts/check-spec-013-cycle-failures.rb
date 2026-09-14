#!/usr/bin/env ruby
# frozen_string_literal: true

require "pathname"
require "yaml"

ROOT = Pathname.new(File.expand_path("../..", __dir__))
FIXTURE = ROOT.join("Tests/ContractFixtures/SPEC013/cycles.yaml")
PIPELINE_TESTS = ROOT.join("Tests/GiftUIRuntimeCoreTests/RuntimeCompletePipelineTests.swift")
CLEANUP_TESTS = ROOT.join("Tests/GiftUIRuntimeCoreTests/RuntimeCoordinatorCleanupTests.swift")

def fail_check(message)
  warn "SPEC-013 cycle failure check failed: #{message}"
  exit 1
end

cases = YAML.safe_load(FIXTURE.read, aliases: false).fetch("cases")
fail_check("canonical case set differs") unless cases.map { |item| item.fetch("name") } == [
  "focused-owner-stage-cleanup-matrix",
]

matrix = cases.first
fail_check("focused-owner count differs") unless matrix.fetch("focusedOwnerCount") == 5
fail_check("stage count differs") unless matrix.fetch("stageCount") == 11
fail_check("injection count differs") unless matrix.fetch("injectionCount") == 55
%w[
  firstFailureWins laterFallibleWorkSkipped cleanupExactAndOnceOnly
  candidatesDiscardedBeforePublication canvasCallableReleasedWhenAcquired
  dispositionRecordedOnce wakeMatchesPublicationBoundary
].each do |field|
  fail_check("#{field} is not proven") unless matrix.fetch(field)
end
fail_check("mutation replay differs") if matrix.fetch("appliedMutationReplayed")
fail_check("finalization count differs") unless matrix.fetch("finalizationCount") == 1

pipeline_tests = PIPELINE_TESTS.read
%w[
  everyFocusedOwnerFailureAtEveryStageHasExactCleanupAndDisposition
  everyFocusedOwnerFailure exactPipelineOrder expectedFailureCleanups
].each do |marker|
  fail_check("pipeline matrix lacks #{marker}") unless pipeline_tests.include?(marker)
end

cleanup_tests = CLEANUP_TESTS.read
%w[
  cleanupOracleCoversEveryStageWithExactOrderedActions
  mutationApplicationIsAtMostOnceAndNeverBecomesCleanupWork
  prepublicationAndPostpublicationPlansRespectCandidateBoundaries
].each do |marker|
  fail_check("cleanup evidence lacks #{marker}") unless cleanup_tests.include?(marker)
end

puts "SPEC-013 cycle failures passed: five focused owners across eleven stages produce 55 exact cleanup and disposition cells."
