#!/usr/bin/env ruby
# frozen_string_literal: true

require "pathname"

ROOT = Pathname.new(File.expand_path("../..", __dir__))
SOURCE = ROOT.join("Sources/GiftUIRenderLowering/RenderStreaming.swift").read
TEST = ROOT.join("Tests/GiftUIRenderLoweringTests/RenderPreflightTests.swift").read

def fail_check(message)
  warn "SPEC-008 painter-order check failed: #{message}"
  exit 1
end

fail_check("streaming must walk canonical child indices in ascending order") unless
  SOURCE.include?("var childIndex: UInt16 = 0") &&
    SOURCE.include?("semantic.child(of: identity, at: childIndex)") &&
    SOURCE.include?("childIndex += 1")
fail_check("streaming introduces forbidden painter reordering") if
  SOURCE.match?(/\.sort(?:ed)?\b|\bbatch\b|\bcoalesc|overdraw/)
fail_check("glyph streaming must use occurrence-wide indices") unless
  SOURCE.include?("var glyphIndex: UInt16 = 0") &&
    SOURCE.include?("glyph.glyphIndex == glyphIndex") &&
    SOURCE.include?("glyphIndex = nextGlyphIndex.partialValue")
fail_check("glyph groups must be opened and closed per non-empty line") unless
  SOURCE.include?("line.glyphCount > 0") &&
    SOURCE.include?("sink.beginPositionedGlyphs(") &&
    SOURCE.include?("sink.endPositionedGlyphs()")
fail_check("focused painter-order golden is missing") unless
  TEST.include?(
    "sourceOrderChildrenPaintBackToFrontWithoutOpaqueEliminationAndLinesStayGrouped"
  )

puts "SPEC-008 painter order passed: source-order children and whole occurrence-indexed glyph groups."
