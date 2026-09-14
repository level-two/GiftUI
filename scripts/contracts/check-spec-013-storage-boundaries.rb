#!/usr/bin/env ruby
# frozen_string_literal: true

require "pathname"
require "yaml"

ROOT = Pathname.new(File.expand_path("../..", __dir__))
FIXTURE = ROOT.join("Tests/ContractFixtures/SPEC013/storage.yaml")
DYNAMIC_TESTS = ROOT.join("Tests/GiftUIRuntimeDynamicTests/DynamicProfileBoundaryTests.swift")
STATIC_TESTS = ROOT.join("Tests/GiftUIRuntimeStaticTests/StaticGeneratedMetadataTests.swift")
CORE_TESTS = ROOT.join("Tests/GiftUIRuntimeCoreTests/RuntimeStorageAuditTests.swift")
REGISTRY = ROOT.join("Sources/GiftUIRuntimeCore/RuntimeStorageRegistry.swift")

def fail_check(message)
  warn "SPEC-013 storage boundary check failed: #{message}"
  exit 1
end

document = YAML.safe_load(FIXTURE.read, aliases: false)
cases = document.fetch("cases")
expected_names = %w[
  dynamic-exact-limit-and-first-excess
  static-exact-limit-and-first-excess
  exclusive-physical-storage-audit
  dynamic-allocator-bookkeeping-is-separate
]
fail_check("canonical case set differs") unless cases.map { |item| item.fetch("name") } == expected_names

limit_cases = cases.first(2)
fail_check("logical limit count differs") unless limit_cases.all? { |item| item.fetch("logicalLimitCount") == 51 }
fail_check("physical family count differs") unless limit_cases.all? { |item| item.fetch("physicalFamilyCount") == 16 }
fail_check("exact result differs") unless limit_cases.all? { |item| item.fetch("exactResult") == "accepted" }
fail_check("first-excess result differs") unless limit_cases.all? { |item| item.fetch("firstExcessResult") == "limitExceeded" }
fail_check("rejected reservation mutates use") unless limit_cases.none? { |item| item.fetch("rejectedReservationMutatesUse") }

audit = cases.fetch(2)
fail_check("audit family bytes differ") unless audit.fetch("artificialFamilyBytes") == (1..16).to_a
fail_check("audit total differs") unless audit.fetch("expectedTotalProfileBytes") == 136
fail_check("audit overlaps bytes") unless audit.fetch("overlappingBytes").zero?

allocator = cases.fetch(3)
fail_check("allocator owned bytes differ") unless allocator.fetch("ownedPayloadBytes") == 136
fail_check("allocator reserved floor differs") unless allocator.fetch("minimumReservedPayloadBytes") == 136
fail_check("allocator count differs") unless allocator.fetch("allocationCount") == 16
fail_check("allocator bookkeeping entered profile total") if allocator.fetch("includedInTotalProfileBytes")

registry = REGISTRY.read
fail_check("runtime family count differs") unless registry.scan(/^    case \w+ =? ?\d*$/).first(16).length == 16
fail_check("runtime limit case count differs") unless registry[/package enum RuntimeStorageLimit.*?\n}/m]&.scan(/^    case /)&.length == 51

dynamic_tests = DYNAMIC_TESTS.read
static_tests = STATIC_TESTS.read
core_tests = CORE_TESTS.read
%w[
  everyDynamicLogicalDimensionAcceptsExactLimitAndRejectsFirstExcess
  dynamicStorageAccountsEveryIndependentHeapRegion
].each do |name|
  fail_check("Dynamic test lacks #{name}") unless dynamic_tests.include?(name)
end
fail_check("Static exact-limit test is missing") unless static_tests.include?(
  "fixedStaticLogicalDimensionsAcceptExactLimitAndRejectFirstExcess"
)
fail_check("exact audit-field test is missing") unless core_tests.include?(
  "checkedAuditPreservesEveryExclusiveFieldAndExactTotal"
)

puts "SPEC-013 storage boundaries passed: 51 logical limits and 16 physical families have exact-limit, first-excess, audit, high-water, and allocator-bookkeeping evidence."
