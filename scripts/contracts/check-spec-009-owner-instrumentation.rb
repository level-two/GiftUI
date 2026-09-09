#!/usr/bin/env ruby
# frozen_string_literal: true

require "yaml"

root = File.expand_path("../../Tests/ContractFixtures/SPEC009", __dir__)
cases = YAML.safe_load(File.read(File.join(root, "owner-failures.yaml")), aliases: false).fetch("cases")
expected = {
  "state-change" => 0x0101_0001,
  "completion" => 0x0202_0002,
  "semantic" => 0x0303_0003,
  "layout" => 0x0404_0004,
  "immutable-render-input" => 0x0505_0005,
}
actual = cases.to_h { |item| [item.dig("ownerFailure", "name"), item.dig("ownerFailure", "rawValue")] }
abort "SPEC-009 owner/instrumentation check failed: finite owner set differs" unless actual == expected
abort "SPEC-009 owner/instrumentation check failed: cleanup matrix differs" unless cases.all? { |item| item.dig("cleanupFailures", "matrix") == "all-32-combinations" }
abort "SPEC-009 owner/instrumentation check failed: layout or allocation differs" unless cases.all? do |item|
  item.fetch("expectedStaticLayout") == { "ownerFailureBytes" => 4, "runCycleFailureMaximumBytes" => 8, "heapAllocations" => 0 }
end

schema = File.readlines(File.join(root, "instrumentation-fields.tsv"), chomp: true).reject { |line| line.start_with?("#") || line.empty? }
abort "SPEC-009 owner/instrumentation check failed: instrumentation field count differs" unless schema.length == 22
source = File.read(File.join(root, "Instrumentation/ExecutionResourceProbe.swift"))
schema.each do |row|
  field = row.split("\t", 2).first
  normalized = field.sub(/Duration\z/, "")
  abort "SPEC-009 owner/instrumentation check failed: probe lacks #{field}" unless source.include?(field) || source.include?(normalized)
end
abort "SPEC-009 owner/instrumentation check failed: link-map digest is not inline" if source.match?(/\b(?:Array|String|Dictionary|Set)\b/)

puts "SPEC-009 owner/instrumentation passed: five exact owner failures, all cleanup combinations, static layout, and 22 bounded measurement fields are registered."
