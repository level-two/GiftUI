#!/usr/bin/env ruby
# frozen_string_literal: true

require "pathname"
require "yaml"

ROOT = Pathname.new(File.expand_path("../..", __dir__))
FIXTURES = ROOT.join("Tests/ContractFixtures/SPEC008")
EVIDENCE_CLASSES = %w[
  host-execution
  cross-build
  inspection
  simulator
  connected-hardware
].freeze
TOKEN_PATTERNS = {
  "identity" => /\Aidentity:[a-z0-9]+(?:-[a-z0-9]+)*\z/,
  "resource" => /\A(?:resource|instance|glyph):[a-z0-9]+(?:-[a-z0-9]+)*\z/,
}.freeze
FORBIDDEN_TOKEN_PATTERN = /\A(?:pointer|address|hash|metatype|profile-private):/

def fail_check(message)
  warn "SPEC-008 harness check failed: #{message}"
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

def load_yaml(relative, expected_schema, collection)
  path = FIXTURES.join(relative)
  fail_check("missing #{relative}") unless path.file?
  begin
    document = YAML.safe_load(path.read, aliases: false)
  rescue Psych::Exception => error
    fail_check("#{relative} is invalid YAML: #{error.message}")
  end
  fail_check("#{relative} root must be a mapping") unless document.is_a?(Hash)
  fail_check("#{relative} has unknown root fields") unless document.keys.sort == [collection, "schema"].sort
  fail_check("#{relative} schema differs") unless document["schema"] == expected_schema
  rows = document[collection]
  fail_check("#{relative} #{collection} must be a sequence") unless rows.is_a?(Array)
  rows
end

def token_strings(value)
  case value
  when Hash
    value.flat_map { |key, nested| [key.to_s] + token_strings(nested) }
  when Array
    value.flat_map { |nested| token_strings(nested) }
  when String
    [value]
  else
    []
  end
end

manifest = tsv_rows(
  "fixture-manifest.tsv",
  "# order\tfile\tdomain\tcollection\tevidence_classes",
  5
)
fail_check("fixture manifest order differs") unless manifest.map(&:first) == %w[1 2]
fail_check("fixture manifest files differ") unless manifest.map { |row| row[1] } == %w[fixtures.yaml signal-analyzer.yaml]
fail_check("fixture manifest domains are duplicated") unless manifest.map { |row| row[2] }.uniq.length == 2
manifest.each do |_order, file, _domain, collection, evidence|
  expected_collection = file == "fixtures.yaml" ? "cases" : "variants"
  fail_check("#{file} collection differs") unless collection == expected_collection
  values = evidence.split(",")
  fail_check("#{file} evidence classes differ") unless values.sort == EVIDENCE_CLASSES.sort && values == values.sort.uniq
end

fixture_fields = tsv_rows("fixture-fields.tsv", "# field\tkind\trule", 3)
signal_fields = tsv_rows("signal-analyzer-fields.tsv", "# field\tkind\trule", 3)
[fixture_fields, signal_fields].each do |rows|
  fail_check("field registry is empty") if rows.empty?
  fail_check("field registry has duplicate fields") unless rows.map(&:first).uniq.length == rows.length
  fail_check("field registry has an empty rule") if rows.any? { |row| row.any?(&:empty?) }
end

tokens = tsv_rows("symbolic-tokens.tsv", "# namespace\tformat\tauthority", 3)
fail_check("symbolic token namespaces differ") unless tokens.map(&:first) == %w[identity resource instance glyph]
fail_check("symbolic token registry has an empty field") if tokens.any? { |row| row.any?(&:empty?) }

events = tsv_rows("recording-events.tsv", "# order\tevent\trequired_fields", 3)
fail_check("recording event order differs") unless events.map(&:first) == (1..6).map(&:to_s)
expected_events = %w[begin fill begin-glyphs glyph end-glyphs finish]
fail_check("recording event vocabulary differs") unless events.map { |row| row[1] } == expected_events
event_fields = events.to_h { |_order, event, fields| [event, fields == "-" ? [] : fields.split(",")] }

results = tsv_rows("normalized-results.tsv", "# result\trequired_fields\tallowed_values", 3)
fail_check("normalized result vocabulary differs") unless results.map(&:first) == %w[success failure]

