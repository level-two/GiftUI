#!/usr/bin/env ruby
# frozen_string_literal: true

require "pathname"

def fail_check(message)
  warn "SPEC-006 layout/allocation check failed: #{message}"
  exit 1
end

fail_check("usage: check-spec-006-layout-allocation.rb IR SIL ABI OUTPUT") unless ARGV.length == 4
ir_path, sil_path, abi_path, output_path = ARGV.map { |argument| Pathname.new(argument) }
[ir_path, sil_path, abi_path].each do |path|
  fail_check("missing input #{path}") unless path.file?
end

ir = ir_path.read
sil = sil_path.read
abi = abi_path.read
values = {
  "SemanticExpansionLimits" => ["Limits", 10, false],
  "SemanticExpansionSummary" => ["Summary", 10, false],
  "SemanticExpansionError" => ["Error", 1, true],
  "SemanticExpansionResult" => ["Result", 12, false],
}

rows = values.map do |name, (prefix, bound, exact)|
  metrics = %w[Size Stride Alignment].to_h do |metric|
    function = ir[/define [^{]*spec006#{prefix}#{metric}[^\{]*\{(.*?)^\}/m, 1]
    fail_check("missing IR function spec006#{prefix}#{metric}") unless function
    raw = function[/ret i32 ([0-9]+)/, 1]
    fail_check("#{name} #{metric.downcase} is not constant") unless raw
    [metric.downcase, Integer(raw, 10)]
  end
  if exact
    fail_check("#{name} size differs") unless metrics["size"] == bound
  else
    fail_check("#{name} size exceeds #{bound}") if metrics["size"] > bound
  end
  fail_check("#{name} stride is smaller than size") if metrics["stride"] < metrics["size"]
  fail_check("#{name} alignment is zero") if metrics["alignment"].zero?
  [name, metrics["size"], metrics["stride"], metrics["alignment"], exact ? "exact" : "maximum", bound]
end

allocations = sil.each_line.count do |line|
  !line.lstrip.start_with?("//") && line.match?(/\b(?:alloc_ref|alloc_box)\b/)
end
fail_check("optimized static path contains #{allocations} heap allocation instruction(s)") unless allocations.zero?

unless abi.strip == "not-applicable"
  hard_float = abi.include?("Tag_ABI_VFP_args: VFP registers") || abi.include?("1c01")
  fail_check("ARM artifact lacks hard-float calling convention") unless hard_float
end

abi_result = abi.strip == "not-applicable" ? "not-applicable" : "hard-float"
Pathname.new(output_path).write(
  "value\tsize\tstride\talignment\trequirement\tbound\n" +
    rows.map { |row| row.join("\t") }.join("\n") +
    "\nallocation_instructions\t#{allocations}\nabi\t#{abi_result}\n"
)
puts "SPEC-006 layout/allocation passed: four owned values, zero optimized heap allocation instructions, and target ABI evidence are recorded."
