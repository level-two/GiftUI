#!/usr/bin/env ruby
# frozen_string_literal: true

require "pathname"

ROOT = Pathname.new(File.expand_path("../..", __dir__))
BOUNDED_TESTS = ROOT.join("Tests/GiftUITests/BoundedTextTests.swift").read
TEXT_TESTS = ROOT.join("Tests/GiftUITests/TextTests.swift").read
SEMANTIC_TESTS = ROOT.join("Tests/GiftUISemanticCoreTests/SemanticLayoutResultAdapterTests.swift").read
LAYOUT_TESTS = ROOT.join("Tests/GiftUILayoutTests/LayoutCollaborationTests.swift").read
LAYOUT_SOURCE = ROOT.join("Sources/GiftUILayout/Layout.swift").read
PROBE = ROOT.join("Tests/ContractFixtures/SPEC008/Instrumentation/DeclarationProbe/main.swift").read
DRIVER = ROOT.join("scripts/contracts/check-spec-008-declaration-profiles.sh").read

def fail_check(message)
  warn "SPEC-008 text integration check failed: #{message}"
  exit 1
end

required_bounded_fragments = [
  "count: 96",
  "payload + [UInt8(ascii: \"b\")]",
  "EmptyCollection<UInt8>()",
  "0xC2, 0xB0",
  "0xEF, 0xBF, 0xBD",
  "[0x80]",
  "[0xC0, 0x80]",
  "[0xE0, 0x80, 0x80]",
  "[0xED, 0xA0, 0x80]",
  "[0xF0, 0x80, 0x80, 0x80]",
  "[0xF4, 0x90, 0x80, 0x80]",
  "[0xF5, 0x80, 0x80, 0x80]",
  "[0xE2, 0x82]",
  "[0xF0, 0x9F, 0x8E]",
  "BoundedText(\"gi\\0ft\")",
  "BoundedText(\"gift\\0\\0\")",
  "(Int32.min, \"-2147483648\")",
  "(-1, \"-1\")",
  "(0, \"0\")",
  "(1, \"1\")",
  "(Int32.max, \"2147483647\")",
]
required_bounded_fragments.each do |fragment|
  fail_check("bounded UTF-8/integer matrix lacks #{fragment}") unless BOUNDED_TESTS.include?(fragment)
end

fail_check("Text does not preserve exact admitted bytes") unless TEXT_TESTS.include?("[0x41, 0xC2, 0xB0]")
fail_check("oversized literal marker test is absent") unless TEXT_TESTS.include?("oversizedTextLiteralStoresOnlyInvalidDeclarationMarker") && TEXT_TESTS.include?(".invalidDeclaration")
fail_check("semantic invalid marker propagation is absent") unless SEMANTIC_TESTS.include?("invalidTextMarkerRemainsInvalidInTheSharedLayoutProjection") && SEMANTIC_TESTS.include?("0xd800")
fail_check("layout/render suppression integration is absent") unless LAYOUT_TESTS.include?("invalidTextDeclarationStopsBeforeLayoutPublicationOrRenderInvocation") && LAYOUT_TESTS.include?("#expect(sink.beginCount == 0)") && LAYOUT_TESTS.include?("#expect(renderInvocationCount == 0)")

validation = LAYOUT_SOURCE.index("validation.validate(")
measurement = LAYOUT_SOURCE.index("engine.measure(")
publication = LAYOUT_SOURCE.index("publishLayout(")
fail_check("layout validation does not precede measurement/publication") unless validation && measurement && publication && validation < measurement && measurement < publication

probe_fragments = [
  "BoundedText(\"\")",
  "BoundedText(maximum)",
  "BoundedText(oversized) == nil",
  "BoundedText(utf8: $0) == nil",
  "BoundedText(\"A\\0B\")",
  "matchesTrailingNull",
  "BoundedText(\"ASCII\")",
  "BoundedText(\"°\")",
  "BoundedText(\"�\")",
  "BoundedText(Int32.min)",
  "BoundedText(Int32.max)",
  "Text(oversized)._giftUITraverse(&visitor)",
]
probe_fragments.each do |fragment|
  fail_check("profile probe lacks #{fragment}") unless PROBE.include?(fragment)
end
%w[allocation_count=0 trap_count=0 primitive_visit_count=2].each do |expectation|
  fail_check("profile driver lacks #{expectation}") unless DRIVER.include?(expectation)
end

puts "SPEC-008 text integration passed: UTF-8, Int32, invalid marker, layout rejection, and zero render invocation"
