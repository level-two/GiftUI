#!/usr/bin/env ruby
# frozen_string_literal: true

def fail_check(message)
  warn "SPEC-005 validator check failed: #{message}"
  exit 1
end

source = File.read(ARGV.fetch(0) { fail_check("expected source path") })

fields = %w[
  unsupportedSchema
  capacityExceeded
  invalidCount
  invalidIdentity
  incompatibleViews
  malformedMetrics
  malformedMapping
  malformedRasterRecord
  integrityMismatch
].freeze
fields.each do |field|
  fail_check("predicate set lacks #{field}") unless
    source.include?("var #{field} = false")
end

result = source[/var result: TextResourceValidationResult \{(.*?)^    \}/m, 1]
fail_check("could not isolate precedence result") unless result
observed = result.scan(/\.invalid\(\.([A-Za-z]+)\)/).flatten
fail_check("raw-value precedence differs: #{observed.inspect}") unless observed == fields

required_traversals = [
  "while instanceOrdinal < instanceTraversalCount",
  "while mappingOrdinal < mappingTraversalCount",
  "while glyphOrdinal < glyphTraversalCount",
  "while realizationOrdinal < realizationTraversalCount",
  "while recordOrdinal < recordTraversalCount",
  "payloadSHA256.update(with: byte)",
  "canonicalManifestDigest(of: resourcePackage)",
  "return predicates.result",
].freeze
required_traversals.each do |fragment|
  fail_check("validator lacks #{fragment}") unless source.include?(fragment)
end

puts "SPEC-005 validator check passed: nine precedence classes and complete bounded traversals are present."
