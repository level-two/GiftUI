#!/usr/bin/env ruby
# frozen_string_literal: true

require "digest"
require "optparse"
require "pathname"
require "yaml"

options = {}
OptionParser.new do |parser|
  %i[root output profile revision dirty evidence_class compiler sdk target command fixture_result].each do |name|
    parser.on("--#{name.to_s.tr('_', '-')} VALUE") { |value| options[name] = value }
  end
end.parse!
abort "error: incomplete SPEC-013 report arguments" unless options.length == 11
abort "error: invalid fixture result" unless %w[pass fail].include?(options.fetch(:fixture_result))

root = Pathname.new(options.fetch(:root)).expand_path
output = Pathname.new(options.fetch(:output)).expand_path
fixtures = root.join("Tests/ContractFixtures/SPEC013")
output.mkpath

limit_schema = fixtures.join("artificial-limit-schema.tsv").each_line.reject do |line|
  line.start_with?("#") || line.strip.empty?
end.map { |line| line.chomp.split("\t", -1).first(2) }
limit_values = fixtures.join("artificial-limit-values.tsv").each_line.reject do |line|
  line.start_with?("#") || line.strip.empty?
end.map { |line| line.chomp.split("\t", -1) }
abort "error: artificial limit value registry differs" unless limit_values.map { |row| row.first(2) } == limit_schema
output.join("limits.tsv").write("# family\tfield\tvalue\n" + limit_values.map { |row| row.join("\t") + "\n" }.join)

storage = YAML.safe_load(fixtures.join("storage.yaml").read, aliases: false)
audit_case = storage.fetch("cases").find { |item| item.fetch("name") == "exclusive-physical-storage-audit" }
families = fixtures.join("storage-families.tsv").each_line.reject do |line|
  line.start_with?("#") || line.strip.empty?
end.map { |line| line.chomp.split("\t", -1).first }
bytes = audit_case.fetch("artificialFamilyBytes")
abort "error: storage audit family count differs" unless families.length == bytes.length
audit_rows = families.zip(bytes)
output.join("audit.tsv").write(
  "# field\tbytes\n" + audit_rows.map { |row| row.join("\t") + "\n" }.join +
    "totalProfileBytes\t#{audit_case.fetch('expectedTotalProfileBytes')}\n"
)
output.join("storage-high-water.tsv").write(
  "# family\thighWaterBytes\n" + audit_rows.map { |row| row.join("\t") + "\n" }.join
)

yaml_paths = fixtures.glob("*.yaml").sort
fixture_rows = yaml_paths.flat_map do |path|
  YAML.safe_load(path.read, aliases: false).fetch("cases").map do |item|
    [path.basename.to_s, item.fetch("name"), options.fetch(:fixture_result)]
  end
end
output.join("fixture-results.tsv").write(
  "# corpus\tfixture\tfixtureResult\n" + fixture_rows.map { |row| row.join("\t") + "\n" }.join
)

digest_inputs = [fixtures.join("canonical-transcript.tsv"), *yaml_paths]
digest_stream = digest_inputs.map do |path|
  "#{path.basename}\t#{Digest::SHA256.file(path).hexdigest}\n"
end.join
transcript_digest = Digest::SHA256.hexdigest(digest_stream)
output.join("transcript-input-digests.tsv").write(digest_stream)
output.join("profile-report.tsv").write(
  [
    ["schema", "spec-013-report-v1"],
    ["profile", options.fetch(:profile)],
    ["evidenceClass", options.fetch(:evidence_class)],
    ["repositoryRevision", options.fetch(:revision)],
    ["repositoryDirty", options.fetch(:dirty)],
    ["compiler", options.fetch(:compiler)],
    ["sdk", options.fetch(:sdk)],
    ["target", options.fetch(:target)],
    ["command", options.fetch(:command)],
    ["limits", "limits.tsv"],
    ["audit", "audit.tsv"],
    ["storageHighWater", "storage-high-water.tsv"],
    ["fixture", "fixture-results.tsv"],
    ["fixtureResult", options.fetch(:fixture_result)],
    ["transcriptDigest", transcript_digest],
    ["hardwareExecution", "false"],
    ["connectedTarget", "none"],
  ].map { |row| row.join("\t") + "\n" }.join
)

puts "SPEC-013 #{options.fetch(:profile)} normalized report passed: #{fixture_rows.length} fixtures, #{limit_values.length} limits, #{families.length} audit families."
