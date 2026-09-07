#!/usr/bin/env ruby
# frozen_string_literal: true

require "pathname"

ROOT = Pathname.new(File.expand_path("../..", __dir__))
SOURCE = ROOT.join("Sources/GiftUIObservableState/PresentationFactAdmission.swift")
TEST = ROOT.join("Tests/GiftUIObservableStateTests/PresentationFactAdmissionTests.swift")

def fail_check(message)
  warn "SPEC-010 fact admission check failed: #{message}"
  exit 1
end

source = SOURCE.read
tests = TEST.read
fail_check("fact admission imports differ") unless source.scan(/^import (\w+)$/).flatten == %w[GiftUIExecution]

matches = Dir[ROOT.join("Sources/**/*.swift")].select do |path|
  File.read(path).match?(/package protocol PresentationFactAdmissionAdapter\b/)
end
fail_check("fact adapter ownership differs: #{matches}") unless matches == [SOURCE.to_s]

required = [
  "associatedtype Fact: Sendable",
  "mutating func submit(_ fact: Fact) -> ExecutionAdmissionOutcome",
]
required.each do |fragment|
  fail_check("fact adapter lacks #{fragment}") unless source.include?(fragment)
end

forbidden = /\b(?:public|open|Any|any|String|Array|ContiguousArray|Dictionary|Set|class|actor|Task|queue|limit|sequence|model|closure|callable|platform|mutate|GiftUIFailureCore|GiftUIRuntime|GiftUIBackend)\b/i
fail_check("fact adapter contains a second queue, payload carrier, fallback, or prohibited owner") if source.match?(forbidden)

fixture = tests[/private struct FixturePresentationFact.*?^}/m]
fail_check("finite presentation fact fixture is missing") unless fixture
stored = fixture.scan(/^\s*let ([^\n]+)$/).flatten
expected = ["producer: UInt16", "sequence: UInt16", "value: Int16"]
fail_check("presentation fact fields differ: #{stored}") unless stored == expected
fail_check("fixture fact stores a reference or callable") if fixture.match?(/\b(?:class|Any|String|Task|->)\b/)

puts "SPEC-010 fact admission passed: one finite typed fact forwards through the exact Execution outcome seam."
