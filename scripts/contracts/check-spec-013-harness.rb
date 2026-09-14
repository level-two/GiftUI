#!/usr/bin/env ruby
# frozen_string_literal: true

require "pathname"
require "yaml"

ROOT = Pathname.new(File.expand_path("../..", __dir__))
FIXTURES = ROOT.join("Tests/ContractFixtures/SPEC013")
MANIFEST = FIXTURES.join("fixture-manifest.tsv")
EVIDENCE_CLASSES = %w[
  connected-hardware cross-build host-execution inspection simulator
].freeze
EXPECTED_FILES = %w[
  storage.yaml startup.yaml cycles.yaml handoff.yaml static-canvas.yaml
  borrows.yaml equivalence.yaml signal-analyzer.yaml
].freeze
EXPECTED_CRITERIA = (1..15).map { |number| format("RP-%03d", number) }.freeze
EXPECTED_PROFILES = %w[
  macos-dynamic macos-static raspberry-pi-armv6 nrf52840-embedded
].freeze

def fail_check(message)
  warn "SPEC-013 harness check failed: #{message}"
  exit 1
end

required_files = %w[
  README.md artificial-limit-schema.tsv artificial-limit-values.tsv canonical-transcript.tsv
  fixture-manifest.tsv migration-inventory.tsv report-schema.tsv
  required-evidence.tsv module-boundaries.tsv storage-families.tsv
] + EXPECTED_FILES
missing = required_files.reject { |name| FIXTURES.join(name).file? }
fail_check("required fixtures are missing: #{missing.join(', ')}") unless missing.empty?

manifest_rows = MANIFEST.each_line.each_with_object([]) do |line, rows|
  next if line.start_with?("#") || line.strip.empty?

  fields = line.chomp.split("\t", -1)
  fail_check("fixture manifest row width differs") unless fields.length == 5
  rows << fields
end
fail_check("fixture manifest order differs") unless manifest_rows.map { |row| row[0].to_i } == (1..8).to_a
fail_check("fixture manifest file set differs") unless manifest_rows.map { |row| row[1] } == EXPECTED_FILES
manifest_rows.each do |row|
  classes = row[4].split(",", -1)
  fail_check("duplicate evidence class for #{row[1]}") unless classes.uniq.length == classes.length
  unknown = classes - EVIDENCE_CLASSES
  fail_check("unknown evidence class for #{row[1]}: #{unknown.join(', ')}") unless unknown.empty?

  document = YAML.safe_load(FIXTURES.join(row[1]).read)
  fail_check("#{row[1]} schema differs") unless document.is_a?(Hash) && document["schema"] == "spec-013-v1"
  fail_check("#{row[1]} cases must be a sequence") unless document["cases"].is_a?(Array)
  fail_check("#{row[1]} has unknown top-level fields") unless document.keys.sort == %w[cases schema]
end

names = manifest_rows.flat_map do |row|
  YAML.safe_load(FIXTURES.join(row[1]).read).fetch("cases").map do |fixture|
    fail_check("#{row[1]} case must be a mapping") unless fixture.is_a?(Hash)
    name = fixture["name"]
    fail_check("#{row[1]} case name is invalid") unless name&.match?(/\A[a-z0-9]+(?:-[a-z0-9]+)*\z/)
    criteria = fixture["criteria"]
    fail_check("#{name} has no criteria") unless criteria.is_a?(Array) && !criteria.empty?
    fail_check("#{name} has unknown criteria") unless (criteria - EXPECTED_CRITERIA).empty?
    classes = fixture["evidenceClasses"]
    fail_check("#{name} has no evidence classes") unless classes.is_a?(Array) && !classes.empty?
    fail_check("#{name} has unknown evidence classes") unless (classes - EVIDENCE_CLASSES).empty?
    name
  end
end
fail_check("fixture case names are duplicated") unless names.uniq.length == names.length

criteria_rows = FIXTURES.join("required-evidence.tsv").each_line.each_with_object([]) do |line, rows|
  next if line.start_with?("#") || line.strip.empty?

  fields = line.chomp.split("\t", -1)
  fail_check("required evidence row width differs") unless fields.length == 5
  rows << fields
end
fail_check("acceptance registry differs") unless criteria_rows.map(&:first) == EXPECTED_CRITERIA
fail_check("acceptance registry must begin pending") unless criteria_rows.all? { |row| row[4] == "pending" }

%w[artificial-limit-schema.tsv canonical-transcript.tsv report-schema.tsv].each do |name|
  rows = FIXTURES.join(name).each_line.reject { |line| line.strip.empty? }
  width = rows.first.chomp.split("\t", -1).length
  fail_check("#{name} contains an empty registry") if rows.length < 2
  fail_check("#{name} row width differs") unless rows.all? { |line| line.chomp.split("\t", -1).length == width }
end

report_fields = FIXTURES.join("report-schema.tsv").each_line.each_with_object([]) do |line, fields|
  next if line.start_with?("#") || line.strip.empty?

  fields << line.split("\t", 2).first
end
%w[profile repositoryRevision repositoryDirty compiler sdk target command limits audit transcriptDigest hardwareExecution connectedTarget].each do |field|
  fail_check("report field is missing: #{field}") unless report_fields.include?(field)
end

runner = ROOT.join("scripts/contracts/run-spec-013.sh")
fail_check("SPEC-013 driver is missing") unless runner.file? && runner.executable?
runner_text = runner.read
EXPECTED_PROFILES.each do |profile|
  fail_check("driver profile is missing: #{profile}") unless runner_text.include?(profile)
end
%w[
  check-spec-013-module-contract.rb check-spec-013-module-contract.sh
  check-spec-013-dynamic-binding.rb
  check-spec-013-storage-registry.rb
  check-spec-013-static-generated-fixture.rb
  check-spec-013-static-profiles.sh
  check-spec-013-static-storage.rb
  check-spec-013-storage-boundaries.rb
  check-spec-013-startup-corpus.rb
  check-spec-013-cycle-failures.rb
  check-spec-013-handoff-recovery.rb
  check-spec-013-borrow-boundaries.rb
  check-spec-013-equivalence.rb
  check-spec-013-report-driver.rb
  report-spec-013-profile.rb
].each do |name|
  path = ROOT.join("scripts/contracts", name)
  fail_check("SPEC-013 command is missing or not executable: #{name}") unless path.file? && path.executable?
end

puts "SPEC-013 harness passed: 8 ordered corpora, 15 pending criteria, and 4 exact driver modes are fail-closed."
