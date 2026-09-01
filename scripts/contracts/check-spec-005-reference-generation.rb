#!/usr/bin/env ruby
# frozen_string_literal: true

require "digest"
require "json"
require "pathname"

ROOT = Pathname.new(File.expand_path("../..", __dir__))
PINS_PATH = ROOT.join("scripts/text-resources/reference-generation-pins.json")
GENERATED_ROOT = ROOT.join("Sources/GiftUIReferenceTextResources/Generated")
PROVENANCE_INVENTORY = ROOT.join(
  "Tests/ContractFixtures/SPEC005/Evidence/milestone-3/reference-provenance.tsv"
)

def fail_check(message)
  warn "SPEC-005 reference generation check failed: #{message}"
  exit 1
end

def sha256(path)
  Digest::SHA256.file(path).hexdigest
end

pins = JSON.parse(PINS_PATH.read)
manifest_path = GENERATED_ROOT.join("generation-manifest.json")
fail_check("generation manifest is missing") unless manifest_path.file?
manifest = JSON.parse(manifest_path.read)

expected_inputs = {
  "sourceFontSHA256" => "40d692fce188e4471e2b3cba937be967878f631ad3ebbbdcd587687c7ebe0c82",
  "licenseSHA256" => "262481e844521b326f5ecd053e59b98c8b2da78c8ee1bdbb6e8174305e54935a"
}
expected_tools = {
  "python" => "3.9.6",
  "fontTools" => "4.60.2",
  "Pillow" => "11.3.0",
  "FreeType" => "2.13.3"
}
expected_resource = {
  "bitmapPayloadSHA256" => "69cf6841d1ecd25079a63f3dcc6866c119cd11ca4c62115185af99781d13af68",
  "canonicalManifestByteCount" => 6218,
  "glyphCount" => 102,
  "mappingCount" => 96,
  "outlinePayloadSHA256" => "3d05ced8a32b17a45569b6650ea4fe88b1f2f0dc93493e79631a628d56df4c5f",
  "resourceID" => "bd14de9ff2baaaf464c130d5e2d0554004a4055cc57a8c16a65fe2cc39394910"
}
fail_check("input pins differ") unless pins.fetch("inputs") == expected_inputs
fail_check("tool pins differ") unless pins.fetch("tools") == expected_tools
fail_check("adopted resource pins differ") unless pins.fetch("adopted") == expected_resource
fail_check("manifest input pins differ") unless manifest.fetch("inputs") == expected_inputs
fail_check("manifest tool pins differ") unless manifest.fetch("tools") == expected_tools
fail_check("manifest resource identity differs") unless manifest.fetch("resource") == expected_resource
fail_check("derived family name differs") unless manifest.fetch("derivedName") == "GiftUI Reference Sans"
fail_check("license declaration differs") unless manifest.fetch("license") == "SIL Open Font License 1.1"
fail_check("upstream declaration differs") unless manifest.fetch("upstream") == {
  "project" => "Inter", "version" => "4.1"
}

source = ROOT.join("ThirdParty/Inter-4.1/Inter-Regular.ttf")
license = ROOT.join("ThirdParty/Inter-4.1/LICENSE.txt")
fail_check("checked-in Inter source is missing") unless source.file?
fail_check("checked-in OFL text is missing") unless license.file?
fail_check("checked-in Inter source hash differs") unless sha256(source) == expected_inputs["sourceFontSHA256"]
fail_check("checked-in OFL hash differs") unless sha256(license) == expected_inputs["licenseSHA256"]

provenance_readme = ROOT.join("ThirdParty/Inter-4.1/README.md")
fail_check("production provenance README is missing") unless provenance_readme.file?
provenance_text = provenance_readme.read
[
  "Inter Project Authors",
  "extras/ttf/Inter-Regular.ttf",
  expected_inputs["sourceFontSHA256"],
  expected_inputs["licenseSHA256"],
  "GiftUI Reference Sans",
  "scripts/text-resources/verify-reference-generation.sh --verify",
  "not legal advice"
].each do |fragment|
  fail_check("production provenance lacks #{fragment.inspect}") unless provenance_text.include?(fragment)
end

inventory_rows = PROVENANCE_INVENTORY.each_line.with_index(1).each_with_object([]) do |(line, line_number), rows|
  next if line.start_with?("#") || line.strip.empty?
  fields = line.chomp.split("\t", -1)
  fail_check("provenance inventory line #{line_number} must have four fields") unless fields.length == 4
  rows << fields
end
fail_check("provenance inventory must contain eleven rows") unless inventory_rows.length == 11
paths = inventory_rows.map { |row| row[1] }
fail_check("provenance inventory paths must be unique") unless paths.uniq.length == paths.length
inventory_rows.each do |classification, relative, expected_bytes, expected_hash|
  fail_check("unknown provenance classification #{classification.inspect}") unless
    %w[source license generator pin workflow generated manifest].include?(classification)
  path = ROOT.join(relative)
  fail_check("provenance inventory path is missing: #{relative}") unless path.file?
  fail_check("provenance byte count differs: #{relative}") unless path.size == Integer(expected_bytes, 10)
  fail_check("provenance SHA-256 differs: #{relative}") unless sha256(path) == expected_hash
end

expected_outputs = %w[
  ReferenceBitmapPayload.generated.swift
  ReferenceCatalogue.generated.swift
  ReferenceOutlinePayload.generated.swift
]
outputs = manifest.fetch("outputs")
fail_check("generated output names differ") unless outputs.keys.sort == expected_outputs
actual_files = GENERATED_ROOT.children.select(&:file?).map(&:basename).map(&:to_s).sort
fail_check("generated directory contains an unexpected file") unless actual_files ==
  (expected_outputs + ["generation-manifest.json"]).sort
outputs.each do |name, facts|
  path = GENERATED_ROOT.join(name)
  fail_check("generated output is missing: #{name}") unless path.file?
  fail_check("generated byte count differs: #{name}") unless path.size == facts.fetch("bytes")
  fail_check("generated SHA-256 differs: #{name}") unless sha256(path) == facts.fetch("sha256")
  fail_check("generated header differs: #{name}") unless path.each_line.first ==
    "// Generated by scripts/text-resources/generate-reference-resources.py. Do not edit.\n"
end

catalogue = GENERATED_ROOT.join("ReferenceCatalogue.generated.swift").read
fail_check("generated resource descriptor is absent") unless catalogue.include?("static let descriptor = TextResourceDescriptor(")
fail_check("generated instance descriptor is absent") unless catalogue.include?("static let instanceDescriptor = FontInstanceDescriptor(")
fail_check("generated mapping row count differs") unless catalogue.scan(/case \d+: return ScalarGlyphMappingRecord/).length == 96
fail_check("generated metric row count differs") unless catalogue.scan(/case \d+: return GlyphMetrics/).length == 102
fail_check("generated raster-record row count differs") unless catalogue.scan(/case \(\d+, \d+\): return GlyphRasterRecord/).length == 204

{
  "ReferenceBitmapPayload.generated.swift" => 1911,
  "ReferenceOutlinePayload.generated.swift" => 13_195
}.each do |name, byte_count|
  payload_source = GENERATED_ROOT.join(name).read
  fail_check("generated payload byte count differs: #{name}") unless
    payload_source.scan(/0x[0-9a-f]{2} as UInt8/).length == byte_count
end

puts "SPEC-005 reference generation check passed: exact source, license, provenance, pins, tables, payloads, and identity."
