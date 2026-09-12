#!/usr/bin/env ruby
# frozen_string_literal: true

require "pathname"
require "yaml"

ROOT = Pathname.new(File.expand_path("../..", __dir__))
FIXTURES = ROOT.join("Tests/ContractFixtures/SPEC014")
EXPECTED_FILES = %w[
  raster.yaml transactions.yaml capabilities.yaml failures.yaml resources.yaml
].freeze
EXPECTED_FIELDS = %w[
  fixtureID criteria evidenceClasses profiles descriptor effectiveCapability
  header operationsResources injectedEvents orderedRegions encodedImage
  offerResult bodyResult health highWater
].freeze
EXPECTED_CRITERIA = (1..15).map { |number| format("BI-%03d", number) }.freeze
EXPECTED_PROFILES = %w[
  macos-dynamic macos-static raspberry-pi-armv6 nrf52840-embedded
].freeze
EVIDENCE_CLASSES = %w[cross-build host-execution inspection].freeze

def fail_check(message)
  warn "SPEC-014 fixture check failed: #{message}"
  exit 1
end

required_files = %w[
  README.md fixture-manifest.tsv shared-field-schema.tsv required-evidence.tsv
  module-owners.tsv dependency-fixtures.tsv migration-inventory.tsv
  declaration-compile-fixtures.tsv
] + EXPECTED_FILES
missing = required_files.reject { |name| FIXTURES.join(name).file? }
fail_check("required fixture files are missing: #{missing.join(', ')}") unless missing.empty?

compile_rows = FIXTURES.join("declaration-compile-fixtures.tsv").each_line.each_with_object([]) do |line, rows|
  next if line.start_with?("#") || line.strip.empty?

  fields = line.chomp.split("\t", -1)
  fail_check("declaration compile row width differs") unless fields.length == 4
  rows << fields
end
fail_check("declaration compile fixture count differs") unless compile_rows.length == 5
fail_check("declaration compile fixture IDs are duplicated") unless compile_rows.map(&:first).uniq.length == compile_rows.length
compile_rows.each do |fixture_id, from_module, forbidden_module, diagnostic|
  fail_check("invalid declaration fixture ID #{fixture_id}") unless fixture_id.match?(/\A[a-z0-9]+(?:-[a-z0-9]+)*\z/)
  valid_module = /\AGiftUI[A-Za-z0-9]*\z/
  fail_check("invalid declaration fixture module") unless from_module.match?(valid_module) && forbidden_module.match?(valid_module)
  fail_check("empty declaration fixture diagnostic") if diagnostic.empty?
  source = FIXTURES.join("Fixtures/Negative", fixture_id, "main.swift")
  fail_check("missing declaration fixture source #{fixture_id}") unless source.file?
end
fail_check("missing positive compile-surface fixture") unless FIXTURES.join("Fixtures/Positive/compile-surface/main.swift").file?
fail_check("missing value-layout instrumentation") unless FIXTURES.join("Instrumentation/BackendValueLayoutProbe.swift").file?

manifest_rows = FIXTURES.join("fixture-manifest.tsv").each_line.each_with_object([]) do |line, rows|
  next if line.start_with?("#") || line.strip.empty?

  fields = line.chomp.split("\t", -1)
  fail_check("fixture manifest row width differs") unless fields.length == 5
  rows << fields
end
fail_check("fixture manifest order differs") unless manifest_rows.map { |row| row[0].to_i } == (1..5).to_a
fail_check("fixture manifest file set differs") unless manifest_rows.map { |row| row[1] } == EXPECTED_FILES

schema_rows = FIXTURES.join("shared-field-schema.tsv").each_line.each_with_object([]) do |line, rows|
  next if line.start_with?("#") || line.strip.empty?

  fields = line.chomp.split("\t", -1)
  fail_check("shared-field schema row width differs") unless fields.length == 4
  rows << fields
end
fail_check("shared-field schema differs") unless schema_rows.map(&:first) == EXPECTED_FIELDS
fail_check("shared-field schema contains duplicate fields") unless schema_rows.map(&:first).uniq.length == schema_rows.length

