#!/usr/bin/env ruby
# frozen_string_literal: true

VALUES = {
  "SubpathRange" => ["subpathRange", :exact, 4],
  "DrawingPlanSummary" => ["drawingPlanSummary", :exact, 10],
  "StraightLineStrokeHeader" => ["straightLineStrokeHeader", :maximum, 40],
  "DrawingProductionError" => ["drawingProductionError", :exact, 1],
  "DrawingPlanResult" => ["drawingPlanResult", :maximum, 12],
}.freeze

def fail_check(message)
  warn "SPEC-012 value layout check failed: #{message}"
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

puts "SPEC-012 value layouts passed: #{rows.length} bounded drawing values."