failures = tsv_rows(
  "failure-schema.tsv",
  "# precedence\tlocal_error\tcondition\torigin\taffected_scope\tcontainment",
  6
)
expected_errors = %w[
  reentrancy-violation
  invalid-input
  arithmetic-overflow
  capacity-exhausted
  incompatible-text-resource
  sink-refused
  invariant-violation
]
fail_check("failure precedence differs") unless failures.map(&:first) == (1..7).map(&:to_s)
fail_check("failure vocabulary differs") unless failures.map { |row| row[1] } == expected_errors
failure_result_values = results.assoc("failure").fetch(2).split(",")
fail_check("result and failure vocabularies differ") unless failure_result_values == expected_errors.drop(1).insert(5, expected_errors.first)

evidence = tsv_rows(
  "required-evidence.tsv",
  "# criterion\towner_tasks\tevidence\tcases\tstatus",
  5
)
expected_criteria = (1..11).map { |value| format("RD-%03d", value) }
fail_check("required evidence criteria differ") unless evidence.map(&:first) == expected_criteria
fail_check("required evidence criteria are duplicated") unless evidence.map(&:first).uniq.length == evidence.length
fail_check("initial evidence must remain pending") unless evidence.all? { |row| row[4] == "pending" }
fail_check("owner task or evidence is empty") if evidence.any? { |row| row[1].empty? || row[2].empty? }

fixture_cases = load_yaml("fixtures.yaml", "spec-008-fixtures-v1", "cases")
signal_variants = load_yaml("signal-analyzer.yaml", "spec-008-signal-analyzer-v1", "variants")
all_names = []
case_criteria = Hash.new { |hash, key| hash[key] = [] }

[
  ["fixtures.yaml", fixture_cases, fixture_fields.map(&:first)],
  ["signal-analyzer.yaml", signal_variants, signal_fields.map(&:first)],
].each do |relative, rows, required_fields|
  rows.each do |row|
    fail_check("#{relative} entry must be a mapping") unless row.is_a?(Hash)
    name = row["name"]
    valid_name = name.is_a?(String) && name.match?(/\A[a-z0-9]+(?:-[a-z0-9]+)*\z/)
    fail_check("#{relative} has invalid entry name") unless valid_name
    missing = required_fields - row.keys
    unknown = row.keys - required_fields
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

    next unless relative == "fixtures.yaml"

    fail_check("#{name} has invalid damage mode") unless %w[root-intersection initialize-complete-surface].include?(row["damageMode"])
    expected = row["expectedResult"]
    fail_check("#{name} expected result must be a mapping") unless expected.is_a?(Hash)
    fail_check("#{name} expected result has unknown fields") unless (expected.keys - %w[kind header error]).empty?
    kind = expected["kind"]
    fail_check("#{name} has unknown result kind") unless %w[success failure].include?(kind)
    if kind == "success"
      fail_check("#{name} success must have only kind and header") unless expected.keys.sort == %w[header kind]
    else
      fail_check("#{name} failure must have only kind and error") unless expected.keys.sort == %w[error kind]
      fail_check("#{name} has unknown local error") unless expected_errors.include?(expected["error"])
    end
    recording = row["expectedRecordingEvents"]
    fail_check("#{name} recording events must be a sequence") unless recording.is_a?(Array)
    recording.each do |event|
      valid_event = event.is_a?(Hash) && event.keys.sort == %w[event fields] &&
        expected_events.include?(event["event"]) && event["fields"].is_a?(Hash)
      fail_check("#{name} has an unknown recording event") unless valid_event
      required_event_fields = event_fields.fetch(event["event"])
      fail_check("#{name} #{event['event']} event fields differ") unless event["fields"].keys.sort == required_event_fields.sort
    end

    mapping = row["expectedFailureMapping"]
    if kind == "success"
      fail_check("#{name} successful result must have no failure mapping") unless mapping == "none"
    else
      fail_check("#{name} failure mapping must be a mapping") unless mapping.is_a?(Hash)
      mapping_row = failures.find { |failure| failure[1] == expected["error"] }
      expected_mapping = {
        "condition" => mapping_row[2],
        "origin" => mapping_row[3],
        "affectedScope" => mapping_row[4],
        "containment" => mapping_row[5],
      }
      fail_check("#{name} failure mapping differs") unless mapping == expected_mapping
    end

    declared_identities = row["identityTokens"]
    declared_resources = row["resourceTokens"]
    fail_check("#{name} identity tokens must be a unique sequence") unless declared_identities.is_a?(Array) && declared_identities.uniq.length == declared_identities.length
    fail_check("#{name} resource tokens must be a unique sequence") unless declared_resources.is_a?(Array) && declared_resources.uniq.length == declared_resources.length
    fail_check("#{name} has invalid identity token") unless declared_identities.all? { |token| token.is_a?(String) && token.match?(TOKEN_PATTERNS["identity"]) }
    fail_check("#{name} has invalid resource token") unless declared_resources.all? { |token| token.is_a?(String) && token.match?(TOKEN_PATTERNS["resource"]) }
    referenced = token_strings(row.reject { |key, _value| %w[identityTokens resourceTokens].include?(key) })
    fail_check("#{name} uses a forbidden identity representation") if referenced.any? { |token| token.match?(FORBIDDEN_TOKEN_PATTERN) }
    referenced_identities = referenced.grep(TOKEN_PATTERNS["identity"]).uniq
    referenced_resources = referenced.grep(TOKEN_PATTERNS["resource"]).uniq
    fail_check("#{name} identity declarations and references differ") unless declared_identities.sort == referenced_identities.sort
    fail_check("#{name} resource declarations and references differ") unless declared_resources.sort == referenced_resources.sort
  end
