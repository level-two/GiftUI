#!/usr/bin/env ruby
# frozen_string_literal: true

def fail_check(message)
  warn "SPEC-005 validation-corpus check failed: #{message}"
  exit 1
end

fail_check("expected corpus and test-directory paths") unless ARGV.length == 2
rows = File.readlines(ARGV.fetch(0), chomp: true).reject do |line|
  line.start_with?("#") || line.empty?
end.map { |line| line.split("\t", -1) }
tests = Dir.glob(File.join(ARGV.fetch(1), "*.swift")).sort.map do |path|
  File.read(path)
end.join("\n")

isolated = rows.select { |row| row[1] == "validation-isolated" }
pairs = rows.select { |row| row[1] == "validation-pair" }
fail_check("expected 9 isolated rows, found #{isolated.length}") unless isolated.length == 9
fail_check("expected 36 pair rows, found #{pairs.length}") unless pairs.length == 36

isolated_values = isolated.map do |row|
  input = Integer(row[2], 10)
  expected = Integer(row[3], 10)
  fail_check("isolated row #{row[0]} does not preserve raw value") unless input == expected
  input
end
fail_check("isolated raw values differ") unless isolated_values.sort == (0..8).to_a

observed_pairs = pairs.map do |row|
  values = row[2].split(",").map { |word| Integer(word, 10) }
  fail_check("pair #{row[0]} is malformed") unless values.length == 2 && values[0] < values[1]
  fail_check("pair #{row[0]} precedence differs") unless Integer(row[3], 10) == values.min
  values
end
expected_pairs = (0..8).to_a.combination(2).to_a
fail_check("pair coverage differs") unless observed_pairs.sort == expected_pairs.sort

required_tests = [
  "testEachValidationClassHasAnIsolatedFixture",
  "testEveryPairUsesRawValuePrecedenceInBothFaultOrders",
  "XCTAssertEqual(pairCount, 36)",
  "testZeroBytePayloadAndEmptyRecordPartitionValidate",
  "outlineRealization",
].freeze
required_tests.each do |fragment|
  fail_check("focused tests lack #{fragment}") unless tests.include?(fragment)
end

puts "SPEC-005 validation-corpus check passed: 9 isolated classes and all 36 raw-precedence pairs."
