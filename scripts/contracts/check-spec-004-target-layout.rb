#!/usr/bin/env ruby
# frozen_string_literal: true

VALUES = {
  "RasterPresentationRequirement" => ["requirement", 32],
  "RasterRealizationContribution" => ["realization", 40],
  "RasterBackendContribution" => ["backend", 88],
  "SurfaceDisplayContribution" => ["surface", 40],
  "RasterPresentationPolicy" => ["policy", 32],
  "RasterPresentationContributions" => ["contributions", 192],
  "RasterPresentationResolverWorkspace" => ["workspace", 96],
  "EffectiveRasterPresentation" => ["effective", 48],
  "RasterPresentationUnavailable" => ["unavailable", 16],
  "CapabilitySnapshot" => ["snapshot", 56],
}.freeze

def fail_check(message)
  warn "SPEC-004 target-layout check failed: #{message}"
  exit 1
end

fail_check("expected LLVM IR and output paths") unless ARGV.length == 2
ir = File.read(ARGV.fetch(0))
rows = VALUES.map do |name, (prefix, ceiling)|
  values = %w[size stride alignment].map do |measurement|
    function = "#{prefix}#{measurement.capitalize}"
    body = ir[/define [^{]+#{function}[^\{]*\{(.*?)^\}/m, 1]
    fail_check("missing IR function #{function}") unless body
    value = body[/ret i32 ([0-9]+)/, 1]
    fail_check("#{function} is not a constant i32 return") unless value
    Integer(value, 10)
  end
  size, stride, alignment = values
  fail_check("#{name} size #{size} exceeds #{ceiling}") if size > ceiling
  fail_check("#{name} stride #{stride} is smaller than size #{size}") if stride < size
  fail_check("#{name} alignment #{alignment} is invalid") unless
    alignment.positive? && (alignment & (alignment - 1)).zero?
  [name, size, stride, alignment, ceiling]
end

File.open(ARGV.fetch(1), "w") do |output|
  output.puts("value\tsize\tstride\talignment\tmaximum_size")
  rows.each { |row| output.puts(row.join("\t")) }
end
puts "SPEC-004 target-layout check passed: #{rows.length} bounded values."
