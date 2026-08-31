#!/usr/bin/env ruby

require "date"
require "yaml"

ROOT = File.expand_path("../..", __dir__)
FIXTURES = File.join(ROOT, "Tests/ContractFixtures/SPEC002")

def fail!(message)
  warn "error: #{message}"
  exit 1
end

plan_path = File.join(ROOT, "docs/implementation-plans/spec-002-implementation-plan.md")
plan_content = File.read(plan_path)
front_matter = plan_content[/\A---\s*\n(.*?)\n---\s*\n/m, 1]
fail!("SPEC-002 plan front matter is missing") unless front_matter
plan = YAML.safe_load(front_matter, permitted_classes: [Date], aliases: false)
fail!("SPEC-002 unexpectedly owns a design note") unless plan.fetch("related_design_notes") == []
design_notes = Dir.glob(File.join(ROOT, "docs/implementation-designs/spec-002-*.md"))
fail!("SPEC-002 design note exists without a justified trigger") unless design_notes.empty?

foundation = File.read(File.join(ROOT, "Sources/GiftUI/GiftUI.swift"))
forbidden_foundation = {
  /\b(?:View|Button|VStack|HStack|ZStack|Spacer|State)\b/ => "declarative behavior",
  /\b(?:GiftUIOutcome|GiftUIFailure|Disposition|Diagnostic)\b/ => "failure policy or diagnostics",
  /\b(?:GiftUICapabilit\w*|CapabilityResolver)\b/ => "capability resolution",
  /\b(?:LayoutPolicy|layoutPass|layoutNode)\b/i => "layout policy",
  /\b(?:admit|admission|hitTest|dispatchAction)\b/i => "input admission or dispatch",
  /\b(?:BackendPolicy|HostPolicy|ProductPolicy)\b/ => "backend or host policy"
}
forbidden_foundation.each do |pattern, label|
  fail!("GiftUI Foundation defines #{label}") if foundation.match?(pattern)
end

fixture_sources = Dir.glob(File.join(FIXTURES, "**/*.{swift,c}")).sort
fail!("SPEC-002 fixture source inventory is empty") if fixture_sources.empty?
forbidden_fixture = /\b(?:View|Button|VStack|HStack|ZStack|Spacer|GiftUIOutcome|GiftUIFailureFact|GiftUICapabilit\w*|CapabilityResolver|LayoutPolicy|BackendPolicy|HostPolicy|ProductPolicy)\b/
fixture_sources.each do |path|
  content = File.read(path)
  next unless content.match?(forbidden_fixture)
  fail!("SPEC-002-owned fixture defines another owner's vocabulary: #{path.delete_prefix(ROOT + '/')}")
end

graph = YAML.safe_load(
  File.read(File.join(FIXTURES, "target-dependencies.yaml")),
  permitted_classes: [Date], aliases: false
).fetch("targets")
fail!("GiftUI Foundation acquired a dependency") unless graph.fetch("GiftUI").fetch("dependencies") == []

adapter_paths = %w[
  Tests/GiftUIFoundationFailureAdapterTests/GiftUIFoundationFailureAdapterTests.swift
  Tests/GiftUICapabilityAdapterTests/GiftUICapabilityAdapterTests.swift
  Sources/GiftUICapabilityFailureAdapterFixture/CapabilityFailureAdapter.swift
]
adapter_paths.each do |relative_path|
  fail!("owner adapter moved into SPEC-002 fixtures") if relative_path.start_with?("Tests/ContractFixtures/SPEC002/")
  fail!("owner adapter is missing: #{relative_path}") unless File.file?(File.join(ROOT, relative_path))
end

puts "SPEC-002 scope passed: Foundation and owned fixtures contain no downstream policy; adapters remain at split owner boundaries."
