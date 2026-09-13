#!/usr/bin/env ruby
# frozen_string_literal: true

require "json"
require "pathname"
require_relative "spec014_fixture_loader"

FIELDS = %w[
  fixtureID descriptor effectiveCapability header orderedRegions encodedImage
  offerResult bodyResult health highWater failures
].freeze

def fail_report(message)
  warn "SPEC-014 normalized fixture report failed: #{message}"
  exit 1
end

def canonical(value)
  case value
  when Hash
    value.keys.sort.to_h { |key| [key, canonical(value.fetch(key))] }
  when Array
    value.map { |item| canonical(item) }
  else
    value
  end
end

fail_report("usage: report-spec-014-normalized-fixtures.rb PROFILE OUTPUT") unless ARGV.length == 2
profile = ARGV.fetch(0)
fail_report("unknown profile") unless SPEC014::PROFILES.include?(profile)
output = Pathname.new(ARGV.fetch(1))
root = Pathname.new(File.expand_path("../..", __dir__))
loader = SPEC014::FixtureLoader.new(root.join("Tests/ContractFixtures/SPEC014")).load!

rows = loader.cases_by_id.each_with_object([]) do |(id, entry), result_rows|
  fixture = entry.fetch("case")
  profiles = fixture.fetch("profiles")
  next unless SPEC014::PROFILES.all? { |name| profiles.include?(name) }

  values = {
    "fixtureID" => id,
    "descriptor" => fixture.fetch("descriptor"),
    "effectiveCapability" => fixture.fetch("effectiveCapability"),
    "header" => fixture.fetch("header"),
    "orderedRegions" => fixture.fetch("orderedRegions"),
    "encodedImage" => fixture.fetch("encodedImage"),
    "offerResult" => fixture.fetch("offerResult"),
    "bodyResult" => fixture.fetch("bodyResult"),
    "health" => fixture.fetch("health"),
    "highWater" => fixture.fetch("highWater"),
    "failures" => fixture.fetch("injectedEvents"),
  }
  result_rows << FIELDS.map do |field|
    field == "fixtureID" ? id : JSON.generate(canonical(values.fetch(field)))
  end
end
fail_report("no shared four-profile fixtures") if rows.empty?

output.dirname.mkpath
output.write(FIELDS.join("\t") + "\n" + rows.map { |row| row.join("\t") }.join("\n") + "\n")
puts "SPEC-014 #{profile} normalized #{rows.length} shared four-profile fixture IDs."
