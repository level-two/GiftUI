#!/usr/bin/env ruby
# frozen_string_literal: true

require "pathname"

ROOT = Pathname.new(File.expand_path("../..", __dir__))
SOURCE = ROOT.join(
  "Sources/GiftUIBackendIntegration/RasterTextResourceValidation.swift"
)

def fail_check(message)
  warn "SPEC-014 text-resource check failed: #{message}"
  exit 1
end

fail_check("text-resource validator is missing") unless SOURCE.file?
source = SOURCE.read
%w[
  prevalidation
  expectedDescriptor
  selectedRealization
  isPayloadAvailable
  greatestGlyphRasterBytes
  admitsGlyphRasterBytes
  admitsStrokeWorkspaceBytes
].each do |fragment|
  fail_check("text-resource validator lacks #{fragment}") unless source.include?(fragment)
end

{
  "fallback coalescing" => /\?\?/,
  "scalar remapping" => /mapScalar/,
  "replacement glyph substitution" => /replacementGlyph/,
  "ambient lookup" => /Foundation|Bundle|FileManager|ProcessInfo/,
  "realization search" => /while\s+[^\{]*realization/,
}.each do |description, pattern|
  fail_check("text-resource validator contains #{description}") if source.match?(pattern)
end

exact_lookup = /raster\.realization\(at: selectedRealization\.id\.rawValue\)/
fail_check("selected realization lookup is not identity-exact") unless source.match?(exact_lookup)
exact_record = /realization: selectedRealization\.id/
fail_check("glyph record lookup is not identity-exact") unless source.match?(exact_record)

puts "SPEC-014 text-resource check passed: exact identity, bounded records, and no fallback."
