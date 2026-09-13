#!/usr/bin/env ruby
# frozen_string_literal: true

require "pathname"
require "yaml"

ROOT = Pathname.new(File.expand_path("../..", __dir__))
PATH = ROOT.join("Tests/ContractFixtures/SPEC014/transactions.yaml")
EXPECTED_IDS = %w[
  spec014-transaction-zero-payload-complete
  spec014-transaction-one-payload-complete
  spec014-transaction-multi-payload-complete
  spec014-transaction-writer-body-discard
  spec014-transaction-pretransfer-submit-failure
  spec014-transaction-frame-end-failure-before
  spec014-transaction-frame-end-failure-after
  spec014-transaction-retained-payload-teardown
  spec014-transaction-cancel-and-counter-reset
  spec014-transaction-identity-exhaustion
].freeze
COUNTERS = %w[
  reservations writerBorrows payloads payloadBytes regions
  responsibilityTransfers finishes cancels inFlightPayloadsAfterTerminal
  inFlightBytesAfterTerminal
].freeze

def fail_check(message)
  warn "SPEC-014 transaction check failed: #{message}"
  exit 1
end

document = YAML.safe_load(PATH.read)
fail_check("schema differs") unless document["schema"] == "spec-014-v1"
cases = document["cases"]
fail_check("case order or set differs") unless cases.map { |item| item["fixtureID"] } == EXPECTED_IDS

by_id = cases.to_h { |item| [item.fetch("fixtureID"), item] }
cases.each do |item|
  id = item.fetch("fixtureID")
  events = item.fetch("injectedEvents")
  high_water = item.fetch("highWater")
  fail_check("#{id} has no transaction events") unless events.is_a?(Array) && !events.empty?
  fail_check("#{id} does not reserve first") unless events.first == { "call" => "reserveFrame", "result" => events.first["result"] }
  terminal_count = events.count do |event|
    %w[finishFrame cancelFrame].include?(event["call"])
  end
  fail_check("#{id} does not terminate each reservation exactly once") unless terminal_count == high_water["reservations"]
  fail_check("#{id} omits required counters") unless (COUNTERS - high_water.keys).empty?
  fail_check("#{id} retains in-flight data after terminal") unless high_water["inFlightPayloadsAfterTerminal"].zero? && high_water["inFlightBytesAfterTerminal"].zero?
  fail_check("#{id} terminal counters differ") unless high_water["finishes"] + high_water["cancels"] == high_water["reservations"]
end

zero = by_id.fetch("spec014-transaction-zero-payload-complete")
fail_check("zero-payload oracle differs") unless zero["header"]["damage"] == "empty" && zero["highWater"]["payloads"].zero? && zero["offerResult"] == { "result" => "accepted" }

one = by_id.fetch("spec014-transaction-one-payload-complete")
fail_check("one-payload oracle differs") unless one["highWater"]["payloads"] == 1 && one["highWater"]["responsibilityTransfers"] == 1

multi = by_id.fetch("spec014-transaction-multi-payload-complete")
fail_check("multi-payload oracle is not synchronous reusable tiled") unless multi["descriptor"]["realization"] == "tiled" && multi["effectiveCapability"] == { "submissionLifetime" => "synchronousCopy", "handoff" => "synchronous", "inFlightCount" => 1, "inFlightBytes" => 8 } && multi["highWater"]["payloads"] == 2 && multi["highWater"]["responsibilityTransfers"] == 1

discard = by_id.fetch("spec014-transaction-writer-body-discard")
fail_check("writer discard oracle differs") unless discard["injectedEvents"].any? { |event| event == { "call" => "writerDiscard", "result" => "reset" } } && discard["highWater"]["payloads"].zero? && discard["highWater"]["cancels"] == 1

before = by_id.fetch("spec014-transaction-pretransfer-submit-failure")
fail_check("pre-transfer failure is not reversible") unless before["injectedEvents"].any? { |event| event["result"] == "failureBeforeAcceptance-transportUnavailable" } && before["highWater"]["responsibilityTransfers"].zero? && before["health"] == { "state" => "available", "failureCount" => 0 } && before["highWater"]["cancels"] == 1

finish_before = by_id.fetch("spec014-transaction-frame-end-failure-before")
fail_check("before-acceptance frame-end oracle differs") unless finish_before["offerResult"] == { "result" => "failed-frame" } && finish_before["highWater"]["responsibilityTransfers"].zero?

finish_after = by_id.fetch("spec014-transaction-frame-end-failure-after")
fail_check("after-acceptance frame-end oracle differs") unless finish_after["offerResult"] == { "result" => "accepted" } && finish_after["highWater"]["responsibilityTransfers"] == 1 && finish_after["health"] == { "state" => "unavailable", "failureCount" => 1 }

retained = by_id.fetch("spec014-transaction-retained-payload-teardown")
fail_check("retained payload ownership oracle differs") unless retained["effectiveCapability"]["submissionLifetime"] == "ownershipTransfer" && retained["effectiveCapability"]["handoff"] == "queued" && retained["highWater"]["inFlightPayloadsBeforeTerminal"] == 1 && retained["highWater"]["inFlightBytesBeforeTerminal"] == 4

reset = by_id.fetch("spec014-transaction-cancel-and-counter-reset")
fail_check("counter reset oracle differs") unless reset["injectedEvents"].map { |event| event["result"] }.include?("reserved-1") && reset["highWater"]["finalWriterBytes"].zero? && reset["highWater"]["finalWriterRegions"].zero?

exhaustion = by_id.fetch("spec014-transaction-identity-exhaustion")
fail_check("identity exhaustion oracle differs") unless exhaustion["injectedEvents"].map { |event| event["result"] } == %w[reserved-4294967295 completed failure-capacityExhausted] && exhaustion["bodyResult"] == { "result" => "not-called" }

puts "SPEC-014 transaction check passed: #{cases.length} ordered transaction oracles."
