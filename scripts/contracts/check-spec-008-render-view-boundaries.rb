#!/usr/bin/env ruby
# frozen_string_literal: true

require "json"
require "fileutils"
require "open3"
require "pathname"
require "tmpdir"

ROOT = Pathname.new(File.expand_path("../..", __dir__))

def fail_check(message)
  warn "SPEC-008 render view boundary check failed: #{message}"
  exit 1
end

semantic_path = ROOT.join("Sources/GiftUISemanticCore/SemanticRenderView.swift")
semantic_adapter_path = ROOT.join("Sources/GiftUISemanticCore/SemanticLayoutView.swift")
layout_path = ROOT.join("Sources/GiftUILayout/ResolvedRenderLayoutView.swift")
semantic = semantic_path.read
semantic_adapter = semantic_adapter_path.read
layout = layout_path.read

semantic_imports = Dir[ROOT.join("Sources/GiftUISemanticCore/**/*.swift")].flat_map do |path|
  File.readlines(path).map { |line| line[/\Aimport ([A-Za-z0-9_]+)/, 1] }.compact
end.uniq.sort
fail_check("Semantic Core imports differ: #{semantic_imports}") unless semantic_imports == ["GiftUI"]

render_core_imports = Dir[ROOT.join("Sources/GiftUIRenderCore/**/*.swift")].flat_map do |path|
  File.readlines(path).map { |line| line[/\Aimport ([A-Za-z0-9_]+)/, 1] }.compact
end.uniq.sort
expected_render_core_imports = %w[GiftUI GiftUITextResources]
unless render_core_imports == expected_render_core_imports
  fail_check("Render Core imports differ: #{render_core_imports}")
end

fail_check("Semantic render result adapter does not forward its authoritative view") unless semantic_adapter.include?(
  "var renderView: Storage.RenderView {\n        storage.renderView\n    }"
)
fail_check("resolved layout adapter does not forward its authoritative view") unless layout.include?(
  "package var renderView: Storage.RenderView {\n        storage.renderView\n    }"
)

semantic_adapter_body = semantic_adapter[/package extension SemanticLayoutResultSink where Storage: SemanticRenderResultStorage \{(.*?)\n\}/m, 1]
layout_adapter_body = layout[/package struct ResolvedRenderLayoutResultSink<Storage>:(.*?)\n\}/m, 1]
fail_check("Semantic render adapter body is missing") unless semantic_adapter_body
fail_check("resolved layout adapter body is missing") unless layout_adapter_body
adapter_sources = [semantic_adapter_body, layout_adapter_body].join("\n")
forbidden_storage = /(?:\bArray\b|\bDictionary\b|\bSet\b|\bContiguousArray\b|\[\s*[^\]]+\s*\])/
fail_check("render view adapter materializes collection storage") if adapter_sources.match?(forbidden_storage)
fail_check("render view adapter owns a reference type") if adapter_sources.match?(/^\s*(?:package\s+)?(?:final\s+)?class\s+/)

layout_authority = /\b(?:measure|proposal|placement|layoutAlgorithm|shape|fallback)\b/i
render_core_sources = Dir[ROOT.join("Sources/GiftUIRenderCore/**/*.swift")].map { |path| File.read(path) }.join("\n")
fail_check("Render Core contains layout authority") if render_core_sources.match?(layout_authority)

render_authority = /\b(?:RenderOperationSink|RenderProducer|FillRectOperation|PositionedGlyphOperationHeader)\b/
layout_sources = Dir[ROOT.join("Sources/GiftUILayout/**/*.swift")].map { |path| File.read(path) }.join("\n")
fail_check("Layout contains normalized rendering authority") if layout_sources.match?(render_authority)

cache_root = Dir.mktmpdir("giftui-spec008-render-view-boundary-")
package_json, package_error, package_status = Open3.capture3(
  {
    "CLANG_MODULE_CACHE_PATH" => File.join(cache_root, "clang-cache"),
    "SWIFTPM_MODULECACHE_OVERRIDE" => File.join(cache_root, "swiftpm-cache"),
  },
  "swift", "package", "--disable-sandbox", "dump-package", chdir: ROOT.to_s
)
FileUtils.remove_entry(cache_root)
fail_check("package dump failed: #{package_error}") unless package_status.success?
targets = JSON.parse(package_json).fetch("targets").to_h { |target| [target.fetch("name"), target] }
dependencies = targets.transform_values do |target|
  target.fetch("dependencies", []).map do |dependency|
    declaration = dependency.fetch("byName", dependency.fetch("target", nil))
    declaration.is_a?(Array) ? declaration.first : declaration
  end.compact
end

fail_check("Semantic Core dependency closure differs") unless dependencies.fetch("GiftUISemanticCore") == ["GiftUI"]
unless dependencies.fetch("GiftUILayout") == %w[GiftUI GiftUISemanticCore GiftUITextResources]
  fail_check("Layout dependency closure differs")
end
unless dependencies.fetch("GiftUIRenderCore") == %w[GiftUI GiftUITextResources]
  fail_check("Render Core dependency closure differs")
end

puts "SPEC-008 render view boundaries passed: authoritative borrowed projections share identity without materialization or authority leakage."
