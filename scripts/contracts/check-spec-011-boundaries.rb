#!/usr/bin/env ruby
# frozen_string_literal: true

require "pathname"
require "yaml"

ROOT = Pathname.new(File.expand_path("../..", __dir__))
GRAPH = YAML.safe_load(
  ROOT.join("Tests/ContractFixtures/SPEC002/target-dependencies.yaml").read,
  aliases: false
).fetch("targets")

def fail_check(message)
  warn "SPEC-011 boundary check failed: #{message}"
  exit 1
end

expected_interaction = %w[GiftUI GiftUIExecution GiftUILayout GiftUISemanticCore]
fail_check("Interaction dependencies differ") unless
  GRAPH.dig("GiftUIInteraction", "dependencies") == expected_interaction
expected_adapter = %w[GiftUIFailureCore GiftUIFailureExecution GiftUIInteraction]
fail_check("failure adapter dependencies differ") unless
  GRAPH.dig("GiftUIInteractionFailureAdapterFixture", "dependencies") == expected_adapter
expected_tests = %w[
  GiftUIExecution GiftUIFailureCore GiftUIFailureExecution GiftUIInteraction
  GiftUIInteractionFailureAdapterFixture
]
fail_check("failure adapter test dependencies differ") unless
  GRAPH.dig("GiftUIInteractionFailureAdapterTests", "dependencies") == expected_tests

%w[GiftUI GiftUIExecution GiftUILayout GiftUISemanticCore].each do |owner|
  fail_check("forbidden reverse edge from #{owner}") if
    GRAPH.fetch(owner).fetch("dependencies").include?("GiftUIInteraction")
end

interaction_sources = ROOT.glob("Sources/GiftUIInteraction/*.swift").sort
fail_check("Interaction source is missing") if interaction_sources.empty?
interaction_text = interaction_sources.map(&:read).join("\n")
imports = interaction_text.scan(/^import (\w+)/).flatten.uniq.sort
fail_check("Interaction imports outside approved owners: #{imports.inspect}") unless
  (imports - expected_interaction).empty?
forbidden = /@_exported\s+import|\b(?:String|Array|ContiguousArray|Dictionary|Set|Any|any|Mirror|Task|actor|async|await|Allocator|malloc|calloc|realloc)\b/
fail_check("Interaction contains a forbidden dependency or mechanism") if interaction_text.match?(forbidden)

adapter = ROOT.join(
  "Sources/GiftUIInteractionFailureAdapterFixture/InteractionFailureAdapter.swift"
).read
fail_check("failure adapter imports differ") unless
  adapter.scan(/^import (\w+)/).flatten == expected_adapter
%w[
  capacityExhausted invalidIdentity invalidGeometry invalidPhase
  reentrancyViolation invariantViolation incompatibleActionDomain
  invalidActionValue missingModelTarget interaction coordinator
  observableState candidateFrame activeCycle runtime contained safetyNotProven
  mandatoryEffectsComplete localError detector
].each do |fragment|
  fail_check("failure adapter lacks #{fragment}") unless adapter.include?(fragment)
end

puts "SPEC-011 boundaries passed: exact Interaction and failure-adapter graph, imports, reverse edges, and finite mapping surface."
