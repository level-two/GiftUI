#!/usr/bin/env ruby
# frozen_string_literal: true

root = File.expand_path("../..", __dir__)
source = File.read(File.join(root, "Sources/GiftUI/ObservableState.swift"))

def fail_check(message)
  warn "SPEC-010 declaration surface check failed: #{message}"
  exit 1
end

required = [
  "@propertyWrapper\npublic struct State<Value: _GiftUIObservableReference>",
  "public init(wrappedValue: Value)",
  "public var wrappedValue: Value",
  "public enum _GiftUIObservableChangeReportOutcome: UInt8, Equatable, Sendable",
  "public struct _GiftUIObservableChangeSink: ~Copyable",
  "public var attachment: _GiftUIObservationAttachment",
  "public mutating func reportChange()",
  "public protocol _GiftUIObservableReference",
  "_ sink: consuming _GiftUIObservableChangeSink",
  "public struct _GiftUIObservationAttachment: Equatable, Sendable",
  "public let slot: UInt16",
  "public let generation: UInt32",
  "public protocol _GiftUIObservableStateDeclarationVisitor",
  "declarationOrdinal: UInt16",
  "public protocol _GiftUIObservableStateHost"
]
missing = required.reject { |fragment| source.include?(fragment) }
fail_check("missing exact fragments #{missing.inspect}") unless missing.empty?

expected_cases = {
  "dirtied" => 0,
  "coalesced" => 1,
  "staleAttachment" => 2,
  "invalidPhaseContained" => 3,
  "invalidPhaseSafetyNotProven" => 4,
  "reentrancyViolation" => 5,
  "invariantViolation" => 6
}
expected_cases.each do |name, raw_value|
  fail_check("missing exact outcome #{name}") unless source.include?("case #{name} = #{raw_value}")
end

fail_check("attachment construction became public") if source.match?(/public\s+init\(slot:/)
fail_check("sink construction became public") if source.match?(/public\s+init\(\s*attachment:/m)

forbidden = /\b(?:Any|Mirror|StateKey|StateBindingContext|TaskLocal)\b|import\s+(?:Foundation|Observation)/
fail_check("portable declarations contain a forbidden mechanism") if source.match?(forbidden)

puts "SPEC-010 declaration surface passed: exact portable family and non-forgeable construction boundary."
