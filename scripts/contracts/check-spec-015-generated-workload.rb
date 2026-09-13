#!/usr/bin/env ruby
# frozen_string_literal: true

require "pathname"
require "rbconfig"

root = Pathname.new(File.expand_path("../..", __dir__))
generator = root.join("scripts/contracts/generate-spec-015-workload.rb")
abort "SPEC-015 generated workload freshness failed" unless system(RbConfig.ruby, generator.to_s, "--check")

corpus = root.join("Tests/ContractFixtures/SPEC015/Generated/runtime-limit-leaves.generated.tsv")
rows = corpus.read.lines.reject { |line| line.start_with?("#") || line.strip.empty? }
abort "SPEC-015 per-leaf corpus must contain 41 leaves for each of four presets" unless rows.length == 164

keys = rows.map { |line| line.split("\t", -1).first(3) }
abort "SPEC-015 per-leaf corpus contains duplicate rows" unless keys.uniq.length == keys.length

profiles = rows.group_by { |line| line.split("\t", -1)[0] }
abort "SPEC-015 per-leaf corpus does not cover four presets" unless profiles.keys.sort == %w[macos_dynamic macos_static nrf52840_static raspberry_pi_dynamic]
profiles.each do |name, preset_rows|
  abort "SPEC-015 #{name} does not cover every limit leaf" unless preset_rows.length == 41
end

puts "SPEC-015 generated workload check passed: four manifests, 164 exact leaf rows."
