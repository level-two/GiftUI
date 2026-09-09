#!/usr/bin/env ruby
# frozen_string_literal: true

require "pathname"
require "yaml"

ROOT = Pathname.new(File.expand_path("../..", __dir__))
FIXTURES = Pathname.new(ENV.fetch("SPEC009_FIXTURE_ROOT", ROOT.join("Tests/ContractFixtures/SPEC009").to_s))
EXPECTED_FILES = %w[
  cycles.yaml
  handoff.yaml
  input.yaml
  recovery.yaml
  owner-failures.yaml
  signal-analyzer.yaml
].freeze
SHARED_FIELDS = %w[
  name
  initialState
  limits
  preOpportunityAdmissions
  phaseInjections
  endpointScript
  expectedPhaseTranscript
  expectedAdmissionSummary
  expectedResult
  expectedAuthoritativeState
  expectedWakeTransitions
  expectedFailureOrOperationalMapping
].freeze
CASE_METADATA_FIELDS = %w[criteria evidenceClasses].freeze
FORBIDDEN_IDENTITY_NAMESPACES = %w[
  pointer
  address
  closure
  metatype
  hash
  profile-private
].freeze
SUMMARY_FIELDS = %w[
  cycle admission semanticRevision semanticDisposition logicalFrameDisposition
  committedPresentationRevision presentationIntentState presentationPending operationalEvents
].freeze
ADMISSION_FIELDS = %w[
  inputEvents stateChangeFacts completionFacts semanticActions semanticDirty presentationPending
].freeze
ENDPOINT_FIELDS = %w[
  bodyCalled frameStreamResult retainedRenderError frameOfferResult irreversibleOutputBegan
].freeze
OPERATIONAL_PRECEDENCE = %w[
  retryable-refusal backpressured superseded deferred-to-later-admission no-change
].freeze

def fail_check(message)
  warn "SPEC-009 harness check failed: #{message}"
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

def explicit_value?(value)
  !value.nil? && value != ""
end

def validate_shape(name, field, value, kind)
  fail_check("#{name}.#{field} must use explicit none") unless explicit_value?(value)
  return if value == "none"

  expected = if kind.start_with?("mapping")
               Hash
             elsif kind.start_with?("sequence")
               Array
             else
               String
             end
  fail_check("#{name}.#{field} has wrong #{kind} shape") unless value.is_a?(expected)
end

def validate_exact_keys(name, value, fields)
  fail_check("#{name} must be a mapping") unless value.is_a?(Hash)
  fail_check("#{name} fields differ") unless value.keys.sort == fields.sort
end

def validate_identity_tokens(name, value, namespaces)
  case value
  when Hash
    value.each do |key, child|
      validate_identity_tokens(name, key, namespaces)
      validate_identity_tokens(name, child, namespaces)
    end
  when Array
    value.each { |child| validate_identity_tokens(name, child, namespaces) }
  when String
    token = value.match(/\A([a-z][a-z-]*):(.*)\z/)
    return unless token

    namespace = token[1]
    fail_check("#{name} uses forbidden identity representation") if FORBIDDEN_IDENTITY_NAMESPACES.include?(namespace)
    return unless namespaces.include?(namespace)

    fail_check("#{name} has invalid symbolic identity") unless token[2].match?(/\A\d+\z/)
  end
end

def validate_admission(name, admission)
  validate_exact_keys("#{name}.admission", admission, ADMISSION_FIELDS)
  numeric = %w[inputEvents stateChangeFacts completionFacts semanticActions]
  fail_check("#{name} admission counts must be nonnegative integers") unless numeric.all? { |field| admission[field].is_a?(Integer) && admission[field] >= 0 }
  fail_check("#{name} admission flags must be boolean") unless %w[semanticDirty presentationPending].all? { |field| [true, false].include?(admission[field]) }
  fail_check("#{name} semantic actions exceed inputs") if admission["semanticActions"] > admission["inputEvents"]
end

