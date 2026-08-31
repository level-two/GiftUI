#!/usr/bin/env ruby
# frozen_string_literal: true

ROOT = File.expand_path("../..", __dir__)
CORPUS = File.join(ROOT, "Tests/ContractFixtures/SPEC004/SemanticCorpus/cases.tsv")
PROBE = File.join(
  ROOT,
  "Tests/ContractFixtures/SPEC004/NormalizedProfileProbe/NormalizedProfileProbe.swift"
)
MAIN = File.join(ROOT, "Tests/ContractFixtures/SPEC004/NormalizedProfileProbe/main.swift")
EXPECTED_CODES = [1, 1, 2, 3, 5].freeze
EXPECTED_CHECKSUM = EXPECTED_CODES.sum

def fail_check(message)
  warn "SPEC-004 profile corpus check failed: #{message}"
  exit 1
end

begin
  rows = File.readlines(CORPUS, chomp: true).each_with_object([]) do |line, selected|
    next if line.empty? || line.start_with?("#")

    fields = line.split("\t", -1)
    fail_check("corpus row must have four fields: #{line.inspect}") unless fields.length == 4
    selected << fields.join("|") if fields[1] == "configuration"
  end
  probe = File.read(PROBE)
  main = File.read(MAIN)
rescue Errno::ENOENT => error
  fail_check(error.message)
end

fail_check("expected five normalized configuration rows, found #{rows.length}") unless rows.length == 5
fail_check("duplicate normalized configuration rows") unless rows.uniq.length == rows.length

probe_rows = probe.scan(%r{// corpus-row: (.+)$}).flatten
fail_check("probe rows differ from the normalized corpus") unless probe_rows == rows

codes = probe.scan(%r{// corpus-code: ([0-9]+)$}).flatten.map { |word| Integer(word, 10) }
fail_check("probe codes differ from normalized rows") unless codes == EXPECTED_CODES
fail_check("probe return checksum differs") unless probe.include?("return #{EXPECTED_CHECKSUM}")
fail_check("probe main checksum differs") unless main.include?("checksum == #{EXPECTED_CHECKSUM}")

puts "SPEC-004 profile corpus check passed: #{rows.length} ordered cases, checksum #{EXPECTED_CHECKSUM}."
