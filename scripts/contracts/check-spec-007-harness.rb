#!/usr/bin/env ruby
# frozen_string_literal: true

require "pathname"
require "yaml"

ROOT = Pathname.new(File.expand_path("../..", __dir__))
FIXTURES = ROOT.join("Tests/ContractFixtures/SPEC007")
EVIDENCE_CLASSES = %w[
  host-execution
  cross-build
  inspection
  simulator
  connected-hardware
].freeze
TOKEN_PATTERNS = {
  "scope" => /\Ascope:[a-z0-9]+(?:-[a-z0-9]+)*\z/,
  "resource" => /\A(?:instance|glyph):[a-z0-9]+(?:-[a-z0-9]+)*\z/,
}.freeze
FORBIDDEN_TOKEN_PATTERN = /\A(?:pointer|address|hash|metatype|profile-private):/

def fail_check(message)
  warn "SPEC-007 harness check failed: #{message}"
  exit 1
end

def tsv_rows(relative, header, width)
  path = FIXTURES.join(relative)
  fail_check("missing #{relative}") unless path.file?
  lines = path.each_line.to_a
  fail_check("#{relative} header differs") unless lines.first&.chomp == header
  lines.drop(1).each_with_object([]) do |line, rows|
    next if line.strip.empty? || line.start_with?("#")

    fields = line.chomp.split("\t", -1)
    fail_check("#{relative} row must have #{width} fields") unless fields.length == width
    rows << fields
  end
end

manifest = tsv_rows(
  "fixture-manifest.tsv",
  "# order\tfile\tdomain\tcollection\tevidence_classes",
  5
)
fail_check("fixture manifest order differs") unless manifest.map(&:first) == ["1"]
fail_check("fixture manifest file differs") unless manifest.dig(0, 1) == "fixtures.yaml"
fail_check("fixture manifest domain differs") unless manifest.dig(0, 2) == "layout-corpus"
fail_check("fixture manifest collection differs") unless manifest.dig(0, 3) == "cases"
manifest.each do |_order, _file, _domain, _collection, evidence|
  values = evidence.split(",")
  fail_check("fixture evidence classes differ") unless values.sort == EVIDENCE_CLASSES.sort && values == values.sort.uniq
end

fields = tsv_rows("fixture-fields.tsv", "# field\tkind\trule", 3)
fail_check("field registry is empty") if fields.empty?
fail_check("field registry has duplicate fields") unless fields.map(&:first).uniq.length == fields.length
fail_check("field registry has an empty value") if fields.any? { |row| row.any?(&:empty?) }

tokens = tsv_rows("source-tokens.tsv", "# namespace\tformat\tauthority", 3)
fail_check("source-token namespaces differ") unless tokens.map(&:first) == %w[scope instance glyph]
fail_check("source-token registry has an empty value") if tokens.any? { |row| row.any?(&:empty?) }

events = tsv_rows("source-token-transcript.tsv", "# order\tevent\trequired_fields", 3)
fail_check("transcript event order differs") unless events.map(&:first) == %w[1 2 3]
fail_check("transcript vocabulary differs") unless events.map { |row| row[1] } == %w[scope text-line glyph]
event_fields = events.to_h { |_order, event, required| [event, required.split(",")] }

results = tsv_rows("normalized-results.tsv", "# result\trequired_fields\tallowed_values", 3)
fail_check("normalized result vocabulary differs") unless results.map(&:first) == %w[success failure]

failures = tsv_rows(
  "failure-schema.tsv",
  "# raw_value\tlocal_error\tcondition\torigin\taffected_scope\tcontainment",
  6
)
expected_errors = %w[
  invalid-declaration
  arithmetic-overflow
  capacity-exhausted
  reentrancy-violation
  invariant-violation
]
fail_check("failure raw values differ") unless failures.map(&:first) == (0..4).map(&:to_s)
fail_check("failure vocabulary differs") unless failures.map { |row| row[1] } == expected_errors
fail_check("result and failure vocabularies differ") unless results.assoc("failure").fetch(2).split(",") == expected_errors

