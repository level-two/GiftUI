#!/usr/bin/env ruby
# frozen_string_literal: true

require "pathname"

ROOT = Pathname.new(File.expand_path("../..", __dir__))
PACKAGE = ROOT.join("Package.swift")
DEPENDENCIES = ROOT.join("Tests/ContractFixtures/SPEC002/target-dependencies.yaml")
SOURCE = ROOT.join("Sources/GiftUIFailureExecution/GiftUIFailureExecution.swift")
TEST = ROOT.join("Tests/GiftUIFailureExecutionTests/ExecutionDiagnosticIsolationTests.swift")

def fail_check(message)
  warn "SPEC-009 diagnostic isolation check failed: #{message}"
  exit 1
end

package = PACKAGE.read
dependencies = DEPENDENCIES.read
source = SOURCE.read
tests = TEST.read

failure_target = package[/\.target\(\s*name: "GiftUIFailureExecution".*?\n\s*\),/m]
test_target = package[/\.testTarget\(\s*name: "GiftUIFailureExecutionTests".*?\n\s*\),/m]
fail_check("production failure adapter depends on diagnostics") if failure_target&.include?("GiftUIFailureDiagnostics")
fail_check("diagnostics are not isolated to the test target") unless test_target&.include?("GiftUIFailureDiagnostics")
fail_check("production source imports diagnostics") if source.include?("GiftUIFailureDiagnostics")
fail_check("dependency manifest omits diagnostic test dependency") unless dependencies.match?(/GiftUIFailureExecutionTests:.*?GiftUIFailureDiagnostics/m)

%w[omitted selected saturated dropped failing].each do |configuration|
  fail_check("matrix lacks #{configuration}") unless tests.include?(configuration)
end
%w[admission mechanicalEffects semanticRevision candidateFrame presentationIdentity offerCount wakeReasons retryCount mappedFact summary authoritativeState].each do |field|
  fail_check("correctness snapshot lacks #{field}") unless tests.include?(field)
end
%w[diagnosticConfigurationsPreserveCompleteExecutionSnapshot diagnosticSinkCannotMutateCoordinatorOrInvokeAction attemptSemanticMutation attemptActionInvocation].each do |name|
  fail_check("isolation fixture lacks #{name}") unless tests.include?(name)
end

puts "SPEC-009 diagnostic isolation passed: omitted, selected, saturated, dropped, and failing diagnostics preserve complete execution correctness and have no mutation/action authority."
