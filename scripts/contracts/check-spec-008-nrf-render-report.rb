#!/usr/bin/env ruby
# frozen_string_literal: true

require "digest"
require "pathname"

EXPECTED_LAYOUTS = {
  "Color" => ["exact", 3],
  "BoundedText" => ["maximum", 100],
  "RenderLimits" => ["exact", 6],
  "RenderWorkspaceCapacity" => ["exact", 8],
  "RenderWorkspaceVisit" => ["exact", 1],
  "RenderSinkCapacity" => ["exact", 4],
  "RenderDamageMode" => ["exact", 1],
  "RenderPlanHeader" => ["maximum", 40],
  "PositionedGlyph" => ["maximum", 12],
  "FillRectOperation" => ["maximum", 36],
  "PositionedGlyphOperationHeader" => ["maximum", 60],
  "RenderProductionError" => ["exact", 1],
  "RenderProductionResult" => ["maximum", 44],
}.freeze

def fail_check(message)
  warn "SPEC-008 nRF render report check failed: #{message}"
  exit 1
end

def metadata(path)
  path.each_line.each_with_object({}) do |line, values|
    key, value = line.chomp.split("=", 2)
    values[key] = value if value
  end
end

def tsv(path, header, width)
  fail_check("missing #{path}") unless path.file?
  lines = path.each_line.to_a
  fail_check("#{path} header differs") unless lines.shift&.chomp == header
  lines.each_with_object([]) do |line, rows|
    next if line.strip.empty? || line.start_with?("#")

    fields = line.chomp.split("\t", -1)
    fail_check("#{path} row width differs") unless fields.length == width
    rows << fields
  end
end

fail_check("usage: check-spec-008-nrf-render-report.rb REPORT OUTPUT") unless ARGV.length == 2
report = Pathname.new(ARGV.fetch(0))
output = Pathname.new(ARGV.fetch(1))
identity = metadata(report.join("metadata.txt"))
fail_check("profile differs") unless identity["profile"] == "nrf52840-embedded"
fail_check("report was not produced from a clean revision") unless identity["repository_dirty"] == "false"
fail_check("target differs") unless identity["target"] == "armv7em-none-none-eabi"
fail_check("board differs") unless identity["board"] == "nrf52840dk/nrf52840"
fail_check("optimization differs") unless identity["optimization"] == "-Osize -whole-module-optimization"
fail_check("float ABI differs") unless identity["float_abi"] == "hard"
%w[connected_target_execution flashing remote_access deployment service_restart].each do |key|
  fail_check("report claims #{key}") unless identity[key] == "false"
end

declarations = tsv(
  report.join("declarations/results.tsv"),
  "# id\texpectation\tresult",
  3
)
fail_check("declaration fixture count differs") unless declarations.length == 17
fail_check("a declaration fixture failed") unless declarations.all? { |row| row.fetch(2) == "pass" }

layouts = tsv(
  report.join("value-layouts/render-value-layouts.tsv"),
  "value\tsize\tstride\talignment\trequirement\tbound",
  6
)
fail_check("value layout set differs") unless layouts.map(&:first) == EXPECTED_LAYOUTS.keys
layouts.each do |value, size, _stride, _alignment, requirement, bound|
  expected_requirement, expected_bound = EXPECTED_LAYOUTS.fetch(value)
  fail_check("#{value} requirement differs") unless requirement == expected_requirement
  fail_check("#{value} bound differs") unless Integer(bound, 10) == expected_bound
  valid = requirement == "exact" ? Integer(size, 10) == expected_bound : Integer(size, 10) <= expected_bound
  fail_check("#{value} violates its layout bound") unless valid
end

