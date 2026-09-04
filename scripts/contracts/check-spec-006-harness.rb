#!/usr/bin/env ruby
# frozen_string_literal: true

require "pathname"

ROOT = Pathname.new(File.expand_path("../..", __dir__))
FIXTURES = ROOT.join("Tests/ContractFixtures/SPEC006")

def fail_check(message)
  warn "SPEC-006 harness check failed: #{message}"
  exit 1
end

expected_headers = {
  "fixture-manifest.tsv" => "# id\texpectation\taccess\tentry_point\tdiagnostic_patterns\tallowed_modules",
  "SemanticCorpus/cases.tsv" => "# id\tdeclaration_shape\tinputs\texpected_result\tevidence_class",
  "SemanticCorpus/canonical-transcript.tsv" => "# case_id\tevent_index\tpath\tevent_kind\trole\tchain_index",
  "SemanticCorpus/normalized-results.tsv" => "# case_id\tresult\tsemantic_nodes\tbody_evaluations\tmodifier_applications\taction_occurrences\tmaximum_observed_depth\ttranscript_rows\tidentity_relation_set\tevidence_class",
}
expected_headers.each do |relative, expected|
  path = FIXTURES.join(relative)
  fail_check("missing #{relative}") unless path.file?
  actual = path.each_line.first&.chomp
  fail_check("#{relative} header differs") unless actual == expected
end

rows = FIXTURES.join("fixture-manifest.tsv").each_line.each_with_object([]) do |line, result|
  next if line.start_with?("#") || line.strip.empty?

  fields = line.chomp.split("\t", -1)
  fail_check("fixture row must have six fields") unless fields.length == 6
  result << fields
end
fail_check("fixture identifiers are duplicated") unless rows.map(&:first).uniq.length == rows.length
fail_check("fixture baseline must not be empty") if rows.empty?

rows.each do |id, expectation, access, entry, patterns, modules|
  fail_check("invalid fixture identifier #{id}") unless id.match?(/\A[a-z0-9]+(?:-[a-z0-9]+)*\z/)
  fail_check("invalid expectation for #{id}") unless %w[pass fail].include?(expectation)
  fail_check("invalid access for #{id}") unless %w[public package].include?(access)
  fail_check("missing fixture entry for #{id}") unless FIXTURES.join(entry).file?
  fail_check("invalid diagnostic path for #{id}") if expectation == "pass" && patterns != "-"
  if expectation == "fail"
    fail_check("missing diagnostic patterns for #{id}") unless FIXTURES.join(patterns).file?
  end
  names = modules.split(",", -1)
  fail_check("invalid module allowlist for #{id}") if names.empty? || names.any?(&:empty?)
  fail_check("module allowlist is not sorted/unique for #{id}") unless names == names.sort.uniq
end

if ARGV.empty?
  puts "SPEC-006 fixture schemas passed: #{rows.length} compile fixture(s)."
  exit 0
end

fail_check("expected one report directory") unless ARGV.length == 1
report = Pathname.new(ARGV.first)
%w[metadata.txt commands.txt input-hashes.tsv image-hashes.tsv required-evidence.tsv].each do |relative|
  path = report.join(relative)
  fail_check("report lacks #{relative}") unless path.file? && !path.empty?
end

metadata = report.join("metadata.txt").each_line.each_with_object({}) do |line, result|
  key, value = line.chomp.split("=", 2)
  result[key] = value if value
end
%w[spec profile repository_revision repository_dirty target optimization compiler_path
   compiler_sha256 evidence_complete connected_target_execution flashing].each do |key|
  fail_check("metadata lacks #{key}") if metadata.fetch(key, "").empty?
end
fail_check("wrong report spec") unless metadata["spec"] == "SPEC-006"
fail_check("driver must not claim connected execution") unless metadata["connected_target_execution"] == "false"
fail_check("driver must not claim flashing") unless metadata["flashing"] == "false"

required_rows = report.join("required-evidence.tsv").each_line.each_with_object([]) do |line, result|
  next if line.start_with?("#") || line.strip.empty?

  name, status = line.chomp.split("\t", -1)
  fail_check("malformed evidence row") unless name && %w[complete missing not-applicable].include?(status)
  result << [name, status]
end
fail_check("required evidence rows are duplicated") unless required_rows.map(&:first).uniq.length == required_rows.length
required = required_rows.to_h
expected_evidence = %w[
  compiler-identity target-pin optimization command-transcript repository-revision
  portable-module ordered-corpus normalized-results allocation-record owned-value-layouts
  summary-counters maximum-observed-depth underscored-reference-inventory nrf-elf-inspection
]
fail_check("required evidence set differs") unless required.keys.sort == expected_evidence.sort
missing = required.value?("missing")
fail_check("missing evidence was reported complete") if missing && metadata["evidence_complete"] != "false"
fail_check("complete evidence was reported incomplete") if !missing && metadata["evidence_complete"] != "true"

puts "SPEC-006 report is fail-closed: #{required.count { |_key, value| value == 'missing' }} required item(s) pending."
