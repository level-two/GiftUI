#!/usr/bin/env ruby
# frozen_string_literal: true

require "pathname"

ROOT = Pathname.new(File.expand_path("../..", __dir__))
SOURCE = ROOT.join("Sources/GiftUIObservableState/ObservableStateReplacementTransaction.swift")
REGISTRATION = ROOT.join("Sources/GiftUIObservableState/ObservableStateRegistrationLifecycle.swift")
TEST = ROOT.join("Tests/GiftUIObservableStateTests/ObservableStateReplacementTransactionTests.swift")

def fail_check(message)
  warn "SPEC-010 replacement transaction check failed: #{message}"
  exit 1
end

source = SOURCE.read
registration = REGISTRATION.read
tests = TEST.read

fail_check("replacement imports differ") unless source.scan(/^import (\S+)/).flatten == %w[GiftUI GiftUIExecution]
fail_check("replacement transaction must remain internal") if source.match?(
  /\b(?:package|public|open) (?:struct|enum) ObservableStateReplacement/
)

required = %w[
  beginReplacement
  invalidPhaseContained
  incompatibleAssociation
  duplicateOwner
  registrationGenerationExhausted
  registrationCapacityExhausted
  replacementStagingCapacityExhausted
  acceptCandidateReport
  acceptAttachmentReturn
  firstFailure
  retire
  liveReservation
  isDirty
  discardCandidate
]
required.each do |fragment|
  fail_check("replacement transaction lacks #{fragment}") unless source.include?(fragment)
end
fail_check("active registration constructor is missing") unless registration.include?(
  "init(activeAttachment: _GiftUIObservationAttachment)"
)

validation = source.index("guard isCompatible")
ownership = source.index("guard !candidateAlreadyOwned")
generation = source.index("allocator.reserve")
registration_capacity = source.index("guard registrationCapacityAvailable")
staging = source.index("guard replacementStagingAvailable")
unless [validation, ownership, generation, registration_capacity, staging].all? &&
    validation < ownership && ownership < generation && generation < registration_capacity &&
    registration_capacity < staging
  fail_check("replacement validation and reservation precedence differs")
end

%w[
  successfulReplacementCommitsFreshRouteDetachesFormerAndStaysDirty
  everyPrecommitValidationOrReservationFailurePreservesFormerState
  attachmentReturnFailureDiscardsCandidateAndPreservesFormer
  reportDuringAttachmentPoisonsMatchingReturnAndPreservesFormer
].each do |name|
  fail_check("replacement fixture lacks #{name}") unless tests.include?(name)
end

forbidden = /\b(?:Array|ContiguousArray|Dictionary|Set|Any|any|Mirror|Task|actor|async|await|throw|fatalError|GiftUIFailureCore|GiftUIRuntime|GiftUIBackend|GiftUIPlatform)\b/
fail_check("replacement transaction selects storage or a prohibited owner") if source.match?(forbidden)

puts "SPEC-010 replacement transaction passed: precedence, attach verification, atomic route swap, rollback, retirement, and dirtiness are covered."
