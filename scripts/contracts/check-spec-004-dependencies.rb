#!/usr/bin/env ruby
# frozen_string_literal: true

require "json"
require "yaml"

root = File.expand_path("../..", __dir__)
contract_path = File.join(root, "Tests/ContractFixtures/SPEC004/target-boundaries.yaml")

def fail_check(message)
  warn "SPEC-004 dependency check failed: #{message}"
  exit 1
end

begin
  contract = YAML.safe_load(File.read(contract_path), aliases: false)
  package = JSON.parse($stdin.read)
rescue Errno::ENOENT, JSON::ParserError, Psych::Exception => error
  fail_check(error.message)
end

fail_check("schema_version must be 1") unless contract["schema_version"] == 1
active = contract["active"]
forbidden = contract["forbidden_capability_imports"]
fail_check("active targets must be a mapping") unless active.is_a?(Hash)
fail_check("forbidden imports must be unique strings") unless
  forbidden.is_a?(Array) && forbidden.all? { |name| name.is_a?(String) } &&
    forbidden.uniq.length == forbidden.length

targets = package.fetch("targets", []).to_h { |target| [target.fetch("name"), target] }
products = package.fetch("products", []).to_h { |product| [product.fetch("name"), product] }

active.each do |name, expected|
  target = targets[name] || fail_check("active target is missing: #{name}")
  dependencies = target.fetch("dependencies", []).map do |dependency|
    declaration = dependency.fetch("target", dependency["byName"])
    declaration.is_a?(Array) ? declaration.first : declaration
  end
  fail_check("#{name} type differs") unless target["type"] == expected["type"]
  fail_check("#{name} dependencies differ") unless dependencies.sort == expected["dependencies"].sort
end

direct_capability_consumers = targets.each_with_object([]) do |(name, target), consumers|
  next unless target["type"] == "regular"

  dependencies = target.fetch("dependencies", []).map do |dependency|
    declaration = dependency.fetch("target", dependency["byName"])
    declaration.is_a?(Array) ? declaration.first : declaration
  end
  consumers << name if dependencies.include?("GiftUICapabilities")
end.sort
expected_capability_consumers = active.each_with_object([]) do |(name, declaration), consumers|
  next unless declaration["type"] == "regular"
  next unless declaration["dependencies"].include?("GiftUICapabilities")

  consumers << name
end.sort
fail_check("direct production capability consumer set differs") unless
  direct_capability_consumers == expected_capability_consumers

expected_capability_consumers.each do |name|
  sources = Dir.glob(File.join(root, "Sources", name, "**", "*.swift"))
    .sort.map { |path| File.read(path) }.join("\n")
  fail_check("#{name} re-exports capabilities") if
    sources.match?(/@_exported\s+import\s+GiftUICapabilities/)
  fail_check("#{name} correctness path imports diagnostics") if
    sources.match?(/^import GiftUIFailureDiagnostics$/)
end

production_resolver_sites = Dir.glob(File.join(root, "Sources", "**", "*.swift"))
  .reject { |path| path.include?("/GiftUICapabilities/") || path.include?("/SignalAnalyzerPresetHarness/") }
  .each_with_object({}) do |path, sites|
    count = File.read(path).scan(/RasterPresentationResolver\.resolve\(/).length
    sites[path.delete_prefix("#{root}/")] = count if count.positive?
  end
expected_resolver_sites = {
  "Sources/GiftUIHostConfiguration/CheckedMVPHostConfigurationValidator.swift" => 1,
  "Sources/SignalAnalyzerTargetHost/StaticSignalAnalyzerNRFAssembly.swift" => 1,
  "Sources/SignalAnalyzerTargetHost/DynamicSignalAnalyzerPiAssembly.swift" => 1,
}
fail_check("production capability resolution sites differ from host owners") unless
  production_resolver_sites == expected_resolver_sites

product = products["GiftUICapabilities"] || fail_check("GiftUICapabilities product is missing")
fail_check("GiftUICapabilities product must be a library") unless product["type"].key?("library")
fail_check("GiftUICapabilities product target differs") unless product["targets"] == ["GiftUICapabilities"]

puts "SPEC-004 dependency check passed: #{active.length} active targets and " \
     "#{forbidden.length} forbidden imports."
