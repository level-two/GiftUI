#!/usr/bin/env ruby
# frozen_string_literal: true

VALUES = {
  "Color" => ["color", :exact, 3],
  "BoundedText" => ["boundedText", :maximum, 100],
  "RenderLimits" => ["renderLimits", :exact, 6],
  "RenderWorkspaceCapacity" => ["renderWorkspaceCapacity", :exact, 8],
  "RenderWorkspaceVisit" => ["renderWorkspaceVisit", :exact, 1],
  "RenderSinkCapacity" => ["renderSinkCapacity", :exact, 4],
  "RenderDamageMode" => ["renderDamageMode", :exact, 1],
  "RenderPlanHeader" => ["renderPlanHeader", :maximum, 40],
  "PositionedGlyph" => ["positionedGlyph", :maximum, 12],
  "FillRectOperation" => ["fillRectOperation", :maximum, 36],
  "PositionedGlyphOperationHeader" => ["positionedGlyphHeader", :maximum, 60],
  "RenderProductionError" => ["renderProductionError", :exact, 1],
  "RenderProductionResult" => ["renderProductionResult", :maximum, 44],
}.freeze

def fail_check(message)
  warn "SPEC-008 value layout check failed: #{message}"
  exit 1
end

fail_check("expected LLVM IR and output paths") unless ARGV.length == 2
ir = File.read(ARGV[0])
rows = VALUES.map do |name, (prefix, kind, bound)|
  metrics = %w[Size Stride Alignment].to_h do |metric|
    body = ir[/define [^{]+#{prefix}#{metric}[^\{]*\{(.*?)^\}/m, 1]
    fail_check("missing IR function #{prefix}#{metric}") unless body
    value = body[/ret i32 ([0-9]+)/, 1]
    fail_check("#{prefix}#{metric} is not a constant i32 return") unless value
    [metric.downcase, Integer(value, 10)]
  end
  if kind == :exact
    fail_check("#{name} size #{metrics['size']} differs from #{bound}") unless metrics["size"] == bound
  else
    fail_check("#{name} size #{metrics['size']} exceeds #{bound}") if metrics["size"] > bound
  end
  fail_check("#{name} stride is smaller than size") if metrics["stride"] < metrics["size"]
  fail_check("#{name} alignment is zero") if metrics["alignment"].zero?
  [name, metrics["size"], metrics["stride"], metrics["alignment"], kind, bound]
end

File.open(ARGV[1], "w") do |output|
  output.puts("value\tsize\tstride\talignment\trequirement\tbound")
  rows.each { |row| output.puts(row.join("\t")) }
end

puts "SPEC-008 value layouts passed: #{rows.length} bounded rendering values."
