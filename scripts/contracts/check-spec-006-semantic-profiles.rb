#!/usr/bin/env ruby
# frozen_string_literal: true

require "digest"
require "pathname"

ROOT = Pathname.new(File.expand_path("../..", __dir__))
CORPUS = ROOT.join("Tests/ContractFixtures/SPEC006/SemanticCorpus")
FIXTURES = CORPUS.parent

def fail_check(message)
  warn "SPEC-006 semantic profile check failed: #{message}"
  exit 1
end

def rows(path, width)
  path.each_line.each_with_object([]) do |line, result|
    next if line.start_with?("#") || line.strip.empty?

    fields = line.chomp.split("\t", -1)
    fail_check("#{path.basename} row width differs") unless fields.length == width
    result << fields
  end
end

cases = rows(CORPUS.join("cases.tsv"), 5)
results = rows(CORPUS.join("normalized-results.tsv"), 10)
events = rows(CORPUS.join("canonical-transcript.tsv"), 6)
relations = rows(CORPUS.join("identity-relations.tsv"), 8)
profile = rows(CORPUS.join("profile-corpus.tsv"), 3)
variants = rows(CORPUS.join("rank-zero-variants.tsv"), 6)

case_ids = cases.map(&:first)
fail_check("case IDs are duplicated") unless case_ids.uniq.length == case_ids.length
fail_check("normalized result IDs differ") unless results.map(&:first) == case_ids

events.group_by(&:first).each do |case_id, case_events|
  fail_check("transcript references unknown case #{case_id}") unless case_ids.include?(case_id)
  indices = case_events.map { |event| Integer(event[1], 10) }
  fail_check("event indices are not contiguous for #{case_id}") unless indices == (0...indices.length).to_a
end

result_by_id = results.to_h { |row| [row.first, row] }
results.each do |row|
  case_id = row.first
  event_count = events.count { |event| event.first == case_id }
  fail_check("transcript count differs for #{case_id}") unless Integer(row[7], 10) == event_count
end

required_categories = %w[
  declaration transcript identity summary bounds failure-order
  framework-failure owner-mapping state-host state-host-failure
  primitive-container
]
fail_check("profile corpus categories differ") unless profile.map(&:first) == required_categories
profile.each do |_category, artifact, _relation|
  fail_check("profile corpus artifact is missing: #{artifact}") unless FIXTURES.join(artifact).file?
end

variants.each do |id, case_id, backend, platform, capability, relation|
  fail_check("variant #{id} references unknown case") unless result_by_id.key?(case_id)
  fail_check("variant #{id} has unknown fixture fact") unless [backend, platform, capability].all? { |fact| %w[baseline alternate].include?(fact) }
  fail_check("variant #{id} can alter Rank 0 semantics") unless relation == "canonical-equal"
end

maximum_depth = results.map { |row| row[6] == "-" ? 0 : Integer(row[6], 10) }.max
counter_totals = (2..5).map do |index|
  results.sum { |row| row[index] == "-" ? 0 : Integer(row[index], 10) }
end
canonical_paths = %w[
  cases.tsv canonical-transcript.tsv identity-relations.tsv normalized-results.tsv
].map { |name| CORPUS.join(name) }
canonical_digest = Digest::SHA256.hexdigest(canonical_paths.map(&:read).join)

container_events = events.select { |event| event.first == "layout-container-chain" }
container_kinds = container_events.map { |event| event[3] }
fail_check("primitive container transcript does not stage before content") unless
  container_kinds[0, 12] == [
    "enter-structural-occurrence", "enter-structural-occurrence",
    "enter-structural-occurrence", "enter-structural-occurrence",
    "enter-structural-occurrence", "stage-semantic-occurrence",
    "enter-structural-occurrence", "stage-semantic-occurrence",
    "enter-structural-occurrence", "stage-semantic-occurrence",
    "enter-structural-occurrence", "stage-semantic-occurrence",
  ]
fail_check("primitive container modifier indices differ") unless
  container_events.last(4).map { |event| event[5] } == %w[0 1 2 3]

report = [
  "schema_version=1",
  "case_count=#{cases.length}",
  "transcript_rows=#{events.length}",
  "identity_relations=#{relations.length}",
  "semantic_nodes=#{counter_totals[0]}",
  "body_evaluations=#{counter_totals[1]}",
  "modifier_applications=#{counter_totals[2]}",
  "action_occurrences=#{counter_totals[3]}",
  "maximum_observed_depth=#{maximum_depth}",
  "rank_zero_variants=#{variants.length}",
  "canonical_sha256=#{canonical_digest}",
  "profile_relation=event-and-result-equal",
]

if ARGV.empty?
  puts "SPEC-006 semantic profiles passed: #{cases.length} cases, #{events.length} events, #{variants.length} Rank 0 variants, maximum depth #{maximum_depth}."
elsif ARGV.length == 2 && ARGV[0] == "--output"
  Pathname.new(ARGV[1]).write(report.join("\n") + "\n")
  puts "SPEC-006 semantic profile report written: #{ARGV[1]}"
else
  fail_check("usage: check-spec-006-semantic-profiles.rb [--output PATH]")
end
