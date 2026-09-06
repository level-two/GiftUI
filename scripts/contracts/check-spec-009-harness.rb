#!/usr/bin/env ruby
# frozen_string_literal: true

require "pathname"
require "yaml"

ROOT = Pathname.new(File.expand_path("../..", __dir__))
FIXTURES = ROOT.join("Tests/ContractFixtures/SPEC009")
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
    missing = SHARED_FIELDS - fixture_case.keys
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
    fixture_case.to_s.scan(/\b([a-z][a-z-]*):([^\s,}\]]+)/).each do |namespace, value|
      fail_check("#{name} uses forbidden identity representation") if FORBIDDEN_IDENTITY_NAMESPACES.include?(namespace)
      next unless namespaces.include?(namespace)

      fail_check("#{name} has invalid symbolic identity") unless value.match?(/\A\d+\z/)
    end
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
