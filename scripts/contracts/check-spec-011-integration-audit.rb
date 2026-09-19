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
  warn "SPEC-011 integration audit failed: #{message}"
  exit 1
end

approved_consumers = %w[
  GiftUIHostConfigurationTests
  GiftUIInteractionFailureAdapterFixture
  GiftUIInteractionFailureAdapterTests
  GiftUIInteractionTests
  GiftUIRuntimeConformanceTests
  GiftUIRuntimeCore
  GiftUIRuntimeCoreTests
  GiftUIRuntimeDynamic
  GiftUIRuntimeDynamicTests
  GiftUIRuntimeStatic
  GiftUIRuntimeStaticTests
  SignalAnalyzerHost
]
actual_consumers = GRAPH.each_with_object([]) do |(target, declaration), consumers|
  consumers << target if declaration.fetch("dependencies").include?("GiftUIInteraction")
end.sort
fail_check("direct Interaction consumers differ: #{actual_consumers.inspect}") unless
  actual_consumers == approved_consumers

source_files = ROOT.glob("Sources/**/*.swift").sort
source_by_path = source_files.to_h { |path| [path.relative_path_from(ROOT).to_s, path.read] }
all_source = source_by_path.values.join("\n")

definitions = {
  "action-generation allocator" => /package struct ActionGenerationAllocator\b/,
  "pointer capture owner" => /package struct PointerActionCapture</,
  "Interaction state owner" => /package struct InteractionState</,
  "observable target-generation owner" => /struct ObservableStateAttachmentGenerationAllocator\b/,
  "candidate coordinator join" => /package enum RuntimeInteractionCandidateCoordinator\b/,
}
definitions.each do |label, pattern|
  count = all_source.scan(pattern).length
  fail_check("expected one #{label} definition, found #{count}") unless count == 1
end

action_allocator_constructions = all_source.scan(/ActionGenerationAllocator\(\)/).length
fail_check("expected one production action-generation allocator construction") unless
  action_allocator_constructions == 1
coordinator_calls = all_source.scan(/RuntimeInteractionCandidateCoordinator\.build\(/).length
fail_check("expected one production candidate-coordinator join") unless coordinator_calls == 1

interaction_state_paths = source_by_path.each_with_object([]) do |(path, source), paths|
  paths << path if path.start_with?("Sources/GiftUIRuntime") && source.match?(/\bInteractionState</)
end.sort
expected_state_paths = %w[
  Sources/GiftUIRuntimeDynamic/DynamicInteractionStorage.swift
  Sources/GiftUIRuntimeStatic/StaticInteractionStorage.swift
]
fail_check("profile Interaction state realizations differ: #{interaction_state_paths.inspect}") unless
  interaction_state_paths == expected_state_paths

dispatch_paths = source_by_path.each_with_object([]) do |(path, source), paths|
  paths << path if source.include?("RuntimeInteractionDispatcher(")
end.sort
expected_dispatch_paths = %w[
  Sources/SignalAnalyzerHost/DynamicSignalAnalyzerActionDispatcher.swift
  Sources/SignalAnalyzerHost/StaticSignalAnalyzerActionDispatcher.swift
]
fail_check("production dispatch joins differ: #{dispatch_paths.inspect}") unless
  dispatch_paths == expected_dispatch_paths

forbidden_classes = /(?:Backend|Display|Driver|Platform)/
forbidden_consumers = actual_consumers.grep(forbidden_classes)
fail_check("backend/platform/driver owns Interaction dispatch: #{forbidden_consumers.inspect}") unless
  forbidden_consumers.empty?

reexports = source_by_path.each_with_object([]) do |(path, source), paths|
  paths << path if source.match?(/@_exported\s+import\s+GiftUIInteraction\b/)
end
fail_check("portable Interaction re-export found: #{reexports.inspect}") unless reexports.empty?

puts "SPEC-011 integration audit passed: exact consumers, five single owners, two profile states, two Signal Analyzer dispatch joins, and no backend/platform/driver path or re-export."
