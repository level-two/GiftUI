#!/usr/bin/env ruby
# frozen_string_literal: true

require "pathname"
require "yaml"

ROOT = Pathname.new(File.expand_path("../..", __dir__))
SOURCES = ROOT.join("Sources")
DEPENDENCIES = ROOT.join("Tests/ContractFixtures/SPEC002/target-dependencies.yaml")

def fail_check(message)
  warn "SPEC-008 package boundary check failed: #{message}"
  exit 1
end

graph = YAML.safe_load(DEPENDENCIES.read, aliases: false).fetch("targets")
expected_edges = {
  "GiftUIRenderCore" => %w[GiftUI GiftUITextResources],
  "GiftUIRenderLowering" => %w[
    GiftUI GiftUILayout GiftUIRenderCore GiftUISemanticCore GiftUITextResources
  ],
}
expected_edges.each do |target, dependencies|
  actual = graph.fetch(target).fetch("dependencies")
  fail_check("#{target} dependencies differ") unless actual == dependencies
end

imports_for = lambda do |target|
  SOURCES.join(target).glob("*.swift").flat_map do |path|
    path.each_line.each_with_object([]) do |line, values|
      import = line[/\A(?:@_exported\s+)?import\s+(\w+)/, 1]
      values << import if import
    end
  end.uniq.sort
end
expected_edges.each do |target, dependencies|
  fail_check("#{target} imports differ") unless imports_for.call(target) == dependencies.sort
end

prohibited = /(?:Runtime|Execution|Failure|Capabilities|Backend|Raster|ReferenceTextResources|Platform|Driver|OS|RTOS|HAL|Hardware)/
%w[GiftUIRenderCore GiftUIRenderLowering].each do |target|
  invalid = imports_for.call(target).grep(prohibited)
  fail_check("#{target} imports prohibited owners: #{invalid.join(', ')}") unless invalid.empty?
end

joiners = SOURCES.glob("*/*.swift").select do |path|
  imports = path.each_line.each_with_object([]) do |line, values|
    import = line[/\Aimport\s+(\w+)/, 1]
    values << import if import
  end
  imports.include?("GiftUISemanticCore") && imports.include?("GiftUILayout")
end
fail_check("semantic/layout join exists outside Render Lowering") unless
  !joiners.empty? && joiners.all? { |path| path.to_s.include?("/GiftUIRenderLowering/") }

consumer_directories = SOURCES.children.select do |path|
  path.directory? && path.basename.to_s.match?(/(?:Backend|Raster|Platform|Driver)/)
end
consumer_directories.each do |directory|
  imports = directory.glob("*.swift").flat_map do |path|
    path.each_line.each_with_object([]) do |line, values|
      import = line[/\Aimport\s+(\w+)/, 1]
      values << import if import
    end
  end
  forbidden = imports & %w[GiftUISemanticCore GiftUILayout GiftUIRenderLowering]
  fail_check("#{directory.basename} imports producer authority: #{forbidden.join(', ')}") unless forbidden.empty?
end

giftui = SOURCES.join("GiftUI").glob("*.swift").map(&:read).join("\n")
fail_check("GiftUI re-exports another module") if giftui.include?("@_exported import")
fail_check("GiftUI exposes internal render SPI") if
  giftui.match?(/\b(?:RenderProducer|RenderProductionResult|RenderOperationSink|SemanticRenderView|ResolvedRenderLayoutView)\b/)

owners = {
  "Color" => "GiftUI/Color.swift",
  "BoundedText" => "GiftUI/BoundedText.swift",
  "RenderPlanHeader" => "GiftUIRenderCore/RenderValues.swift",
  "RenderOperationSink" => "GiftUIRenderCore/RenderOperationSink.swift",
  "RenderProducer" => "GiftUIRenderLowering/RenderPreflight.swift",
  "RenderLimits" => "GiftUIRenderLowering/RenderProductionValues.swift",
  "SemanticRenderView" => "GiftUISemanticCore/SemanticRenderView.swift",
  "ResolvedRenderLayoutView" => "GiftUILayout/ResolvedRenderLayoutView.swift",
}
all_sources = SOURCES.glob("*/*.swift")
owners.each do |symbol, owner|
  declarations = all_sources.select { |path| path.read.match?(/\b(?:struct|enum|protocol)\s+#{symbol}\b/) }
  fail_check("#{symbol} declaration owner differs") unless
    declarations.map { |path| path.relative_path_from(SOURCES).to_s } == [owner]
end

puts "SPEC-008 package boundaries passed: exact Render Core/Lowering edges, sole semantic-layout join, symbol ownership, backend isolation, and no GiftUI SPI re-export."
