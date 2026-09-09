#!/usr/bin/env ruby
# frozen_string_literal: true

ROOT = File.expand_path("../..", __dir__)
VALUES = File.join(ROOT, "Sources/GiftUILayout/LayoutValues.swift")
ERRORS = File.join(ROOT, "Sources/GiftUILayout/LayoutError.swift")

def fail_check(message)
  warn "SPEC-007 value check failed: #{message}"
  exit 1
end

values = File.read(VALUES)
errors = File.read(ERRORS)
source = values + "\n" + errors

required = [
  "package struct LayoutLimits: Equatable, Sendable",
  "package struct LayoutSummary: Equatable, Sendable",
  "package enum LayoutError: UInt8, Equatable, Sendable",
  "package enum LayoutResult: Equatable, Sendable",
]
required.each do |declaration|
  fail_check("missing exact declaration #{declaration}") unless source.include?(declaration)
end

%w[
  maximumScopes maximumDepth maximumTextScalars maximumTextLines
  maximumPositionedGlyphs scopeCount textScalarCount textLineCount
  positionedGlyphCount maximumObservedDepth rootBounds
].each do |field|
  fail_check("missing field #{field}") unless values.include?(field)
end

prohibited = {
  "class declaration" => /\bclass\b/,
  "existential" => /\bany\s+[A-Za-z_]/,
  "string storage" => /\b(?:String|StaticString)\b/,
  "closure" => /->/,
  "array" => /\bArray\s*</,
  "dictionary" => /\bDictionary\s*</,
  "set" => /\bSet\s*</,
}
prohibited.each do |label, pattern|
  fail_check("#{label} appears in bounded values") if source.match?(pattern)
end

puts "SPEC-007 values passed: exact closed values and bounded storage surface."
