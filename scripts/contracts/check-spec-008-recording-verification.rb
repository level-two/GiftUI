#!/usr/bin/env ruby
# frozen_string_literal: true

require "pathname"

ROOT = Pathname.new(File.expand_path("../..", __dir__))
TEST = ROOT.join("Tests/GiftUIRenderCoreTests/RenderRecordingVerificationTests.swift")

def fail_check(message)
  warn "SPEC-008 recording verification check failed: #{message}"
  exit 1
end

source = TEST.read
required = [
  "header.surfaceBounds == verificationSurface",
  "header.damageBounds == verificationDamage",
  "header.operationCount == 4",
  "header.positionedGlyphCount == 3",
  "header.maximumObservedClipDepth == 5",
  "fill.bounds == verificationFillBounds",
  "fill.clip == verificationClip",
  "fill.color.red == 11",
  "fill.color.green == 22",
  "fill.color.blue == 33",
  "group.instance.resource == verificationResource",
  "group.instance.instanceIndex == 7",
  "group.glyphCount == 2",
  "firstGlyph.glyph == GlyphID(rawValue: 101)",
  "firstGlyph.baseline == Point(x: 8, y: 19)",
  "secondFill.bounds == verificationSurface",
  "secondGroup.instance == verificationInstance",
  "thirdGlyph.glyph == GlyphID(rawValue: 103)",
  "operationCount == header.operationCount",
  "positionedGlyphCount == header.positionedGlyphCount",
]
required.each do |fragment|
  fail_check("field verification lacks #{fragment}") unless source.include?(fragment)
end

forbidden = /\b(?:MemoryLayout|Unsafe|hashValue|ObjectIdentifier|String\(reflecting:)\b/
fail_check("verification uses representation or identity shortcuts") if source.match?(forbidden)

puts "SPEC-008 recording verification passed: typed fields, counts, groups, order."
