#!/usr/bin/env ruby
# frozen_string_literal: true

abort "usage: check-spec-007-resource-ir.rb <input.ll> <output.tsv>" unless ARGV.length == 2

input, output = ARGV
ir = File.read(input)
probes = {
  "semantic-layout-primitive" => ["spec007PrimitiveSize", 16],
  "semantic-layout-modifier" => ["spec007ModifierSize", 48],
  "layout-limits" => ["spec007LimitsSize", 10],
  "layout-summary" => ["spec007SummarySize", 28],
  "layout-error" => ["spec007ErrorSize", 1],
  "layout-result" => ["spec007ResultSize", 32],
  "static-workspace" => ["spec007StaticWorkspaceSize", nil],
  "static-workspace-stride" => ["spec007StaticWorkspaceStride", nil],
}.freeze

values = probes.to_h do |label, (symbol, ceiling)|
  body = ir[/define[^\n]*#{symbol}[^\n]*\{(.*?)^\}/m, 1]
  abort "SPEC-007 resource IR check failed: missing #{symbol}" unless body
  value = body[/\bret i32 (\d+)/, 1]&.to_i
  abort "SPEC-007 resource IR check failed: nonconstant #{symbol}" unless value
  if ceiling && value > ceiling
    abort "SPEC-007 resource IR check failed: #{label}=#{value} exceeds #{ceiling}"
  end
  [label, [value, ceiling]]
end

entry = ir[/define[^\n]*spec007StaticLayoutEntry[^\n]*\{(.*?)^\}/m, 1]
abort "SPEC-007 resource IR check failed: missing static layout entry" unless entry
if entry.match?(/swift_(?:alloc|slowAlloc)|\bmalloc\b/)
  abort "SPEC-007 resource IR check failed: allocation call in static layout entry"
end

workspace = values.fetch("static-workspace").first
stride = values.fetch("static-workspace-stride").first
abort "SPEC-007 resource IR check failed: workspace size/stride differ" unless workspace == stride

File.open(output, "w") do |file|
  file.puts "# value\tsize_bytes\tceiling_bytes\tstatus"
  values.each do |label, (value, ceiling)|
    file.puts [label, value, ceiling || "exact", "pass"].join("\t")
  end
  file.puts ["static-layout-entry-heap-allocations", 0, 0, "pass"].join("\t")
end

puts "SPEC-007 resource IR passed: 6 value layouts and #{workspace}-byte finite workspace."
