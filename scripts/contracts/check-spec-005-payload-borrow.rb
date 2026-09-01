#!/usr/bin/env ruby
# frozen_string_literal: true

def fail_check(message)
  warn "SPEC-005 payload-borrow check failed: #{message}"
  exit 1
end

source = File.read(ARGV.fetch(0) { fail_check("expected source path") })

required_fragments = [
  "static func withPayloadSlice<Result>(",
  "_ body: (UnsafeRawBufferPointer) throws -> Result",
  ") rethrows -> Result?",
  "record == cataloguedRecord",
  "realization == cataloguedRealization.id",
  "record.glyph.rawValue < cataloguedRealization.glyphCount",
  "let payloadCount = UInt32(exactly: payload.count)",
  "let end = record.offset.addingReportingOverflow(record.byteCount)",
  "UnsafeRawBufferPointer(\n            rebasing:",
  "return try body(slice)",
].freeze
required_fragments.each do |fragment|
  fail_check("missing #{fragment}") unless source.include?(fragment)
end

helper = source[/static func withPayloadSlice<Result>\(.+?^    \}/m]
fail_check("could not isolate payload helper") unless helper
fail_check("payload helper allocates storage") if helper.match?(/\b(?:Array|allocate|Data)\b/)
fail_check("payload helper stores a mutable pointer") if helper.include?("UnsafeMutable")

puts "SPEC-005 payload-borrow check passed: exact catalogue guards, rebased borrow, and body-only rethrows."
