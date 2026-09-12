#!/usr/bin/env ruby
# frozen_string_literal: true

VALUES = {
  "CanonicalEncodedPixel" => ["canonicalEncodedPixel", :maximum, 8],
  "RasterSurfaceDescriptor" => ["rasterSurfaceDescriptor", :maximum, 32],
  "RasterPayloadLimits" => ["rasterPayloadLimits", :maximum, 40],
  "DisplayReservationID" => ["displayReservationID", :exact, 4],
  "DisplayReservationResult" => ["displayReservationResult", :reported, nil],
  "DisplayTransferResult" => ["displayTransferResult", :reported, nil],
  "DisplayTargetError" => ["displayTargetError", :exact, 1],
  "RasterBackendError" => ["rasterFailureCode", :exact, 1],
}.freeze

def fail_check(message)
  warn "SPEC-014 value layout check failed: #{message}"
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

  case kind
  when :exact
    fail_check("#{name} size #{metrics['size']} differs from #{bound}") unless metrics["size"] == bound
  when :maximum
    fail_check("#{name} size #{metrics['size']} exceeds #{bound}") if metrics["size"] > bound
  end
  fail_check("#{name} stride is smaller than size") if metrics["stride"] < metrics["size"]
  fail_check("#{name} alignment is zero") if metrics["alignment"].zero?
  [name, metrics["size"], metrics["stride"], metrics["alignment"], kind, bound || "-"]
end

File.open(ARGV[1], "w") do |output|
  output.puts("value\tsize\tstride\talignment\trequirement\tbound")
  rows.each { |row| output.puts(row.join("\t")) }
end

puts "SPEC-014 value layouts passed: #{rows.length} normative values reported."
