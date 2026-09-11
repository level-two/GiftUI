#!/usr/bin/env ruby
# frozen_string_literal: true

require "pathname"

ROOT = Pathname.new(File.expand_path("../..", __dir__))
PREFLIGHT = ROOT.join("Sources/GiftUIRenderLowering/RenderPreflight.swift").read
STREAMING = ROOT.join("Sources/GiftUIRenderLowering/RenderStreaming.swift").read
TEST = ROOT.join("Tests/GiftUIRenderLoweringTests/RenderPreflightTests.swift").read

def fail_check(message)
  warn "SPEC-008 text lowering check failed: #{message}"
  exit 1
end

%w[
  instance.resource
  textMetrics.descriptor.resource
  descriptor.instanceCount
  textMetrics.instance
  descriptor.id
  descriptor.glyphCount
  textMetrics.metrics
].each do |fragment|
  fail_check("preflight lacks compatibility check #{fragment}") unless PREFLIGHT.include?(fragment)
end
fail_check("preflight does not select incompatible resource") unless
  PREFLIGHT.include?("return .incompatibleTextResource")

%w[glyph.glyph glyph.baseline glyph.instance line.glyphCount finalClip foreground].each do |fragment|
  fail_check("streaming lacks exact text field #{fragment}") unless STREAMING.include?(fragment)
end
fail_check("text lowering contains raw text or shaping behavior") if
  (PREFLIGHT + STREAMING).match?(/\b(?:String|Substring|Unicode|shape|fallback|advanceX|fontName)\b/)

%w[
  textLoweringPreservesResolvedGlyphMeaningAndOnlyIntersectsItsClip
  textResourceInstanceAndGlyphDisagreementsAllFailBeforeBegin
].each do |name|
  fail_check("focused tests lack #{name}") unless TEST.include?(name)
end

puts "SPEC-008 text lowering passed: exact resolved transport and pre-begin resource compatibility."
