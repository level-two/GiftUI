#!/usr/bin/env ruby
# frozen_string_literal: true

ROOT = File.expand_path("../..", __dir__)
CORPUS = File.join(ROOT, "Tests/ContractFixtures/SPEC003/SemanticCorpus/cases.tsv")
PROBE = File.join(
  ROOT,
  "Tests/ContractFixtures/SPEC003/ProfileCorpusProbe/ProfileCorpusProbe.swift"
)
MAIN = File.join(ROOT, "Tests/ContractFixtures/SPEC003/ProfileCorpusProbe/main.swift")

def fail_check(message)
  warn "SPEC-003 profile corpus check failed: #{message}"
  exit 1
end

begin
  rows = File.readlines(CORPUS, chomp: true).reject do |line|
    line.empty? || line.start_with?("#")
  end
  probe = File.read(PROBE)
  main = File.read(MAIN)
rescue Errno::ENOENT => error
  fail_check(error.message)
end

ids = []
checksum = 0
rows.each_with_index do |line, index|
  fields = line.split("\t", -1)
  fail_check("corpus line #{index + 2} must have four fields") unless fields.length == 4
  id, _domain, _inputs, outputs = fields
  fail_check("duplicate corpus id #{id}") if ids.include?(id)
  ids << id
  outputs.split(",").each do |word|
    fail_check("non-decimal expected word #{word.inspect}") unless word.match?(/\A[0-9]+\z/)
    checksum += Integer(word, 10)
  end
end

probe_ids = probe.scan(%r{// corpus-case: ([a-z0-9-]+)$}).flatten
fail_check("probe case order differs: #{probe_ids.inspect}") unless probe_ids == ids
fail_check("probe checksum differs from corpus sum #{checksum}") unless
  probe.include?("return #{checksum}") && main.include?("checksum == #{checksum}")

puts "SPEC-003 profile corpus check passed: #{ids.length} ordered cases, checksum #{checksum}."
