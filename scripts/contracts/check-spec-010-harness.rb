#!/usr/bin/env ruby
# frozen_string_literal: true

require "pathname"

root = Pathname.new(File.expand_path("../..", __dir__))
fixtures = root.join("Tests/ContractFixtures/SPEC010")

def fail_check(message)
  warn "SPEC-010 harness check failed: #{message}"
  exit 1
end

headers = {
  "fixture-manifest.tsv" => "# id\texpectation\taccess\tentry_point\tdiagnostic_patterns\tallowed_modules",
  "MacroExpansion/cases.tsv" => "# id\tsource\texpected_expansion\texpected_diagnostics\tevidence_class",
  "SemanticCorpus/cases.tsv" => "# id\toperation\tinputs\texpected_result\tevidence_class",
  "SemanticCorpus/canonical-transcript.tsv" => "# case_id\tevent_index\tphase\tlocation\tdeclaration_ordinal\tevent\tattachment_slot\tgeneration\tdirty\twake",
  "SemanticCorpus/normalized-results.tsv" => "# case_id\tresult\tlive_locations\tregistrations\tstaged_associations\tdirty_locations\toutstanding_wakes\ttree_evaluations\tpublished_revisions\tevidence_class",
  "required-evidence.tsv" => "# criterion\towner_tasks\tevidence\tstatus"
}

headers.each do |relative, expected|
  path = fixtures.join(relative)
  fail_check("missing #{relative}") unless path.file?
  fail_check("#{relative} header differs") unless path.each_line.first&.chomp == expected
end

manifest_rows = fixtures.join("fixture-manifest.tsv").each_line.each_with_object([]) do |line, rows|
  next if line.start_with?("#") || line.strip.empty?

  fields = line.chomp.split("\t", -1)
  fail_check("compile fixture row must have six fields") unless fields.length == 6
  rows << fields
end
fail_check("compile fixture identifiers are duplicated") unless manifest_rows.map(&:first).uniq.length == manifest_rows.length

macro_rows = fixtures.join("MacroExpansion/cases.tsv").each_line.each_with_object([]) do |line, rows|
  next if line.start_with?("#") || line.strip.empty?

  fields = line.chomp.split("\t", -1)
  fail_check("macro row must have five fields") unless fields.length == 5
  rows << fields
end
fail_check("macro fixture identifiers are duplicated") unless macro_rows.map(&:first).uniq.length == macro_rows.length

evidence_rows = fixtures.join("required-evidence.tsv").each_line.each_with_object([]) do |line, rows|
  next if line.start_with?("#") || line.strip.empty?

  fields = line.chomp.split("\t", -1)
  fail_check("evidence row must have four fields") unless fields.length == 4
  rows << fields
end
expected_criteria = (1..12).map { |value| format("OS-%03d", value) }
criteria = evidence_rows.map(&:first)
fail_check("required evidence criteria differ") unless criteria == expected_criteria
fail_check("required evidence criteria are duplicated") unless criteria.uniq.length == criteria.length
fail_check("initial evidence must remain fail-closed") unless evidence_rows.all? { |row| row[3] == "pending" }
fail_check("owner task or evidence is empty") if evidence_rows.any? { |row| row[1].empty? || row[2].empty? }

puts "SPEC-010 fixture schemas passed: 12 pending acceptance criteria"

exit 0 if ARGV.empty?
fail_check("expected one report directory") unless ARGV.length == 1

report = Pathname.new(ARGV.first)
%w[metadata.txt commands.txt input-hashes.tsv image-hashes.tsv required-evidence.tsv].each do |relative|
  path = report.join(relative)
  fail_check("report lacks #{relative}") unless path.file? && !path.empty?
end

metadata = report.join("metadata.txt").each_line.each_with_object({}) do |line, values|
  key, value = line.chomp.split("=", 2)
  values[key] = value if value
end
%w[spec profile repository_revision repository_dirty target optimization compiler_path
   compiler_sha256 evidence_complete public_contract_compile connected_target_execution
   deployment service_restart flashing].each do |key|
  fail_check("metadata lacks #{key}") if metadata.fetch(key, "").empty?
end
fail_check("wrong report spec") unless metadata["spec"] == "SPEC-010"
fail_check("public contract status must remain pending") unless metadata["public_contract_compile"] == "pending"
%w[connected_target_execution deployment service_restart flashing].each do |key|
  fail_check("driver must not claim #{key}") unless metadata[key] == "false"
end

report_rows = report.join("required-evidence.tsv").each_line.each_with_object([]) do |line, rows|
  next if line.start_with?("#") || line.strip.empty?

  fields = line.chomp.split("\t", -1)
  fail_check("report evidence row must have two fields") unless fields.length == 2
  rows << fields
end
fail_check("report evidence criteria differ") unless report_rows.map(&:first) == expected_criteria
fail_check("initial report evidence must be missing") unless report_rows.all? { |row| row[1] == "missing" }
fail_check("missing evidence was reported complete") unless metadata["evidence_complete"] == "false"

puts "SPEC-010 report is fail-closed: 12 acceptance criteria missing"
