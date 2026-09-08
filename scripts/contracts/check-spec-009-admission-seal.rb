#!/usr/bin/env ruby
# frozen_string_literal: true

require "pathname"

ROOT = Pathname.new(File.expand_path("../..", __dir__))
SEALER = ROOT.join("Sources/GiftUIExecution/ExecutionAdmissionSealer.swift")
ADMISSION = ROOT.join("Sources/GiftUIExecution/ExecutionAdmissionController.swift")
TEST = ROOT.join("Tests/GiftUIExecutionTests/ExecutionAdmissionSealerTests.swift")
AFTER_SEAL_TEST = ROOT.join("Tests/GiftUIExecutionTests/ExecutionAdmissionControllerTests.swift")

def fail_check(message)
  warn "SPEC-009 admission seal check failed: #{message}"
  exit 1
end

sealer = SEALER.read
admission = ADMISSION.read
tests = TEST.read
after_seal_tests = AFTER_SEAL_TEST.read
fail_check("sealer must not import another owner") unless sealer.scan(/^import /).empty?

required = [
  "pendingInputEvents",
  "pendingStateChangeFacts",
  "pendingCompletionFacts",
  "sameCycleActivationCandidates",
  "includesDirtyRederivation",
  "includesPresentationRecovery",
  "sameCycleActivationCandidates <= inputCount",
  "sameCycleActivationCandidates <= limits.maximumSemanticActions",
  "pendingInputEvents > inputCount",
  "pendingStateChangeFacts > stateChangeCount",
  "pendingCompletionFacts > completionCount",
]
required.each do |fragment|
  fail_check("admission sealer lacks #{fragment}") unless sealer.include?(fragment)
end

%w[isSealClosed didDeferAfterSeal closeAdmissionSeal recordQueuedWork].each do |fragment|
  fail_check("after-seal admission lacks #{fragment}") unless admission.include?(fragment)
end

%w[
  sealSelectsExactOrderedCategoryPrefixes
  overLimitSuffixesRemainDeferredRatherThanFailing
  countEqualToEveryLimitSucceedsWithoutDeferral
  activationMembershipMustComeFromSelectedPointersAndFitItsLimit
  emptySealAndSingleIntentMembershipAreExact
].each do |name|
  fail_check("seal fixture lacks #{name}") unless tests.include?(name)
end
fail_check("after-seal fixture is missing") unless after_seal_tests.include?(
  "workArrivingAfterSealIsDeferredAndRequestsFreshWake"
)

forbidden = /\b(?:Any|any|Task|actor|async|await|throw|handler|model|GiftUISemanticCore|GiftUILayout|GiftUIObservableState|Backend|Platform)\b/
fail_check("sealer retains payload or prohibited authority") if sealer.match?(forbidden)

puts "SPEC-009 admission seal passed: ordered prefixes, suffix deferral, intents, and after-seal wake behavior are covered."
