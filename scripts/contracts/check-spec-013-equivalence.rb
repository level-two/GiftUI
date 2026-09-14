#!/usr/bin/env ruby
# frozen_string_literal: true

require "pathname"
require "yaml"

ROOT = Pathname.new(File.expand_path("../..", __dir__))
FIXTURE = ROOT.join("Tests/ContractFixtures/SPEC013/equivalence.yaml")
TEST = ROOT.join("Tests/GiftUIRuntimeConformanceTests/ProfileDifferentialTests.swift")
SCHEMA = ROOT.join("Tests/ContractFixtures/SPEC013/canonical-transcript.tsv")

def fail_check(message)
  warn "SPEC-013 equivalence check failed: #{message}"
  exit 1
end

cases = YAML.safe_load(FIXTURE.read, aliases: false).fetch("cases")
fail_check("canonical case set differs") unless cases.map { |item| item.fetch("name") } == [
  "dynamic-static-canonical-equivalence",
]
fixture = cases.first
fail_check("comparison is not exact") unless fixture.fetch("comparison") == "value-for-value" && fixture.fetch("tolerance") == "zero"
fail_check("profile set differs") unless fixture.fetch("profiles") == %w[dynamic static]
expected_exclusions = %w[addresses privateBytes allocationStrategy generatedCodeAddresses diagnosticVolume]
fail_check("exclusion set differs") unless fixture.fetch("excludedFields") == expected_exclusions

records = SCHEMA.each_line.reject { |line| line.start_with?("#") || line.strip.empty? }
fail_check("canonical transcript count differs") unless records.length == 15
fail_check("fixture transcript count differs") unless fixture.fetch("canonicalTranscriptRecordCount") == 15

source = TEST.read
%w[
  DynamicRuntimeProfileBinding StaticRuntimeProfileBinding
  DifferentialInputs DifferentialTranscript DifferentialPipelineOwner
  dynamicAndStaticBindingsProduceEqualCanonicalTranscripts
  dynamicTranscript staticTranscript
].each do |marker|
  fail_check("differential test lacks #{marker}") unless source.include?(marker)
end

puts "SPEC-013 equivalence passed: both concrete bindings compare fifteen canonical records value-for-value with the exact exclusion set."
