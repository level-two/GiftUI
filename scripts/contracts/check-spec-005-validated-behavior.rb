#!/usr/bin/env ruby
# frozen_string_literal: true

def fail_check(message)
  warn "SPEC-005 validated-behavior check failed: #{message}"
  exit 1
end

tests = File.read(ARGV.fetch(0) { fail_check("expected test source path") })

required = [
  "testGoldenBaselineMetricsAndExplicitPoints",
  "FontLineMetrics(ascent: 12, descent: 3, lineGap: 2)",
  "Point(x: 20, y: 30)",
  "Point(x: 18, y: 21)",
  "Point(x: 31, y: 30)",
  "testGoldenMappingsAndExplicitLineBreaks",
  ".glyph(.exact(GlyphID(rawValue: 0)))",
  ".glyph(.replacement(GlyphID(rawValue: 0)))",
  "testExpectedNilAndUnexpectedPostValidationNilStayDistinct",
  ".explicitLineBreak",
  ".invalidPrevalidatedInput",
  ".unexpectedPostValidationLookupFailure",
  "testEveryConsumerGeometryOverflowSiteReturnsNil",
  "offsetXOverflow.checkedInkRectangle",
  "offsetYOverflow.checkedInkRectangle",
  "rightEdgeOverflow.checkedInkRectangle",
  "bottomEdgeOverflow.checkedInkRectangle",
  "advanceOverflow.checkedAdvancedOrigin",
].freeze

required.each do |fragment|
  fail_check("missing #{fragment}") unless tests.include?(fragment)
end

puts "SPEC-005 validated-behavior check passed: geometry, mapping, break, lookup, and overflow goldens are present."
