#!/usr/bin/env ruby
# frozen_string_literal: true

require "pathname"

root = Pathname.new(File.expand_path("../..", __dir__))
fixture_root = root.join("Tests/ContractFixtures/SPEC003")
manifest_path = fixture_root.join("fixture-manifest.tsv")

def fail_check(message)
  warn "SPEC-003 fixture manifest check failed: #{message}"
  exit 1
end

rows = []
manifest_path.each_line.with_index(1) do |line, line_number|
  next if line.start_with?("#") || line.strip.empty?

  fields = line.chomp.split("\t", -1)
  fail_check("line #{line_number} must have five tab-separated fields") unless fields.length == 5
  rows << fields
end

ids = rows.map(&:first)
fail_check("fixture identifiers must be unique") unless ids.uniq.length == ids.length

registered_directories = rows.map do |id, expectation, access, entry_path, patterns_path|
  fail_check("invalid fixture identifier #{id.inspect}") unless id.match?(/\A[a-z0-9]+(?:-[a-z0-9]+)*\z/)
  fail_check("#{id} has unknown expectation #{expectation.inspect}") unless %w[pass fail].include?(expectation)
  fail_check("#{id} has unknown access #{access.inspect}") unless %w[public package].include?(access)
  fail_check("#{id} negative fixture must use public access") if expectation == "fail" && access != "public"

  expected_family = expectation == "pass" ? "Positive" : "Negative"
  expected_entry = "Fixtures/#{expected_family}/#{id}/main.swift"
  fail_check("#{id} entry point must be #{expected_entry}") unless entry_path == expected_entry
  fail_check("#{id} entry point is missing") unless fixture_root.join(entry_path).file?

  if expectation == "pass"
    fail_check("#{id} positive fixture must use '-' for diagnostics") unless patterns_path == "-"
  else
    expected_patterns = "Fixtures/Negative/#{id}/expected-diagnostic-patterns.txt"
    fail_check("#{id} diagnostic path must be #{expected_patterns}") unless patterns_path == expected_patterns
    patterns = fixture_root.join(patterns_path)
    fail_check("#{id} diagnostic patterns are missing") unless patterns.file?
    meaningful = patterns.each_line.any? { |line| !line.strip.empty? && !line.lstrip.start_with?("#") }
    fail_check("#{id} has no diagnostic patterns") unless meaningful
  end

  fixture_root.join(entry_path).dirname.realpath.to_s
end

actual_directories = fixture_root.join("Fixtures").glob("{Positive,Negative}/*")
  .select(&:directory?).map { |path| path.realpath.to_s }
unless registered_directories.sort == actual_directories.sort
  fail_check("registered fixture directories differ from the checked-in layout")
end

puts "SPEC-003 fixture manifest check passed: #{rows.length} fixtures."
