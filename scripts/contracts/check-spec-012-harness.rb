#!/usr/bin/env ruby
# frozen_string_literal: true

require "pathname"
require "yaml"

ROOT = Pathname.new(File.expand_path("../..", __dir__))
FIXTURES = ROOT.join("Tests/ContractFixtures/SPEC012")
EVIDENCE_CLASSES = %w[
  connected-hardware cross-build host-execution inspection simulator
].freeze
CRITERIA = (1..13).map { |number| format("DR-%03d", number) }.freeze

def fail_check(message)
  warn "SPEC-012 harness check failed: #{message}"
  exit 1
end

def rows(path, header, width)
  lines = path.each_line.to_a
  fail_check("#{path.basename} header differs") unless lines.first&.chomp == header
  lines.drop(1).each_with_object([]) do |line, result|
    next if line.strip.empty? || line.start_with?("#")

    fields = line.chomp.split("\t", -1)
    fail_check("#{path.basename} row width differs") unless fields.length == width
    result << fields
  end
end

manifest = rows(
  FIXTURES.join("fixture-manifest.tsv"),
  "# order\tfile\tdomain\tcollection\tevidence_classes",
  5
)
fail_check("fixture order differs") unless manifest.map(&:first) == %w[1 2]
fail_check("fixture files differ") unless manifest.map { |row| row[1] } == %w[fixtures.yaml raster-vectors.yaml]
manifest.each do |_, file, _, collection, classes|
  document = YAML.safe_load(FIXTURES.join(file).read, aliases: false)
  fail_check("#{file} root differs") unless document.is_a?(Hash) && document[collection].is_a?(Array)
  if file == "raster-vectors.yaml"
    fail_check("#{file} must remain empty before T8") unless document[collection].empty?
  end
  unknown = classes.split(",") - EVIDENCE_CLASSES
  fail_check("#{file} has unknown evidence classes") unless unknown.empty?
end

fixtures = YAML.safe_load(FIXTURES.join("fixtures.yaml").read, aliases: false).fetch("cases")
fail_check("combined fixture names differ") unless fixtures.map { |entry| entry["name"] } == [
  "mixed-fill-strokes-and-glyph",
  "zero-canvas-ordinary-equivalence"
]
fixtures.each do |entry|
  required = %w[
    name semanticEvents canvasOccurrenceOrder resolvedBounds resolvedClips
    planSummary expectedHeader recordingEvents sinkCalls expectedResult criteria
    evidenceClasses
  ]
  fail_check("#{entry['name']} fields differ") unless (required - entry.keys).empty?
  fail_check("#{entry['name']} has unknown criterion") unless (entry["criteria"] - CRITERIA).empty?
  fail_check("#{entry['name']} has unknown evidence class") unless (entry["evidenceClasses"] - EVIDENCE_CLASSES).empty?
end
mixed, zero = fixtures
fail_check("mixed recording order differs") unless mixed["recordingEvents"].map { |event| event["event"] } == [
  "begin", "fill", "stroke", "stroke", "begin-glyphs", "glyph", "end-glyphs", "finish"
]
fail_check("mixed no-op stroke differs") unless mixed["recordingEvents"][3].values_at("points", "subpaths") == [[], []]
fail_check("zero-Canvas ordinary transcript is absent") unless zero["ordinaryRecordingEvents"].is_a?(Array)
fail_check("zero-Canvas ordinary transcript differs") unless zero["recordingEvents"] == zero["ordinaryRecordingEvents"]

static_input = FIXTURES.join("static-canvas-input.yaml")
static_manifest = FIXTURES.join("static-canvas-manifest.yaml")
fail_check("static Canvas input is missing") unless static_input.file?
fail_check("static Canvas manifest is missing") unless static_manifest.file?

