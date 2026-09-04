#!/usr/bin/env ruby
# frozen_string_literal: true

def fail_check(message)
  warn "SPEC-005 static-path check failed: #{message}"
  exit 1
end

fail_check("expected allocation output, production source, and probe source") unless ARGV.length == 3
allocation_path, production_path, probe_path = ARGV
allocation = File.read(allocation_path)
production = File.read(production_path)
probe = File.read(probe_path)

operations = %w[
  validation
  mapping
  metric_lookup
  raster_lookup
  payload_borrow
  synchronous_offer
  combined
]
operations.each do |operation|
  row = allocation.lines.grep(/^allocation_count\.#{Regexp.escape(operation)}=/)
  fail_check("#{operation} allocation row is missing or duplicated") unless row.length == 1
  fail_check("#{operation} allocated heap storage") unless row.first == "allocation_count.#{operation}=0\n"
end
fail_check("aggregate allocation count is not zero") unless allocation.lines.include?("allocation_count=0\n")

forbidden_source = {
  "Foundation import" => /^import Foundation$/,
  "Objective-C interoperation" => /@objc|NSObject|ObjectiveC/,
  "Task" => /\bTask\b/,
  "MainActor" => /\bMainActor\b/,
  "reflection" => /\bMirror\b|_typeName|reflecting:/,
  "runtime discovery" => /dlopen|dlsym|NSClassFromString/,
  "desktop concurrency" => /DispatchQueue|NSLock|pthread_/,
  "unrestricted existential storage" => /\bany\s+(CanonicalTextMetricsView|TextRasterResourceView)\b/,
}.freeze
forbidden_source.each do |label, pattern|
  fail_check("production source contains #{label}") if production.match?(pattern)
end

%w[
  TextResourceValidator.validate(
  mapScalar(
  metrics(
  record(
  withPayload(
  offerStaticPositionedGlyph(
].each do |fragment|
  fail_check("allocation probe does not exercise #{fragment}") unless probe.include?(fragment)
end

puts "SPEC-005 static-path check passed: seven named paths allocate zero bytes and prohibited runtime facilities are absent."
