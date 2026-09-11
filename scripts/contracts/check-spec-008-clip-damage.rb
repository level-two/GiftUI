#!/usr/bin/env ruby
# frozen_string_literal: true

require "pathname"

ROOT = Pathname.new(File.expand_path("../..", __dir__))
PREFLIGHT = ROOT.join("Sources/GiftUIRenderLowering/RenderPreflight.swift").read
STREAMING = ROOT.join("Sources/GiftUIRenderLowering/RenderStreaming.swift").read
TEST = ROOT.join("Tests/GiftUIRenderLoweringTests/RenderPreflightTests.swift").read

def fail_check(message)
  warn "SPEC-008 clip/damage check failed: #{message}"
  exit 1
end

fail_check("nonzero surface origin is not rejected as invalid input") unless
  PREFLIGHT.include?("guard surfaceBounds.origin == Point(x: 0, y: 0)") &&
    PREFLIGHT.include?("return .failure(.invalidInput)")
fail_check("root-intersection damage is missing") unless
  PREFLIGHT.include?("LayoutGeometry.intersection(") &&
    PREFLIGHT.include?("layout.rootBounds")
fail_check("complete-surface damage is missing") unless
  PREFLIGHT.include?("case .initializeCompleteSurface:") &&
    PREFLIGHT.include?("damageBounds = surfaceBounds")
fail_check("streaming must preserve unclipped fill bounds") unless
  STREAMING.include?("bounds: bounds") && STREAMING.include?("clip: finalClip")
fail_check("streaming contains frame-history state") if
  STREAMING.match?(/\b(?:firstFrame|previousFrame|priorFrame|frameHistory)\b/)

%w[
  backgroundKeepsUnclippedBoundsAndOmitsOnlyAnEmptyFinalClip
  damageModeIsExplicitAndRetainsNoFirstFrameHistory
].each do |name|
  fail_check("focused tests lack #{name}") unless TEST.include?(name)
end

puts "SPEC-008 clip/damage passed: checked final clips, unclamped bounds, and explicit stateless damage."
