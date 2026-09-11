#!/usr/bin/env ruby
# frozen_string_literal: true

require "pathname"

ROOT = Pathname.new(File.expand_path("../..", __dir__))
FIXTURE = ROOT.join("Tests/ContractFixtures/SPEC008/canvas-coexistence.tsv")
SPEC = ROOT.join("docs/specs/spec-012-canvas-path-stroke-drawing.md")
PLAN = ROOT.join("docs/implementation-plans/spec-012-implementation-plan.md")
DECLARATIONS = ROOT.join("Sources/GiftUI/DeclarativeView.swift")
SCOPES = ROOT.join("Sources/GiftUISemanticCore/SemanticRenderView.swift")
SINK = ROOT.join("Sources/GiftUIRenderCore/RenderOperationSink.swift")
ORDINARY_TEST = ROOT.join("Tests/GiftUIRenderLoweringTests/RenderPreflightTests.swift")
BASE_CONTRACT = %w[
  Tests/ContractFixtures/SPEC008/required-evidence.tsv
  Tests/ContractFixtures/SPEC008/recording-events.tsv
  Tests/ContractFixtures/SPEC008/fixtures.yaml
  Tests/ContractFixtures/SPEC008/signal-analyzer.yaml
].map { |path| ROOT.join(path) }

def fail_check(message)
  warn "SPEC-008 Canvas coexistence check failed: #{message}"
  exit 1
end

rows = FIXTURE.each_line.each_with_object([]) do |line, values|
  next if line.start_with?("#") || line.strip.empty?

  fields = line.chomp.split("\t", -1)
  fail_check("coexistence row width differs") unless fields.length == 4
  values << fields
end
fail_check("coexistence boundaries differ") unless rows.map(&:first) == %w[
  semantic-declaration semantic-render-scope ordered-operation-sink ordinary-production
]
fail_check("future integration escaped SPEC-012") unless rows.all? { |row| row[3].start_with?("SPEC-012-") }

spec = SPEC.read
plan = PLAN.read
fail_check("SPEC-012 is not approved") unless spec.match?(/\A---\n.*?\nstatus: approved\n/m)
fail_check("SPEC-012 does not preserve pre-existing cases and results") unless
  spec.match?(/without changing any\s+previous case, raw value, traversal order, or non-Canvas result/)
fail_check("SPEC-012 does not own zero-Canvas equivalence") unless
  spec.match?(/both entry points MUST produce identical\s+ordinary-operation transcripts when .* zero\s+Canvas occurrences/m)
fail_check("SPEC-012 plan does not own the executable comparison") unless
  plan.include?("T5.3") &&
    plan.match?(/Prove zero-Canvas ordinary transcripts equal SPEC-008\s+exactly/)

BASE_CONTRACT.each do |path|
  fail_check("#{path.relative_path_from(ROOT)} contains Canvas/stroke contract") if
    path.read.match?(/\b(?:canvas|stroke)\b/i)
end

declarations = DECLARATIONS.read
fail_check("generic primitive payload extension point is missing") unless
  declarations.include?("public protocol _GiftUISemanticPrimitivePayload {}") &&
    declarations.include?("visitPrimitive<Payload: _GiftUISemanticPrimitivePayload>")

scopes = SCOPES.read
ordinary_cases = scopes.scan(/^    case (structural|clipBoundary|text|foregroundStyle|background)\b/).flatten
fail_check("ordinary semantic render cases changed") unless ordinary_cases == %w[
  structural clipBoundary text foregroundStyle background
]
fail_check("Canvas prematurely entered the SPEC-008 semantic render scope") if scopes.match?(/\bcanvas\b/i)

sink = SINK.read
required_sink_calls = %w[begin fillRect beginPositionedGlyphs positionedGlyph endPositionedGlyphs finish discard]
fail_check("ordinary sink surface changed") unless required_sink_calls.all? { |name| sink.include?("func #{name}") }
fail_check("stroke prematurely entered the SPEC-008 sink") if sink.match?(/\bstroke\b/i)

ordinary_test = ORDINARY_TEST.read
fail_check("exact ordinary transcript fixture is missing") unless
  ordinary_test.include?("func streamingRepeatsCanonicalLookupsAndEmitsTheExactOrderedValues()") &&
    ordinary_test.include?("sink.events == [") &&
    ordinary_test.include?(".fill(") && ordinary_test.include?(".beginGlyphs(") &&
    ordinary_test.include?(".glyph(") && ordinary_test.include?(".finish")
fail_check("ordinary transcript fixture contains Canvas/stroke behavior") if
  ordinary_test[/func streamingRepeatsCanonicalLookupsAndEmitsTheExactOrderedValues\(\).*?\n}\n/m]
    &.match?(/\b(?:canvas|stroke)\b/i)

puts "SPEC-008 Canvas coexistence passed: the base contract stays ordinary-only, extension points remain available, and SPEC-012 retains combined-production ownership."
