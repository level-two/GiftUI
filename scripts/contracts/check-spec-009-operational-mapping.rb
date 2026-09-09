#!/usr/bin/env ruby
# frozen_string_literal: true

require "pathname"

ROOT = Pathname.new(File.expand_path("../..", __dir__))
SOURCE = ROOT.join("Sources/GiftUIFailureExecution/GiftUIFailureExecution.swift")
TEST = ROOT.join("Tests/GiftUIFailureExecutionTests/OperationalFailureMappingTests.swift")

def fail_check(message)
  warn "SPEC-009 operational mapping check failed: #{message}"
  exit 1
end

source = SOURCE.read
tests = TEST.read
%w[completeEvents attemptOrdinal attemptLimit mechanicalEffectsComplete residualInput noChange backpressured retryableRefusal superseded deferredToLaterAdmission].each do |fragment|
  fail_check("operational adapter lacks #{fragment}") unless source.include?(fragment)
end
%w[everyOperationalPrimaryMapsExactFactAndCorrelation completeEventSetUsesExactPrimaryPrecedenceWithoutLoss mappingRejectsWrongPrimaryInvalidAttemptsAndIncompleteEffects residualPolicyInputPreservesAttemptsAndRestrictsPacedRetry].each do |name|
  fail_check("operational tests lack #{name}") unless tests.include?(name)
end
puts "SPEC-009 operational mapping passed: exact primary facts, complete events, attempts, effect ordering, residual targets, and paced-retry exclusion are covered."
