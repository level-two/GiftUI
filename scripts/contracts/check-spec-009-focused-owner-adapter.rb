#!/usr/bin/env ruby
# frozen_string_literal: true

require "pathname"

ROOT = Pathname.new(File.expand_path("../..", __dir__))
SOURCE = ROOT.join("Sources/GiftUIFailureExecution/GiftUIFailureExecution.swift")
TEST = ROOT.join("Tests/GiftUIFailureExecutionTests/FocusedOwnerFailurePreservationTests.swift")

def fail_check(message)
  warn "SPEC-009 focused-owner adapter check failed: #{message}"
  exit 1
end

source = SOURCE.read
tests = TEST.read
body = source[/package static func focusedOwner<.*?^    \}/m]
fail_check("focused-owner adapter is missing") unless body
fail_check("focused-owner adapter has fallback translation") if body.match?(/default|GiftUIFailureFact|unknownProducerCondition/)
fail_check("focused-owner adapter does not preserve concrete payload") unless body.include?("failure: ownerFailure")

%w[mutation completion semantic layout immutableRenderInput everyFocusedOwnerCasePreservesConcreteValueAndContext commonAdapterNeverSubstitutesForNonfocusedFailure].each do |fragment|
  fail_check("focused-owner fixture lacks #{fragment}") unless tests.include?(fragment)
end
fail_check("fixture owner switch is not exhaustive") if tests.include?("default:")

puts "SPEC-009 focused-owner adapter passed: the concrete finite sum and context survive for owner-only exhaustive mapping with no common fallback."