evidence = tsv_rows(
  "required-evidence.tsv",
  "# criterion\towner_tasks\tevidence\tcases\tstatus",
  5
)
expected_criteria = (1..9).map { |value| format("LY-%03d", value) }
fail_check("required evidence criteria differ") unless evidence.map(&:first) == expected_criteria
fail_check("required evidence criteria are duplicated") unless evidence.map(&:first).uniq.length == evidence.length
fail_check("initial evidence must remain pending") unless evidence.all? { |row| row[4] == "pending" }
fail_check("owner task or evidence is empty") if evidence.any? { |row| row[1].empty? || row[2].empty? }

fixture_path = FIXTURES.join("fixtures.yaml")
fail_check("missing fixtures.yaml") unless fixture_path.file?
begin
  document = YAML.safe_load(fixture_path.read, aliases: false)
rescue Psych::Exception => error
  fail_check("fixtures.yaml is invalid YAML: #{error.message}")
end
fail_check("fixtures.yaml root differs") unless document.is_a?(Hash) && document.keys.sort == %w[cases schema]
fail_check("fixtures.yaml schema differs") unless document["schema"] == "spec-007-fixtures-v1"
cases = document["cases"]
fail_check("fixtures.yaml cases must be a sequence") unless cases.is_a?(Array)

all_names = []
case_criteria = Hash.new { |hash, key| hash[key] = [] }
cases.each do |row|
  fail_check("fixture entry must be a mapping") unless row.is_a?(Hash)
  name = row["name"]
  valid_name = name.is_a?(String) && name.match?(/\A[a-z0-9]+(?:-[a-z0-9]+)*\z/)
  fail_check("fixture has invalid name") unless valid_name
  missing = fields.map(&:first) - row.keys
  unknown = row.keys - fields.map(&:first)
  fail_check("#{name} lacks fields: #{missing.join(',')}") unless missing.empty?
  fail_check("#{name} has unknown fields: #{unknown.join(',')}") unless unknown.empty?

  criteria = row["criteria"]
  valid_criteria = criteria.is_a?(Array) && !criteria.empty? && (criteria - expected_criteria).empty?
  fail_check("#{name} has invalid criterion references") unless valid_criteria
  classes = row["evidenceClasses"]
  valid_classes = classes.is_a?(Array) && !classes.empty? && (classes - EVIDENCE_CLASSES).empty?
  fail_check("#{name} has invalid evidence classes") unless valid_classes
  criteria.each { |criterion| case_criteria[criterion] << name }
  all_names << name

  transcript = row["expectedTranscript"]
  fail_check("#{name} transcript must be a sequence") unless transcript.is_a?(Array)
  transcript.each do |event|
    valid_event = event.is_a?(Hash) && event.keys.sort == %w[event fields] &&
      event_fields.key?(event["event"]) && event["fields"].is_a?(Hash)
    fail_check("#{name} has an unknown transcript event") unless valid_event
    required = event_fields.fetch(event["event"])
    fail_check("#{name} #{event['event']} fields differ") unless event["fields"].keys.sort == required.sort
  end

  declared = row["sourceTokens"]
  fail_check("#{name} source tokens must be a unique sequence") unless declared.is_a?(Array) && declared.uniq.length == declared.length
  valid_tokens = declared.all? do |token|
    token.is_a?(String) && (token.match?(TOKEN_PATTERNS["scope"]) || token.match?(TOKEN_PATTERNS["resource"]))
  end
  fail_check("#{name} has invalid source token") unless valid_tokens
  serialized = row.reject { |key, _value| key == "sourceTokens" }.to_s.scan(/[a-z-]+:[a-z0-9-]+/)
  fail_check("#{name} uses a forbidden identity representation") if serialized.any? { |token| token.match?(FORBIDDEN_TOKEN_PATTERN) }
  referenced = serialized.select { |token| token.match?(TOKEN_PATTERNS["scope"]) || token.match?(TOKEN_PATTERNS["resource"]) }.uniq
  fail_check("#{name} token declarations and references differ") unless declared.sort == referenced.sort
end
fail_check("fixture names are duplicated") unless all_names.uniq.length == all_names.length

