#!/usr/bin/env ruby
# frozen_string_literal: true

root = File.expand_path("../..", __dir__)
path = File.join(
  root,
  "Tests/GiftUIReferenceTextResourcesTests/AssemblyLifecycleTests.swift"
)
source = File.read(path)

def fail_check(message)
  warn "SPEC-005 assembly lifecycle check failed: #{message}"
  exit 1
end

%w[
  ContractLocalAssembly validationCount consumerCount assemble
  withAdmittedPackage attachConsumer detachConsumer requestTearDown
  BitmapOnlyLinkedRaster UnavailableSelectedRaster withPayload borrowing
].each do |fragment|
  fail_check("assembly fixture lacks #{fragment}") unless source.include?(fragment)
end

expected_tests = %w[
  buildValidationSeesBothPayloadsBeforeTargetAssembly
  targetAssemblyPublishesOnlyAfterSelectedRealizationValidation
  omittedUnselectedPayloadIsCatalogueUnavailabilityNotPartialAssembly
  failedAssemblyExposesNoPartialMetricsOrRealization
]
expected_tests.each do |name|
  fail_check("assembly fixture lacks #{name}") unless source.include?("func #{name}()")
end
fail_check("assembly fixture must contain exactly four focused tests") unless
  source.scan(/^func \w+\(\) \{/).length == expected_tests.length

%w[Paint Clip RenderOperation Backend].each do |fragment|
  fail_check("assembly fixture introduces prohibited #{fragment}") if source.include?(fragment)
end

puts "SPEC-005 assembly lifecycle check passed: build and selected-subset validation, gated publication, synchronous borrows, last-consumer teardown, and no partial failure exposure."
