#!/usr/bin/env ruby
# frozen_string_literal: true

require "pathname"

ROOT = Pathname.new(File.expand_path("../..", __dir__))
SOURCE = ROOT.join("Sources/GiftUIObservableStateFailureAdapterFixture/ObservableStateFailureAdapter.swift")
POLICY_TEST = ROOT.join("Tests/GiftUIObservableStateFailureAdapterTests/ObservableStateFailurePolicyTests.swift")
MUTATION_TEST = ROOT.join("Tests/GiftUIObservableStateTests/ObservableStateMutationResultSlotTests.swift")
FAULT_TEST = ROOT.join("Tests/GiftUIObservableStateTests/ObservableStateReconciliationFaultTests.swift")

def fail_check(message)
  warn "SPEC-010 failure policy check failed: #{message}"
  exit 1
end

source = SOURCE.read
policy_tests = POLICY_TEST.read
owner_tests = MUTATION_TEST.read + FAULT_TEST.read

precedence = %w[
  reentrancyViolation invalidPhaseSafetyNotProven invalidPhaseContained
  incompatibleAssociation duplicateOwner registrationGenerationExhausted
  locationCapacityExhausted registrationCapacityExhausted
  associationStagingCapacityExhausted replacementStagingCapacityExhausted
  staleAttachment invariantViolation
]
indices = precedence.map do |condition|
  source.index("visible.contains(.failure(.#{condition}))") ||
    fail_check("focused selector lacks #{condition}")
end
fail_check("focused-owner precedence differs") unless indices == indices.sort

%w[
  priorRootExists residualPolicyPermitted retiredReport replacementAttachment
  continueOperation quiesceAffectedScope invokeFatalHook attemptOrdinal attemptLimit
].each do |fragment|
  fail_check("residual table lacks #{fragment}") unless source.include?(fragment)
end
fail_check("failure policy permits paced retry") if
  source.match?(/residualInput[\s\S]*requestPacedRetry/)
fail_check("contained phase must make no policy input") unless
  source.match?(/case \(\.invalidPhaseContained, \.activeCycle\):\s*return nil/)
fail_check("policy input must retain the correlated fact") unless
  source.include?("outcome: .failure(failure.fact)")

%w[
  individualAndSimultaneousFailuresFollowExactFocusedPrecedence
  residualPolicyTableIsExactForEveryConditionContext
  policyInputsPreserveFailureScopeContainmentAndBoundedAttempt
  secondaryCleanupFailureNeverReplacesFocusedCondition
].each do |name|
  fail_check("policy corpus lacks #{name}") unless policy_tests.include?(name)
end
%w[
  firstFailureSurvivesLaterFailureAndSuccessUntilConsumed
  finishInvariantFailureClearsCandidateAndPreservesFirstFailure
].each do |name|
  fail_check("mandatory cleanup corpus lacks #{name}") unless owner_tests.include?(name)
end

puts "SPEC-010 failure policy passed: exact focused precedence, mandatory cleanup, bounded failure-only policy inputs, and every residual/no-call row are covered."
