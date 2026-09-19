#!/usr/bin/env ruby
# frozen_string_literal: true

require "json"
require "yaml"

ROOT = File.expand_path("../..", __dir__)
CONTRACT_PATH = File.join(ROOT, "Tests/ContractFixtures/SPEC005/target-boundaries.yaml")

def fail_check(message)
  warn "SPEC-005 downstream integration check failed: #{message}"
  exit 1
end

begin
  contract = YAML.safe_load(File.read(CONTRACT_PATH), aliases: false)
  package = JSON.parse($stdin.read)
rescue Errno::ENOENT, JSON::ParserError, Psych::Exception => error
  fail_check(error.message)
end

integration = contract.fetch("downstream_integration")
fixture_only = integration.fetch("fixture_only_consumers")
expected_direct = integration.fetch("direct_text_resource_consumers")
platform_roots = integration.fetch("platform_roots")
evidence = integration.fetch("evidence")
targets = package.fetch("targets", []).to_h { |target| [target.fetch("name"), target] }

dependencies = lambda do |name|
  target = targets[name] || fail_check("target is missing: #{name}")
  target.fetch("dependencies", []).map do |dependency|
    declaration = dependency.fetch("target", dependency["byName"])
    declaration.is_a?(Array) ? declaration.first : declaration
  end
end

actual_direct = targets.values.each_with_object([]) do |target, consumers|
  name = target.fetch("name")
  next if target["type"] == "test" || fixture_only.include?(name)

  consumers << name if dependencies.call(name).include?("GiftUITextResources")
end
fixture_only.each do |name|
  fail_check("fixture-only consumer is missing: #{name}") unless targets.key?(name)
end
unless actual_direct.sort == expected_direct.sort
  fail_check(
    "direct production consumers differ: expected #{expected_direct.sort.inspect}, " \
    "found #{actual_direct.sort.inspect}"
  )
end

reachable = lambda do |root, wanted|
  pending = [root]
  visited = {}
  until pending.empty?
    name = pending.shift
    next if visited[name]
    return true if name == wanted

    visited[name] = true
    pending.concat(dependencies.call(name).select { |dependency| targets.key?(dependency) })
  end
  false
end

platform_roots.each do |name|
  fail_check("#{name} does not reach GiftUITextResources") unless
    reachable.call(name, "GiftUITextResources")
end

required_fragments = {
  "layout" => ["CanonicalTextMetricsView", "metrics.mapScalar", "metrics.metrics"],
  "render" => ["CanonicalTextMetricsView", "FontInstanceID", "GlyphID", "textMetrics.metrics"],
  "raster" => ["TextRasterResourceView", "raster.withPayload", "GlyphRasterRecord"],
  "backend" => ["TextResourceValidationResult", "RasterRealizationDescriptor", "GlyphID"],
  "host" => ["textResourceValidation", "selectedTextRasterRealization", "HostValidationResult"]
}

unless evidence.keys.sort == required_fragments.keys.sort
  fail_check("evidence roles differ: #{evidence.keys.sort.inspect}")
end
evidence.each do |role, row|
  source = File.join(ROOT, row.fetch("source"))
  fail_check("#{role} source is missing: #{row.fetch('source')}") unless File.file?(source)
  text = File.read(source)
  required_fragments.fetch(role).each do |fragment|
    fail_check("#{role} source lacks #{fragment.inspect}") unless text.include?(fragment)
  end
  row.fetch("checks").each do |relative|
    fail_check("#{role} check is missing: #{relative}") unless File.file?(File.join(ROOT, relative))
  end
end

host_bootstrap = File.read(File.join(ROOT, "Sources/GiftUIHostConfiguration/HostPresetBootstrap.swift"))
%w[resourcePackageCount audit.owners.isExact instance.teardown].each do |fragment|
  fail_check("host bootstrap lacks #{fragment.inspect}") unless host_bootstrap.include?(fragment)
end

host_lifecycle = File.read(File.join(ROOT, "Sources/GiftUIHostConfiguration/HostActivationController.swift"))
%w[releasePlatformOwners resetProfileStorage invalidateAssemblyReportRuntimeUse].each do |fragment|
  fail_check("host lifecycle lacks #{fragment.inspect}") unless host_lifecycle.include?(fragment)
end

puts "SPEC-005 downstream integration check passed: exact direct consumers, " \
     "platform reachability, lookup/payload adapters, backend validation, and host lifetime."
