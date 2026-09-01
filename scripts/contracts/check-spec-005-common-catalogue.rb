#!/usr/bin/env ruby
# frozen_string_literal: true

def fail_check(message)
  warn "SPEC-005 common-catalogue check failed: #{message}"
  exit 1
end

tests = File.read(ARGV.fetch(0) { fail_check("expected test path") })
required = [
  "testCompleteCatalogueValidatesForEachRequiredRealization",
  "testBitmapOnlyAndOutlineOnlyPreserveCatalogueAndIdentity",
  "testAvailabilityClaimWithoutCompleteBorrowIsIncompatible",
  "testOmittedUnselectedRecordMetadataStillValidates",
  "testEveryAvailableUnselectedPayloadMustPassIntegrity",
  "canonicalManifestByteCount: 194",
  "availability: [true, false]",
  "availability: [false, true]",
].freeze
required.each do |fragment|
  fail_check("fixture lacks #{fragment}") unless tests.include?(fragment)
end

puts "SPEC-005 common-catalogue check passed: complete and payload-subset compositions preserve one identity."
