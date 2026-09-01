#!/usr/bin/env ruby
# frozen_string_literal: true

require "digest"
require "json"

ROOT = File.expand_path("../..", __dir__)
SPIKE_ROOT = File.join(ROOT, "experiments/spike-005-inter-reference-font")
INVENTORY = File.join(
  ROOT,
  "Tests/ContractFixtures/SPEC005/Evidence/milestone-0/baseline-input-inventory.tsv"
)

def fail_check(message)
  warn "SPEC-005 adopted input check failed: #{message}"
  exit 1
end

rows = File.readlines(INVENTORY, chomp: true).each_with_object([]) do |line, selected|
  next if line.empty? || line.start_with?("#")

  fields = line.split("\t", -1)
  fail_check("inventory row must have four fields: #{line.inspect}") unless fields.length == 4
  selected << fields
end
paths = rows.map { |row| row[1] }
fail_check("inventory paths must be unique") unless paths.uniq.length == paths.length
rows.each do |classification, relative, expected_hash, byte_count|
  fail_check("unknown classification #{classification.inspect}") unless %w[
    adopted-source adopted-license adopted-package-byte adopted-package-records
    provenance-evidence calibration-evidence derivation-pin disposable-mechanism
  ].include?(classification)
  path = File.join(ROOT, relative)
  fail_check("inventory path is missing: #{relative}") unless File.file?(path)
  fail_check("byte count differs for #{relative}") unless File.size(path) == Integer(byte_count, 10)
  actual_hash = Digest::SHA256.file(path).hexdigest
  fail_check("SHA-256 differs for #{relative}") unless actual_hash == expected_hash
end

load_json = lambda do |relative|
  JSON.parse(File.read(File.join(SPIKE_ROOT, relative)))
rescue JSON::ParserError => error
  fail_check("#{relative}: #{error.message}")
end

provenance = load_json.call("generated/PROVENANCE.json")
expected_provenance = {
  "upstreamVersion" => "4.1",
  "upstreamReleaseArchiveSHA256" => "9883fdd4a49d4fb66bd8177ba6625ef9a64aa45899767dde3d36aa425756b11e",
  "selectedArchiveMember" => "extras/ttf/Inter-Regular.ttf",
  "selectedSourceSHA256" => "40d692fce188e4471e2b3cba937be967878f631ad3ebbbdcd587687c7ebe0c82",
  "license" => "SIL Open Font License 1.1",
  "derivedResourceName" => "GiftUI Reference Sans",
  "reproductionCommand" => "experiments/spike-005-inter-reference-font/run.sh --verify"
}
expected_provenance.each do |key, expected|
  fail_check("provenance #{key} differs") unless provenance[key] == expected
end
derivation = provenance.fetch("derivation")
{
  "fontTools" => "4.60.2",
  "Pillow" => "11.3.0",
  "FreeType" => "2.13.3",
  "pixelSize" => 16,
  "requiredScalars" => "U+0020...U+007E, U+00B0"
}.each do |key, expected|
  fail_check("derivation #{key} differs") unless derivation[key] == expected
end

measurements = load_json.call("evidence/measurements.json")
{
  "mappingCount" => 96,
  "glyphCount" => 102,
  "canonicalManifestBytes" => 6218,
  "bitmapPayloadBytes" => 1911,
  "outlinePayloadBytes" => 13195,
  "sourceFontBytes" => 411640,
  "subsetFontBytes" => 20752,
  "resourceID" => "bd14de9ff2baaaf464c130d5e2d0554004a4055cc57a8c16a65fe2cc39394910",
  "result" => "pass"
}.each do |key, expected|
  fail_check("measurement #{key} differs") unless measurements[key] == expected
end

coverage = load_json.call("evidence/coverage.json")
fail_check("coverage result differs") unless coverage == {
  "actualMappingCount" => 96,
  "missing" => [],
  "replacementGlyph" => 0,
  "replacementSourceGlyphName" => ".notdef",
  "requiredMappingCount" => 96,
  "result" => "pass",
  "unexpected" => []
}

toolchain = load_json.call("evidence/toolchain.json")
{
  "python" => "3.9.6",
  "pythonImplementation" => "CPython",
  "fontTools" => "4.60.2",
  "Pillow" => "11.3.0",
  "FreeType" => "2.13.3"
}.each do |key, expected|
  fail_check("toolchain #{key} differs") unless toolchain[key] == expected
end

expected_nrf = <<~TSV
  metric\tbaseline\tcandidate\tdelta\tceiling
  linked_flash_bytes\t22836\t32060\t9224\t98304
  linked_ram_bytes\t4988\t4988\t0\t512
  bss_bytes\t1013\t1013\t0\t512
  data_bytes\t28\t28\t0\t512
  validation_stack_bytes\t0\t568\t568\t1024
TSV
nrf_measurements = File.read(File.join(SPIKE_ROOT, "evidence/nrf52840/measurements.tsv"))
fail_check("nRF calibration differs") unless nrf_measurements == expected_nrf
host_validation = File.read(File.join(SPIKE_ROOT, "evidence/nrf52840/host-validation.txt"))
fail_check("host validation transcript differs") unless host_validation == "nominal=0 manifest_tamper=2 bitmap_tamper=3\n"

disposable = rows.select { |row| row[0] == "disposable-mechanism" }.map { |row| row[1] }
fail_check("disposable generator is not classified") unless disposable.include?("experiments/spike-005-inter-reference-font/generate.py")
fail_check("disposable validator is not classified") unless disposable.include?("experiments/spike-005-inter-reference-font/nrf/candidate/validator.c")

puts "SPEC-005 adopted input check passed: #{rows.length} hashed inputs, exact provenance/counts, and nRF calibration."
