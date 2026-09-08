#!/usr/bin/env ruby
# frozen_string_literal: true

require "pathname"

ROOT = Pathname.new(File.expand_path("../..", __dir__))
SOURCE = ROOT.join("Sources/GiftUIObservableState/ObservableStateReportGuard.swift")
TEST = ROOT.join("Tests/GiftUIObservableStateTests/ObservableStateReportGuardTests.swift")

def fail_check(message)
  warn "SPEC-010 report guard check failed: #{message}"
  exit 1
end

source = SOURCE.read
tests = TEST.read

fail_check("report guard imports differ") unless source.scan(/^import (\S+)/).flatten == %w[GiftUI GiftUIExecution]
fail_check("report guard must remain internal") if source.match?(
  /\b(?:package|public|open) (?:struct|enum|protocol) ObservableStateReport(?:RouteState|Guard)/
)

%w[
  attaching
  candidate
  live
  detaching
  retired
  shutdown
  expectedAttachment
  lastPublishedRevision
  pacedRederivationRequired
  normalCycleExcluded
  partialCandidatePresent
  residualPolicyPermitted
  noModelWriteProven
  reportAlreadyActive
  semanticDispatchActive
  invalidPhaseContained
  invalidPhaseSafetyNotProven
  reentrancyViolation
  staleAttachment
].each do |fragment|
  fail_check("report guard lacks #{fragment}") unless source.include?(fragment)
end

reentrant_index = source.index("if reportAlreadyActive || semanticDispatchActive")
phase_index = source.index("guard phase == .mutating")
contained_index = source.index("containPacedRederivation()")
safety_index = source.index("containSafetyNotProven()", contained_index || 0)
unless reentrant_index && phase_index && contained_index && safety_index &&
    reentrant_index < phase_index && contained_index < safety_index
  fail_check("reentrancy or phase-containment precedence differs")
end

%w[
  inactiveLifecycleStatesAndReusedSlotsRejectAsStale
  containedPhaseViolationMarksDirtyAndSchedulesOnePacedWake
  safetyNotProvenPhaseViolationDiscardsPartialAndExcludesNormalCycle
  activeReportAndSemanticDispatchUseReentrancyContainment
  validMutatingReportStillDirtiesThenCoalesces
].each do |name|
  fail_check("report guard fixture lacks #{name}") unless tests.include?(name)
end

forbidden = /\b(?:String|Array|ContiguousArray|Dictionary|Set|Any|any|Mirror|Task|actor|async|await|throw|fatalError|GiftUISemanticCore|GiftUILayout|GiftUIInteraction|GiftUIRenderCore|GiftUIRuntime|GiftUIBackend|GiftUIPlatform|GiftUIFailureCore)\b/
fail_check("report guard selects dynamic storage or a prohibited owner") if source.match?(forbidden)

puts "SPEC-010 report guard passed: stale lifetimes, paced contained recovery, safety exclusion, reentrancy, publication preservation, and residual-policy boundaries are covered."
