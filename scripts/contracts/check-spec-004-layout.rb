#!/usr/bin/env ruby
# frozen_string_literal: true

CEILINGS = {
  "RasterPresentationRequirement" => 32,
  "RasterRealizationContribution" => 40,
  "RasterBackendContribution" => 88,
  "SurfaceDisplayContribution" => 40,
  "RasterPresentationPolicy" => 32,
  "RasterPresentationContributions" => 192,
  "RasterPresentationResolverWorkspace" => 96,
  "EffectiveRasterPresentation" => 48,
  "RasterPresentationUnavailable" => 16,
  "CapabilitySnapshot" => 56,
}.freeze

def fail_check(message)
  warn "SPEC-004 layout check failed: #{message}"
  exit 1
end

fail_check("expected one probe output path") unless ARGV.length == 1
begin
  lines = File.readlines(ARGV.fetch(0), chomp: true)
rescue Errno::ENOENT => error
  fail_check(error.message)
end

allocation_rows = lines.grep(/^allocation_count=/)
fail_check("allocation row differs: #{allocation_rows.inspect}") unless allocation_rows == ["allocation_count=0"]

observed = {}
lines.grep(/^layout\./).each do |line|
  match = line.match(/\Alayout\.([A-Za-z0-9_]+)=(\d+),(\d+),(\d+)\z/)
  fail_check("malformed layout row: #{line}") unless match
  name = match[1]
  fail_check("duplicate layout row: #{name}") if observed.key?(name)
  observed[name] = match.captures.drop(1).map(&:to_i)
end
fail_check("layout type set differs: #{observed.keys.sort.inspect}") unless observed.keys.sort == CEILINGS.keys.sort

observed.each do |name, (size, stride, alignment)|
  fail_check("#{name} size #{size} exceeds #{CEILINGS.fetch(name)}") if size > CEILINGS.fetch(name)
  fail_check("#{name} stride #{stride} is smaller than size #{size}") if stride < size
  fail_check("#{name} alignment #{alignment} is not a positive power of two") unless
    alignment.positive? && (alignment & (alignment - 1)).zero?
end

puts "SPEC-004 layout check passed: zero measured allocations and #{observed.length} bounded layouts."
