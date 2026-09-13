#!/usr/bin/env ruby
# frozen_string_literal: true

require "pathname"
require "yaml"

ROOT = Pathname.new(File.expand_path("../..", __dir__))
SOURCES = ROOT.join("Sources")
DEPENDENCIES = ROOT.join("Tests/ContractFixtures/SPEC002/target-dependencies.yaml")

def fail_check(message)
  warn "SPEC-012 module contract check failed: #{message}"
  exit 1
end

expected_edges = {
  "GiftUIDrawing" => %w[
    GiftUI GiftUIExecution GiftUILayout GiftUIRenderCore GiftUIRenderLowering
    GiftUISemanticCore GiftUITextResources
  ],
  "GiftUIRenderCore" => %w[GiftUI GiftUITextResources],
}
graph = YAML.safe_load(DEPENDENCIES.read, aliases: false).fetch("targets")
expected_edges.each do |target, dependencies|
  actual = graph.fetch(target).fetch("dependencies")
  fail_check("#{target} dependencies differ") unless actual == dependencies
end

imports_for = lambda do |target|
  SOURCES.join(target).glob("*.swift").flat_map do |path|
    path.each_line.each_with_object([]) do |line, values|
      imported = line[/\A(?:@_exported\s+)?import\s+(\w+)/, 1]
      values << imported if imported
    end
  end.uniq.sort
end
expected_edges.each do |target, dependencies|
  fail_check("#{target} imports differ") unless imports_for.call(target) == dependencies.sort
end
fail_check("Render Core imports GiftUIDrawing") if imports_for.call("GiftUIRenderCore").include?("GiftUIDrawing")

consumer_directories = SOURCES.children.select do |path|
  path.directory? && path.basename.to_s.match?(/(?:Backend|Raster|Platform|Driver)/)
end
consumer_directories.each do |directory|
  imports = directory.glob("*.swift").flat_map do |path|
    path.each_line.each_with_object([]) do |line, values|
      imported = line[/\Aimport\s+(\w+)/, 1]
      values << imported if imported
    end
  end
  fail_check("#{directory.basename} imports GiftUIDrawing") if imports.include?("GiftUIDrawing")
end

