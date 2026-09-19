#!/usr/bin/env ruby
# frozen_string_literal: true

require "pathname"
require "yaml"

ROOT = Pathname.new(File.expand_path("../..", __dir__))
FIXTURES = ROOT.join("Tests/ContractFixtures")
PACKAGE_GRAPH = YAML.safe_load(
  FIXTURES.join("SPEC002/target-dependencies.yaml").read,
  aliases: false
).fetch("targets")
FAILURE_GRAPH = YAML.safe_load(
  FIXTURES.join("SPEC003/target-boundaries.yaml").read,
  aliases: false
).fetch("active")
CAPABILITY_GRAPH = YAML.safe_load(
  FIXTURES.join("SPEC004/target-boundaries.yaml").read,
  aliases: false
).fetch("active")

def fail_check(message)
  warn "SPEC-003 integration audit failed: #{message}"
  exit 1
end

FAILURE_GRAPH.each do |target, declaration|
  package_declaration = PACKAGE_GRAPH[target]
  fail_check("failure target is absent from package registry: #{target}") unless package_declaration
  fail_check("failure/package declaration differs for #{target}") unless
    declaration.fetch("type") == package_declaration.fetch("type") &&
      declaration.fetch("dependencies").sort == package_declaration.fetch("dependencies").sort
end

CAPABILITY_GRAPH.each do |target, declaration|
  package_declaration = PACKAGE_GRAPH[target]
  fail_check("capability target is absent from package registry: #{target}") unless package_declaration
  fail_check("capability/package declaration differs for #{target}") unless
    declaration.fetch("type") == package_declaration.fetch("type") &&
      declaration.fetch("dependencies").sort == package_declaration.fetch("dependencies").sort
end

expected_execution = %w[GiftUIExecution GiftUIFailureCore]
fail_check("execution-correlation owner edges differ") unless
  FAILURE_GRAPH.dig("GiftUIFailureExecution", "dependencies") == expected_execution

expected_capability_adapter = %w[GiftUICapabilities GiftUIFailureCore]
fail_check("capability adapter owner edges differ") unless
  FAILURE_GRAPH.dig("GiftUICapabilityFailureAdapterFixture", "dependencies") == expected_capability_adapter &&
    CAPABILITY_GRAPH.dig("GiftUICapabilityFailureAdapterFixture", "dependencies") == expected_capability_adapter

host_dependencies = FAILURE_GRAPH.dig("GiftUIHostConfiguration", "dependencies") || []
%w[GiftUICapabilities GiftUIFailureCore GiftUIExecution GiftUIRuntimeCore].each do |dependency|
  fail_check("host integration lacks #{dependency}") unless host_dependencies.include?(dependency)
end

host_routing = ROOT.join("Sources/GiftUIHostConfiguration/HostResidualFailureRouting.swift").read
fail_check("host residual routing import differs") unless
  host_routing.scan(/^import (\w+)/).flatten == ["GiftUIFailureCore"]
%w[MVPHostInvariantFailureOwner preventNormalCycle quiesce fatalHook].each do |fragment|
  fail_check("host residual routing lacks #{fragment}") unless host_routing.include?(fragment)
end

production_sources = ROOT.glob("Sources/**/*.swift").sort
diagnostic_importers = production_sources.each_with_object([]) do |path, importers|
  importers << path.relative_path_from(ROOT).to_s if path.read.match?(/^import GiftUIFailureDiagnostics$/)
end
fail_check("production correctness target imports diagnostics: #{diagnostic_importers.inspect}") unless
  diagnostic_importers.empty?

execution_sources = ROOT.glob("Sources/GiftUIExecution/*.swift").map(&:read).join("\n")
fail_check("Execution imports downstream failure correlation") if
  execution_sources.match?(/^import GiftUIFailureExecution$/)
capability_sources = ROOT.glob("Sources/GiftUICapabilities/*.swift").map(&:read).join("\n")
fail_check("Capabilities imports downstream Failure Core") if
  capability_sources.match?(/^import GiftUIFailureCore$/)

%w[
  docs/future-work/fw-009-shared-delegated-service-foundation.md
  docs/future-work/fw-012-durable-failure-identity-compatibility.md
].each do |relative|
  text = ROOT.join(relative).read
  fail_check("deferred-work boundary is not captured: #{relative}") unless text.include?("status: captured")
end

puts "SPEC-003 integration audit passed: SPEC-002/003/004 registries agree, execution/capability/host ownership is one-way, diagnostics remain observational, and deferred boundaries remain captured."
