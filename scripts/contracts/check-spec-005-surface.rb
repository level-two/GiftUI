#!/usr/bin/env ruby
# frozen_string_literal: true

def fail_check(message)
  warn "SPEC-005 surface check failed: #{message}"
  exit 1
end

unless ARGV.length == 2
  fail_check("expected public and package interface paths")
end

begin
  public_interface = File.read(ARGV[0])
  package_interface = File.read(ARGV[1])
rescue Errno::ENOENT => error
  fail_check(error.message)
end

expected_declarations = %w[
  TextResourceDigest
  FontResourceID
  FontInstanceID
  GlyphID
  RasterRealizationID
  TextRasterKind
  FontLineMetrics
  GlyphMetrics
  FontInstanceDescriptor
  RasterRealizationDescriptor
  TextResourceDescriptor
  GlyphMapping
  ScalarGlyphMappingRecord
  GlyphRasterRecord
  CanonicalTextMetricsView
  TextRasterResourceView
  TextResourcePackage
  TextResourceValidationError
  TextResourceValidationResult
  TextResourceValidator
].freeze

actual_declarations = package_interface.scan(/^package (?:struct|enum|protocol) ([A-Za-z0-9_]+)/).flatten
unless actual_declarations == expected_declarations
  fail_check("declaration order/set differs: #{actual_declarations.inspect}")
end

resource_token = expected_declarations.map { |name| Regexp.escape(name) }.join("|")
if public_interface.match?(/^public (?:struct|enum|protocol|typealias) (?:#{resource_token})\b/) ||
   public_interface.match?(/^package (?:struct|enum|protocol|typealias) (?:#{resource_token})\b/)
  fail_check("text-resource SPI leaked into the public interface")
end

required_fragments = [
  "package let word0: Swift.UInt32",
  "package let word7: Swift.UInt32",
  "package let rawValue: GiftUITextResources.TextResourceDigest",
  "package let instanceIndex: Swift.UInt16",
  "package let rawValue: Swift.UInt16",
  "package enum TextRasterKind : Swift.UInt8",
  "package let canonicalManifestByteCount: Swift.UInt32",
  "case exact(GiftUITextResources.GlyphID)",
  "case replacement(GiftUITextResources.GlyphID)",
  "func withPayload<Result>(for record: GiftUITextResources.GlyphRasterRecord, realization: GiftUITextResources.RasterRealizationID, _ body: (Swift.UnsafeRawBufferPointer) throws -> Result) rethrows -> Result?",
  "package enum TextResourceValidationError : Swift.UInt8",
  "case integrityMismatch",
  "_ resourcePackage: borrowing GiftUITextResources.TextResourcePackage<M, R>",
]
required_fragments.each do |fragment|
  fail_check("package interface lacks #{fragment}") unless package_interface.include?(fragment)
end

forbidden_storage = /package let (?:pointer|reference|string|handle|closure|existential)\b/i
fail_check("identity surface contains forbidden storage") if package_interface.match?(forbidden_storage)
fail_check("resource surface declares a class or actor") if package_interface.match?(/^package (?:class|actor)\b/)

puts "SPEC-005 surface check passed: #{expected_declarations.length} exact package declarations and no public resource SPI."
