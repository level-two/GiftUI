#!/usr/bin/env ruby
# frozen_string_literal: true

require "digest"

root = File.expand_path("../..", __dir__)
profile = ARGV.fetch(0) { abort "usage: #{$PROGRAM_NAME} <profile> <output>" }
output = ARGV.fetch(1) { abort "usage: #{$PROGRAM_NAME} <profile> <output>" }
profiles = {
  "macos-dynamic" => ["0,1", "0,1"],
  "macos-static" => ["0,1", "0,1"],
  "raspberry-pi-armv6" => ["0,1", "0,1"],
  "nrf52840-embedded" => ["0", "0"]
}
required, available = profiles.fetch(profile) { abort "unknown profile: #{profile}" }

catalogue_path = File.join(root, "Sources/GiftUIReferenceTextResources/Generated/ReferenceCatalogue.generated.swift")
manifest_path = File.join(root, "Sources/GiftUIReferenceTextResources/Generated/generation-manifest.json")
corpus_path = File.join(root, "Tests/ContractFixtures/SPEC005/SemanticCorpus/cases.tsv")
owner_path = File.join(root, "Sources/GiftUITextResourceFailureAdapterFixture/GiftUITextResourceFailureAdapterFixture.swift")
catalogue = File.read(catalogue_path)
manifest = File.read(manifest_path)
owner = File.read(owner_path)

expected_fragments = {
  catalogue => [
    "word0: 0xbd14de9f", "lineMetrics: FontLineMetrics(ascent: 16, descent: 4, lineGap: 0)",
    "scalarValue: 0x0041, glyph: GlyphID(rawValue: 1)",
    "scalarValue: 0x007a, glyph: GlyphID(rawValue: 54)",
    "scalarValue: 0x00b0, glyph: GlyphID(rawValue: 96)",
    "case 0: return GlyphMetrics(advanceX: 11, offsetX: 0, offsetY: -15, inkSize: Size(width: 11, height: 19)!)"
  ],
  manifest => [
    '"resourceID": "bd14de9ff2baaaf464c130d5e2d0554004a4055cc57a8c16a65fe2cc39394910"',
    '"bitmapPayloadSHA256": "69cf6841d1ecd25079a63f3dcc6866c119cd11ca4c62115185af99781d13af68"',
    '"outlinePayloadSHA256": "3d05ced8a32b17a45569b6650ea4fe88b1f2f0dc93493e79631a628d56df4c5f"'
  ],
  owner => ["invalidValue", "invalidIdentity", "capacityExhausted", "hostComposition", "runtime", "contained"]
}
expected_fragments.each do |source, fragments|
  fragments.each { |fragment| abort "semantic source lacks #{fragment}" unless source.include?(fragment) }
end

rows = []
add = ->(scope, domain, id, value) { rows << [scope, domain, id, value].join("\t") }
add.call("logical", "identity", "resource-id", "bd14de9ff2baaaf464c130d5e2d0554004a4055cc57a8c16a65fe2cc39394910")
add.call("logical", "digest", "bitmap", "69cf6841d1ecd25079a63f3dcc6866c119cd11ca4c62115185af99781d13af68")
add.call("logical", "digest", "outline", "3d05ced8a32b17a45569b6650ea4fe88b1f2f0dc93493e79631a628d56df4c5f")
add.call("logical", "catalogue", "counts", "instances=1,glyphs=102,mappings=96,realizations=2,manifest-bytes=6218")
add.call("logical", "mapping", "U+0041", "exact:1")
add.call("logical", "mapping", "U+007A", "exact:54")
add.call("logical", "mapping", "U+00B0", "exact:96")
add.call("logical", "mapping", "U+2603", "replacement:0")
add.call("logical", "metrics", "line", "ascent=16,descent=4,line-gap=0,baseline-step=20")
add.call("logical", "metrics", "glyph-0", "advance=11,offset-x=0,offset-y=-15,width=11,height=19")
add.call("logical", "geometry", "glyph-0-at-20-30", "ink=20,15,11,19;advance=31,30")
add.call("logical", "work", "maximum-comparisons", "256")

File.foreach(corpus_path) do |line|
  next if line.start_with?("#") || line.strip.empty?
  id, domain, _inputs, expected, _evidence = line.chomp.split("\t")
  add.call("logical", "validation:#{domain}", id, expected)
end

%w[unsupportedSchema invalidCount malformedMetrics malformedMapping malformedRasterRecord].each do |error|
  add.call("logical", "owner-map", error, "invalidValue/hostComposition/runtime/contained")
end
%w[invalidIdentity incompatibleViews integrityMismatch].each do |error|
  add.call("logical", "owner-map", error, "invalidIdentity/hostComposition/runtime/contained")
end
add.call("logical", "owner-map", "capacityExceeded", "capacityExhausted/hostComposition/runtime/contained")
add.call("profile", "availability", "required-realizations", required)
add.call("profile", "availability", "available-realizations", available)
add.call("profile", "evidence", "classification", profile.start_with?("macos") ? "host" : "cross-built-hardware-free")

File.write(output, "scope\tdomain\tid\tvalue\n#{rows.join("\n")}\n")
puts "SPEC-005 #{profile} semantic transcript generated: #{rows.length} rows, corpus=#{Digest::SHA256.file(corpus_path).hexdigest}"
