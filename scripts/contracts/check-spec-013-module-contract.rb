#!/usr/bin/env ruby
# frozen_string_literal: true

require "json"
require "pathname"

ROOT = Pathname.new(File.expand_path("../..", __dir__))
BOUNDARIES = ROOT.join("Tests/ContractFixtures/SPEC013/module-boundaries.tsv")
OWNERS = %w[
  GiftUIRuntimeCore GiftUIRuntimeDynamic GiftUIRuntimeStatic
  GiftUIRuntimeFailureAdapterFixture GiftUIDynamicConveniences
].freeze

def fail_check(message)
  warn "SPEC-013 module contract check failed: #{message}"
  exit 1
end

package = JSON.parse($stdin.read)
targets = package.fetch("targets").to_h { |target| [target.fetch("name"), target] }
rows = BOUNDARIES.each_line.each_with_object([]) do |line, values|
  next if line.start_with?("#") || line.strip.empty?

  fields = line.chomp.split("\t", -1)
  fail_check("module-boundary row width differs") unless fields.length == 3
  values << fields
end
fail_check("module-boundary rows are duplicated") unless rows.uniq.length == rows.length
fail_check("unknown boundary disposition") unless rows.all? { |row| %w[allowed forbidden].include?(row[2]) }

package_names = targets.keys
OWNERS.each do |owner|
  target = targets[owner] || fail_check("target is missing: #{owner}")
  dependencies = target.fetch("dependencies", []).map do |dependency|
    declaration = dependency.fetch("target", dependency["byName"])
    declaration.is_a?(Array) ? declaration.first : declaration
  end
  expected = rows.select { |row| row[0] == owner && row[2] == "allowed" }.map { |row| row[1] }
  fail_check("#{owner} direct dependencies differ") unless dependencies.sort == expected.sort

  source_root = ROOT.join("Sources", owner)
  paths = source_root.glob("**/*.swift").sort
  fail_check("#{owner} has no source") if paths.empty?
  source = paths.map(&:read).join("\n")
  fail_check("#{owner} exports an import") if source.match?(/@_exported\s+import/)
  imports = source.scan(/^\s*(?:@(?:_implementationOnly|_spi\([^)]*\))\s+)?import\s+([A-Za-z0-9_]+)/).flatten
  package_imports = imports & package_names
  fail_check("#{owner} source imports differ") unless package_imports.sort == expected.sort

  forbidden = rows.select { |row| row[0] == owner && row[2] == "forbidden" }.map { |row| row[1] }
  leaked = (dependencies + imports) & forbidden
  fail_check("#{owner} contains forbidden edges #{leaked.sort.inspect}") unless leaked.empty?
end

giftui = targets["GiftUI"] || fail_check("GiftUI target is missing")
giftui_dependencies = giftui.fetch("dependencies", []).map do |dependency|
  declaration = dependency.fetch("target", dependency["byName"])
  declaration.is_a?(Array) ? declaration.first : declaration
end
runtime_names = %w[GiftUIRuntimeCore GiftUIRuntimeDynamic GiftUIRuntimeStatic]
fail_check("GiftUI depends on a runtime profile") unless (giftui_dependencies & runtime_names).empty?
giftui_source = ROOT.join("Sources/GiftUI").glob("**/*.swift").map(&:read).join("\n")
fail_check("GiftUI references a runtime profile") if runtime_names.any? { |name| giftui_source.include?(name) }

puts "SPEC-013 module contract passed: 5 owner targets have exact imports and no sibling, reverse, failure, backend, platform, driver, or host edge."