image = report.join("render-image")
allocation = tsv(image.join("allocation.tsv"), "measurement\tcount\tmethod", 3)
fail_check("allocation result differs") unless allocation == [[
  "production-entry-heap-allocation-instructions", "0", "optimized-target-sil"
]]
workspace_path = image.join("concrete-workspace.tsv")
workspace_lines = workspace_path.readlines.map(&:chomp)
fail_check("finite workspace header differs") unless workspace_lines.fetch(0) ==
  "workspace_size\tworkspace_stride\tworkspace_alignment\tforeground_slot_bytes"
fail_check("finite workspace report differs") unless workspace_lines.fetch(1) == "22\t22\t2\t3"
fail_check("workspace capacities are incomplete") unless workspace_lines.drop(2) == [
  "capacity\tvalue",
  "operations\t1",
  "positioned-glyphs\t1",
  "clip-depth\t1",
  "semantic-scopes\t1",
  "layout-scopes\t1",
  "traversal-depth\t1",
  "text-lines\t1",
]

sections = tsv(
  image.join("linked-section-deltas.tsv"),
  "category\tbaseline_bytes\tcandidate_bytes\tdelta_bytes",
  4
).to_h { |category, _baseline, _candidate, delta| [category, Integer(delta, 10)] }
fail_check("section categories differ") unless sections.keys == %w[
  code read_only initialized zero_initialized file_size
]
fail_check("linked render code is absent") unless sections.fetch("code").positive?
fail_check("linked render read-only data is absent") unless sections.fetch("read_only").positive?

%w[baseline.map candidate.map candidate symbols.txt arm-attributes.txt].each do |relative|
  path = image.join(relative)
  fail_check("missing or empty #{relative}") unless path.file? && path.size.positive?
end
symbols = image.join("symbols.txt").read
fail_check("production entry is not linked") unless symbols.include?("spec008StaticRenderProductionEntry")
fail_check("Zephyr Swift wrapper is not linked") unless symbols.include?("giftui_spec008_render_probe")
attributes = image.join("arm-attributes.txt").read
fail_check("ELF lacks ARMv7E-M") unless attributes.include?("Tag_CPU_arch: v7E-M")
fail_check("ELF lacks VFPv4-D16") unless attributes.include?("Tag_FP_arch: VFPv4-D16")
fail_check("ELF lacks hard-float arguments") unless attributes.include?("Tag_ABI_VFP_args: VFP registers")

log = report.join("run.log").read
fail_check("complete canonical corpus did not pass") unless
  log.include?("canonical corpus passed: 5 field-by-field golden cases")
fail_check("complete failure corpus did not pass") unless
  log.include?("failure corpus passed: mismatches, seven independent capacities")

output.dirname.mkpath
output.write(
  "evidence\tdisposition\tsha256\n" +
    [
      ["declarations", "17-pass", Digest::SHA256.file(report.join("declarations/results.tsv")).hexdigest],
      ["value-layouts", "13-pass", Digest::SHA256.file(report.join("value-layouts/render-value-layouts.tsv")).hexdigest],
      ["allocation", "zero", Digest::SHA256.file(image.join("allocation.tsv")).hexdigest],
      ["workspace", "finite-22-bytes", Digest::SHA256.file(image.join("concrete-workspace.tsv")).hexdigest],
      ["sections", "linked-code-and-read-only-data", Digest::SHA256.file(image.join("linked-section-deltas.tsv")).hexdigest],
      ["link-map", "baseline-and-candidate-present", Digest::SHA256.file(image.join("candidate.map")).hexdigest],
      ["symbols", "production-entry-and-wrapper-linked", Digest::SHA256.file(image.join("symbols.txt")).hexdigest],
      ["abi", "armv7e-m-vfpv4-d16-hard-float", Digest::SHA256.file(image.join("arm-attributes.txt")).hexdigest],
      ["execution", "cross-build-inspection-only", "-"],
    ].map { |row| row.join("\t") }.join("\n") + "\n"
)

puts "SPEC-008 nRF report passed: complete fixture linked, 13 layouts, zero allocation, finite workspace, linked sections/symbols, and Cortex-M4F hard-float ELF; no flash."
