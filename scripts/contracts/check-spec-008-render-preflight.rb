#!/usr/bin/env ruby
# frozen_string_literal: true

require "pathname"

ROOT = Pathname.new(File.expand_path("../..", __dir__))
SOURCE = ROOT.join("Sources/GiftUIRenderLowering/RenderPreflight.swift")
TESTS = ROOT.join("Tests/GiftUIRenderLoweringTests/RenderPreflightTests.swift")

def fail_check(message)
  warn "SPEC-008 render preflight check failed: #{message}"
  exit 1
end

source = SOURCE.read
tests = TESTS.read
expected_imports = %w[GiftUI GiftUILayout GiftUIRenderCore GiftUISemanticCore GiftUITextResources]
fail_check("preflight imports differ") unless source.scan(/^import (\w+)$/).flatten == expected_imports

required = [
  "package enum RenderProducer",
  "semantic.renderSnapshotVersion",
  "layout.renderSnapshotVersion",
  "semantic.semanticOrdinal(of: identity)",
  "semantic.semanticIdentity(at: ordinal)",
  "layout.layoutOrdinal(of: layoutIdentity)",
  "layout.layoutIdentity(at: layoutOrdinal)",
  "workspace.visitSemanticScope(at: ordinal)",
  "workspace.visitLayoutScope(at: layoutOrdinal)",
  "structuralCapacity.maximumSemanticScopes",
  "structuralCapacity.maximumLayoutScopes",
  "structuralCapacity.maximumTraversalDepth",
  "structuralCapacity.maximumTextLines",
  "LayoutGeometry.intersection",
  "textMetrics.metrics(for: glyph, in: instance)",
  "maximumObservedClipDepth",
]
required.each do |fragment|
  fail_check("preflight lacks #{fragment}") unless source.include?(fragment)
end

fail_check("sink capacity must be read exactly once") unless source.scan(/sink\.capacity/).length == 1
fail_check("preflight emits or mutates sink lifecycle") if source.match?(/sink\.(?:begin|fillRect|beginPositionedGlyphs|positionedGlyph|endPositionedGlyphs|finish|discard)/)
fail_check("preflight retains a dynamic transcript") if source.match?(/\b(?:Array|ContiguousArray|Set|Dictionary|String|Unsafe|class|actor)\b/)

%w[
  preflightValidatesTheCompleteViewsAndBuildsTheExactHeaderWithoutEmission
  preflightChecksDeclaredStructuralAndSinkCapacityAtExactBoundaries
  preflightRejectsRootOrdinalSnapshotAndResourceDisagreementExactly
].each do |name|
  fail_check("focused tests lack #{name}") unless tests.include?(name)
end

puts "SPEC-008 render preflight passed: bounded ordinal validation and exact header construction without emission."
