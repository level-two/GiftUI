#!/usr/bin/env ruby
# frozen_string_literal: true

require "pathname"

ROOT = Pathname.new(File.expand_path("../..", __dir__))
FIXTURE_ROOT = ROOT.join("Tests/ContractFixtures/SPEC006")
MANIFEST = FIXTURE_ROOT.join("fixture-manifest.tsv")
RUNNER = ROOT.join("scripts/contracts/run-spec-006.sh")

def fail_check(message)
  warn "SPEC-006 portable declaration check failed: #{message}"
  exit 1
end

rows = MANIFEST.each_line.reject { |line| line.start_with?("#") || line.strip.empty? }
fixtures = rows.map { |line| line.chomp.split("\t", -1) }

required = %w[
  external-custom-view
  external-invalid-conformance
  builder-zero-through-five
  builder-nested-six
  builder-direct-six
  builder-dynamic-array
  wrapper-initializer-access
  wrapper-storage-access
]
ids = fixtures.map(&:first)
required.each do |id|
  fail_check("fixture manifest lacks #{id}") unless ids.include?(id)
end

fixtures.each do |id, _expectation, access, entry, _patterns, modules|
  next unless required.include?(id)

  fail_check("portable fixture #{id} is not public-client access") unless access == "public"
  fail_check("portable fixture #{id} imports more than GiftUI") unless modules == "GiftUI"
  imports = FIXTURE_ROOT.join(entry).read.scan(/^import (\S+)/).flatten
  fail_check("portable fixture #{id} source imports differ") unless imports == ["GiftUI"]
end

runner = RUNNER.read
%w[macos-dynamic macos-static raspberry-pi-armv6 nrf52840-embedded].each do |profile|
  fail_check("runner lacks #{profile}") unless runner.include?(profile)
end
fail_check("runner does not emit a public interface") unless runner.include?("-emit-module-interface-path")

puts "SPEC-006 portable declarations passed: identical GiftUI-only positive and negative fixtures cover all four profiles and emit a public interface."
