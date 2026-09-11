#!/usr/bin/env ruby
# frozen_string_literal: true

require "pathname"
require "yaml"

ROOT = Pathname.new(File.expand_path("../..", __dir__))
FIXTURES = ROOT.join("Tests/ContractFixtures/SPEC008")

def fail_report(message)
  warn "SPEC-008 render evidence report failed: #{message}"
  exit 1
end

fail_report("usage: report-spec-008-render-evidence.rb PROFILE OUTPUT") unless ARGV.length == 2
profile = ARGV.fetch(0)
fail_report("unknown profile") unless %w[
  macos-dynamic macos-static raspberry-pi-armv6 nrf52840-embedded
].include?(profile)
output = Pathname.new(ARGV.fetch(1))
output.mkpath

variant = YAML.safe_load(
  FIXTURES.join("signal-analyzer.yaml").read,
  aliases: false
).fetch("variants").fetch(0)
limits = variant.fetch("renderLimits")
workspace = variant.fetch("workspaceCapacity")
sink = variant.fetch("sinkCapacity")
observed = variant.fetch("expectedHighWater")

capacity_by_metric = {
  "operations" => limits.fetch("maximumOperations"),
  "positioned-glyphs" => limits.fetch("maximumPositionedGlyphs"),
  "clip-depth" => limits.fetch("maximumClipDepth"),
  "semantic-scopes" => workspace.fetch("maximumSemanticScopes"),
  "layout-scopes" => workspace.fetch("maximumLayoutScopes"),
  "traversal-depth" => workspace.fetch("maximumTraversalDepth"),
  "text-lines" => workspace.fetch("maximumTextLines"),
  "foreground-depth" => workspace.fetch("maximumTraversalDepth"),
}
observed_by_metric = {
  "operations" => observed.fetch("operations"),
  "positioned-glyphs" => observed.fetch("positionedGlyphs"),
  "clip-depth" => observed.fetch("clipDepth"),
  "semantic-scopes" => observed.fetch("semanticScopes"),
  "layout-scopes" => observed.fetch("layoutScopes"),
  "traversal-depth" => observed.fetch("traversalDepth"),
  "text-lines" => observed.fetch("textLines"),
  "foreground-depth" => observed.fetch("foregroundDepth"),
}
capacity_by_metric.each do |metric, capacity|
  value = observed_by_metric.fetch(metric)
  fail_report("#{metric} exceeds capacity") unless value.positive? && value <= capacity
end

output.join("signal-analyzer-high-water.tsv").write(
  "metric\tdeclared\tobserved\tunit\n" +
    capacity_by_metric.map { |metric, capacity|
      unit = metric.end_with?("depth") ? "level" : "count"
      [metric, capacity, observed_by_metric.fetch(metric), unit].join("\t")
    }.join("\n") + "\n"
)

observed_workspace_bytes =
  observed.fetch("semanticScopes") + observed.fetch("layoutScopes") +
  observed.fetch("foregroundDepth") * 3
fail_report("observed logical workspace exceeds capacity") unless
  observed_workspace_bytes <= workspace.fetch("logicalStorageBytes")
output.join("workspace.tsv").write(
  "component\tcapacity\tobserved\tunit\n" +
    [
      ["semantic-visit-storage", workspace.fetch("semanticVisitBytes"), observed.fetch("semanticScopes"), "byte"],
      ["layout-visit-storage", workspace.fetch("layoutVisitBytes"), observed.fetch("layoutScopes"), "byte"],
      ["foreground-storage", workspace.fetch("foregroundSlotBytes"), observed.fetch("foregroundDepth") * 3, "byte"],
      ["logical-workspace", workspace.fetch("logicalStorageBytes"), observed_workspace_bytes, "byte"],
      ["sink-operations", sink.fetch("maximumOperations"), observed.fetch("operations"), "count"],
      ["sink-glyphs", sink.fetch("maximumPositionedGlyphs"), observed.fetch("positionedGlyphs"), "count"],
    ].map { |row| row.join("\t") }.join("\n") + "\n"
)

work_rows = FIXTURES.join("Instrumentation/render-work.tsv").each_line.each_with_object([]) do |line, rows|
  next if line.start_with?("#") || line.strip.empty?

  rows << line.chomp.split("\t").map { |field| Integer(field, 10) }
end
maximum_frames = observed.fetch("traversalDepth")
fail_report("Signal Analyzer stack high-water lacks a registered method") unless
  work_rows.any? { |row| row.fetch(4) == row.fetch(0) } && maximum_frames.positive?
output.join("stack-high-water.tsv").write(
  "measurement\tvalue\tunit\tmethod\n" \
  "maximum-render-traversal-frames\t#{maximum_frames}\tframe\trecursive semantic traversal depth\n"
)

methods = FIXTURES.join("Instrumentation/render-measurement-methods.tsv").read
fail_report("ContinuousClock timing method is missing") unless methods.include?("Swift ContinuousClock")
execution = profile.start_with?("macos-") ? "host-execution" : "cross-build-not-executed"
sample_count = profile.start_with?("macos-") ? 9 : 0
output.join("timing-method.tsv").write(
  "profile\texecution\tmethod\trequired_samples\n" \
  "#{profile}\t#{execution}\tSwift ContinuousClock around RenderProducer.produce\t#{sample_count}\n"
)

puts "SPEC-008 render evidence reported for #{profile}: exact Signal Analyzer limits, high-water, workspace, stack method, and timing disposition."
