#!/usr/bin/env ruby

require "date"
require "yaml"

ROOT = File.expand_path("../..", __dir__)

def fail!(message)
  warn "error: #{message}"
  exit 1
end

def metadata(relative_path)
  content = File.read(File.join(ROOT, relative_path))
  match = content.match(/\A---\s*\n(.*?)\n---\s*\n/m)
  fail!("#{relative_path} has no front matter") unless match
  YAML.safe_load(match[1], permitted_classes: [Date], aliases: false)
end

specs = {
  "SPEC-002" => "docs/specs/spec-002-portable-foundation.md",
  "SPEC-003" => "docs/specs/spec-003-failure-outcomes-and-containment.md",
  "SPEC-004" => "docs/specs/spec-004-capability-contribution-and-resolution.md"
}.transform_values { |path| metadata(path) }

specs.each do |id, spec|
  fail!("#{id} is not implementing") unless spec["status"] == "implementing"
  (specs.keys - [id]).each do |peer|
    fail!("#{id} lacks reciprocal #{peer} relation") unless spec.fetch("related_specs").include?(peer)
  end
end

rfc004 = metadata("docs/rfcs/rfc-004-run-cycle-and-frame-transaction.md")
rfc011 = metadata("docs/rfcs/rfc-011-bounded-application-actions.md")
adr013 = metadata("docs/adrs/adr-013-provenance-validated-input-admission.md")
adr033 = metadata("docs/adrs/adr-033-bounded-application-actions-and-model-target-dispatch.md")
spec002 = specs.fetch("SPEC-002")

fail!("SPEC-002 lacks RFC-004") unless spec002.fetch("related_rfcs").include?("RFC-004")
fail!("RFC-004 lacks SPEC-002") unless rfc004.fetch("related_specs").include?("SPEC-002")
fail!("SPEC-002 lacks RFC-011") unless spec002.fetch("related_rfcs").include?("RFC-011")
fail!("RFC-011 lacks SPEC-002") unless rfc011.fetch("related_specs").include?("SPEC-002")
fail!("SPEC-002 lacks ADR-033") unless spec002.fetch("related_adrs").include?("ADR-033")
fail!("ADR-033 lacks SPEC-002") unless adr033.fetch("related_specs").include?("SPEC-002")
fail!("ADR-013 is not superseded") unless adr013["status"] == "superseded"
fail!("ADR-013 lacks ADR-033 successor") unless adr013.fetch("superseded_by") == ["ADR-033"]
fail!("ADR-033 does not supersede ADR-013") unless adr033.fetch("supersedes") == ["ADR-013"]

manifest = YAML.safe_load(
  File.read(File.join(ROOT, "docs/features.yaml")),
  permitted_classes: [Date], aliases: false
).fetch("features")
architecture = manifest.fetch("giftui-mvp-architecture")
capabilities = manifest.fetch("capability-system")
fail!("architecture manifest stage differs") unless architecture["status"] == "implementation"
fail!("capability manifest stage differs") unless capabilities["status"] == "implementation"
fail!("architecture manifest lacks SPEC-002/003") unless (specs.keys.first(2) - architecture.fetch("specs")).empty?
fail!("capability manifest lacks SPEC-004") unless capabilities.fetch("specs").include?("SPEC-004")
fail!("capability dependency is missing") unless capabilities.fetch("dependencies").include?("giftui-mvp-architecture")

graph = YAML.safe_load(
  File.read(File.join(ROOT, "Tests/ContractFixtures/SPEC002/target-dependencies.yaml")),
  permitted_classes: [Date], aliases: false
).fetch("targets")
expected_edges = {
  "GiftUIFoundationFailureAdapterTests" => %w[GiftUI GiftUIFailureCore],
  "GiftUICapabilityAdapterTests" => %w[GiftUI GiftUICapabilities],
  "GiftUICapabilityFailureAdapterFixture" => %w[GiftUICapabilities GiftUIFailureCore],
  "GiftUICapabilityFailureAdapterTests" => %w[GiftUICapabilityFailureAdapterFixture GiftUICapabilities GiftUIFailureCore],
  "GiftUISemanticCore" => %w[GiftUI],
  "GiftUISemanticFailureAdapterFixture" => %w[GiftUIFailureCore GiftUISemanticCore],
  "GiftUISemanticFailureAdapterTests" => %w[GiftUIFailureCore GiftUISemanticCore GiftUISemanticFailureAdapterFixture]
}
expected_edges.each do |target, edges|
  fail!("#{target} edge set differs") unless graph.fetch(target).fetch("dependencies") == edges
end
graph.each do |target, entry|
  imports = entry.fetch("dependencies")
  if %w[GiftUI GiftUIFailureCore GiftUICapabilities].all? { |owner| imports.include?(owner) }
    fail!("#{target} creates a monolithic three-owner boundary")
  end
end

source_imports = {
  "Tests/GiftUIFoundationFailureAdapterTests/GiftUIFoundationFailureAdapterTests.swift" => %w[GiftUI GiftUIFailureCore XCTest],
  "Tests/GiftUICapabilityAdapterTests/GiftUICapabilityAdapterTests.swift" => %w[GiftUI GiftUICapabilities XCTest],
  "Sources/GiftUICapabilityFailureAdapterFixture/CapabilityFailureAdapter.swift" => %w[GiftUICapabilities GiftUIFailureCore],
  "Sources/GiftUISemanticCore/GiftUISemanticCore.swift" => %w[GiftUI],
  "Sources/GiftUISemanticFailureAdapterFixture/SemanticFailureAdapter.swift" => %w[GiftUIFailureCore GiftUISemanticCore]
}
source_imports.each do |path, expected|
  actual = File.readlines(File.join(ROOT, path)).each_with_object([]) do |line, imports|
    imports << Regexp.last_match(1) if line =~ /^import (\S+)/
  end
  fail!("#{path} import set differs") unless actual == expected
end

package = File.read(File.join(ROOT, "Package.swift"))
products = package[/products:\s*\[(.*?)\n\s*\],\n\s*targets:/m, 1]
fail!("Package products block is unreadable") unless products
if products.include?("GiftUICapabilityFailureAdapterFixture")
  fail!("test-only capability/failure adapter is published as a product")
end
if products.include?("GiftUISemanticCore") || products.include?("GiftUISemanticFailureAdapterFixture")
  fail!("package-internal semantic targets are published as products")
end

puts "SPEC-002 traceability passed: reciprocal authority links, supersession, manifest navigation, and split adapter ownership."
