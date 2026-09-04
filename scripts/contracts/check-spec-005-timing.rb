#!/usr/bin/env ruby
# frozen_string_literal: true

def fail_check(message)
  warn "SPEC-005 timing check failed: #{message}"
  exit 1
end

fail_check("expected timing output and probe source") unless ARGV.length == 2
rows = File.readlines(ARGV.fetch(0), chomp: true).to_h { |line| line.split("=", 2) }
source = File.read(ARGV.fetch(1))

expected = {
  "schema_version" => "1",
  "evidence" => "host-executed",
  "representative_scalar_count" => "103",
  "maximum_scalar_count" => "4096",
  "sample_count" => "9",
  "interval_limit_ns" => "250000000",
  "layout_ns" => "not_measured_owned_by_SPEC-007",
  "raster_ns" => "not_measured_owned_by_SPEC-014",
  "cache_ns" => "not_measured_owned_by_SPEC-014",
  "transfer_ns" => "not_measured_owned_by_SPEC-014"
}
expected.each { |key, value| fail_check("#{key} differs") unless rows[key] == value }
%w[representative_worst_ns maximum_worst_ns checksum].each do |key|
  fail_check("#{key} is missing or nonnumeric") unless rows[key]&.match?(/\A\d+\z/)
end
limit = Integer(rows.fetch("interval_limit_ns"), 10)
%w[representative_worst_ns maximum_worst_ns].each do |key|
  fail_check("#{key} does not fit the interval") unless Integer(rows.fetch(key), 10) < limit
end
forbidden_calls = {
  "validation" => /TextResourceValidator\.validate\s*\(/,
  "layout" => /\blayout\s*\(/,
  "rasterization" => /\brasterize\s*\(/,
  "cache" => /\bcache\s*\(/,
  "transfer" => /\btransfer\s*\(/
}
forbidden_calls.each do |label, pattern|
  fail_check("timing probe includes out-of-scope #{label}") if source.match?(pattern)
end

puts "SPEC-005 timing check passed: representative and maximum resource-only work fit 250 ms."
