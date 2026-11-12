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

engine = source[/(?:internal|package) struct TextResourceValidationEngine \{(.*?)^private struct _TextResourceValidationPredicates/m, 1]
fail_check("could not isolate shared validation engine") unless engine

# The shared streaming engine now owns the bounded scans. Check both each
# capped request range and its independent surplus query; runtime policy and
# query-order equivalence remain covered by the execution corpus.
required_traversals = [
  "instanceOrdinal < min(descriptor.instanceCount, 1)",
  "mappingOrdinal < min(instance!.mappingCount, 256)",
  "glyphOrdinal < min(instance!.glyphCount, 256)",
  "realizationOrdinal < min(descriptor.realizationCount, 2)",
  "recordOrdinal < min(realization!.glyphCount, 256)",
  "case .instanceTail: return .instance(metricsDescriptor!.instanceCount)",
  "case .mappingTail: return .mapping(instance!.mappingCount, instance!.id)",
  "case .metricsTail: return .metrics(GlyphID(rawValue: instance!.glyphCount), instance!.id)",
  "case .realizationTail: return .realization(metricsDescriptor!.realizationCount)",
  "GlyphID(rawValue: realization!.glyphCount), realization!.id",
  "case .requiredAvailable, .available: return .available(realization!.id)",
  "case .availabilityTail:",
  "payloadSHA256.update(with: byte)",
  "return predicates.result",
].freeze
required_traversals.each do |fragment|
  fail_check("validator lacks #{fragment}") unless engine.include?(fragment)
end
fail_check("generic facade does not consume the shared engine") unless
  source.include?("var engine = TextResourceValidationEngine(requiring: requiredRealization)")
fail_check("validation omits the separate complete canonical digest") unless
  source.include?("case .manifest: engine.acceptManifest(canonicalManifestDigest(of: resourcePackage))")

puts "SPEC-005 validator check passed: nine precedence classes and complete bounded traversals are present."
