#!/usr/bin/env ruby
# frozen_string_literal: true

ROOT = File.expand_path("../..", __dir__)
DRIVER = File.join(ROOT, "scripts/contracts/run-spec-001.sh")
REGISTRY = File.join(ROOT, "scripts/contracts/driver-registry.tsv")
INVOCATIONS = File.join(ROOT, "Tests/ContractFixtures/SPEC001/driver-invocations.tsv")
PROFILES = %w[macos-dynamic macos-static raspberry-pi-armv6 nrf52840-embedded].freeze

source = File.read(DRIVER)
abort "SPEC-001 report root differs" unless source.include?('.build/contract-reports/spec-001')
%w[remote_access=false deployment=false service_restart=false hardware_probe=false flashing=false network_access=false].each do |marker|
  abort "SPEC-001 driver omits safety marker #{marker}" unless source.include?(marker)
end
%w[repository_revision source_identity fixture_identity compiler_identity sdk_identity target_triple optimization command_identity artifact_path artifact_identity].each do |field|
  abort "SPEC-001 driver omits identity #{field}" unless source.include?("#{field}=")
end

registry_rows = File.readlines(REGISTRY, chomp: true).reject { |line| line.empty? || line.start_with?("#") }.map { |line| line.split("\t", -1) }
row = registry_rows.find { |entry| entry[0] == "SPEC-001" }
abort "SPEC-001 driver is not registered" unless row == ["SPEC-001", "scripts/contracts/run-spec-001.sh", PROFILES.join(",")]

invocation_rows = File.readlines(INVOCATIONS, chomp: true).reject { |line| line.empty? || line.start_with?("#") }.map { |line| line.split("\t", -1) }
abort "SPEC-001 invocation rows differ" unless invocation_rows.map(&:first) == PROFILES
abort "SPEC-001 invocation columns differ" unless invocation_rows.all? { |entry| entry.length == 4 }
abort "SPEC-001 standalone invocation differs" unless invocation_rows.all? { |entry| entry[1] == "scripts/contracts/run-spec-001.sh --profile #{entry[0]}" }
abort "SPEC-001 report root differs in registry" unless invocation_rows.all? { |entry| entry[3] == ".build/contract-reports/spec-001" }

puts "SPEC-001 driver audit passed: four exact profiles, immutable identities, output boundary, and safety markers are registered."