evidence.each do |criterion, _tasks, _stable_evidence, listed_cases, _status|
  registered = listed_cases == "-" ? [] : listed_cases.split(",").sort
  fail_check("#{criterion} case references are not reciprocal") unless registered == case_criteria[criterion].sort
end

yaml_files = FIXTURES.children.select { |path| path.extname == ".yaml" }.map { |path| path.basename.to_s }.sort
fail_check("unregistered or missing YAML fixture") unless yaml_files == ["fixtures.yaml"]

if ARGV.empty?
  puts "SPEC-007 fixture schemas passed: #{cases.length} canonical case(s), 9 pending acceptance criteria"
  exit 0
end

report = Pathname.new(ARGV.fetch(0))
required_report_files = %w[
  metadata.txt commands.txt input-hashes.tsv image-hashes.tsv
  required-evidence.tsv prerequisites.tsv run.log
]
missing_report_files = required_report_files.reject { |relative| report.join(relative).file? }
fail_check("report lacks #{missing_report_files.join(',')}") unless missing_report_files.empty?
fail_check("command transcript is empty") if report.join("commands.txt").read.strip.empty?
fail_check("input digest inventory is empty") if report.join("input-hashes.tsv").read.strip.empty?

metadata = report.join("metadata.txt").each_line.each_with_object({}) do |line, values|
  key, value = line.chomp.split("=", 2)
  values[key] = value if value
end
fail_check("report schema differs") unless metadata["schema_version"] == "1"
fail_check("report spec differs") unless metadata["spec"] == "SPEC-007"
profiles = %w[macos-dynamic macos-static raspberry-pi-armv6 nrf52840-embedded]
fail_check("report profile differs") unless profiles.include?(metadata["profile"])
fail_check("report lacks repository revision") unless metadata["repository_revision"]&.match?(/\A[0-9a-f]{40}\z/)
fail_check("report lacks dirty state") unless %w[true false].include?(metadata["repository_dirty"])
fail_check("report lacks input digest") unless metadata["input_set_sha256"]&.match?(/\A[0-9a-f]{64}\z/)
fail_check("report lacks run identity") if metadata.fetch("run_id", "").empty?
fail_check("layout target must remain blocked") unless metadata["layout_target"] == "blocked"
fail_check("fixture corpus must remain missing") unless metadata["fixture_corpus"] == "missing"
fail_check("incomplete evidence must not claim completion") unless metadata["evidence_complete"] == "false"
%w[
  remote_access deployment service_restart simulator_execution
  connected_target_execution flashing
].each do |key|
  fail_check("driver must report #{key}=false") unless metadata[key] == "false"
end

report_evidence = report.join("required-evidence.tsv").each_line.each_with_object([]) do |line, rows|
  next if line.start_with?("#") || line.strip.empty?

  row = line.chomp.split("\t", -1)
  fail_check("malformed report evidence row") unless row.length == 3
  rows << row
end
fail_check("report evidence criteria differ") unless report_evidence.map(&:first) == expected_criteria
fail_check("report evidence must remain missing") unless report_evidence.all? { |row| row[1] == "missing" }
fail_check("report evidence lacks reasons") if report_evidence.any? { |row| row[2].empty? }

prerequisites = report.join("prerequisites.tsv").each_line.each_with_object([]) do |line, rows|
  next if line.start_with?("#") || line.strip.empty?

  row = line.chomp.split("\t", -1)
  fail_check("malformed prerequisite row") unless row.length == 3
  rows << row
end
expected_prerequisites = %w[
  compiler-identity target-sdk-identity optimization repository-state
  command-transcript fixture-digest layout-target fixture-corpus value-layouts
  limits-high-water allocation workspace stack linked-code-delta no-second-graph
  target-inspection nrf-hard-float-elf acceptance-evidence
]
fail_check("prerequisite set differs") unless prerequisites.map(&:first) == expected_prerequisites
allowed_statuses = %w[complete missing blocked]
fail_check("invalid prerequisite status") if prerequisites.any? { |row| !allowed_statuses.include?(row[1]) }
fail_check("prerequisite lacks reason") if prerequisites.any? { |row| row[2].empty? }

puts "SPEC-007 report is fail-closed: 9 criteria missing; layout target blocked"
