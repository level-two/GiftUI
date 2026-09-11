#!/usr/bin/env ruby
# frozen_string_literal: true

require "json"
require "open3"
require "pathname"

ROOT = Pathname.new(File.expand_path("../..", __dir__))
BOUNDARIES = ROOT.join("Tests/ContractFixtures/SPEC007/import-boundaries.tsv")

def fail_check(message)
  warn "SPEC-007 boundary check failed: #{message}"
  exit 1
end

package_json, package_error, package_status = Open3.capture3(
  "swift", "package", "dump-package", chdir: ROOT.to_s
)
fail_check("package dump failed: #{package_error}") unless package_status.success?
package = JSON.parse(package_json)
targets = package.fetch("targets").to_h { |target| [target.fetch("name"), target] }

expected_dependencies = {
  "GiftUILayout" => %w[GiftUI GiftUISemanticCore GiftUITextResources],
  "GiftUILayoutFailureAdapterFixture" => %w[GiftUIFailureCore GiftUILayout],
  "GiftUILayoutTests" => %w[
    GiftUI GiftUILayout GiftUIReferenceTextResources GiftUISemanticCore
    GiftUITextResources
  ],
  "GiftUILayoutFailureAdapterTests" => %w[
    GiftUIFailureCore GiftUILayout GiftUILayoutFailureAdapterFixture
  ],
}.freeze
expected_dependencies.each do |name, expected|
  target = targets[name]
  fail_check("missing target #{name}") unless target
  actual = target.fetch("dependencies", []).map do |dependency|
    declaration = dependency.fetch("byName", dependency.fetch("target", nil))
    declaration.is_a?(Array) ? declaration.first : declaration
  end.compact
  fail_check("#{name} dependencies differ: #{actual}") unless actual.sort == expected.sort
end

rows = BOUNDARIES.each_line.each_with_object([]) do |line, result|
  next if line.start_with?("#") || line.strip.empty?

  fields = line.chomp.split("\t", -1)
  fail_check("boundary row must have four fields") unless fields.length == 4
  result << fields
end
expected_ids = %w[
  reverse-semantic-layout layout-failure-core layout-capability layout-render
  layout-runtime layout-backend layout-platform layout-driver layout-os-rtos
  layout-hal layout-hardware portable-layout-reexport
]
fail_check("import-negative set differs") unless rows.map(&:first) == expected_ids
fail_check("import-negative IDs are duplicated") unless rows.map(&:first).uniq.length == rows.length
fail_check("every boundary must be forbidden") unless rows.all? { |row| row[3] == "forbidden" }

layout_imports = Dir[ROOT.join("Sources/GiftUILayout/**/*.swift")].flat_map do |path|
  File.readlines(path).map { |line| line[/\Aimport ([A-Za-z0-9_]+)/, 1] }.compact
end.uniq.sort
expected_layout_imports = %w[GiftUI GiftUISemanticCore GiftUITextResources]
fail_check("GiftUILayout imports differ: #{layout_imports}") unless layout_imports == expected_layout_imports

adapter_imports = Dir[ROOT.join("Sources/GiftUILayoutFailureAdapterFixture/**/*.swift")].flat_map do |path|
  File.readlines(path).map { |line| line[/\Aimport ([A-Za-z0-9_]+)/, 1] }.compact
end.uniq.sort
fail_check("layout adapter imports differ: #{adapter_imports}") unless adapter_imports == %w[GiftUIFailureCore GiftUILayout]

semantic_imports = Dir[ROOT.join("Sources/GiftUISemanticCore/**/*.swift")].flat_map do |path|
  File.readlines(path).map { |line| line[/\Aimport ([A-Za-z0-9_]+)/, 1] }.compact
end
fail_check("Semantic Core imports GiftUILayout") if semantic_imports.include?("GiftUILayout")

giftui_sources = Dir[ROOT.join("Sources/GiftUI/**/*.swift")]
giftui_text = giftui_sources.map { |path| File.read(path) }.join("\n")
fail_check("portable GiftUI imports or re-exports GiftUILayout") if giftui_text.match?(/(?:@_exported\s+)?import\s+GiftUILayout/)
fail_check("portable GiftUI contains an exported import") if giftui_text.match?(/@_exported\s+import/)

allowed_layout_consumers = %w[
  GiftUILayoutFailureAdapterFixture GiftUIRenderLowering GiftUIInteraction
  GiftUIDrawing GiftUIRuntimeDynamic GiftUIRuntimeStatic
]
consumer_violations = Dir[ROOT.join("Sources/*/**/*.swift")].map do |path|
  next unless File.read(path).match?(/^import GiftUILayout$/)

  target = Pathname.new(path).relative_path_from(ROOT).each_filename.to_a[1]
  target unless allowed_layout_consumers.include?(target)
end.compact
fail_check("unapproved GiftUILayout consumers: #{consumer_violations}") unless consumer_violations.empty?

puts "SPEC-007 boundaries passed: 4 exact targets and 12 import-negative categories."
