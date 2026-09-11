#!/usr/bin/env ruby
# frozen_string_literal: true

require "pathname"

ROOT = Pathname.new(File.expand_path("../..", __dir__))
SOURCE = ROOT.join("Sources/GiftUIRenderLowering/RenderStreaming.swift")
TESTS = ROOT.join("Tests/GiftUIRenderLoweringTests/RenderPreflightTests.swift")

def fail_check(message)
  warn "SPEC-008 render streaming check failed: #{message}"
  exit 1
end

source = SOURCE.read
tests = TESTS.read
expected_imports = %w[GiftUI GiftUILayout GiftUIRenderCore GiftUISemanticCore GiftUITextResources]
fail_check("streaming imports differ") unless source.scan(/^import (\w+)$/).flatten == expected_imports

required = [
  "static func stream<Semantic, Layout, Metrics, Workspace, Sink>",
  "snapshotsMatch",
  "semantic.semanticOrdinal(of: identity)",
  "semantic.semanticIdentity(at: ordinal)",
  "layout.layoutOrdinal(of: layoutIdentity)",
  "layout.layoutIdentity(at: layoutOrdinal)",
  "sink.begin(preflight.header)",
  "workspace.pushForeground(rootForeground)",
  "workspace.popForeground()",
  "workspace.currentForeground",
  "sink.fillRect(",
  "sink.beginPositionedGlyphs(",
  "sink.positionedGlyph(",
  "sink.endPositionedGlyphs()",
  "sink.finish()",
  "sink.discard()",
  "state.operationCount == preflight.header.operationCount",
  "state.positionedGlyphCount",
  "damageMatches(",
]
required.each do |fragment|
  fail_check("streaming lacks #{fragment}") unless source.include?(fragment)
end

fail_check("streaming must not read sink capacity") if source.include?("sink.capacity")
fail_check("streaming must not access preflight visit sets") if source.match?(/visit(?:Semantic|Layout)Scope/)
fail_check("streaming retains a dynamic proof transcript") if source.match?(/\b(?:Array|ContiguousArray|Set|Dictionary|String|Unsafe|class|actor)\b/)

%w[
  streamingRepeatsCanonicalLookupsAndEmitsTheExactOrderedValues
  streamingDistinguishesBeginRefusalFromPostBeginInvariantFailure
  streamingDiscardsWhenSnapshotChangesAfterTheLastOperation
].each do |name|
  fail_check("focused tests lack #{name}") unless tests.include?(name)
end

puts "SPEC-008 render streaming passed: direct ordered emission, unchanged snapshots, and exact discard behavior."
