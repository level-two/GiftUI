#!/usr/bin/env ruby
# frozen_string_literal: true

require "pathname"

ROOT = Pathname.new(File.expand_path("../..", __dir__))
FIXTURES = ROOT.join("Tests/ContractFixtures/SPEC006")
SEMANTIC_CORE = ROOT.join("Sources/GiftUISemanticCore")

def fail_check(message)
  warn "SPEC-006 harness check failed: #{message}"
  exit 1
end

expected_headers = {
  "fixture-manifest.tsv" => "# id\texpectation\taccess\tentry_point\tdiagnostic_patterns\tallowed_modules",
  "SemanticCorpus/cases.tsv" => "# id\tdeclaration_shape\tinputs\texpected_result\tevidence_class",
  "SemanticCorpus/canonical-transcript.tsv" => "# case_id\tevent_index\tpath\tevent_kind\trole\tchain_index",
  "SemanticCorpus/normalized-results.tsv" => "# case_id\tresult\tsemantic_nodes\tbody_evaluations\tmodifier_applications\taction_occurrences\tmaximum_observed_depth\ttranscript_rows\tidentity_relation_set\tevidence_class",
  "SemanticCorpus/identity-relations.tsv" => "# id\tlhs_path\tlhs_endpoint_role\trhs_path\trhs_endpoint_role\texpected_relation\texpected_result\tevidence_class",
  "SemanticCorpus/profile-corpus.tsv" => "# category\tartifact\texpected_relation",
  "SemanticCorpus/rank-zero-variants.tsv" => "# id\tcase_id\tbackend_fact\tplatform_fact\tcapability_fact\texpected_relation",
  "ComplexityCorpus/cases.tsv" => "# id\toutcome\tscale\trejected_subtree_units\tfirst_failure_event",
  "BoundaryCorpus/cases.tsv" => "# id\tboundary_owner\tbelow\texact\tone_over\texpected_one_over\tevidence_class",
  "BoundaryCorpus/coincident-failures.tsv" => "# id\tcompeting_conditions\tdetecting_point\texpected_result\tlater_hook_called\tpublished_rows\treuse\tevidence_class",
  "BoundaryCorpus/framework-invariants.tsv" => "# id\tinjection\texpected_result\tbody_evaluations\tpublished_rows\treuse\tevidence_class",
  "BoundaryCorpus/owner-mapping.tsv" => "# id\tlocal_result\tcondition\torigin\taffected_scope\tcontainment\tcycle_state\tevidence_class",
}
expected_headers.each do |relative, expected|
  path = FIXTURES.join(relative)
  fail_check("missing #{relative}") unless path.file?
  actual = path.each_line.first&.chomp
  fail_check("#{relative} header differs") unless actual == expected
end

semantic_imports = SEMANTIC_CORE.glob("**/*.swift").flat_map do |path|
  path.each_line.map { |line| line[/\Aimport\s+(\S+)/, 1] }.compact
end
fail_check("Semantic Core imports the failure layer") if semantic_imports.include?("GiftUIFailureCore")

rows = FIXTURES.join("fixture-manifest.tsv").each_line.each_with_object([]) do |line, result|
  next if line.start_with?("#") || line.strip.empty?

  fields = line.chomp.split("\t", -1)
  fail_check("fixture row must have six fields") unless fields.length == 6
  result << fields
end
fail_check("fixture identifiers are duplicated") unless rows.map(&:first).uniq.length == rows.length
fail_check("fixture baseline must not be empty") if rows.empty?

identity_rows = FIXTURES.join("SemanticCorpus/identity-relations.tsv").each_line.each_with_object([]) do |line, result|
  next if line.start_with?("#") || line.strip.empty?

  fields = line.chomp.split("\t", -1)
  fail_check("identity relation row must have eight fields") unless fields.length == 8
  result << fields
end
fail_check("identity relation identifiers are duplicated") unless identity_rows.map(&:first).uniq.length == identity_rows.length
fail_check("identity relation corpus must not be empty") if identity_rows.empty?
identity_rows.each do |id, lhs_path, lhs_role, rhs_path, rhs_role, relation, expected_result, evidence|
  fail_check("invalid identity relation identifier #{id}") unless id.match?(/\A[a-z0-9]+(?:-[a-z0-9]+)*\z/)
  fail_check("missing identity relation path for #{id}") if lhs_path.empty? || rhs_path.empty?
  fail_check("missing identity endpoint role for #{id}") if lhs_role.empty? || rhs_role.empty?
  fail_check("invalid identity relation for #{id}") unless %w[equal not-equal alias-rejected].include?(relation)
  fail_check("invalid identity result for #{id}") unless %w[success invalid-identity].include?(expected_result)
  fail_check("invalid identity evidence class for #{id}") unless %w[host cross-built simulator connected-target].include?(evidence)
  fail_check("alias rejection must fail invalid-identity for #{id}") if relation == "alias-rejected" && expected_result != "invalid-identity"
end

boundary_rows = FIXTURES.join("BoundaryCorpus/cases.tsv").each_line.each_with_object([]) do |line, result|
  next if line.start_with?("#") || line.strip.empty?

  fields = line.chomp.split("\t", -1)
  fail_check("boundary row must have seven fields") unless fields.length == 7
  result << fields
end
fail_check("boundary identifiers are duplicated") unless boundary_rows.map(&:first).uniq.length == boundary_rows.length
fail_check("boundary corpus must not be empty") if boundary_rows.empty?
boundary_rows.each do |id, owner, below, exact, one_over, expected, evidence|
  fail_check("invalid boundary identifier #{id}") unless id.match?(/\A[a-z0-9]+(?:-[a-z0-9]+)*\z/)
  fail_check("invalid boundary owner for #{id}") unless %w[limits workspace sink counter].include?(owner)
  fail_check("invalid boundary values for #{id}") unless below.match?(/\A\d+\z/) && exact.match?(/\A\d+\z/) && (one_over == "overflow" || one_over.match?(/\A\d+\z/))
  fail_check("nonconsecutive boundary for #{id}") unless exact.to_i == below.to_i + 1
  if one_over == "overflow"
    fail_check("invalid overflow edge for #{id}") unless exact.to_i == 65_535
  else
    fail_check("nonconsecutive one-over value for #{id}") unless one_over.to_i == exact.to_i + 1
  end
  fail_check("invalid boundary result for #{id}") unless expected == "capacity-exhausted"
  fail_check("invalid boundary evidence class for #{id}") unless %w[host cross-built simulator connected-target].include?(evidence)
end

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
  portable-module public-interface ordered-corpus normalized-results allocation-record owned-value-layouts
  summary-counters maximum-observed-depth underscored-reference-inventory nrf-elf-inspection
  complexity-instrumentation primitive-container
]
fail_check("required evidence set differs") unless required.keys.sort == expected_evidence.sort
missing = required.value?("missing")
fail_check("missing evidence was reported complete") if missing && metadata["evidence_complete"] != "false"
fail_check("complete evidence was reported incomplete") if !missing && metadata["evidence_complete"] != "true"

puts "SPEC-006 report is fail-closed: #{required.count { |_key, value| value == 'missing' }} required item(s) pending."
