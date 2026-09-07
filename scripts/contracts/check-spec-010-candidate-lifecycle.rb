#!/usr/bin/env ruby
# frozen_string_literal: true

require "pathname"

ROOT = Pathname.new(File.expand_path("../..", __dir__))
SOURCE = ROOT.join("Sources/GiftUIObservableState/ObservableStateCandidateLifecycle.swift")
TEST = ROOT.join("Tests/GiftUIObservableStateTests/ObservableStateCandidateLifecycleTests.swift")

def fail_check(message)
  warn "SPEC-010 candidate lifecycle check failed: #{message}"
  exit 1
end

source = SOURCE.read
tests = TEST.read
fail_check("candidate lifecycle imports differ") unless source.scan(/^import (\w+)$/).flatten == %w[GiftUIExecution]
fail_check("candidate lifecycle must remain internal") if source.match?(/\b(?:package|public|open) (?:struct|enum|protocol) ObservableStateCandidateLifecycle\b/)

required = [
  "case inactive = 0",
  "case active = 1",
  "phase == .deriving",
  "return .failure(.reentrancyViolation)",
  "return .failure(.invalidPhaseContained)",
  "return .invalidPhaseSafetyNotProven",
  "addingReportingOverflow(1)",
  "return record(.locationCapacityExhausted)",
  "return record(.registrationCapacityExhausted)",
  "return record(.associationStagingCapacityExhausted)",
  "? .success(.associationsCommitted)",
  ": .success(.unchanged)",
  "return .success(.candidateDiscarded)",
  "return .failure(.invariantViolation)",
]
required.each do |fragment|
  fail_check("candidate lifecycle lacks #{fragment}") unless source.include?(fragment)
end

forbidden = /\b(?:String|Array|ContiguousArray|Dictionary|Set|Any|any|class|actor|Task|throw|fatalError|model|attachment|sink|handler|GiftUIFailureCore|GiftUIRuntime|GiftUIBackend|GiftUIPlatform)\b/i
fail_check("candidate lifecycle contains concrete storage, payload, or prohibited owner") if source.match?(forbidden)

fail_check("fixture lacks two explicit candidate slots") unless tests.include?("private(set) var first: FixtureCandidateKey?") && tests.include?("private(set) var second: FixtureCandidateKey?")

puts "SPEC-010 candidate lifecycle passed: checked begin/reserve/finish, sticky failure, finite fixture slots, and reuse."
