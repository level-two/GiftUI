#!/usr/bin/env ruby
# frozen_string_literal: true

require "pathname"

ROOT = Pathname.new(File.expand_path("../..", __dir__))
PATH = ROOT.join(
  "Sources/GiftUIBackendIntegration/RasterBackendStartupValidator.swift"
)

def fail_check(message)
  warn "SPEC-014 startup validator check failed: #{message}"
  exit 1
end

fail_check("startup validator is missing") unless PATH.file?
source = PATH.read
imports = source.scan(/^import\s+([A-Za-z0-9_]+)/).flatten
expected_imports = %w[
  GiftUICapabilities GiftUIRasterCore GiftUISurfaceCore GiftUITextResources
]
fail_check("startup validator imports differ: #{imports.inspect}") unless imports == expected_imports

{
  "capability resolver" => /RasterPresentationResolver/,
  "concrete display target" => /\bDisplayTarget\b/,
  "reservation call" => /\breserveFrame\s*\(/,
  "writer call" => /\bwithWriter\s*\(/,
  "health input" => /\bhealth\s*\(/,
  "capability mutation" => /inout\s+EffectiveRasterPresentation/,
  "clamping" => /\b(?:min|max)\s*\(/,
}.each do |description, pattern|
  fail_check("startup validator contains #{description}") if source.match?(pattern)
end

ordered_fragments = [
  "guard let descriptor",
  "matchesEffectivePresentation(",
  "guard resourceValidation == .valid",
  "effectivePresentation.operations",
  "surfaceWritableCapacityBytes\n                ==",
  "guard payloadLimits.admitsGlyphRasterBytes",
  "guard payloadLimits.admitsTileVisits",
]
positions = ordered_fragments.map do |fragment|
  source.index(fragment) || fail_check("missing detection stage: #{fragment}")
end
fail_check("startup detection order differs") unless positions == positions.sort

puts "SPEC-014 startup validator check passed: exact stage order and no forbidden authority."
