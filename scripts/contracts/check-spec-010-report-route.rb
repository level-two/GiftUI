#!/usr/bin/env ruby
# frozen_string_literal: true

require "pathname"

ROOT = Pathname.new(File.expand_path("../..", __dir__))
SOURCE = ROOT.join("Sources/GiftUIObservableState/ObservableStateReportRoute.swift")
REGISTRATION = ROOT.join("Sources/GiftUIObservableState/ObservableStateRegistrationLifecycle.swift")
TEST = ROOT.join("Tests/GiftUIObservableStateTests/ObservableStateReportRouteTests.swift")

def fail_check(message)
  warn "SPEC-010 report route check failed: #{message}"
  exit 1
end

source = SOURCE.read
registration = REGISTRATION.read
tests = TEST.read

fail_check("report route imports differ") unless source.scan(/^import (\S+)/).flatten == %w[GiftUI GiftUIExecution]
fail_check("report route must remain internal") if source.match?(
  /\b(?:package|public|open) (?:struct|enum|protocol) ObservableState(?:ReportDisposition|ReportRoute|MutationReporting)/
)

%w[
  sinkOutcome
  ownerResult
  registration
  isDirty
  semanticWakeOutstanding
  verifyAttachment
  acceptReport
  requestWake
  semanticDirty
  reportIfChanged
  reportChange
  dirtied
  coalesced
  staleAttachment
  invalidPhaseContained
  invalidPhaseSafetyNotProven
  reentrancyViolation
  invariantViolation
].each do |fragment|
  fail_check("report route lacks #{fragment}") unless source.include?(fragment)
end

validation_index = source.index("registration.acceptReport(attachment)")
dirty_index = source.index("isDirty = true")
wake_index = source.index("requester.requestWake(for: .semanticDirty)")
unless validation_index && dirty_index && wake_index &&
    validation_index < dirty_index && dirty_index < wake_index
  fail_check("validation, dirtying, or wake order differs")
end

no_op_index = source.index("guard changed else { return nil }")
report_index = source.index("return sink.reportChange()")
unless no_op_index && report_index && no_op_index < report_index
  fail_check("changed/no-op reporting order differs")
end

if registration.match?(/_GiftUIObservableChangeSink|reportRoute|\bArray\b|\bDictionary\b/)
  fail_check("registration retains a sink, callable route, or report history")
end

%w[
  sinkActivatesOnlyAfterMatchingAttachmentReturn
  validReportsDirtyOnceThenCoalesceIntoOneWakeIntent
  sinkAndOwnerOutcomesCorrespondExactly
  changedMutationReportsSynchronouslyAndProvenNoopOmitsReport
  registrationRetainsNoCallableSinkOrReportHistory
].each do |name|
  fail_check("report route fixture lacks #{name}") unless tests.include?(name)
end

forbidden = /\b(?:String|Array|ContiguousArray|Dictionary|Set|Any|any|Mirror|Task|actor|async|await|throw|fatalError|GiftUISemanticCore|GiftUILayout|GiftUIInteraction|GiftUIRenderCore|GiftUIRuntime|GiftUIBackend|GiftUIPlatform)\b/
fail_check("report route selects dynamic storage or a prohibited owner") if source.match?(forbidden)

puts "SPEC-010 report route passed: verified activation, exact outcome mapping, synchronous changed reporting, one dirty wake, coalescing, and no-op omission are covered."
