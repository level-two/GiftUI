#!/usr/bin/env ruby
# frozen_string_literal: true

VALUES = {
  "TextResourceDigest" => ["digest", 32, 32],
  "FontResourceID" => ["resourceID", 32, 32],
  "FontInstanceID" => ["instanceID", 36, nil],
  "GlyphID" => ["glyphID", 2, 2],
  "RasterRealizationID" => ["realizationID", 2, 2],
  "TextRasterKind" => ["rasterKind", 1, 1],
  "FontLineMetrics" => ["lineMetrics", 12, nil],
  "GlyphMetrics" => ["glyphMetrics", 24, nil],
  "FontInstanceDescriptor" => ["instanceDescriptor", 80, nil],
  "RasterRealizationDescriptor" => ["realizationDescriptor", 80, nil],
  "TextResourceDescriptor" => ["resourceDescriptor", 80, nil],
  "GlyphMapping" => ["glyphMapping", 4, nil],
  "ScalarGlyphMappingRecord" => ["mappingRecord", 8, nil],
  "GlyphRasterRecord" => ["rasterRecord", 80, nil],
  "TextResourceValidationError" => ["validationError", 1, 1],
  "TextResourceValidationResult" => ["validationResult", 2, nil],
}.freeze

def fail_check(message)
  warn "SPEC-005 target-layout check failed: #{message}"
  exit 1
end

fail_check("expected LLVM IR and output paths") unless ARGV.length == 2
ir = File.read(ARGV.fetch(0))
rows = VALUES.map do |name, (prefix, ceiling, exact)|
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
  fail_check("#{name} size #{size} differs from #{exact}") if exact && size != exact
  fail_check("#{name} stride #{stride} is smaller than size #{size}") if stride < size
  fail_check("#{name} alignment #{alignment} is invalid") unless
    alignment.positive? && (alignment & (alignment - 1)).zero?
  [name, size, stride, alignment, ceiling]
end

File.open(ARGV.fetch(1), "w") do |output|
  output.puts("value\tsize\tstride\talignment\tmaximum_size")
  rows.each { |row| output.puts(row.join("\t")) }
end
puts "SPEC-005 target-layout check passed: #{rows.length} bounded values."
