#!/usr/bin/env ruby
# frozen_string_literal: true

require "digest"
require "pathname"
require "yaml"

ROOT = Pathname.new(File.expand_path("../..", __dir__))
OBSERVABLE_INPUT = ROOT.join(
  "Tests/ContractFixtures/SPEC010/MacroExpansion/Expected/portable-profile.swift"
)
CANVAS_INPUT = ROOT.join("Tests/ContractFixtures/SPEC012/static-canvas-manifest.yaml")
GENERATED = ROOT.join(
  "Tests/GiftUIRuntimeStaticTests/GeneratedStaticProfileFixture.swift"
)

def fail_check(message)
  warn "SPEC-013 generated Static fixture failed: #{message}"
  exit 1
end

observable_digest = Digest::SHA256.file(OBSERVABLE_INPUT).hexdigest
canvas_digest = Digest::SHA256.file(CANVAS_INPUT).hexdigest
source = GENERATED.read
manifest = YAML.safe_load(CANVAS_INPUT.read, aliases: false)

fail_check("observable input digest provenance differs") unless source.include?(observable_digest)
fail_check("Canvas input digest provenance differs") unless source.include?(canvas_digest)

slot_count = OBSERVABLE_INPUT.read.scan(/visitor\.visit\(&_[a-zA-Z0-9_]+, declarationOrdinal: \d+\)/).length
fail_check("generated observable slot count differs") unless
  source.include?("let slotCount: UInt16 = #{slot_count}")
(0...slot_count).each do |slot|
  fail_check("generated observable slot #{slot} is not covered exactly once") unless
    source.scan(/^        case #{slot}:/).length >= 1
end

case_count = manifest.fetch("callable_case_count")
fail_check("generated callable case count differs") unless
  source.include?("let callableCaseCount: UInt16 = #{case_count}")
manifest.fetch("callable_cases").each do |callable_case|
  id = callable_case.fetch("id")
  bytes = callable_case.fetch("capture_byte_count")
  fail_check("capture byte count for ID #{id} differs") unless
    source.include?("case #{id}: #{bytes}")
end

coverage_body = source[/struct GeneratedCanvasCoverage:.*?^}/m]
fail_check("generated coverage table is missing") unless coverage_body
fail_check("generated coverage is incomplete") unless
  coverage_body.include?("case 1, 2, 3: 1")
fail_check("generated source contains a closure fallback") if
  source.match?(/@escaping|\[\s*GeneratedCanvasCaptureStorage\s*\]/)

puts "SPEC-013 generated Static fixture passed: #{slot_count} observable slots, " \
  "#{case_count} callable IDs, #{GENERATED.size} generated source bytes, stable input digests."