end
fail_check("fixture and analyzer names are duplicated") unless all_names.uniq.length == all_names.length

evidence.each do |criterion, _tasks, _stable_evidence, listed_cases, _status|
  registered = listed_cases == "-" ? [] : listed_cases.split(",").sort
  fail_check("#{criterion} case references are not reciprocal") unless registered == case_criteria[criterion].sort
end

yaml_files = FIXTURES.children.select { |path| path.extname == ".yaml" }.map { |path| path.basename.to_s }.sort
fail_check("unregistered or missing YAML fixture") unless yaml_files == %w[fixtures.yaml signal-analyzer.yaml]

if ARGV.empty?
  puts "SPEC-008 fixture schemas passed: #{fixture_cases.length} canonical case(s), #{signal_variants.length} analyzer variant(s), 11 pending acceptance criteria"
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
fail_check("report spec differs") unless metadata["spec"] == "SPEC-008"
fail_check("report profile differs") unless %w[
  macos-dynamic macos-static raspberry-pi-armv6 nrf52840-embedded
].include?(metadata["profile"])
fail_check("report lacks repository revision") unless metadata["repository_revision"]&.match?(/\A[0-9a-f]{40}\z/)
fail_check("report lacks input digest") unless metadata["input_set_sha256"]&.match?(/\A[0-9a-f]{64}\z/)
fail_check("report lacks run identity") if metadata.fetch("run_id", "").empty?
fail_check("render core target must be recorded complete") unless metadata["render_core_target"] == "complete"
fail_check("render lowering must remain blocked") unless metadata["render_lowering_target"] == "blocked"
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

  fields = line.chomp.split("\t", -1)
  fail_check("malformed report evidence row") unless fields.length == 3
  rows << fields
end
fail_check("report evidence criteria differ") unless report_evidence.map(&:first) == expected_criteria
fail_check("report evidence must remain missing") unless report_evidence.all? { |row| row[1] == "missing" }
fail_check("report evidence lacks reasons") if report_evidence.any? { |row| row[2].empty? }

prerequisites = report.join("prerequisites.tsv").each_line.each_with_object([]) do |line, rows|
  next if line.start_with?("#") || line.strip.empty?

  fields = line.chomp.split("\t", -1)
  fail_check("malformed prerequisite row") unless fields.length == 3
  rows << fields
end
expected_prerequisites = %w[
  compiler-identity target-sdk-identity optimization repository-revision
  command-transcript fixture-digest render-targets value-layouts result-comparison
  transcript-comparison high-water allocation workspace stack timing section-delta
  link-map target-inspection acceptance-evidence
]
fail_check("prerequisite set differs") unless prerequisites.map(&:first) == expected_prerequisites
allowed_statuses = %w[complete missing blocked]
fail_check("invalid prerequisite status") if prerequisites.any? { |row| !allowed_statuses.include?(row[1]) }
fail_check("prerequisite lacks reason") if prerequisites.any? { |row| row[2].empty? }

puts "SPEC-008 report is fail-closed: 11 criteria missing; rendering targets blocked"