positive = rows(
  FIXTURES.join("declaration-compile-fixtures.tsv"),
  "# case\tfamily\texpected\tcriteria\tstatus",
  5
)
negative = rows(
  FIXTURES.join("negative-compile-fixtures.tsv"),
  "# case\tfamily\texpected_rejection\tcriteria\tstatus",
  5
)
fail_check("positive compile registry differs") unless positive.length == 7
fail_check("negative compile registry differs") unless negative.length == 9
compile_rows = positive + negative
fail_check("compile fixture names are duplicated") unless compile_rows.map(&:first).uniq.length == compile_rows.length
fail_check("compile fixture statuses must be complete") unless compile_rows.all? { |row| row[4] == "complete" }
compile_rows.each do |row|
  fail_check("compile fixture has unknown criterion") unless (row[3].split(",") - CRITERIA).empty?
end
positive.each do |name, _family, _expected, _criteria, _status|
  source = FIXTURES.join("Fixtures/Positive", name, "main.swift")
  fail_check("positive compile fixture #{name} is missing") unless source.file?
end
negative.each do |name, _family, _expected, _criteria, _status|
  directory = FIXTURES.join("Fixtures/Negative", name)
  fail_check("negative compile fixture #{name} is missing") unless directory.join("main.swift").file?
  patterns = directory.join("expected-diagnostic-patterns.txt")
  fail_check("negative diagnostic patterns for #{name} are missing") unless patterns.file?
  fail_check("negative diagnostic patterns for #{name} are empty") if patterns.empty?
end

tokens = rows(FIXTURES.join("symbolic-tokens.tsv"), "# namespace\tformat\tauthority", 3)
fail_check("symbolic namespaces are duplicated") unless tokens.map(&:first).uniq.length == tokens.length
fields = rows(FIXTURES.join("normalized-fields.tsv"), "# domain\tfield\tkind\trule", 4)
keys = fields.map { |row| row.values_at(0, 1) }
fail_check("normalized fields are duplicated") unless keys.uniq.length == keys.length
required_domains = %w[common cycle layout plan raster render semantic]
fail_check("normalized domains differ") unless fields.map(&:first).uniq.sort == required_domains

failures = rows(
  FIXTURES.join("failure-precedence.tsv"),
  "# precedence\tstage\tlocal_error\tcondition\torigin\taffected_scope\tcontainment",
  7
)
fail_check("failure precedence is not dense") unless failures.map(&:first) == (1..20).map(&:to_s)

evidence = rows(
  FIXTURES.join("required-evidence.tsv"),
  "# criterion\towner_tasks\tevidence\tcases\tstatus",
  5
)
fail_check("criterion registry differs") unless evidence.map(&:first) == CRITERIA
fail_check("criterion rows must begin pending") unless evidence.all? { |row| row[4] == "pending" }

boundaries = rows(
  FIXTURES.join("module-boundaries.tsv"),
  "# target\tdependency\tdisposition",
  3
)
fail_check("module boundary rows are duplicated") unless boundaries.uniq.length == boundaries.length
fail_check("module boundary disposition differs") unless boundaries.all? { |row| %w[allowed forbidden].include?(row[2]) }

if ARGV.length == 1
  report = Pathname.new(ARGV.first)
  fail_check("report directory is missing") unless report.directory?
  metadata = report.join("metadata.txt").read
  %w[
    schema_version=1 spec=SPEC-012 evidence_complete=false remote_access=false
    deployment=false service_restart=false simulator_execution=false
    connected_target_execution=false flashing=false exit_code=0
  ].each do |entry|
    fail_check("report metadata lacks #{entry}") unless metadata.each_line.any? { |line| line.chomp == entry }
  end
  reported = rows(
    report.join("required-evidence.tsv"),
    "# criterion\tstatus\treason",
    3
  )
  fail_check("report criterion set differs") unless reported.map(&:first) == CRITERIA
  fail_check("report criteria are not fail-closed") unless reported.all? { |row| row[1] == "missing" }
  fail_check("report command transcript is empty") if report.join("commands.txt").empty?
  fail_check("report input inventory is empty") if report.join("input-hashes.tsv").empty?
elsif !ARGV.empty?
  fail_check("unexpected arguments")
end

puts "SPEC-012 harness passed: frozen schemas and thirteen fail-closed evidence rows are exact."
