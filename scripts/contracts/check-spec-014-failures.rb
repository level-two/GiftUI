#!/usr/bin/env ruby
# frozen_string_literal: true

require "pathname"
require "yaml"

ROOT = Pathname.new(File.expand_path("../..", __dir__))
PATH = ROOT.join("Tests/ContractFixtures/SPEC014/failures.yaml")
EXPECTED_IDS = %w[
  spec014-failure-local-mapping-matrix
  spec014-failure-reservation-operational-matrix
  spec014-failure-health-drain-diagnostics
].freeze
DETECTION_ORDER = %w[
  descriptorConstruction effectiveValueEquality resourceCompatibility
  operationCoverage rasterPayloadInFlightStores glyphStrokeWorkspace
  perFrameWorkCeilings reservation envelopeHeaderEquality streamGrammar
  operationValidation writerGrammar payloadCompletion payloadSubmission
  frameCompletion
].freeze
RASTER_ERRORS = %w[
  invalidEnvelope unsupportedOperation incompatibleResource invalidGeometry
  arithmeticOverflow capacityExhausted malformedStream rasterizationFailure
  displayFailure reentrancyViolation invariantViolation
].freeze
DISPLAY_ERRORS = %w[
  invalidDescriptor invalidReservation capacityExhausted arithmeticOverflow
  transportUnavailable reentrancyViolation invariantViolation
].freeze

def fail_check(message)
  warn "SPEC-014 failure check failed: #{message}"
  exit 1
end

document = YAML.safe_load(PATH.read)
fail_check("schema differs") unless document["schema"] == "spec-014-v1"
cases = document.fetch("cases")
fail_check("case order or set differs") unless cases.map { |item| item["fixtureID"] } == EXPECTED_IDS
by_id = cases.to_h { |item| [item.fetch("fixtureID"), item] }

mapping = by_id.fetch("spec014-failure-local-mapping-matrix")
resources = mapping.fetch("operationsResources")
fail_check("detection order differs") unless resources.fetch(0).fetch("detectionOrder") == DETECTION_ORDER
raster = resources.fetch(1).fetch("rasterMappings")
display = resources.fetch(2).fetch("displayMappings")
fail_check("raster local-error coverage differs") unless raster.map { |row| row.fetch("local") }.sort == RASTER_ERRORS.sort
fail_check("display local-error coverage differs") unless display.map { |row| row.fetch("local") }.sort == DISPLAY_ERRORS.sort
[raster, display].flatten.each do |row|
  fail_check("mapping omits exact fact field") unless %w[condition origin scope containment].all? { |field| row.key?(field) }
end
mapping.fetch("injectedEvents").each do |row|
  first, second = row.fetch("simultaneous").map { |value| DETECTION_ORDER.index(value) }
  fail_check("unknown simultaneous detection point") unless first && second
  fail_check("first-failure precedence differs") unless first < second && row.fetch("selected") == DETECTION_ORDER.fetch(first)
end

reservation = by_id.fetch("spec014-failure-reservation-operational-matrix")
reservation_groups = reservation.fetch("operationsResources")
legal = reservation_groups.fetch(0).fetch("legalOperationalResults")
impossible = reservation_groups.fetch(1).fetch("impossibleOperationalFailures")
fail_check("legal reservation results differ") unless legal.map { |row| row.fetch("target") } == %w[backpressured retryableRefusal nonRetryableRefusal]
fail_check("legal reservation result invoked body") unless legal.all? { |row| row.fetch("bodyCalls").zero? }
fail_check("not every constructed reservation failure is rejected") unless impossible.length == DISPLAY_ERRORS.length && impossible.all? { |row| row.fetch("offer") == "failed-contractViolation" && row.fetch("bodyCalls").zero? }

drain = by_id.fetch("spec014-failure-health-drain-diagnostics")
modes = drain.fetch("operationsResources").fetch(0).fetch("diagnosticModes")
fail_check("diagnostic mode matrix differs") unless modes == %w[omitted selected saturated dropped failing]
events = drain.fetch("injectedEvents")
fail_check("pre-transfer failure is irreversible") unless events.fetch(0).values_at("transfer", "offer", "healthUpdates", "cancel") == [false, "failed", 0, 1]
fail_check("accepted drain matrix differs") unless events.drop(1).all? { |row| row.fetch("transfer") && row.fetch("offer") == "accepted" && row.fetch("healthUpdates") == 1 && row.fetch("cancel").zero? && row.fetch("finish") == 1 }
fail_check("health update count differs") unless drain.fetch("health").fetch("updatesPerFrame") == 1

puts "SPEC-014 failure check passed: complete mapping, precedence, reservation, drain, and diagnostic matrices."
