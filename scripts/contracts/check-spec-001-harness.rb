#!/usr/bin/env ruby
# frozen_string_literal: true

require "yaml"

ROOT = File.expand_path("../..", __dir__)
FIXTURES = File.join(ROOT, "Tests/ContractFixtures/SPEC001")
SCHEMA_VERSION = 1
PROFILE_IDS = %w[macos-dynamic macos-static raspberry-pi-armv6 nrf52840-embedded].freeze
EVIDENCE_CLASSES = %w[governance module semantic execution cross-build connected resource].freeze

def rows(path)
  File.readlines(path, chomp: true).reject { |line| line.empty? || line.start_with?("#") }
end

def require_version(path)
  header = File.readlines(path, chomp: true).find { |line| line.start_with?("# schema_version=") }
  abort "#{path}: missing schema version" unless header == "# schema_version=#{SCHEMA_VERSION}"
end

manifest_path = File.join(FIXTURES, "fixture-registry.tsv")
manifest = rows(manifest_path).map { |line| line.split("\t", -1) }
abort "fixture registry columns differ" unless manifest.all? { |row| row.length == 4 }
abort "fixture registry order is not contiguous" unless manifest.map { |row| row[0].to_i } == (1..manifest.length).to_a
abort "fixture registry contains duplicate IDs" unless manifest.map { |row| row[1] }.uniq.length == manifest.length
abort "fixture registry contains duplicate paths" unless manifest.map { |row| row[2] }.uniq.length == manifest.length
abort "fixture registry has stale schema version" unless manifest.all? { |row| row[3] == SCHEMA_VERSION.to_s }
abort "fixture registry references a missing path" unless manifest.all? { |row| File.file?(File.join(FIXTURES, row[2])) }

expected_paths = %w[
  criterion-evidence-registry.tsv evidence-kinds.tsv semantic-transcript.schema.tsv
  callback-transcript.schema.tsv cycle-transcript.schema.tsv host-transcript.schema.tsv
  resource-transcript.schema.tsv task-evidence.yaml migration-inventory.tsv
  module-boundaries.tsv generated-static-equivalents.tsv driver-invocations.tsv
  prerequisite-registry.tsv downstream-source-truth.tsv
  negative-dependency-fixtures.tsv
  analyzer-consumers.tsv
  diagnostic-cases.tsv
  capture-value-cases.tsv
  capture-publication-cases.tsv
  domain-contract-cases.tsv
  retention-cases.tsv
  repository-lifecycle-cases.tsv
  deterministic-source-cases.tsv
  workload-oracle-cases.tsv
  presentation-value-cases.tsv
  admission-adapter-cases.tsv
  fact-application-cases.tsv
  failure-owner-cases.tsv
  presentation-integration-cases.tsv
  hierarchy-shape-cases.tsv
  control-state-cases.tsv
  waveform-drawing-cases.tsv
  portable-profile-audit.tsv
  fact-admission-cases.tsv
  integrated-cycle-cases.tsv
  exhaustive-failure-cases.tsv
  diagnostic-profile-matrix.tsv
  revision-boundary-cases.tsv
  sustained-workload-cases.tsv
]
abort "fixture registry is not exhaustive" unless manifest.map { |row| row[2] } == expected_paths

versioned_paths = expected_paths.reject { |path| path.end_with?(".yaml") }
versioned_paths.each { |path| require_version(File.join(FIXTURES, path)) }

schema_paths = expected_paths.grep(/\.schema\.tsv\z/)
schema_paths.each do |path|
  entries = rows(File.join(FIXTURES, path)).map { |line| line.split("\t", -1) }
  abort "#{path}: schema columns differ" unless entries.all? { |entry| entry.length == 4 }
  abort "#{path}: field order is not contiguous" unless entries.map { |entry| entry[0].to_i } == (1..entries.length).to_a
  abort "#{path}: duplicate field" unless entries.map { |entry| entry[1] }.uniq.length == entries.length
  abort "#{path}: unknown required marker" unless entries.all? { |entry| entry[3] == "true" }
  abort "#{path}: first field must be schema_version" unless entries.first[1] == "schema_version"
end

kind_rows = rows(File.join(FIXTURES, "evidence-kinds.tsv")).map { |line| line.split("\t", -1) }
abort "evidence kind columns differ" unless kind_rows.all? { |row| row.length == EVIDENCE_CLASSES.length + 1 }
abort "duplicate evidence kind" unless kind_rows.map(&:first).uniq.length == kind_rows.length
abort "invalid evidence permission" unless kind_rows.all? { |row| row.drop(1).all? { |value| %w[true false].include?(value) } }

criterion_rows = rows(File.join(FIXTURES, "criterion-evidence-registry.tsv")).map { |line| line.split("\t", -1) }
expected_criteria = (1..45).map { |number| format("SA-AC-%03d", number) }
abort "criterion registry columns differ" unless criterion_rows.all? { |row| row.length == 4 }
abort "criterion registry is missing, duplicate, unknown, or reordered" unless criterion_rows.map(&:first) == expected_criteria
abort "criterion registry has unknown class" unless criterion_rows.all? { |row| EVIDENCE_CLASSES.include?(row[1]) }
abort "criterion registry has contradictory status" unless criterion_rows.all? { |row| %w[baseline pending].include?(row[2]) }
abort "criterion registry has missing evidence identity" unless criterion_rows.all? { |row| !row[3].empty? }

task_document = YAML.safe_load(File.read(File.join(FIXTURES, "task-evidence.yaml")), aliases: false)
abort "task evidence schema version differs" unless task_document.fetch("schema_version") == SCHEMA_VERSION
abort "task evidence spec differs" unless task_document.fetch("spec") == "SPEC-001"

# Exercise the strict row contract used by transcript producers. These probes
# ensure missing, duplicate, unknown, reordered, stale, and unversioned fields
# are rejected without needing malformed checked-in fixtures.
def valid_transcript?(schema_entries, fields)
  expected = schema_entries.map { |entry| entry[1] }
  names = fields.map(&:first)
  return false unless names == expected
  return false unless names.uniq.length == names.length
  fields.first == ["schema_version", SCHEMA_VERSION.to_s]
end

schema_entries = rows(File.join(FIXTURES, schema_paths.first)).map { |line| line.split("\t", -1) }
valid = schema_entries.map { |entry| [entry[1], entry[1] == "schema_version" ? SCHEMA_VERSION.to_s : "value"] }
abort "valid transcript probe failed" unless valid_transcript?(schema_entries, valid)
probes = [valid.drop(1), valid + [["unknown", "value"]], valid + [valid.last], valid.reverse, valid.tap { |copy| copy[0] = ["schema_version", "0"] }]
abort "invalid transcript probe accepted" unless probes.none? { |probe| valid_transcript?(schema_entries, probe) }

puts "SPEC-001 harness passed: #{manifest.length} fixtures, #{criterion_rows.length} criteria, #{kind_rows.length} evidence kinds, and #{schema_paths.length} transcript schemas are registered."
