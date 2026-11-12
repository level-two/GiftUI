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
  "guard !reportAttempted else",
  "guard let returned else",
  "guard returned == expected else",
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

success_path = binding[/func scopedRootBindsEveryDeclarationBeforeCallingTheBody\(\)(.*?)(?=\n@Test|\z)/m, 1]
fail_check("scoped-root success path is missing") unless success_path
[
  "root.withBoundDeclaration(",
  "bodyCalls += 1",
  "#expect(result)",
  "#expect(bodyCalls == 1)",
  "root.finishCandidate(.publish)",
].each do |fragment|
  fail_check("scoped-root success path lacks #{fragment}") unless success_path.include?(fragment)
end

capacity_failure = binding[/func capacityBindingFailureSuppressesBodyAndDiscardsCandidate\(\)(.*?)(?=\n@Test|\z)/m, 1]
fail_check("scoped-root capacity-failure path is missing") unless capacity_failure
[
  "root.withBoundDeclaration(",
  ".modelCapacityExhausted",
  "#expect(bodyCalls == 0)",
  "root.finishCandidate(.discard)",
].each do |fragment|
  fail_check("scoped-root capacity-failure path lacks #{fragment}") unless capacity_failure.include?(fragment)
end
fail_check("binding fixture must use the package-internal root scope") unless
  binding.include?("ObservableStateRootScope<FixtureBoundModel, UInt16>") &&
    binding.include?("scope.withRoot(storage: &rootStorage)")

forbidden = /\b(?:Array|ContiguousArray|Dictionary|Set|Any|any|Mirror|Task|actor|async|await|throw|fatalError|GiftUIFailureCore|GiftUIRuntime|GiftUIBackend|GiftUIPlatform)\b/
fail_check("registration lifecycle selects storage or a prohibited owner") if route.match?(forbidden)

puts "SPEC-010 reconciliation faults passed: lifecycle and association matrices plus scoped-root success, capacity failure, body suppression, and candidate discard are covered."
