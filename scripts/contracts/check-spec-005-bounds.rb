#!/usr/bin/env ruby
# frozen_string_literal: true

def fail_check(message)
  warn "SPEC-005 bounds check failed: #{message}"
  exit 1
end

fail_check("expected production source and boundary-test paths") unless ARGV.length == 2
source = File.read(ARGV.fetch(0))
tests = File.read(ARGV.fetch(1))

required_source = [
  "static func isWithinCapacity(",
  "instanceCount <= 1",
  "glyphCount <= 256",
  "mappingCount <= 256",
  "realizationCount <= 2",
  "canonicalManifestByteCount <= 16_384",
  "payloadByteCount <= 65_536",
  "instanceDescriptor.mappingCount <= 256",
].freeze
required_source.each do |fragment|
  fail_check("production source lacks #{fragment}") unless source.include?(fragment)
end

required_boundaries = %w[
  instanceCount:2
  glyphCount:257
  mappingCount:257
  realizationCount:3
  canonicalManifestByteCount:16_385
  payloadByteCount:65_537
].freeze
normalized_tests = tests.gsub(/\s+/, "")
required_boundaries.each do |fragment|
  fail_check("tests lack maximum-plus-one #{fragment}") unless
    normalized_tests.include?(fragment)
end

puts "SPEC-005 bounds check passed: six independent ceilings and maximum-plus-one fixtures are present."
