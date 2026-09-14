#!/usr/bin/env ruby
# frozen_string_literal: true

require "json"
require "pathname"
require "yaml"

ROOT = Pathname.new(File.expand_path("../..", __dir__))
FIXTURES = ROOT.join("Tests/ContractFixtures/SPEC014")
OWNERS_PATH = FIXTURES.join("module-owners.tsv")
DEPENDENCY_ALLOW_LIST = ROOT.join("Tests/ContractFixtures/SPEC002/target-dependencies.yaml")
DOWNSTREAM_CONSUMERS = FIXTURES.join("downstream-consumers.tsv")

CLASS_MODULES = {
  "backend-integration" => %w[GiftUIBackendIntegration],
  "display" => %w[GiftUIDisplayCore],
  "driver" => %w[GiftUIDriver GiftUIDisplayILI9341 GiftUIInputADS7846],
  "drawing" => %w[GiftUIDrawing],
  "host" => %w[GiftUIHost],
  "layout" => %w[GiftUILayout],
  "platform" => %w[GiftUIPlatform GiftUIPlatformLinux GiftUIPlatformRaspberryPi],
  "raster" => %w[GiftUIRasterCore],
  "render-lowering" => %w[GiftUIRenderLowering],
  "runtime" => %w[GiftUIRuntimeCore GiftUIRuntimeDynamic GiftUIRuntimeStatic],
  "semantic" => %w[GiftUISemanticCore]
}.freeze

def fail_check(message)
  warn "SPEC-014 module contract check failed: #{message}"
  exit 1
end

def package_dependency_name(dependency)
  declaration = dependency["target"] || dependency["byName"]
  return declaration.is_a?(Array) ? declaration.first : declaration if declaration

  product = dependency["product"]
  product.is_a?(Array) ? "#{product[0]}@#{product[1]}" : product
end

package = JSON.parse($stdin.read)
package_targets = package.fetch("targets").to_h { |target| [target.fetch("name"), target] }
allow_list = YAML.safe_load(DEPENDENCY_ALLOW_LIST.read, aliases: false).fetch("targets")

owners = OWNERS_PATH.each_line.each_with_object({}) do |line, values|
  next if line.start_with?("#") || line.strip.empty?

  fields = line.chomp.split("\t", -1)
  fail_check("module-owner row width differs") unless fields.length == 5
  name, type, state, dependencies, prohibited_classes = fields
  fail_check("duplicate owner #{name}") if values.key?(name)
  fail_check("#{name} has unknown type #{type}") unless %w[regular test].include?(type)
  fail_check("#{name} has unknown state #{state}") unless %w[reserved active].include?(state)
  direct = dependencies.empty? ? [] : dependencies.split(",", -1)
  classes = prohibited_classes.empty? ? [] : prohibited_classes.split(",", -1)
  fail_check("#{name} direct dependencies are not unique and sorted") unless direct == direct.uniq.sort
  fail_check("#{name} prohibited classes are not unique and sorted") unless classes == classes.uniq.sort
  fail_check("#{name} has unknown prohibited classes") unless (classes - CLASS_MODULES.keys).empty?
  values[name] = { "type" => type, "state" => state, "dependencies" => direct, "classes" => classes }
end

owners.each do |name, declaration|
  target = package_targets[name]
  source_root = ROOT.join(declaration["type"] == "test" ? "Tests" : "Sources", name)
  allow_declaration = allow_list[name]

  if declaration["state"] == "reserved"
    fail_check("reserved owner #{name} unexpectedly exists in Package.swift") if target
    fail_check("reserved owner #{name} unexpectedly exists in SPEC-002 allow-list") if allow_declaration
    fail_check("reserved owner #{name} has placeholder source") if source_root.exist?
    next
  end

  fail_check("active owner #{name} is missing from Package.swift") unless target
  fail_check("active owner #{name} is missing from SPEC-002 allow-list") unless allow_declaration
  expected_type = declaration["type"] == "test" ? "test" : "regular"
  fail_check("#{name} package type differs") unless target["type"] == expected_type
  actual_dependencies = target.fetch("dependencies", []).map { |dependency| package_dependency_name(dependency) }
  fail_check("#{name} package dependencies differ") unless actual_dependencies.sort == declaration["dependencies"]
  fail_check("#{name} SPEC-002 dependencies differ") unless allow_declaration.fetch("dependencies").sort == declaration["dependencies"]

  paths = source_root.glob("**/*.swift").sort
  fail_check("active owner #{name} has no substantive source") if paths.empty?
  source = paths.map(&:read).join("\n")
  fail_check("#{name} exports an import") if source.match?(/@_exported\s+import/)
  imports = source.scan(/^\s*(?:@(?:_implementationOnly|_spi\([^)]*\))\s+)?import\s+([A-Za-z0-9_]+)/).flatten
  forbidden_modules = declaration["classes"].flat_map { |kind| CLASS_MODULES.fetch(kind) }
  leaked = imports & forbidden_modules
  fail_check("#{name} imports prohibited modules #{leaked.uniq.sort.inspect}") unless leaked.empty?
end

downstream_consumers = DOWNSTREAM_CONSUMERS.each_line.each_with_object({}) do |line, values|
  next if line.start_with?("#") || line.strip.empty?

  fields = line.chomp.split("\t", -1)
  fail_check("downstream consumer row width differs") unless fields.length == 3
  name, dependencies, authority = fields
  fail_check("duplicate downstream consumer #{name}") if values.key?(name)
  direct = dependencies.split(",", -1)
  fail_check("#{name} downstream dependencies are not unique and sorted") unless direct == direct.uniq.sort
  fail_check("#{name} downstream authority is missing") if authority.empty?
  values[name] = direct
end

new_owner_names = owners.keys
package_targets.each do |name, target|
  next if new_owner_names.include?(name)

  dependencies = target.fetch("dependencies", []).map { |dependency| package_dependency_name(dependency) }
  leaked = dependencies & new_owner_names
  expected = downstream_consumers.fetch(name, [])
  fail_check("downstream edge set differs for #{name}") unless leaked.sort == expected
end
missing_consumers = downstream_consumers.keys - package_targets.keys
fail_check("registered downstream consumers are missing: #{missing_consumers.join(',')}") unless missing_consumers.empty?

fixture_rows = FIXTURES.join("dependency-fixtures.tsv").each_line.each_with_object([]) do |line, rows|
  next if line.start_with?("#") || line.strip.empty?

  fields = line.chomp.split("\t", -1)
  fail_check("dependency fixture row width differs") unless fields.length == 4
  rows << fields
end
fail_check("dependency fixture IDs are duplicated") unless fixture_rows.map(&:first).uniq.length == fixture_rows.length
fixture_rows.each do |fixture_id, from, to, expectation|
  fail_check("invalid dependency fixture ID #{fixture_id}") unless fixture_id.match?(/\A[a-z0-9]+(?:-[a-z0-9]+)*\z/)
  fail_check("unknown dependency expectation #{expectation}") unless %w[allow reject].include?(expectation)
  declaration = owners[from]
  actual = declaration && declaration["dependencies"].include?(to) ? "allow" : "reject"
  fail_check("dependency fixture #{fixture_id} expected #{expectation}, classified #{actual}") unless actual == expectation
end

active_count = owners.count { |_name, declaration| declaration["state"] == "active" }
puts "SPEC-014 module contract passed: #{owners.length} frozen owners, #{active_count} active, #{downstream_consumers.length} downstream consumer, and #{fixture_rows.length} graph fixtures."
