#!/usr/bin/env ruby
# frozen_string_literal: true

require "json"

ROOT = File.expand_path("../..", __dir__)
FIXTURES = File.join(ROOT, "Tests/ContractFixtures/SPEC001")
OWNERS = {
  "SignalAnalyzerDomain" => [],
  "SignalAnalyzerData" => %w[SignalAnalyzerDomain],
  "SignalAnalyzerPresentation" => %w[GiftUI GiftUIFailureCore SignalAnalyzerDomain]
}.freeze
FORBIDDEN_IMPORTS = {
  "SignalAnalyzerDomain" => %w[Foundation GiftUI Observation SwiftUI],
  "SignalAnalyzerData" => %w[GiftUI Observation SwiftUI],
  "SignalAnalyzerPresentation" => %w[Foundation Observation SignalAnalyzerData SwiftUI]
}.freeze

begin
  package = JSON.parse($stdin.read)
rescue JSON::ParserError => error
  abort "cannot read root package JSON: #{error.message}"
end
targets = package.fetch("targets").to_h { |target| [target.fetch("name"), target] }

def dependency_name(dependency)
  value = dependency["byName"] || dependency["target"] || dependency["product"]
  value.is_a?(Array) ? value.first : value
end

OWNERS.each do |owner, expected|
  target = targets[owner]
  abort "missing analyzer target #{owner}" unless target
  actual = target.fetch("dependencies", []).map { |dependency| dependency_name(dependency) }.sort
  abort "#{owner} dependencies differ: #{actual.inspect}" unless actual == expected.sort
  paths = Dir[File.join(ROOT, "Sources", owner, "**/*.swift")].sort
  abort "#{owner} has no source" if paths.empty?
  imports = paths.flat_map { |path| File.read(path).scan(/^\s*import\s+([A-Za-z0-9_]+)/).flatten }.uniq
  leaked = imports & FORBIDDEN_IMPORTS.fetch(owner)
  abort "#{owner} imports forbidden modules #{leaked.sort.inspect}" unless leaked.empty?
end

test_owners = OWNERS.keys.to_h { |owner| ["#{owner}Tests", [owner]] }
test_owners.each do |owner, expected|
  target = targets[owner]
  abort "missing analyzer test target #{owner}" unless target
  actual = target.fetch("dependencies", []).map { |dependency| dependency_name(dependency) }.sort
  abort "#{owner} dependencies differ" unless actual == expected
end

fixtures = File.readlines(File.join(FIXTURES, "negative-dependency-fixtures.tsv"), chomp: true)
  .reject { |line| line.empty? || line.start_with?("#") }
  .map { |line| line.split("\t", -1) }
abort "dependency fixture columns differ" unless fixtures.all? { |row| row.length == 4 }
abort "dependency fixture IDs are duplicated" unless fixtures.map(&:first).uniq.length == fixtures.length
fixtures.each do |fixture_id, from, to, expectation|
  actual = if expectation == "reject-import"
    FORBIDDEN_IMPORTS.fetch(from).include?(to) ? "reject-import" : "allow-import"
  else
    OWNERS.fetch(from).include?(to) ? "allow" : "reject"
  end
  abort "dependency fixture #{fixture_id} expected #{expectation}, got #{actual}" unless actual == expectation
end

reverse_edges = targets.reject { |name, _target| OWNERS.key?(name) || test_owners.key?(name) }.flat_map do |name, target|
  target.fetch("dependencies", []).each_with_object([]) do |dependency, edges|
    value = dependency_name(dependency)
    edges << "#{name}->#{value}" if OWNERS.key?(value)
  end
end

consumer_rows = File.readlines(File.join(FIXTURES, "analyzer-consumers.tsv"), chomp: true)
  .reject { |line| line.empty? || line.start_with?("#") }
  .map { |line| line.split("\t", -1) }
abort "analyzer consumer fixture columns differ" unless consumer_rows.all? { |row| row.length == 3 }
abort "analyzer consumer targets are duplicated" unless consumer_rows.map(&:first).uniq.length == consumer_rows.length
registered_reverse_edges = consumer_rows.flat_map do |target_name, kind, dependencies|
  abort "unknown analyzer consumer kind #{kind}" unless kind == "target-composition-test"
  abort "missing registered analyzer consumer #{target_name}" unless targets.key?(target_name)
  dependencies.split(",").map do |dependency|
    abort "unknown analyzer dependency #{dependency}" unless OWNERS.key?(dependency)
    "#{target_name}->#{dependency}"
  end
end
unless reverse_edges.sort == registered_reverse_edges.sort
  missing = registered_reverse_edges - reverse_edges
  unexpected = reverse_edges - registered_reverse_edges
  abort "reverse analyzer dependency registry mismatch: missing=#{missing.sort.join(', ')} unexpected=#{unexpected.sort.join(', ')}"
end

puts "SPEC-001 boundary audit passed: three production owners, three test owners, #{fixtures.length} dependency fixtures, and #{registered_reverse_edges.length} registered composition edges."
