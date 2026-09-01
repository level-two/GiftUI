#!/usr/bin/env ruby
# frozen_string_literal: true

corpus = File.expand_path(
  "../../Tests/ContractFixtures/SPEC005/SemanticCorpus/cases.tsv",
  __dir__
)

def fail_check(message)
  warn "SPEC-005 normalized corpus check failed: #{message}"
  exit 1
end

expected_header = "# id\tdomain\tinput_words\texpected_words\tevidence_class\n"
lines = File.readlines(corpus)
fail_check("corpus header differs") unless lines.first == expected_header

rows = lines.each_with_index.each_with_object([]) do |(line, index), selected|
  next if line.start_with?("#") || line.strip.empty?

  fields = line.chomp.split("\t", -1)
  fail_check("line #{index + 1} must have five fields") unless fields.length == 5
  selected << fields
end

ids = rows.map(&:first)
fail_check("case identifiers must be unique") unless ids.uniq.length == ids.length
rows.each do |id, domain, input, expected, evidence|
  fail_check("invalid case identifier #{id.inspect}") unless id.match?(/\A[a-z0-9]+(?:-[a-z0-9]+)*\z/)
  fail_check("invalid domain #{domain.inspect}") unless domain.match?(/\A[a-z0-9]+(?:-[a-z0-9]+)*\z/)
  fail_check("invalid input words for #{id}") unless input == "-" || input.match?(/\A(?:0x[0-9A-Fa-f]+|[0-9]+)(?:,(?:0x[0-9A-Fa-f]+|[0-9]+))*\z/)
  fail_check("invalid expected words for #{id}") unless expected == "-" || expected.match?(/\A(?:0x[0-9A-Fa-f]+|[0-9]+)(?:,(?:0x[0-9A-Fa-f]+|[0-9]+))*\z/)
  fail_check("unknown evidence class for #{id}") unless %w[host cross-built simulator connected-target].include?(evidence)
end

puts "SPEC-005 normalized corpus check passed: #{rows.length} cases."
