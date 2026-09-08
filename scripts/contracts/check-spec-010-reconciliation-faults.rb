#!/usr/bin/env ruby
# frozen_string_literal: true

require "pathname"

ROOT = Pathname.new(File.expand_path("../..", __dir__))
ROUTE = ROOT.join("Sources/GiftUIObservableState/ObservableStateRegistrationLifecycle.swift")
FAULT_TEST = ROOT.join("Tests/GiftUIObservableStateTests/ObservableStateReconciliationFaultTests.swift")
BINDING_TEST = ROOT.join("Tests/GiftUIObservableStateTests/ObservableStateBindingDecoratorTests.swift")
ASSOCIATION_TEST = ROOT.join("Tests/GiftUIObservableStateTests/ObservableStateAssociationLifecycleTests.swift")

def fail_check(message)
  warn "SPEC-010 reconciliation fault check failed: #{message}"
  exit 1
end

route = ROUTE.read
faults = FAULT_TEST.read
binding = BINDING_TEST.read
association = ASSOCIATION_TEST.read

fail_check("registration lifecycle imports differ") unless route.scan(/^import (\w+)$/).flatten == %w[GiftUI]
fail_check("registration lifecycle must remain internal") if route.match?(
  /\b(?:package|public|open) (?:struct|enum|protocol) ObservableStateRegistrationLifecycle\b/
)

required_route = [
  "case attaching(_GiftUIObservationAttachment, reportAttempted: Bool)",
  "case active(_GiftUIObservationAttachment)",
  "case retired",
  "case shutdown",
  "guard !reportAttempted, returned == expected else",
  "state = .attaching(expected, reportAttempted: true)",
  "return attachment == expected ? nil : .staleAttachment",
  "guard attachment == expected else",
  "state = .retired",
]
required_route.each do |fragment|
  fail_check("registration lifecycle lacks #{fragment}") unless route.include?(fragment)
end

required_faults = [
  "locationCapacityExhausted",
  "registrationCapacityExhausted",
  "associationStagingCapacityExhausted",
  "nilAndMismatchedAttachmentReturnsInvalidateCandidateRoute",
  "reportDuringAttachPoisonsLaterMatchingReturnAndRoute",
  "mismatchedDetachDoesNotRetireTheInstalledRegistration",
  "finishInvariantFailureClearsCandidateAndPreservesFirstFailure",
  "lifecycle.failure == .duplicateOwner",
]
required_faults.each do |fragment|
  fail_check("fault matrix lacks #{fragment}") unless faults.include?(fragment)
end

%w[duplicateOwner incompatibleAssociation].each do |fragment|
  fail_check("association matrix lacks #{fragment}") unless association.include?(fragment)
end

binding_failures = %w[
  locationCapacityExhausted registrationCapacityExhausted
  associationStagingCapacityExhausted duplicateOwner incompatibleAssociation
  staleAttachment invariantViolation
]
binding_failures.each do |failure|
  fail_check("body-suppression matrix lacks #{failure}") unless binding.include?(".#{failure}")
end
fail_check("body-suppression matrix lacks zero-body assertion") unless binding.include?(
  "decoratorSuppressesBodyForEveryCandidateBindingFailure"
) && binding.include?("#expect(bodyCalls == 0)")

forbidden = /\b(?:Array|ContiguousArray|Dictionary|Set|Any|any|Mirror|Task|actor|async|await|throw|fatalError|GiftUIFailureCore|GiftUIRuntime|GiftUIBackend|GiftUIPlatform)\b/
fail_check("registration lifecycle selects storage or a prohibited owner") if route.match?(forbidden)

puts "SPEC-010 reconciliation faults passed: reservation, association, attachment, detach, finish, and body-suppression seams are covered."
