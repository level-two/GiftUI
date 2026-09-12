#!/usr/bin/env ruby
# frozen_string_literal: true

require "pathname"
require "yaml"

ROOT = Pathname.new(File.expand_path("../..", __dir__))
SOURCE = ROOT.join("Sources/GiftUIFailureExecution/GiftUIFailureExecution.swift")
TEST = ROOT.join("Tests/GiftUIFailureExecutionTests/GiftUIFailureExecutionTests.swift")

def fail_check(message)
  warn "SPEC-003 execution correlation check failed: #{message}"
  exit 1
end

source = SOURCE.read
tests = TEST.read
imports = source.scan(/^import (\w+)/).flatten
fail_check("failure execution imports differ") unless imports == %w[GiftUIExecution GiftUIFailureCore]

required_declaration = [
  "public struct GiftUICorrelatedFailure<Context>",
  "public let fact: GiftUIFailureFact",
  "public let context: Context",
  "public let annotations: GiftUIFailureAnnotations",
  "annotations: GiftUIFailureAnnotations = .init()",
  "extension GiftUICorrelatedFailure: Sendable where Context: Sendable",
  "extension GiftUICorrelatedFailure: Equatable where Context: Equatable",
]
missing = required_declaration.reject { |fragment| source.include?(fragment) }
fail_check("correlation declaration differs: #{missing.inspect}") unless missing.empty?

fail_check("obsolete execution-specific fact envelope remains") if
  source.include?("CorrelatedExecutionFailure")
fail_check("correlation stores a dynamic or escaping carrier") if
  source.match?(/\b(?:String|Array|ContiguousArray|Dictionary|Set|Any|any|Mirror|Task|actor|async|await|throw|fatalError)\b/)

execution_sources = ROOT.glob("Sources/GiftUIExecution/*.swift").map(&:read).join("\n")
fail_check("execution owner imports failure correlation") if
  execution_sources.match?(/^import GiftUIFailureExecution$/)

boundary = YAML.safe_load(
  ROOT.join("Tests/ContractFixtures/SPEC003/target-boundaries.yaml").read,
  aliases: false
).fetch("active")
fail_check("failure execution graph differs") unless
  boundary.dig("GiftUIFailureExecution", "dependencies") == %w[GiftUIExecution GiftUIFailureCore]

negative = ROOT.join("Tests/ContractFixtures/SPEC003/Fixtures/Negative/forbidden-execution-import")
fail_check("driver fixture does not reject correlation") unless
  negative.join("main.swift").read == "import GiftUIFailureExecution\n"

required_tests = [
  "genericCorrelationPreservesFactContextAndBoundedAnnotations",
  "correlated.fact == fact",
  "correlated.context == mappedContext",
  "correlated.annotations == beforeRefusal",
]
missing_tests = required_tests.reject { |fragment| tests.include?(fragment) }
fail_check("correlation tests differ: #{missing_tests.inspect}") unless missing_tests.empty?

puts "SPEC-003 execution correlation passed: generic envelope, exact graph, field preservation, bounded annotations, and one-way imports."
