#!/usr/bin/env ruby
# frozen_string_literal: true

require "open3"
require "pathname"

ROOT = Pathname.new(File.expand_path("../..", __dir__))
INVENTORY = ROOT.join("Tests/ContractFixtures/SPEC007/migration-inventory.tsv")
POC_REVISION = "d5d6330432caa7c983d8dba35cf9f23c3800860b"

def fail_check(message)
  warn "SPEC-007 migration check failed: #{message}"
  exit 1
end

actual_revision, revision_error, revision_status = Open3.capture3(
  "git", "-C", ROOT.to_s, "rev-parse", "PoC^{}"
)
fail_check(revision_error) unless revision_status.success?
fail_check("PoC tag changed") unless actual_revision.chomp == POC_REVISION

rows = INVENTORY.each_line.each_with_object([]) do |line, result|
  next if line.start_with?("#") || line.strip.empty?

  fields = line.chomp.split("\t", -1)
  fail_check("inventory row must have six fields") unless fields.length == 6
  result << fields
end
fail_check("inventory is empty") if rows.empty?
keys = rows.map { |family, baseline, path, _count, _disposition, _owner| [family, baseline, path] }
fail_check("inventory keys are duplicated") unless keys.uniq.length == keys.length

required_families = %w[
  recursive-measurement host-width-geometry retained-layout-graph
  backend-text-measurement font-fallback runtime-layout-entrypoint
  legacy-stack-api floating-geometry legacy-zstack-spacer-padding-frame
  parallel-layout-path
]
fail_check("inventory family coverage differs") unless rows.map(&:first).uniq.sort == required_families.sort
allowed_dispositions = %w[replace retire already-absent]
rows.each do |family, baseline, path, count, disposition, owner|
  fail_check("invalid baseline for #{family}/#{path}") unless %w[PoC PoC-and-current].include?(baseline)
  fail_check("invalid count for #{family}/#{path}") unless count.match?(/\A(?:0|[1-9][0-9]*)\z/)
  fail_check("invalid disposition for #{family}/#{path}") unless allowed_dispositions.include?(disposition)
  fail_check("missing owner for #{family}/#{path}") if owner.empty?

  if baseline == "PoC"
    _output, error, status = Open3.capture3(
      "git", "-C", ROOT.to_s, "cat-file", "-e", "PoC:#{path}"
    )
    fail_check("missing PoC path #{path}: #{error}") unless status.success?
  else
    valid_absence = path == "historical-and-current-maintained-source" &&
      count == "0" && disposition == "already-absent"
    fail_check("invalid absence row") unless valid_absence
  end
end

queries = {
  "recursive-measurement" => [
    "func (measure|measureGroup|measureVerticalStack|measureHorizontalStack|measureButton|measureVStack|measureHStack)",
    %w[Sources/GiftUIRuntimeDynamic/ViewNode.swift Sources/GiftUIRuntimeStatic/StaticRuntime.swift]
  ],
  "host-width-geometry" => [
    "Int",
    %w[Sources/GiftUI/Containers/HStack.swift Sources/GiftUI/Containers/VStack.swift Sources/GiftUI/Layout/LayoutArithmetic.swift]
  ],
  "retained-layout-graph" => [
    "(class ViewNode|struct LayoutNode|struct StaticNode|children: \\[LayoutNode\\]|children: \\[ViewNode\\]|StaticNodeStorage)",
    %w[Sources/GiftUIRuntimeDynamic/ViewNode.swift Sources/GiftUIRuntimeDynamic/LayoutNode.swift Sources/GiftUIRuntimeStatic/StaticRuntime.swift]
  ],
  "backend-text-measurement" => [
    "BuiltinFont8x12\\.(glyph|cellWidth)",
    %w[Sources/GiftUIBackendFramebuffer/BitmapTextRasterizer.swift Sources/GiftUIBackendRGB565/RGB565RetainedRenderer.swift Sources/GiftUIBackendRGB565/RGB565TileRenderer.swift]
  ],
  "font-fallback" => [
    "glyph\\(forCodePoint:",
    %w[Sources/GiftUIBackendFramebuffer/BitmapTextRasterizer.swift Sources/GiftUIBackendRGB565/RGB565RetainedRenderer.swift Sources/GiftUIBackendRGB565/RGB565TileRenderer.swift]
  ],
  "runtime-layout-entrypoint" => [
    "func (layout|layoutSnapshot|layoutResult)",
    %w[Sources/GiftUIRuntimeDynamic/DynamicRuntime.swift Sources/GiftUIRuntimeDynamic/LayoutEngine.swift Sources/GiftUIRuntimeDynamic/ViewGraph.swift Sources/GiftUIRuntimeStatic/StaticRuntime.swift]
  ],
  "legacy-stack-api" => [
    "public struct (HStack|VStack)",
    %w[Sources/GiftUI/Containers/HStack.swift Sources/GiftUI/Containers/VStack.swift]
  ],
}.freeze

