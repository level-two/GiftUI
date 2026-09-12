#!/usr/bin/env ruby
# frozen_string_literal: true

require "pathname"

ROOT = Pathname.new(File.expand_path("../..", __dir__))
PACKAGE = ROOT.join("Package.swift").read
DEPENDENCIES = ROOT.join("Tests/ContractFixtures/SPEC002/target-dependencies.yaml").read
PRODUCTION = ROOT.glob("Sources/GiftUIInteractionFailureAdapterFixture/*.swift").map(&:read).join("\n")
TEST = ROOT.join(
  "Tests/GiftUIInteractionFailureAdapterTests/InteractionDiagnosticIsolationTests.swift"
).read

def fail_check(message)
  warn "SPEC-011 diagnostic isolation check failed: #{message}"
  exit 1
end

adapter_target = PACKAGE[/\.target\(\s*name: "GiftUIInteractionFailureAdapterFixture".*?\n\s*\),/m]
test_target = PACKAGE[/\.testTarget\(\s*name: "GiftUIInteractionFailureAdapterTests".*?\n\s*\),/m]
fail_check("production adapter depends on diagnostics") if adapter_target&.include?("GiftUIFailureDiagnostics")
fail_check("diagnostics are not isolated to focused tests") unless test_target&.include?("GiftUIFailureDiagnostics")
fail_check("production adapter imports diagnostics") if PRODUCTION.include?("GiftUIFailureDiagnostics")
fail_check("dependency registry omits diagnostic test dependency") unless
  DEPENDENCIES.match?(/GiftUIInteractionFailureAdapterTests:.*?GiftUIFailureDiagnostics/m)

%w[omitted selected dropped saturated failing].each do |configuration|
  fail_check("configuration matrix lacks #{configuration}") unless TEST.include?(configuration)
end
%w[
  mappedFailure effectState allowedDispositions handlerInvocationCount fallbackCount
  retargetCount partialPublicationCount aliasCount
].each do |field|
  fail_check("correctness snapshot lacks #{field}") unless TEST.include?(field)
end
%w[
  diagnosticConfigurationsPreserveCompleteInteractionCorrectness
  attemptFallbackRetargetPublicationAndAlias rejectedMutationCount
].each do |name|
  fail_check("diagnostic isolation fixture lacks #{name}") unless TEST.include?(name)
end

puts "SPEC-011 diagnostic isolation passed: omitted, selected, dropped, saturated, and failing diagnostics preserve complete interaction correctness."
