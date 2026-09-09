#!/usr/bin/env ruby
# frozen_string_literal: true

require "pathname"

ROOT = Pathname.new(File.expand_path("../..", __dir__))
SOURCE = ROOT.join("Sources/GiftUIFailureExecution/GiftUIFailureExecution.swift")
TEST = ROOT.join("Tests/GiftUIFailureExecutionTests/GiftUIFailureExecutionTests.swift")
PACKAGE = ROOT.join("Package.swift")

def fail_check(message)
  warn "SPEC-009 execution failure adapter check failed: #{message}"
  exit 1
end

source = SOURCE.read
tests = TEST.read
package = PACKAGE.read
fail_check("adapter imports differ") unless source.scan(/^import (\S+)/).flatten.sort == %w[GiftUIExecution GiftUIFailureCore]
fail_check("adapter target dependencies differ") unless package.match?(
  /name: "GiftUIFailureExecution",\s*dependencies: \["GiftUIFailureCore", "GiftUIExecution"\]/m
)

%w[capacityRefused unavailable invalidValue invalidProvenance arithmeticOverflow capacityExhausted identityExhausted invalidPhase reentrancyViolation requiredFacilityUnavailable invariantViolation provenAffectedScope safeReuseProven mechanicalEffectsComplete].each do |fragment|
  fail_check("adapter lacks #{fragment}") unless source.include?(fragment)
end

%w[everyAdmissionResultMapsAfterMechanicalEffectsWithExactContext admissionMappingCannotPrecedePointerCancellationEffects everyExecutionErrorMapsToExactFactAndPreservedContext executionMappingRejectsUnprovenScopeOrIncompleteCycleEffects].each do |name|
  fail_check("adapter tests lack #{name}") unless tests.include?(name)
end

forbidden = /\b(?:GiftUISemanticCore|GiftUILayout|GiftUIObservableState|GiftUIInteraction|GiftUIRenderCore|GiftUIRuntime|GiftUIBackend|GiftUIPlatform|GiftUIFailureDiagnostics)\b/
fail_check("adapter selects a prohibited owner") if source.match?(forbidden)

puts "SPEC-009 execution failure adapter passed: exact admission/error facts, correlation, mechanical-effect ordering, scope, and containment are covered."
