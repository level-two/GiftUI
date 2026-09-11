#!/usr/bin/env ruby
# frozen_string_literal: true

require "digest"
require "fileutils"
require "pathname"

PROFILES = %w[macos-dynamic macos-static raspberry-pi-armv6].freeze
IDENTICAL_REPORTS = %w[
  declarations/results.tsv
  value-layouts/render-value-layouts.tsv
  render-evidence/signal-analyzer-high-water.tsv
  render-evidence/workspace.tsv
  render-evidence/stack-high-water.tsv
].freeze
IDENTICAL_INPUTS = %w[
  Tests/ContractFixtures/SPEC008/fixtures.yaml
  Tests/ContractFixtures/SPEC008/signal-analyzer.yaml
  Tests/GiftUIRenderLoweringTests/RenderProfileEquivalenceTests.swift
  scripts/contracts/check-spec-008-canonical-corpus.rb
  scripts/contracts/check-spec-008-failure-corpus.rb
  scripts/contracts/check-spec-008-profile-equivalence.rb
  scripts/contracts/check-spec-008-recording-verification.rb
  scripts/contracts/check-spec-008-text-integration.rb
].freeze
REQUIRED_LOG_FACTS = [
  "canonical corpus passed: 5 field-by-field golden cases",
  "failure corpus passed: mismatches, seven independent capacities, failures, snapshots, lifecycle, and mappings",
  "recording verification passed: typed fields, counts, groups, order",
  "text lowering passed: exact resolved transport and pre-begin resource compatibility",
  "profile equivalence passed: all five canonical cases compare recording, dynamic, and static headers, ordered values, results, mappings, limits, and high-water through one producer",
].freeze

def fail_comparison(message)
  warn "SPEC-008 render profile comparison failed: #{message}"
  exit 1
end

def metadata(path)
  path.each_line.each_with_object({}) do |line, values|
    key, value = line.chomp.split("=", 2)
    values[key] = value if value
  end
end

def inventory(path)
  path.each_line.each_with_object({}) do |line, values|
    next if line.start_with?("#") || line.strip.empty?

    name, digest = line.chomp.split("\t", 2)
    values[name] = digest
  end
end

fail_comparison("usage: compare-spec-008-render-profiles.rb RUN_ROOT OUTPUT") unless ARGV.length == 2
root = Pathname.new(ARGV.fetch(0))
output = Pathname.new(ARGV.fetch(1))
reports = PROFILES.to_h do |profile|
  directory = root.join(profile)
  fail_comparison("missing profile report: #{profile}") unless directory.directory?
  [profile, directory]
end

identities = reports.transform_values { |directory| metadata(directory.join("metadata.txt")) }
revisions = identities.values.map { |values| values["repository_revision"] }.uniq
digests = identities.values.map { |values| values["input_set_sha256"] }.uniq
fail_comparison("profile revisions differ") unless revisions.length == 1
fail_comparison("profile input-set digests differ") unless digests.length == 1
fail_comparison("comparison requires a clean source revision") unless
  identities.values.all? { |values| values["repository_dirty"] == "false" }
PROFILES.each do |profile|
  values = identities.fetch(profile)
  fail_comparison("metadata profile differs for #{profile}") unless values["profile"] == profile
  fail_comparison("#{profile} claims connected-target execution") unless
    values["connected_target_execution"] == "false"
end

inventories = reports.transform_values { |directory| inventory(directory.join("input-hashes.tsv")) }
rows = []
IDENTICAL_INPUTS.each do |relative|
  values = PROFILES.map { |profile| inventories.fetch(profile).fetch(relative) }
  fail_comparison("input identity differs: #{relative}") unless values.uniq.length == 1
  rows << ["input:#{relative}", values.first, "identical"]
end
IDENTICAL_REPORTS.each do |relative|
  values = PROFILES.map do |profile|
    path = reports.fetch(profile).join(relative)
    fail_comparison("missing report artifact: #{profile}/#{relative}") unless path.file?
    Digest::SHA256.file(path).hexdigest
  end
  fail_comparison("normalized report differs: #{relative}") unless values.uniq.length == 1
  rows << ["report:#{relative}", values.first, "identical"]
end

PROFILES.each do |profile|
  log = reports.fetch(profile).join("run.log").read
  REQUIRED_LOG_FACTS.each do |fact|
    fail_comparison("#{profile} lacks log fact: #{fact}") unless log.include?(fact)
  end
end

output.dirname.mkpath
output.write(
  "artifact\tsha256\tdisposition\n" +
    rows.map { |row| row.join("\t") }.join("\n") + "\n" +
    "profile-set\t#{PROFILES.join(',')}\tmacOS-host-execution-and-armv6-cross-build-inspection\n" +
    "repository-revision\t#{revisions.fetch(0)}\tclean-and-identical\n" +
    "input-set\t#{digests.fetch(0)}\tidentical\n"
)

puts "SPEC-008 render profiles match: canonical results, failures, owner mappings, ordered values, resources, declarations, layouts, and high-water are identical; ARMv6 is cross-build only."
