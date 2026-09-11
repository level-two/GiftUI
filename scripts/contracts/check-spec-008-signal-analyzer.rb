#!/usr/bin/env ruby
# frozen_string_literal: true

require "pathname"
require "yaml"

ROOT = Pathname.new(File.expand_path("../..", __dir__))
FIXTURE = ROOT.join("Tests/ContractFixtures/SPEC008/signal-analyzer.yaml")

def fail_check(message)
  warn "SPEC-008 Signal Analyzer check failed: #{message}"
  exit 1
end

variants = YAML.safe_load(FIXTURE.read, aliases: false).fetch("variants")
fail_check("expected one complete render surface") unless variants.length == 1
row = variants.fetch(0)
fail_check("render surface name differs") unless row.fetch("name") == "complete-signal-analyzer-render-surface"

labels = [
  "DIGITAL SIGNAL ANALYZER", "Four-channel acquisition", "TIME",
  "CH1", "CH2", "CH3", "CH4", "HIGH", "LOW",
  "Start", "Stop", "Clear", "1 s", "2 s", "5 s",
]
fail_check("required labels differ") unless row.fetch("labels") == labels
fail_check("bounded ruler values differ") unless
  row.fetch("boundedValues") == ["0.00 s", "1.00 s", "2.00 s", "2.50 s", "5.00 s"]
fail_check("status texts differ") unless row.fetch("statusTexts") == %w[READY RUNNING STOPPED FAILED]
errors = row.fetch("errorTexts")
fail_check("nonempty acquisition error text is missing") unless errors == ["ACQUISITION ERROR"]

%w[foregrounds backgrounds].each do |field|
  colors = row.fetch(field)
  fail_check("#{field} is empty") if colors.empty?
  colors.each do |color|
    fail_check("#{field} color fields differ") unless color.keys.sort == %w[blue green red role]
    fail_check("#{field} is not opaque RGB") unless
      %w[red green blue].all? { |component| color.fetch(component).is_a?(Integer) && (0..255).cover?(color.fetch(component)) }
  end
end

hierarchy = row.fetch("maximumHierarchyVariants")
fail_check("maximum hierarchy differs") unless hierarchy.length == 1
maximum = hierarchy.fetch(0)
expected_counts = {
  "titleTexts" => 2, "statusTexts" => 1, "rulerValues" => 3,
  "channelRows" => 4, "channelLabels" => 4, "levelLabels" => 4,
  "controlLabels" => 6, "errorTexts" => 1, "textOccurrences" => 21,
  "rectangularBackgrounds" => 9, "positionedGlyphs" => 139,
  "semanticScopes" => 62, "layoutScopes" => 32, "traversalDepth" => 6,
  "textLines" => 21, "foregroundDepth" => 5,
}
fail_check("maximum hierarchy name differs") unless maximum.fetch("name") == "failed-five-second-four-channel-maximum"
expected_counts.each do |field, value|
  fail_check("maximum hierarchy #{field} differs") unless maximum.fetch(field) == value
end
fail_check("text occurrence accounting differs") unless
  maximum.values_at("titleTexts", "statusTexts", "rulerValues", "channelLabels", "levelLabels", "controlLabels", "errorTexts").sum == maximum.fetch("textOccurrences")
maximum_text = [labels[0], labels[1], "FAILED", "0.00 s", "2.50 s", "5.00 s"] +
  labels.values_at(3, 4, 5, 6) + Array.new(4, "HIGH") + labels.values_at(9, 10, 11, 12, 13, 14) + errors
fail_check("positioned glyph accounting differs") unless
  maximum_text.sum { |text| text.bytesize } == maximum.fetch("positionedGlyphs")
fail_check("layout occurrence accounting differs") unless
  maximum.fetch("layoutScopes") == 1 + 1 + 1 + 3 + 1 + 1 + 3 + 4 + 8 + 1 + 6 + 2
fail_check("semantic render-scope accounting differs") unless
  maximum.fetch("semanticScopes") == maximum.fetch("layoutScopes") +
    maximum.fetch("textOccurrences") + maximum.fetch("rectangularBackgrounds")
fail_check("operation high-water differs") unless
  maximum.fetch("textOccurrences") + maximum.fetch("rectangularBackgrounds") == row.dig("expectedHighWater", "operations")

render_limits = row.fetch("renderLimits")
fail_check("render limits differ") unless render_limits == {
  "maximumOperations" => 64, "maximumPositionedGlyphs" => 512, "maximumClipDepth" => 16,
}
workspace = row.fetch("workspaceCapacity")
fail_check("workspace logical bytes differ") unless
  workspace.fetch("semanticVisitBytes") + workspace.fetch("layoutVisitBytes") + workspace.fetch("foregroundSlotBytes") == workspace.fetch("logicalStorageBytes")
fail_check("foreground storage is not exactly depth times Color bytes") unless
  workspace.fetch("foregroundSlotBytes") == workspace.fetch("maximumTraversalDepth") * 3
fail_check("sink capacity differs from render limits") unless row.fetch("sinkCapacity") == {
  "maximumOperations" => render_limits.fetch("maximumOperations"),
  "maximumPositionedGlyphs" => render_limits.fetch("maximumPositionedGlyphs"),
}

high_water = row.fetch("expectedHighWater")
comparisons = {
  "operations" => render_limits.fetch("maximumOperations"),
  "positionedGlyphs" => render_limits.fetch("maximumPositionedGlyphs"),
  "clipDepth" => render_limits.fetch("maximumClipDepth"),
  "semanticScopes" => workspace.fetch("maximumSemanticScopes"),
  "layoutScopes" => workspace.fetch("maximumLayoutScopes"),
  "traversalDepth" => workspace.fetch("maximumTraversalDepth"),
  "textLines" => workspace.fetch("maximumTextLines"),
  "foregroundDepth" => workspace.fetch("maximumTraversalDepth"),
}
comparisons.each do |field, limit|
  fail_check("#{field} high-water is missing or exceeds capacity") unless
    high_water.fetch(field).positive? && high_water.fetch(field) <= limit
end
fail_check("maximum hierarchy and high-water differ") unless expected_counts.all? do |field, value|
  mapped = {"positionedGlyphs" => "positionedGlyphs", "semanticScopes" => "semanticScopes", "layoutScopes" => "layoutScopes", "traversalDepth" => "traversalDepth", "textLines" => "textLines", "foregroundDepth" => "foregroundDepth"}[field]
  mapped.nil? || high_water.fetch(mapped) == value
end

puts "SPEC-008 Signal Analyzer passed: required text/color/background surface and maximum hierarchy fit exact render, workspace, and sink limits."
