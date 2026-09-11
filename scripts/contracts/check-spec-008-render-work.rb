#!/usr/bin/env ruby
# frozen_string_literal: true

require "pathname"

ROOT = Pathname.new(File.expand_path("../..", __dir__))
FIXTURE_ROOT = ROOT.join("Tests/ContractFixtures/SPEC008/Instrumentation")
WORK = FIXTURE_ROOT.join("render-work.tsv")
METHODS = FIXTURE_ROOT.join("render-measurement-methods.tsv")
TEST = ROOT.join("Tests/GiftUIRenderLoweringTests/RenderPreflightTests.swift")
LOWERING = ROOT.join("Sources/GiftUIRenderLowering")
PROBE = FIXTURE_ROOT.join("RenderViewBorrowProbe.swift")

def fail_check(message)
  warn "SPEC-008 render work check failed: #{message}"
  exit 1
end

rows = WORK.each_line.each_with_object([]) do |line, result|
  next if line.start_with?("#") || line.strip.empty?

  fields = line.chomp.split("\t", -1)
  fail_check("render-work row width differs") unless fields.length == 6
  result << fields.map { |field| Integer(field, 10) }
end
expected_scales = [[1, 0], [2, 1], [4, 0], [4, 1], [4, 2], [4, 4], [8, 1], [8, 8], [16, 16]]
fail_check("registered work scales differ") unless rows.map { |row| row.first(2) } == expected_scales

rows.each do |occurrences, glyphs, accesses, comparisons, stack_frames, foreground|
  expected_accesses = glyphs.zero? ? 26 * occurrences + 25 : 26 * occurrences + 33 + 2 * glyphs
  fail_check("view-access count differs at #{occurrences}/#{glyphs}") unless accesses == expected_accesses
  fail_check("identity-comparison count differs at #{occurrences}/#{glyphs}") unless comparisons == 4 * occurrences + 1
  fail_check("view work exceeds affine bound") unless accesses <= 33 + 26 * occurrences + 2 * glyphs
  fail_check("identity work exceeds affine bound") unless comparisons <= 1 + 4 * (occurrences + glyphs)
  fail_check("call-stack high-water differs") unless stack_frames == occurrences
  fail_check("foreground high-water differs") unless foreground == 1
end

methods = METHODS.each_line.each_with_object([]) do |line, result|
  next if line.start_with?("#") || line.strip.empty?

  fields = line.chomp.split("\t", -1)
  fail_check("measurement-method row width differs") unless fields.length == 3
  result << fields
end
expected_methods = %w[
  duration view-work identity-work call-stack foreground-stack allocation workspace
  linked-sections link-map
]
fail_check("measurement methods differ") unless methods.map(&:first) == expected_methods
fail_check("duration method or sample count differs") unless
  methods.first[1].include?("ContinuousClock") && methods.first[2] == rows.length.to_s

test_source = TEST.read
start = test_source.index("private struct RenderWorkSemanticView")
finish = test_source.index("private extension RenderProductionResult")
fail_check("direct-index instrumentation conformers are missing") unless start && finish && finish > start
conformers = test_source[start...finish]
fail_check("instrumented accessors rescan admitted results") if
  conformers.match?(/\.first(?:Index|\s*\{|\s*\()|first\s*\(where:|for\s+\w+\s+in/)
fail_check("exact affine assertions are missing") unless
  test_source.include?("26 &* occurrences &+ 33 &+ 2 &* glyphs") &&
    test_source.include?("4 &* occurrences &+ 1")
fail_check("ContinuousClock samples are missing") unless
  test_source.include?("let clock = ContinuousClock()") &&
    test_source.include?("timingSamples.append(started.duration(to: clock.now))")

lowering_source = LOWERING.children.select { |path| path.extname == ".swift" }.map(&:read).join("\n")
fail_check("lowering retains a result-sized collection") if
  lowering_source.match?(/\b(?:Array|ContiguousArray|Dictionary|Set)\s*</)
fail_check("lowering introduces retained display-list or transcript storage") if
  lowering_source.match?(/\b(?:displayList|glyphRunArray|preflightTranscript)\b/)

probe = PROBE.read
fail_check("static finite workspace probe is missing") unless
  probe.include?("struct StaticRenderWorkspace: RenderProductionWorkspace") &&
    probe.include?("MemoryLayout<StaticRenderWorkspace>.size") &&
    probe.include?("MemoryLayout<Color>.stride")
fail_check("foreground probe does not expose exactly one Color slot") unless
  probe.scan(/private var foreground = Color\.black/).length == 1

puts "SPEC-008 render work passed: exact access/comparison counts are affine through 16 occurrences and glyphs; timing, stack, workspace, and retention instrumentation are registered."
