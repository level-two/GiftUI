#!/usr/bin/env ruby
# frozen_string_literal: true

require "pathname"
require "yaml"

ROOT = Pathname.new(File.expand_path("../..", __dir__))
FIXTURE = ROOT.join("Tests/ContractFixtures/SPEC008/fixtures.yaml")
TESTS = ROOT.join("Tests/GiftUIRenderLoweringTests/RenderPreflightTests.swift")
EXPECTED_CASES = %w[
  nested-styles-and-sibling-restoration
  zstack-painter-order-and-empty-line
  partial-unclipped-background
  off-surface-and-zero-area-omission
  complete-surface-damage-with-smaller-root
].freeze
EXPECTED_TESTS = %w[
  foregroundStackUsesInnermostColorRestoresSiblingsAndOrdersNestedBackgrounds
  sourceOrderChildrenPaintBackToFrontWithoutOpaqueEliminationAndLinesStayGrouped
  backgroundKeepsUnclippedBoundsAndOmitsOnlyAnEmptyFinalClip
  offSurfaceAndZeroAreaBackgroundsAreBothOmitted
  damageModeIsExplicitAndRetainsNoFirstFrameHistory
].freeze

def fail_check(message)
  warn "SPEC-008 canonical corpus check failed: #{message}"
  exit 1
end

def identity_set(rows)
  rows.map { |row| row.fetch("identity") }.sort
end

document = YAML.safe_load(FIXTURE.read, aliases: false)
cases = document.fetch("cases")
fail_check("case names differ") unless cases.map { |row| row.fetch("name") } == EXPECTED_CASES
fail_check("damage modes are incomplete") unless cases.map { |row| row.fetch("damageMode") }.uniq.sort == %w[initialize-complete-surface root-intersection]

rectangle = lambda do |value, context|
  fail_check("#{context} rectangle fields differ") unless value.is_a?(Hash) && value.keys.sort == %w[height width x y]
  fail_check("#{context} rectangle values are not integers") unless value.values.all?(Integer)
  fail_check("#{context} rectangle has negative extent") if value.fetch("width").negative? || value.fetch("height").negative?
end

cases.each do |row|
  name = row.fetch("name")
  identities = row.fetch("identityTokens").sort
  fail_check("#{name} semantic ordinals differ") unless row.fetch("semanticOrdinals").sort == identities
  fail_check("#{name} layout ordinals differ") unless row.fetch("layoutOrdinals").sort == identities
  %w[resolvedBounds resolvedClips clipDepths traversalDepths].each do |field|
    fail_check("#{name} #{field} identity coverage differs") unless identity_set(row.fetch(field)) == identities
  end
  row.fetch("resolvedBounds").each { |entry| rectangle.call(entry.fetch("rect"), "#{name} bounds") }
  row.fetch("resolvedClips").each { |entry| rectangle.call(entry.fetch("rect"), "#{name} clip") }
  rectangle.call(row.fetch("surfaceBounds"), "#{name} surface")
  fail_check("#{name} surface origin is not zero") unless row.fetch("surfaceBounds").slice("x", "y") == {"x" => 0, "y" => 0}

  events = row.fetch("expectedRecordingEvents")
  fail_check("#{name} does not begin and finish exactly") unless events.first.fetch("event") == "begin" && events.last.fetch("event") == "finish" && events.count { |event| event.fetch("event") == "begin" } == 1 && events.count { |event| event.fetch("event") == "finish" } == 1
  header = row.fetch("expectedResult").fetch("header")
  fail_check("#{name} begin header differs") unless events.first.fetch("fields") == header
  operation_count = events.count { |event| %w[fill begin-glyphs].include?(event.fetch("event")) }
  glyph_count = events.count { |event| event.fetch("event") == "glyph" }
  fail_check("#{name} operation count differs") unless header.fetch("operationCount") == operation_count
  fail_check("#{name} glyph count differs") unless header.fetch("positionedGlyphCount") == glyph_count
  calls = row.fetch("expectedSinkCalls")
  %w[begin fill glyph finish].each do |event|
    fail_check("#{name} #{event} call count differs") unless calls.fetch(event) == events.count { |entry| entry.fetch("event") == event }
  end
  {"beginGlyphs" => "begin-glyphs", "endGlyphs" => "end-glyphs"}.each do |call, event|
    fail_check("#{name} #{call} count differs") unless calls.fetch(call) == events.count { |entry| entry.fetch("event") == event }
  end
  fail_check("#{name} successful call lifecycle differs") unless calls.fetch("capacity") == 1 && calls.fetch("discard") == 0
  workspace = row.fetch("expectedWorkspaceCalls")
  fail_check("#{name} workspace lifecycle differs") unless workspace.fetch("acquire") == 1 && workspace.fetch("reset") == 1 && workspace.fetch("pushForeground") == workspace.fetch("popForeground") && workspace.fetch("foregroundHighWater") <= row.fetch("workspaceCapacity").fetch("maximumTraversalDepth")
end

nested = cases.fetch(0)
fail_check("nested clips are not unchanged") unless nested.fetch("resolvedClips").map { |entry| entry.fetch("rect") }.uniq.length == 1
fills = nested.fetch("expectedRecordingEvents").select { |event| event.fetch("event") == "fill" }.map { |event| event.fetch("fields").slice("red", "green", "blue") }
fail_check("nested background RGB differs") unless fills == [{"red" => 0, "green" => 0, "blue" => 255}, {"red" => 128, "green" => 128, "blue" => 128}]

painter = cases.fetch(1)
fail_check("empty line is absent") unless painter.fetch("textLines").any? { |line| line.fetch("glyphCount").zero? }
fail_check("occurrence-wide glyph indices differ") unless painter.fetch("glyphs").map { |glyph| glyph.fetch("glyphIndex") } == [0, 1, 2]
fail_check("empty line emitted a group") unless painter.fetch("expectedRecordingEvents").count { |event| event.fetch("event") == "begin-glyphs" } == 2

partial = cases.fetch(2)
partial_fill = partial.fetch("expectedRecordingEvents").find { |event| event.fetch("event") == "fill" }.fetch("fields")
fail_check("partial fill bounds were clamped") unless partial_fill.fetch("bounds") == {"x" => -10, "y" => -5, "width" => 60, "height" => 30}
fail_check("partial final clip differs") unless partial_fill.fetch("clip") == {"x" => 30, "y" => 10, "width" => 10, "height" => 10}

omitted = cases.fetch(3)
fail_check("empty backgrounds emitted operations") unless omitted.fetch("expectedResult").fetch("header").fetch("operationCount").zero?
fail_check("off-surface clip is absent") unless omitted.fetch("resolvedClips").any? { |entry| entry.fetch("rect").fetch("x") > omitted.fetch("surfaceBounds").fetch("width") }
fail_check("zero-area bounds are absent") unless omitted.fetch("resolvedBounds").any? { |entry| entry.fetch("rect").fetch("width").zero? || entry.fetch("rect").fetch("height").zero? }

tests = TESTS.read
EXPECTED_TESTS.each do |name|
  fail_check("missing executable golden #{name}") unless tests.include?("func #{name}()")
end

puts "SPEC-008 canonical corpus passed: #{cases.length} field-by-field golden cases"
