#!/usr/bin/env ruby
# frozen_string_literal: true

require "pathname"
require "yaml"

ROOT = Pathname.new(File.expand_path("../..", __dir__))
FIXTURE_ROOT = ROOT.join("Tests/ContractFixtures/SPEC014")
SPEC004_CASES = ROOT.join(
  "Tests/ContractFixtures/SPEC004/SemanticCorpus/cases.tsv"
)

def fail_check(message)
  warn "SPEC-014 capability fixture check failed: #{message}"
  exit 1
end

host_input = YAML.safe_load(FIXTURE_ROOT.join("macos-host-input.yaml").read, aliases: false)
expected_host_input = {
  "schema" => "spec-014-macos-host-input-v1",
  "id" => "spec014-macos-logical-extent-v1",
  "logicalExtent" => { "width" => 640, "height" => 480 },
  "scope" => "paired-test-fixture-only",
  "productionWindowSelection" => false,
}
fail_check("macOS host input differs") unless host_input == expected_host_input

document = YAML.safe_load(FIXTURE_ROOT.join("capabilities.yaml").read, aliases: false)
cases = document.fetch("cases").to_h { |fixture| [fixture.fetch("fixtureID"), fixture] }
expected_ids = %w[
  spec014-macos-dynamic-full-surface
  spec014-macos-static-full-surface
  spec014-raspberry-pi-rgb565-tiled
  spec014-nrf52840-rgb565-tiled
  spec014-nrf52840-full-framebuffer-rejected
]
fail_check("capability fixture IDs differ") unless cases.keys == expected_ids

spec004_rows = SPEC004_CASES.each_line.each_with_object({}) do |line, rows|
  next if line.start_with?("#") || line.strip.empty?

  id, family, input, expected = line.chomp.split("\t", -1)
  rows[id] = [family, input, expected]
end
expected_spec004_rows = {
  "configuration-macos-dynamic" => [
    "configuration", "640,480,1,2",
    "available,31,640,480,640,480,2560,1,2,1,1,1,1228800,1228800,1,1228800",
  ],
  "configuration-macos-static" => [
    "configuration", "640,480,1,2",
    "available,31,640,480,640,480,2560,1,2,1,1,1,1228800,1228800,1,1228800",
  ],
  "configuration-pi-screen" => [
    "configuration", "240,240,2,1",
    "available,31,240,240,240,16,480,1,1,1,1,2,7680,7680,1,7680",
  ],
  "configuration-nrf52840-tft" => [
    "configuration", "480,320,2,1",
    "available,31,480,320,480,4,960,1,1,1,1,2,3840,3840,1,3840",
  ],
  "configuration-nrf52840-full-rgba-negative" => [
    "configuration", "480,320,1,2,3840",
    "unavailable,insufficient-capacity,2,614400,3840",
  ],
}
expected_spec004_rows.each do |id, expected|
  fail_check("SPEC-004 normalized row #{id} differs") unless spec004_rows[id] == expected
end

positive_ids = expected_ids.first(4)
positive_ids.each do |fixture_id|
  fixture = cases.fetch(fixture_id)
  descriptor = fixture.fetch("descriptor")
  effective = fixture.fetch("effectiveCapability")
  fail_check("#{fixture_id} is not available") unless effective["status"] == "available"
  fail_check("#{fixture_id} operation coverage differs") unless effective["operationsRawValue"] == 31
  fail_check("#{fixture_id} extent differs") unless descriptor["extent"] == effective["extent"]
  fail_check("#{fixture_id} region differs") unless descriptor["regionExtent"] == effective["regionExtent"]
  fail_check("#{fixture_id} row bytes differ") unless descriptor["bytesPerRow"] == effective["rowBytes"]
  fail_check("#{fixture_id} encoding differs") unless descriptor["encoding"] == effective["encoding"]
  fail_check("#{fixture_id} realization differs") unless descriptor["realization"] == effective["realization"]
  expected_bytes = effective.fetch("rowBytes") * effective.fetch("regionExtent").fetch("height")
  %w[requiredRasterBytes requiredPayloadBytes requiredInFlightBytes].each do |field|
    fail_check("#{fixture_id} #{field} differs") unless effective[field] == expected_bytes
  end
  fail_check("#{fixture_id} does not use one slot") unless effective["inFlightCount"] == 1
  fail_check("#{fixture_id} leaks runtime profile identity") if effective.keys.any? { |key| key.downcase.include?("profile") }
end

dynamic = cases.fetch("spec014-macos-dynamic-full-surface")
static = cases.fetch("spec014-macos-static-full-surface")
fail_check("macOS fixtures do not share the immutable host input") unless dynamic.dig("descriptor", "hostInput") == host_input["id"] && static.dig("descriptor", "hostInput") == host_input["id"]
fail_check("macOS effective results differ") unless dynamic["effectiveCapability"] == static["effectiveCapability"]
dynamic_descriptor = dynamic.fetch("descriptor").reject { |key, _value| key == "hostInput" }
static_descriptor = static.fetch("descriptor").reject { |key, _value| key == "hostInput" }
fail_check("macOS logical descriptors differ") unless dynamic_descriptor == static_descriptor

pi = cases.fetch("spec014-raspberry-pi-rgb565-tiled").fetch("effectiveCapability")
pi_expected = [240, 240, 240, 16, 480, 7_680]
pi_actual = [
  pi.dig("extent", "width"), pi.dig("extent", "height"),
  pi.dig("regionExtent", "width"), pi.dig("regionExtent", "height"),
  pi["rowBytes"], pi["requiredRasterBytes"],
]
fail_check("Raspberry Pi selected geometry differs") unless pi_actual == pi_expected

nrf_fixture = cases.fetch("spec014-nrf52840-rgb565-tiled")
nrf = nrf_fixture.fetch("effectiveCapability")
nrf_expected = [480, 320, 480, 4, 960, 3_840, 3_840, 1, 3_840]
nrf_actual = [
  nrf.dig("extent", "width"), nrf.dig("extent", "height"),
  nrf.dig("regionExtent", "width"), nrf.dig("regionExtent", "height"),
  nrf["rowBytes"], nrf["requiredRasterBytes"], nrf["requiredPayloadBytes"],
  nrf["inFlightCount"], nrf["requiredInFlightBytes"],
]
fail_check("nRF52840 selected geometry or storage differs") unless nrf_actual == nrf_expected
fail_check("nRF52840 fixture admits a framebuffer") unless nrf_fixture.dig("operationsResources", "completeFramebuffer") == false && nrf_fixture.dig("highWater", "surfaceBytes").zero?

negative = cases.fetch("spec014-nrf52840-full-framebuffer-rejected")
negative_expected = {
  "status" => "unavailable",
  "reason" => "insufficientCapacity",
  "domain" => "raster",
  "requiredBytes" => 614_400,
  "availableBytes" => 3_840,
}
fail_check("nRF52840 framebuffer rejection differs") unless negative["effectiveCapability"] == negative_expected
fail_check("nRF52840 rejection records framebuffer bytes") unless negative.dig("highWater", "admittedFramebufferBytes").zero?

puts "SPEC-014 capability fixtures passed: four exact profiles and one nRF framebuffer rejection."