owners = {
  "Canvas" => "GiftUI/Canvas.swift",
  "SubpathRange" => "GiftUIRenderCore/DrawingOperationSink.swift",
  "StraightLineStrokeHeader" => "GiftUIRenderCore/DrawingOperationSink.swift",
  "StraightLineStrokeView" => "GiftUIRenderCore/DrawingOperationSink.swift",
  "DrawingOperationSink" => "GiftUIRenderCore/DrawingOperationSink.swift",
  "DrawingPlanSummary" => "GiftUIDrawing/DrawingValues.swift",
  "DrawingPlanView" => "GiftUIDrawing/DrawingPlan.swift",
  "DrawingPlanWorkspace" => "GiftUIDrawing/DrawingPlan.swift",
  "DrawingPlanConstructionWorkspace" => "GiftUIDrawing/DrawingPlan.swift",
  "CanvasPlanProducer" => "GiftUIDrawing/CanvasPlanProducer.swift",
  "CanvasRenderProducer" => "GiftUIDrawing/CanvasRenderProducer.swift",
  "CanvasInvocationSource" => "GiftUIDrawing/CanvasInvocationSource.swift",
  "LivePathStorage" => "GiftUIDrawing/PathConstruction.swift",
  "LivePathBuilder" => "GiftUIDrawing/PathConstruction.swift",
  "DrawingPlanMutationStorage" => "GiftUIDrawing/StrokeSnapshot.swift",
  "StrokeSnapshotProducer" => "GiftUIDrawing/StrokeSnapshot.swift",
  "DrawingLimits" => "GiftUIDrawing/DrawingLimits.swift",
  "StaticCanvasLimits" => "GiftUIDrawing/DrawingLimits.swift",
  "StaticCanvasCallableTable" => "GiftUIDrawing/StaticCanvasCallableTable.swift",
  "DrawingProductionError" => "GiftUIDrawing/DrawingValues.swift",
  "DrawingPlanResult" => "GiftUIDrawing/DrawingValues.swift",
  "RenderExtensionVisit" => "GiftUIRenderLowering/RenderExtensions.swift",
  "RenderExtensionVisitResult" => "GiftUIRenderLowering/RenderExtensions.swift",
  "RenderExtensionCompletionResult" => "GiftUIRenderLowering/RenderExtensions.swift",
  "RenderPreflightExtension" => "GiftUIRenderLowering/RenderExtensions.swift",
  "RenderStreamingExtension" => "GiftUIRenderLowering/RenderExtensions.swift",
}
all_sources = SOURCES.glob("*/*.swift")
owners.each do |symbol, owner|
  declarations = all_sources.select do |path|
    path.read.match?(/\b(?:struct|enum|protocol)\s+#{symbol}\b/)
  end
  actual = declarations.map { |path| path.relative_path_from(SOURCES).to_s }
  fail_check("#{symbol} declaration owner differs: #{actual}") unless actual == [owner]
end

source = all_sources.map(&:read).join("\n")
fail_check("Canvas-specific visitor category exists") if source.match?(/\bvisitCanvas\b/)
fail_check("second Canvas identity type exists") if source.match?(/\b(?:struct|enum|class|protocol)\s+CanvasIdentity\b/)
fail_check("second Canvas semantic graph exists") if source.match?(/\b(?:struct|enum|class|protocol)\s+(?:CanvasSemanticGraph|CanvasNode)\b/)

canvas_render_source = SOURCES.join("GiftUIDrawing/CanvasRenderProducer.swift").read
render_preflight_source = SOURCES.join("GiftUIRenderLowering/RenderPreflight.swift").read
render_producer_source = SOURCES.join("GiftUIRenderLowering/RenderProducer.swift").read
render_streaming_source = SOURCES.join("GiftUIRenderLowering/RenderStreaming.swift").read
fail_check("Canvas producer independently recurses semantic state") if
  canvas_render_source.match?(/semantic\.(?:rootIdentity|child|childCount|scope|semanticIdentity|semanticOrdinal)/)
fail_check("Canvas producer forks ordinary fill lowering") if canvas_render_source.include?("fillRect(")
fail_check("Canvas producer forks ordinary glyph lowering") if
  canvas_render_source.match?(/(?:beginPositionedGlyphs|positionedGlyph|endPositionedGlyphs)\(/)
fail_check("Canvas producer retains a complete operation list") if
  canvas_render_source.match?(/\.(?:append|insert)\(/)
fail_check("Canvas producer does not delegate preflight exactly once") unless
  canvas_render_source.scan("RenderProducer.preflight(").length == 1
fail_check("Canvas producer does not delegate production exactly once") unless
  canvas_render_source.scan("RenderProducer.produce(").length == 1
fail_check("ordinary and extended preflight do not share one traversal") unless
  render_preflight_source.scan("preflightTraversal(").length +
    render_producer_source.scan("preflightTraversal(").length == 3
fail_check("ordinary and extended streaming do not share one traversal") unless
  render_streaming_source.scan("static func stream<").length == 2

stroke_emission_owners = all_sources.select do |path|
  next false if path == SOURCES.join("GiftUIRenderCore/DrawingOperationSink.swift")

  path.read.include?(".straightLineStroke(")
end.map { |path| path.relative_path_from(SOURCES).to_s }
fail_check("combined stroke emission owner differs: #{stroke_emission_owners}") unless
  stroke_emission_owners == ["GiftUIDrawing/CanvasRenderProducer.swift"]

bridge_references = (all_sources + ROOT.join("Tests").glob("*/*.swift")).select do |path|
  path.read.include?("_giftUIInvokeCanvas")
end.map { |path| path.relative_path_from(ROOT).to_s }
allowed_bridge_references = %w[
  Sources/GiftUI/Canvas.swift
  Sources/GiftUIRuntimeDynamic/DynamicCanvasCallableStorage.swift
  Tests/GiftUIDrawingTests/CanvasInvocationAdapterTests.swift
]
fail_check("Canvas invocation bridge references differ: #{bridge_references}") unless
  bridge_references.sort == allowed_bridge_references.sort

if ARGV.length == 2
  render_interface = Pathname.new(ARGV[0]).read
  drawing_interface = Pathname.new(ARGV[1]).read
  fail_check("Render Core interface imports GiftUIDrawing") if render_interface.match?(/^import GiftUIDrawing$/)
  fail_check("borrowed stroke operation is absent from interface") unless
    render_interface.include?(
      "mutating func straightLineStroke<Stroke>(_ stroke: borrowing Stroke) -> Swift.Bool where Stroke : GiftUIRenderCore.StraightLineStrokeView"
    )
  %w[SubpathRange StraightLineStrokeHeader StraightLineStrokeView DrawingOperationSink].each do |name|
    fail_check("Render Core interface lacks #{name}") unless render_interface.include?(name)
  end
  %w[
    DrawingLimits DrawingPlanResult DrawingPlanSummary DrawingProductionError
    StaticCanvasLimits
  ].each do |name|
    fail_check("Drawing interface lacks #{name}") unless drawing_interface.include?(name)
  end
  fail_check("Render Core interface lacks exact stroke-header initializer") unless
    render_interface.include?(
      "package init(color: GiftUI.Color, lineWidth: GiftUI.GeometryScalar, lineCap: GiftUI.LineCap, lineJoin: GiftUI.LineJoin, surfaceOrigin: GiftUI.Point, inheritedClip: GiftUI.Rect, pointCount: Swift.UInt16, subpathCount: Swift.UInt16)"
    )
  fail_check("Drawing interface lacks exact plan-summary initializer") unless
    drawing_interface.include?(
      "package init(canvasOccurrenceCount: Swift.UInt16, strokeCount: Swift.UInt16, pointCount: Swift.UInt16, subpathCount: Swift.UInt16, normalizedStrokeOperationCount: Swift.UInt16)"
    )
elsif !ARGV.empty?
  fail_check("expected zero arguments or Render Core and Drawing interfaces")
end

puts "SPEC-012 module contract passed: exact imports, symbol owners, borrowed stroke interface, backend isolation, and one generic semantic identity path."
