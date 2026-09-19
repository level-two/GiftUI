#!/usr/bin/env ruby
# frozen_string_literal: true

require "pathname"

root = Pathname.new(File.expand_path("../..", __dir__))

def require_patterns(root, relative_path, patterns)
  path = root.join(relative_path)
  abort "SPEC-015 negative corpus: missing #{relative_path}" unless path.file?
  source = path.read
  patterns.each do |pattern|
    abort "SPEC-015 negative corpus: #{relative_path} misses #{pattern.inspect}" unless source.match?(pattern)
  end
end

coverage = {
  "Tests/GiftUIHostConfigurationTests/HostComponentGraphValidationTests.swift" => [
    /exactOrderedComponentGraphIsAccepted/, /graphRejectsMissingDuplicateUpwardAndUnknownBits/
  ],
  "Tests/GiftUIHostConfigurationTests/HostResidualPolicyTableValidationTests.swift" => [
    /validationAccessLedgerStopsAtEveryFirstFailure/, /sideEffectCount/
  ],
  "Tests/GiftUIHostConfigurationTests/HostValidatorProfileAndTextTests.swift" => [
    /everyRuntimeProfileErrorIsPreserved/, /everyTextResourceErrorIsPreserved/
  ],
  "Tests/GiftUIHostConfigurationTests/HostWorkloadStartupValidationTests.swift" => [
    /schemaAndMalformedCountsFailBeforeCapacityComparison/,
    /everyManifestSourceCountMustEqualItsOwningLimit/
  ],
  "Tests/GiftUIHostConfigurationTests/SignalAnalyzerDrawingStartupValidationTests.swift" => [
    /structuralGateRejectsEveryDrawingMinimumIndependently/,
    /structuralGateRejectsFirstExcessAndStaticMismatch/
  ],
  "Tests/GiftUIHostConfigurationTests/HostValidatorCapabilityTests.swift" => [
    /everyCapabilityContributionPermutationProducesTheSameExactReport/,
    /capabilityFailureDoesNotRepairAValidDrawingGate/
  ],
  "Tests/GiftUIHostConfigurationTests/HostEndpointStartupValidationTests.swift" => [
    /everyEndpointProjectionFamilyMustMatchTheEffectiveValue/
  ],
  "Tests/GiftUIHostConfigurationTests/HostApplicationStartupValidationTests.swift" => [
    /everyActionDomainProjectionFailsAtTheActionModelStage/,
    /everyInputProjectionFailsAtTheInputWakeStage/
  ],
  "Tests/GiftUIHostConfigurationTests/HostSequencedFactAdmissionTests.swift" => [
    /completeTwentyTwoSixBurstUsesTwentyEightMonotonicSequences/,
    /physicalCompactStoreAcceptsThirtyTwoAndRejectsThirtyThird/
  ],
  "Tests/GiftUIHostConfigurationTests/HostNormalizedInputGateTests.swift" => [
    /configuredBoundSucceedsAndFirstExcessCancelsNewSequence/
  ],
  "Tests/GiftUIHostConfigurationTests/HostResidualFailureRoutingTests.swift" => [
    /everyHostPolicyRouteRequiresItsMandatoryEffects/,
    /diagnosticOutcomeCannotChangeAuthoritativeRouting/
  ],
  "Tests/GiftUIHostConfigurationTests/HostActivationControllerTests.swift" => [
    /everyActivationStepPreservesFailureAndContainsPartialWork/,
    /teardownUsesAllEightStepsFromEveryExternallyStableState/
  ],
  "Tests/GiftUIHostConfigurationTests/HostConfigurationValueTests.swift" => [
    /pacingRejectsEveryZeroField/, /pacingAcceptsRepresentableBoundariesAndRejectsEachOverflowStep/
  ]
}.freeze

coverage.each { |path, patterns| require_patterns(root, path, patterns) }
require_patterns(root, "scripts/contracts/check-spec-015-source-boundaries.rb", [/forbidden/i, /import/i])

puts "SPEC-015 negative corpus audit passed: #{coverage.length} focused suites plus source/import scans."
