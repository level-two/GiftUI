#!/usr/bin/env ruby
# frozen_string_literal: true

require "pathname"
require "yaml"

ROOT = Pathname.new(File.expand_path("../..", __dir__))
FIXTURES = ROOT.join("Tests/ContractFixtures/SPEC014")
EXPECTED_METRICS = %w[
  surfaceBytes tileBytes glyphWorkspaceBytes strokeWorkspaceBytes
  regionRecordBytes payloadBytes inFlightBytes displayTransportBytes
  tileVisits submittedRegions submittedPayloads stackHighWaterBytes heapCalls
  rasterNanoseconds submitNanoseconds
].freeze
EXPECTED_METHODS = %w[
  storage-high-water stack-high-water heap-calls raster-timing submit-timing
  linked-sections linked-symbols
].freeze

def fail_check(message)
  warn "SPEC-014 resource check failed: #{message}"
  exit 1
end

document = YAML.safe_load(FIXTURES.join("resources.yaml").read)
cases = document.fetch("cases")
fail_check("resource fixture set differs") unless cases.map { |row| row.fetch("fixtureID") } == ["spec014-resource-instrumentation-contract"]
fixture = cases.fetch(0)
fail_check("resource metric set differs") unless fixture.fetch("descriptor").fetch("metrics") == EXPECTED_METRICS
methods = FIXTURES.join("Instrumentation/resource-measurement-methods.tsv").each_line.each_with_object([]) do |line, rows|
  next if line.start_with?("#") || line.strip.empty?

  fields = line.chomp.split("\t", -1)
  fail_check("measurement method row width differs") unless fields.length == 3
  rows << fields.fetch(0)
end
fail_check("measurement method set differs") unless methods == EXPECTED_METHODS
fail_check("static heap requirement differs") unless fixture.fetch("operationsResources").fetch(3).fetch("requiredHeapCalls").zero?
fail_check("timing sample count differs") unless fixture.fetch("highWater").fetch("timingSamples") == 9
probe = FIXTURES.join("Instrumentation/BackendResourceProbe.swift").read
EXPECTED_METRICS.each do |metric|
  fail_check("resource probe omits #{metric}") unless probe.include?("var #{metric}:")
end
fail_check("resource probe contains dynamic storage") if probe.match?(/\b(Array|Dictionary|Set|String)\s*</)

puts "SPEC-014 resource instrumentation passed: 15 metrics, 7 methods, bounded counters, and zero static heap requirement."
