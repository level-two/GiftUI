#!/usr/bin/env ruby
# frozen_string_literal: true

require "yaml"

path = File.expand_path("../../Tests/ContractFixtures/SPEC009/handoff.yaml", __dir__)
cases = YAML.safe_load(File.read(path), aliases: false).fetch("cases")
names = cases.map { |item| item.fetch("name") }
abort "SPEC-009 handoff corpus check failed: expected 12 unique cases" unless names.length == 12 && names.uniq.length == 12

required = %w[
  complete-frame-acceptance backpressure-without-body retryable-refusal-without-body
  endpoint-refusal-without-body invalid-envelope-without-body producer-failure-retains-error
  capacity-failure-retains-error render-producer-refusal-retains-origin
  contract-violation-retains-error illegal-endpoint-body-pair-matrix
  reservation-discard-and-post-return-lifetime irreversible-output-only-after-accepted-health
]
abort "SPEC-009 handoff corpus check failed: missing canonical case" unless (required - names).empty?

called = cases.select { |item| item.fetch("endpointScript").fetch("bodyCalled") }
not_called = cases - called
abort "SPEC-009 handoff corpus check failed: body/no-body matrix incomplete" unless called.length == 8 && not_called.length == 4
abort "SPEC-009 handoff corpus check failed: nonaccepted candidate survived" if cases.any? do |item|
  item["expectedFrameOfferResult"] != "accepted" && item["expectedCandidateDisposition"] == "committed"
end
abort "SPEC-009 handoff corpus check failed: irreversible output escaped acceptance" if cases.any? do |item|
  item["expectedIrreversibleOutput"] && item["expectedFrameOfferResult"] != "accepted"
end

puts "SPEC-009 handoff corpus passed: 12 cases cover the legal and illegal body/endpoint matrix, reservations, discard, lifetime, operation counts, retained producer errors, contract collapse, and irreversible output."
