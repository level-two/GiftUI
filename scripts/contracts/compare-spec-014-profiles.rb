#!/usr/bin/env ruby
# frozen_string_literal: true

require "csv"
require "json"
require "pathname"

FIELDS = %w[
  fixtureID descriptor effectiveCapability header orderedRegions encodedImage
  offerResult bodyResult health highWater failures
].freeze

def fail_comparison(message)
  warn "SPEC-014 profile comparison failed: #{message}"
  exit 1
end

def canonical_json(value)
  normalized = case value
  when Hash
    value.keys.sort.to_h { |key| [key, canonical_json(value.fetch(key))] }
  when Array
    value.map { |item| canonical_json(item) }
  else
    value
  end
  normalized
end

fail_comparison("usage: compare-spec-014-profiles.rb OUTPUT PROFILE=RESULTS [PROFILE=RESULTS ...]") unless ARGV.length >= 3
output = Pathname.new(ARGV.shift)
reports = ARGV.to_h do |argument|
  profile, path = argument.split("=", 2)
  fail_comparison("invalid profile input #{argument}") unless profile && path
  fail_comparison("unknown profile #{profile}") unless %w[macos-dynamic macos-static raspberry-pi-armv6 nrf52840-embedded].include?(profile)
  [profile, Pathname.new(path)]
end
fail_comparison("profile inputs are duplicated") unless reports.length == ARGV.length

normalized = reports.transform_values do |path|
  fail_comparison("missing normalized result #{path}") unless path.file?
  table = CSV.read(path, headers: true, col_sep: "\t")
  fail_comparison("normalized field set differs for #{path}") unless table.headers == FIELDS
  rows = table.each_with_object({}) do |row, values|
    id = row.fetch("fixtureID")
    fail_comparison("duplicate fixture ID #{id} in #{path}") if values.key?(id)
    canonical = FIELDS.drop(1).to_h do |field|
      begin
        [field, JSON.generate(canonical_json(JSON.parse(row.fetch(field))))]
      rescue JSON::ParserError
        fail_comparison("#{id} #{field} is not canonical JSON")
      end
    end
    values[id] = canonical
  end
  rows
end

fixture_sets = normalized.values.map { |rows| rows.keys.sort }.uniq
fail_comparison("profile fixture-ID sets differ") unless fixture_sets.length == 1
fixture_ids = fixture_sets.fetch(0)
fixture_ids.each do |id|
  values = normalized.values.map { |rows| rows.fetch(id) }
  fail_comparison("normalized fixture differs: #{id}") unless values.uniq.length == 1
end

output.dirname.mkpath
output.write(
  "fixtureID\tprofiles\tdisposition\n" +
    fixture_ids.map { |id| "#{id}\t#{reports.keys.join(',')}\tidentical" }.join("\n") + "\n"
)
puts "SPEC-014 profiles match by #{fixture_ids.length} stable fixture IDs."