queries.each do |family, (pattern, paths)|
  output, error, status = Open3.capture3(
    "git", "-C", ROOT.to_s, "grep", "-n", "-E", pattern, "PoC", "--", *paths
  )
  fail_check("#{family} PoC scan failed: #{error}") unless status.success?
  expected = Hash.new(0)
  output.each_line do |line|
    match = line.match(/\APoC:(.*?):[0-9]+:/)
    fail_check("unreadable #{family} grep row") unless match
    expected[match[1]] += 1
  end
  recorded = rows.each_with_object({}) do |(row_family, baseline, path, count, _disposition, _owner), result|
    result[path] = count.to_i if row_family == family && baseline == "PoC"
  end
  fail_check("#{family} inventory differs: expected #{expected}, got #{recorded}") unless recorded == expected
end

legacy_paths = %w[
  Sources/GiftUI/Layout/LayoutArithmetic.swift
  Sources/GiftUIRuntimeDynamic/LayoutEngine.swift
  Sources/GiftUIRuntimeDynamic/LayoutNode.swift
  Sources/GiftUIRuntimeDynamic/ViewNode.swift
]
remaining_paths = legacy_paths.select { |relative| ROOT.join(relative).exist? }
fail_check("legacy layout paths remain: #{remaining_paths}") unless remaining_paths.empty?

maintained_sources = Dir[ROOT.join("Sources/**/*.swift")].sort
layout_owner = ROOT.join("Sources/GiftUILayout").to_s + "/"
measurement_leaks = maintained_sources.select do |path|
  !path.start_with?(layout_owner) && File.read(path).match?(/\bfunc\s+measure(?:[A-Z(])/)
end
unless measurement_leaks.empty?
  relative = measurement_leaks.map { |path| Pathname.new(path).relative_path_from(ROOT).to_s }
  fail_check("measurement escaped GiftUILayout: #{relative}")
end

layout_sources = Dir[ROOT.join("Sources/GiftUILayout/**/*.swift")].sort
floating = layout_sources.select { |path| File.read(path).match?(/\b(?:Float|Double)\b/) }
unless floating.empty?
  relative = floating.map { |path| Pathname.new(path).relative_path_from(ROOT).to_s }
  fail_check("floating geometry entered GiftUILayout: #{relative}")
end

runtime_or_backend = Dir[
  ROOT.join("Sources/GiftUIRuntime*/**/*.swift"),
  ROOT.join("Sources/GiftUIBackend*/**/*.swift"),
  ROOT.join("Sources/GiftUIPlatform*/**/*.swift")
].sort
parallel_types = runtime_or_backend.select do |path|
  File.read(path).match?(/\b(?:class|struct|enum)\s+(?:LayoutNode|ViewNode|LayoutEngine)\b/)
end
unless parallel_types.empty?
  relative = parallel_types.map { |path| Pathname.new(path).relative_path_from(ROOT).to_s }
  fail_check("parallel layout graph or engine entered runtime/backend/platform: #{relative}")
end

backend_measurement = runtime_or_backend.select do |path|
  File.read(path).match?(/\b(?:CanonicalTextMetricsView|textScalarCount|glyphAdvance|measureText)\b/)
end
unless backend_measurement.empty?
  relative = backend_measurement.map { |path| Pathname.new(path).relative_path_from(ROOT).to_s }
  fail_check("backend or runtime text measurement entered maintained source: #{relative}")
end

puts "SPEC-007 migration inventory passed: #{rows.length} rows and no maintained parallel layout path."
