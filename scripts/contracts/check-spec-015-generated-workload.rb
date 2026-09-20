#!/usr/bin/env ruby
# frozen_string_literal: true

require "pathname"
require "rbconfig"
require "digest"

root = Pathname.new(File.expand_path("../..", __dir__))
generator = root.join("scripts/contracts/generate-spec-015-workload.rb")
abort "SPEC-015 generated workload freshness failed" unless system(RbConfig.ruby, generator.to_s, "--check")

corpus = root.join("Tests/ContractFixtures/SPEC015/Generated/runtime-limit-leaves.generated.tsv")
rows = corpus.read.lines.reject { |line| line.start_with?("#") || line.strip.empty? }
abort "SPEC-015 per-leaf corpus must contain 42 leaves for each of four presets" unless rows.length == 168

keys = rows.map { |line| line.split("\t", -1).first(3) }
abort "SPEC-015 per-leaf corpus contains duplicate rows" unless keys.uniq.length == keys.length

profiles = rows.group_by { |line| line.split("\t", -1)[0] }
abort "SPEC-015 per-leaf corpus does not cover four presets" unless profiles.keys.sort == %w[macos_dynamic macos_static nrf52840_static raspberry_pi_dynamic]
profiles.each do |name, preset_rows|
  abort "SPEC-015 #{name} does not cover every limit leaf" unless preset_rows.length == 42
end

hierarchy_path = root.join("Tests/ContractFixtures/SPEC001/hierarchy-shape-cases.tsv")
hierarchy = hierarchy_path.read.lines.reject { |line| line.start_with?("#") || line.strip.empty? }
  .to_h { |line| line.chomp.split("\t", 2) }
abort "SPEC-015 Static root model type differs" unless hierarchy.fetch("direct-state-type") == "SignalAnalyzerViewModel"
abort "SPEC-015 Static root count differs" unless hierarchy.fetch("direct-state-count") == "1"

static_root_identity = Digest::SHA256.hexdigest(hierarchy_path.read)[0, 8].to_i(16)
source = root.join(
  "Sources/GiftUIHostConfiguration/Generated/SignalAnalyzerPresets.generated.swift"
).read
abort "SPEC-015 generated Static root descriptor is missing" unless
  source.include?("package struct GeneratedSignalAnalyzerStaticRootDescriptor")
abort "SPEC-015 generated Static root structural identity differs" unless
  source.include?("structuralIdentity: #{static_root_identity}")
%w[
  declarationOrdinal:\ 0
  modelStorageSlots:\ 2
  locationCapacity:\ 1
  registrationCapacity:\ 1
  replacementCapacity:\ 1
].each do |field|
  abort "SPEC-015 generated Static root field differs: #{field}" unless source.include?(field)
end

puts "SPEC-015 generated workload check passed: four manifests, 168 exact leaf rows, " \
  "and one provenance-bound Static root descriptor."
