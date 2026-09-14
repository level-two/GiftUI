#!/usr/bin/env ruby
# frozen_string_literal: true

require "pathname"

ROOT = Pathname.new(File.expand_path("../..", __dir__))
FIXTURE = ROOT.join("Tests/ContractFixtures/SPEC008/button-coexistence.tsv")
SPEC = ROOT.join("docs/specs/spec-011-interaction.md")
TEST = ROOT.join("Tests/GiftUIRenderLoweringTests/RenderPreflightTests.swift")
RENDER_SURFACES = %w[
  Sources/GiftUISemanticCore/SemanticRenderView.swift
  Sources/GiftUIRenderCore/RenderOperationSink.swift
  Sources/GiftUIRenderCore/RenderValues.swift
  Sources/GiftUIRenderLowering/RenderPreflight.swift
  Sources/GiftUIRenderLowering/RenderStreaming.swift
  Sources/GiftUIRenderLowering/RenderProducer.swift
].map { |path| ROOT.join(path) }

def fail_check(message)
  warn "SPEC-008 Button coexistence check failed: #{message}"
  exit 1
end

rows = FIXTURE.each_line.each_with_object([]) do |line, values|
  next if line.start_with?("#") || line.strip.empty?

  fields = line.chomp.split("\t", -1)
  fail_check("Button fixture row width differs") unless fields.length == 4
  values << fields
end

render_facts = %w[label foreground background painter-order]
interaction_facts = %w[disabled hit-geometry action-identity pointer-capture dispatch hit-map]
fail_check("Button fixture fact set differs") unless rows.map(&:first) == render_facts + interaction_facts
fail_check("visual facts do not remain in SPEC-008") unless
  rows.first(render_facts.length).all? { |row| row[1] == "SPEC-008" && row[3] == "included" }
fail_check("runtime facts escaped SPEC-011") unless
  rows.last(interaction_facts.length).all? { |row| row[1] == "SPEC-011" && row[3] == "excluded" }

spec = SPEC.read
fail_check("SPEC-011 is not approved for implementation") unless
  spec.match?(/\A---\n.*?\nstatus: (?:approved|implementing)\n/m)
fail_check("SPEC-011 does not keep enabled state backend-independent") unless
  spec.match?(/Effective enabled state .* independent of backend behavior/m)
fail_check("SPEC-011 does not own hit maps and pointer gestures") unless
  spec.match?(/`GiftUIInteraction` owns effective enabled lowering, bound records, hit maps,\s+pointer gesture resolution/m)
fail_check("SPEC-011 backend prohibition differs") unless
  spec.match?(/Backends MUST NOT receive Buttons, disabled scopes, action values, handlers,\s+hit maps, records, captures, target generations, or models/m)

forbidden = /\b(?:Button|disabled|actionIdentity|CapturedAction|pointerCapture|hitMap|dispatch)\b/
RENDER_SURFACES.each do |path|
  fail_check("#{path.relative_path_from(ROOT)} consumes or publishes runtime interaction state") if
    path.read.match?(forbidden)
end

test = TEST.read
test_body = test[/func visualButtonProjectionLowersOnlyLabelStylesAndPainterOrder\(\).*?\n}\n/m]
fail_check("visual Button projection fixture is missing") unless test_body
fail_check("visual Button projection does not use the canonical semantic/layout views") unless
  test_body.include?("DirectRenderFixtures.validSemantic") &&
    test_body.include?("DirectRenderFixtures.validLayout")
fail_check("visual Button projection does not prove background-before-label order") unless
  test_body.index(".fill(") && test_body.index(".beginGlyphs(") &&
    test_body.index(".fill(") < test_body.index(".beginGlyphs(")
runtime_state = /\b(?:disabled|actionIdentity|CapturedAction|pointerCapture|hitMap|dispatch)\b/
fail_check("visual Button projection contains runtime interaction state") if test_body.match?(runtime_state)

puts "SPEC-008 Button coexistence passed: only label/style/painter facts lower, while hit-map and interaction authority remain absent from rendering."
