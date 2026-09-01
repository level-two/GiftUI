#!/usr/bin/env ruby
# frozen_string_literal: true

def fail_check(message)
  warn "SPEC-005 accessor check failed: #{message}"
  exit 1
end

source = File.read(ARGV.fetch(0) { fail_check("expected source path") })

required_fragments = [
  "package extension CanonicalTextMetricsView",
  "TextResourceValidator.isValidUnicodeScalar(scalarValue)",
  "scalarValue != 0x0a",
  "scalarValue != 0x0d",
  "instanceDescriptor.mappingCount <= 256",
  "return .replacement(instanceDescriptor.replacementGlyph)",
  "func checkedInkRectangle(at logicalOrigin: Point) -> Rect?",
  "func checkedAdvancedOrigin(from logicalOrigin: Point) -> Point?",
  "GeometryArithmetic.add(logicalOrigin.x, offsetX)",
  "static func recordsFormGapFreePartition<R>",
  "static func isStructurallyValidMonochromeBitmap(",
  "let mask = UInt8(0x80 >> UInt8(x & 7))",
  "static func isStructurallyValidPackagedOutline(",
  "let isImpliedPoint = x == 0x7fff && y == 0x7fff",
].freeze
required_fragments.each do |fragment|
  fail_check("missing #{fragment}") unless source.include?(fragment)
end

unless source.include?("scalarValue <= 0x10_ffff") &&
       source.include?("!(0xd800 ... 0xdfff).contains(scalarValue)")
  fail_check("Unicode scalar boundaries are incomplete")
end

unless source.include?("opcode == 5 || opcode == 6") &&
       source.include?("guard opcode >= 1, opcode <= 4") &&
       source.include?("operandCount == 3")
  fail_check("outline opcode or arity checks are incomplete")
end

puts "SPEC-005 accessor check passed: scalar, identity, geometry, bitmap, partition, and outline seams are present."