all_cases = {}
manifest_rows.each do |row|
  classes = row[4].split(",", -1)
  fail_check("duplicate evidence class for #{row[1]}") unless classes.uniq.length == classes.length
  fail_check("unknown evidence class for #{row[1]}") unless (classes - EVIDENCE_CLASSES).empty?

  document = YAML.safe_load(FIXTURES.join(row[1]).read)
  fail_check("#{row[1]} schema differs") unless document.is_a?(Hash) && document["schema"] == "spec-014-v1"
  fail_check("#{row[1]} cases must be a sequence") unless document["cases"].is_a?(Array)
  fail_check("#{row[1]} has unknown top-level fields") unless document.keys.sort == %w[cases schema]

  document.fetch("cases").each do |fixture|
    fail_check("#{row[1]} case must be a mapping") unless fixture.is_a?(Hash)
    missing_fields = EXPECTED_FIELDS - fixture.keys
    unknown_fields = fixture.keys - EXPECTED_FIELDS
    fail_check("#{row[1]} case has missing fields: #{missing_fields.join(', ')}") unless missing_fields.empty?
    fail_check("#{row[1]} case has unknown fields: #{unknown_fields.join(', ')}") unless unknown_fields.empty?

    fixture_id = fixture["fixtureID"]
    fail_check("#{row[1]} fixtureID is invalid") unless fixture_id&.match?(/\Aspec014-[a-z0-9]+(?:-[a-z0-9]+)*\z/)
    fail_check("duplicate fixtureID #{fixture_id}") if all_cases.key?(fixture_id)

    criteria = fixture["criteria"]
    fail_check("#{fixture_id} has no criteria") unless criteria.is_a?(Array) && !criteria.empty?
    fail_check("#{fixture_id} has duplicate criteria") unless criteria.uniq.length == criteria.length
    fail_check("#{fixture_id} has unknown criteria") unless (criteria - EXPECTED_CRITERIA).empty?

    evidence_classes = fixture["evidenceClasses"]
    fail_check("#{fixture_id} has no evidence classes") unless evidence_classes.is_a?(Array) && !evidence_classes.empty?
    fail_check("#{fixture_id} has duplicate evidence classes") unless evidence_classes.uniq.length == evidence_classes.length
    fail_check("#{fixture_id} has unknown evidence classes") unless (evidence_classes - classes).empty?

    profiles = fixture["profiles"]
    fail_check("#{fixture_id} has no profiles") unless profiles.is_a?(Array) && !profiles.empty?
    fail_check("#{fixture_id} has duplicate profiles") unless profiles.uniq.length == profiles.length
    fail_check("#{fixture_id} has unknown profiles") unless (profiles - EXPECTED_PROFILES).empty?

    EXPECTED_FIELDS.drop(4).each do |field|
      value = fixture[field]
      fail_check("#{fixture_id} #{field} must be a mapping, sequence, or explicit none") unless value == "none" || value.is_a?(Hash) || value.is_a?(Array)
    end
    all_cases[fixture_id] = row[1]
  end
end

evidence_rows = FIXTURES.join("required-evidence.tsv").each_line.each_with_object([]) do |line, rows|
  next if line.start_with?("#") || line.strip.empty?

  fields = line.chomp.split("\t", -1)
  fail_check("required-evidence row width differs") unless fields.length == 5
  rows << fields
end
fail_check("acceptance registry differs") unless evidence_rows.map(&:first) == EXPECTED_CRITERIA
fail_check("acceptance registry must begin pending") unless evidence_rows.all? { |row| row[4] == "pending" }

referenced_cases = evidence_rows.flat_map do |row|
  next [] if row[3] == "-"

  references = row[3].split(",", -1)
  fail_check("#{row[0]} contains duplicate case references") unless references.uniq.length == references.length
  references.each do |fixture_id|
    fail_check("#{row[0]} references unknown case #{fixture_id}") unless all_cases.key?(fixture_id)
  end
  references
end
unreferenced = all_cases.keys - referenced_cases
fail_check("unreferenced fixture data: #{unreferenced.join(', ')}") unless unreferenced.empty?

runner = ROOT.join("scripts/contracts/run-spec-014.sh")
fail_check("SPEC-014 driver is missing or not executable") unless runner.file? && runner.executable?
runner_text = runner.read
EXPECTED_PROFILES.each do |profile|
  fail_check("driver profile is missing: #{profile}") unless runner_text.include?(profile)
end
fail_check("driver does not use the SPEC-014 output root") unless runner_text.include?(".build/spec-014")
fail_check("driver uses the shared contract-report output root") if runner_text.include?(".build/contract-reports")

puts "SPEC-014 fixture check passed: 5 ordered corpora, #{all_cases.length} registered cases, and 15 pending criteria."
