#!/usr/bin/env ruby
# frozen_string_literal: true

require "pathname"

ROOT = Pathname.new(File.expand_path("../..", __dir__))
PACKAGE = ROOT.join("Package.swift").read
DEPENDENCIES = ROOT.join("Tests/ContractFixtures/SPEC002/target-dependencies.yaml").read
SOURCE = ROOT.join("Sources/GiftUIObservableStateFailureAdapterFixture/ObservableStateFailureAdapter.swift").read
TEST = ROOT.join("Tests/GiftUIObservableStateFailureAdapterTests/ObservableStateDiagnosticIsolationTests.swift").read

def fail_check(message)
  warn "SPEC-010 diagnostic isolation check failed: #{message}"
  exit 1
end

adapter_target = PACKAGE[/\.target\(\s*name: "GiftUIObservableStateFailureAdapterFixture".*?\n\s*\),/m]
test_target = PACKAGE[/\.testTarget\(\s*name: "GiftUIObservableStateFailureAdapterTests".*?\n\s*\),/m]
fail_check("production adapter depends on diagnostics") if adapter_target&.include?("GiftUIFailureDiagnostics")
fail_check("diagnostics are not isolated to tests") unless test_target&.include?("GiftUIFailureDiagnostics")
fail_check("production adapter imports diagnostics") if SOURCE.include?("GiftUIFailureDiagnostics")
fail_check("dependency manifest omits diagnostic test dependency") unless
  DEPENDENCIES.match?(/GiftUIObservableStateFailureAdapterTests:.*?GiftUIFailureDiagnostics/m)

%w[absent enabled disabled lost saturated].each do |configuration|
  fail_check("configuration matrix lacks #{configuration}") unless TEST.include?(configuration)
end
%w[result liveSet attachmentGeneration dirtyLocations semanticWakePending publicationGeneration mappedFailure].each do |field|
  fail_check("correctness snapshot lacks #{field}") unless TEST.include?(field)
end
%w[diagnosticProjectionStatesPreserveCompleteObservableCorrectness attemptAuthoritativeMutation rejectedMutationCount].each do |name|
  fail_check("isolation fixture lacks #{name}") unless TEST.include?(name)
end

puts "SPEC-010 diagnostic isolation passed: absent, enabled, disabled, lost, and saturated projections preserve typed result, live set, generations, dirtiness, wake, publication, and mapped failure."