def validate_operational_events(name, events)
  validate_exact_keys("#{name}.operationalEvents", events, %w[rawValue events])
  values = events["events"]
  fail_check("#{name} operational events must be a unique sequence") unless values.is_a?(Array) && values.uniq == values
  fail_check("#{name} has unknown operational event") unless (values - OPERATIONAL_PRECEDENCE).empty?
  expected_raw = values.sum { |event| 1 << (4 - OPERATIONAL_PRECEDENCE.index(event)) }
  fail_check("#{name} operational raw value differs") unless events["rawValue"] == expected_raw
end

def validate_summary(name, summary)
  validate_exact_keys("#{name}.summary", summary, SUMMARY_FIELDS)
  validate_admission(name, summary["admission"])
  validate_operational_events(name, summary["operationalEvents"])
  symbolic_or_none = ->(value, namespace) { value == "none" || value.is_a?(String) && value.match?(%r{\A#{namespace}:\d+\z}) }
  fail_check("#{name} has invalid cycle") unless symbolic_or_none.call(summary["cycle"], "cycle") && summary["cycle"] != "none"
  fail_check("#{name} has invalid semantic revision") unless symbolic_or_none.call(summary["semanticRevision"], "semantic")
  fail_check("#{name} has invalid presentation revision") unless symbolic_or_none.call(summary["committedPresentationRevision"], "presentation")
  semantic = summary["semanticDisposition"]
  frame = summary["logicalFrameDisposition"]
  intent = summary["presentationIntentState"]
  pending = summary["presentationPending"]
  fail_check("#{name} has unknown semantic disposition") unless %w[unchanged published dirty].include?(semantic)
  fail_check("#{name} has unknown frame disposition") unless %w[not-produced committed aborted].include?(frame)
  fail_check("#{name} has unknown presentation intent") unless %w[satisfied pending unavailable].include?(intent)
  fail_check("#{name} published without semantic revision") if semantic == "published" && summary["semanticRevision"] == "none"
  fail_check("#{name} committed without presentation revision") if frame == "committed" && summary["committedPresentationRevision"] == "none"
  fail_check("#{name} committed frame is not satisfied") if frame == "committed" && intent != "satisfied"
  fail_check("#{name} pending intent shape differs") unless (intent == "pending") == pending.is_a?(Hash)
  if pending.is_a?(Hash)
    validate_exact_keys("#{name}.presentationPending", pending, %w[semanticRevision retryableRefusalCount])
    fail_check("#{name} pending revision differs") unless pending["semanticRevision"] == summary["semanticRevision"]
    fail_check("#{name} pending retry count is invalid") unless pending["retryableRefusalCount"].is_a?(Integer) && pending["retryableRefusalCount"].between?(0, 255)
  elsif pending != "none"
    fail_check("#{name} presentationPending must use explicit none")
  end
  values = summary["operationalEvents"]["events"]
  fail_check("#{name} has contradictory refusal events") if values.include?("backpressured") && values.include?("retryable-refusal")
  fail_check("#{name} no-change summary differs") if values.include?("no-change") && (semantic != "unchanged" || frame != "not-produced" || intent != "satisfied")
  fail_check("#{name} backpressure summary differs") if values.include?("backpressured") && (frame != "aborted" || intent != "pending")
  fail_check("#{name} retryable-refusal summary differs") if values.include?("retryable-refusal") && (frame != "aborted" || intent == "satisfied")
  fail_check("#{name} superseded summary differs") if values.include?("superseded") && semantic != "published"
end

def validate_expected_result(name, result)
  return if result == "none"

  fail_check("#{name}.expectedResult must be a mapping") unless result.is_a?(Hash)
  kind = result["kind"]
  case kind
  when "success"
    validate_exact_keys("#{name}.expectedResult", result, %w[kind summary])
  when "operational"
    validate_exact_keys("#{name}.expectedResult", result, %w[kind primary summary])
  when "failure"
    validate_exact_keys("#{name}.expectedResult", result, %w[kind context failure summary])
  else
    fail_check("#{name} has unknown result kind")
  end
  validate_summary(name, result["summary"]) if result["summary"].is_a?(Hash)
  return unless kind == "operational"

  events = result.fetch("summary").fetch("operationalEvents").fetch("events")
  expected = OPERATIONAL_PRECEDENCE.find { |candidate| events.include?(candidate) }
  fail_check("#{name} primary operational precedence differs") unless result["primary"] == expected
end

def validate_endpoint(name, endpoint)
  return if endpoint == "none"

  validate_exact_keys("#{name}.endpointScript", endpoint, ENDPOINT_FIELDS)
  fail_check("#{name} endpoint booleans differ") unless %w[bodyCalled irreversibleOutputBegan].all? { |field| [true, false].include?(endpoint[field]) }
  fail_check("#{name} no-body endpoint declares a stream result") if !endpoint["bodyCalled"] && endpoint["frameStreamResult"] != "none"
  fail_check("#{name} irreversible output requires the body") if endpoint["irreversibleOutputBegan"] && !endpoint["bodyCalled"]
end

manifest = tsv_rows(
  "fixture-manifest.tsv",
  "# order\tfile\tdomain\textra_fields\tevidence_classes",
  5
)
fail_check("fixture manifest order differs") unless manifest.map(&:first) == (1..6).map(&:to_s)
fail_check("fixture manifest files differ") unless manifest.map { |row| row[1] } == EXPECTED_FILES
fail_check("fixture manifest domains are duplicated") unless manifest.map { |row| row[2] }.uniq.length == 6

shared = tsv_rows("shared-fields.tsv", "# field\tkind\trule", 3)
fail_check("shared fields differ") unless shared.map(&:first) == SHARED_FIELDS
fail_check("shared fields are duplicated") unless shared.map(&:first).uniq.length == shared.length

phases = tsv_rows("phase-vocabulary.tsv", "# event\tphase\trequired_fields", 3)
fail_check("phase events are duplicated") unless phases.map(&:first).uniq.length == phases.length

normalized = tsv_rows("normalized-schema.tsv", "# record\trequired_fields\tallowed_values", 3)
fail_check("normalized records are duplicated") unless normalized.map(&:first).uniq.length == normalized.length

identities = tsv_rows("identity-rules.tsv", "# namespace\tformat\tfirst\tallocation", 4)
namespaces = identities.map(&:first)
fail_check("identity namespaces are duplicated") unless namespaces.uniq.length == namespaces.length

evidence = tsv_rows(
  "required-evidence.tsv",
  "# criterion\towner_tasks\tevidence\tcases\tstatus",
  5
)
criteria = evidence.map(&:first)
expected_criteria = (1..14).map { |value| format("EX-%03d", value) }
fail_check("required evidence criteria differ") unless criteria == expected_criteria
fail_check("initial evidence must remain pending") unless evidence.all? { |row| row[4] == "pending" }

yaml_files = FIXTURES.children.select { |path| path.extname == ".yaml" }.map { |path| path.basename.to_s }.sort
fail_check("unregistered or missing YAML fixture") unless yaml_files == EXPECTED_FILES.sort

case_criteria = Hash.new { |hash, key| hash[key] = [] }
case_names = []
manifest.each do |_order, relative, _domain, extra_field_text, evidence_class_text|
  allowed_fields = SHARED_FIELDS + CASE_METADATA_FIELDS + extra_field_text.split(",")
  allowed_evidence = evidence_class_text.split(",")
  begin
    document = YAML.safe_load(FIXTURES.join(relative).read, aliases: false)
  rescue Psych::Exception => error
    fail_check("#{relative} is invalid YAML: #{error.message}")
  end
  fail_check("#{relative} root must be a mapping") unless document.is_a?(Hash)
  fail_check("#{relative} has unknown root fields") unless document.keys.sort == %w[cases schema]
  fail_check("#{relative} schema differs") unless document["schema"] == "spec-009-v1"
  cases = document["cases"]
  fail_check("#{relative} cases must be a sequence") unless cases.is_a?(Array)

  cases.each do |fixture_case|
    fail_check("#{relative} case must be a mapping") unless fixture_case.is_a?(Hash)
    name = fixture_case["name"]
    valid_name = name.is_a?(String) && name.match?(/\A[a-z0-9]+(?:-[a-z0-9]+)*\z/)
    fail_check("#{relative} has invalid case name") unless valid_name
    extra_fields = extra_field_text.split(",")
    missing = SHARED_FIELDS + extra_fields - fixture_case.keys
    unknown = fixture_case.keys - allowed_fields
    fail_check("#{name} lacks shared fields: #{missing.join(',')}") unless missing.empty?
    fail_check("#{name} has unknown fields: #{unknown.join(',')}") unless unknown.empty?
    fixture_criteria = fixture_case["criteria"]
    valid_criteria = fixture_criteria.is_a?(Array) && !fixture_criteria.empty?
    fail_check("#{name} has no criterion references") unless valid_criteria
    fail_check("#{name} has an unknown criterion") unless (fixture_criteria - expected_criteria).empty?
    fixture_evidence = fixture_case["evidenceClasses"]
    valid_evidence = fixture_evidence.is_a?(Array) && !fixture_evidence.empty?
    fail_check("#{name} has invalid evidence classes") unless valid_evidence &&
      (fixture_evidence - allowed_evidence).empty?
    shared.each { |field, kind, _rule| validate_shape(name, field, fixture_case[field], kind) }
    validate_endpoint(name, fixture_case["endpointScript"])
    validate_admission(name, fixture_case["expectedAdmissionSummary"]) if fixture_case["expectedAdmissionSummary"].is_a?(Hash)
    validate_expected_result(name, fixture_case["expectedResult"])
    validate_identity_tokens(name, fixture_case, namespaces)
    fixture_criteria.each { |criterion| case_criteria[criterion] << name }
    case_names << name
  end
end
fail_check("fixture case names are duplicated") unless case_names.uniq.length == case_names.length

evidence.each do |criterion, owner_tasks, stable_evidence, listed_cases, _status|
  fail_check("#{criterion} lacks owner tasks or evidence") if owner_tasks.empty? || stable_evidence.empty?
  expected_cases = case_criteria[criterion].sort
  registered_cases = listed_cases == "-" ? [] : listed_cases.split(",").sort
  fail_check("#{criterion} case references are not reciprocal") unless registered_cases == expected_cases
end

puts "SPEC-009 fixture schemas passed: #{case_names.length} case(s), 14 pending acceptance criteria"

exit 0 if ARGV.empty?
fail_check("expected one report directory") unless ARGV.length == 1
report = Pathname.new(ARGV.first)
%w[
  metadata.txt commands.txt input-hashes.tsv image-hashes.tsv
  required-evidence.tsv prerequisites.tsv
].each do |relative|
  path = report.join(relative)
  fail_check("report lacks #{relative}") unless path.file? && !path.empty?
end

metadata = report.join("metadata.txt").each_line.each_with_object({}) do |line, result|
  key, value = line.chomp.split("=", 2)
  result[key] = value if value
end
%w[
  spec profile repository_revision repository_dirty input_set_sha256 run_id
  invocation execution_target fixture_corpus target optimization compiler_path
  compiler_sha256 value_surface evidence_complete remote_access deployment service_restart
  simulator_execution connected_target_execution flashing
].each do |key|
  fail_check("metadata lacks #{key}") if metadata.fetch(key, "").empty?
end
fail_check("wrong report spec") unless metadata["spec"] == "SPEC-009"
profiles = %w[macos-dynamic macos-static raspberry-pi-armv6 nrf52840-embedded]
fail_check("unknown report profile") unless profiles.include?(metadata["profile"])
fail_check("execution target must be present") unless metadata["execution_target"] == "present"
fail_check("execution value surface must be complete") unless metadata["value_surface"] == "complete"
fail_check("fixture corpus must be complete") unless metadata["fixture_corpus"] == "complete"
fail_check("incomplete report claimed completeness") unless metadata["evidence_complete"] == "false"
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
  compiler-identity target-sdk-identity optimization command-transcript
  repository-revision fixture-schema execution-target fixture-corpus value-layouts
  allocations dependency-checks target-inspection acceptance-evidence
]
fail_check("prerequisite set differs") unless prerequisites.map(&:first) == expected_prerequisites
allowed_statuses = %w[complete missing blocked]
fail_check("invalid prerequisite status") if prerequisites.any? { |row| !allowed_statuses.include?(row[1]) }
fail_check("prerequisite lacks reason") if prerequisites.any? { |row| row[2].empty? }

puts "SPEC-009 report is fail-closed: 14 criteria missing; target present"
