#!/usr/bin/env ruby
# frozen_string_literal: true

require "pathname"

ROOT = Pathname.new(File.expand_path("../..", __dir__))
FIXTURE = ROOT.join("Tests/ContractFixtures/SPEC008/consumer-seams.tsv")
HANDOFF = ROOT.join("Sources/GiftUIExecution/FrameHandoffValues.swift")
ENDPOINT = ROOT.join("Sources/GiftUIExecution/RecordingFrameEndpoint.swift")
ENDPOINT_TEST = ROOT.join("Tests/GiftUIExecutionTests/RecordingFrameEndpointTests.swift")
PROFILE_TEST = ROOT.join("Tests/GiftUIRenderLoweringTests/RenderProfileEquivalenceTests.swift")
SINK_TEST = ROOT.join("Tests/GiftUIRenderCoreTests/RenderOperationSinkTests.swift")

def fail_check(message)
  warn "SPEC-008 consumer seam check failed: #{message}"
  exit 1
end

rows = FIXTURE.each_line.each_with_object([]) do |line, values|
  next if line.start_with?("#") || line.strip.empty?

  fields = line.chomp.split("\t", -1)
  fail_check("consumer row width differs") unless fields.length == 4
  values << fields
end
fail_check("consumer owners differ") unless rows.map(&:first) == %w[SPEC-009 SPEC-013 SPEC-014]
fail_check("consumer boundaries differ") unless rows.map { |row| row[2] } == %w[
  synchronous-one-shot-sink-envelope shared-render-lowering-coordination
  backend-side-render-core-consumption
]
fail_check("consumer fixture retains authority") unless rows.all? { |row| row[3] == "none" }

tests = [ENDPOINT_TEST.read, PROFILE_TEST.read, SINK_TEST.read]
rows.zip(tests).each do |row, source|
  fail_check("missing executable consumer fixture #{row[1]}") unless source.include?("func #{row[1]}()")
end

handoff = HANDOFF.read
fail_check("one-shot endpoint protocol differs") unless
  handoff.include?("associatedtype Sink: RenderOperationSink") &&
    handoff.include?("body: (inout Sink) -> FrameStreamResult")
fail_check("one-shot body can escape") if handoff.match?(/@escaping[^\n]*FrameStreamResult/)

endpoint = ENDPOINT.read
fail_check("endpoint does not poison its sink borrow after one body call") unless
  endpoint.include?("let streamResult = body(&sink)") &&
    endpoint.include?("sink.poisonAfterReturn()")
fail_check("endpoint retains operation or resource values") if
  endpoint.match?(/(?:let|var)\s+\w+\s*:\s*(?:FillRectOperation|PositionedGlyphOperationHeader|PositionedGlyph|FontResourceID)/)
fail_check("accepted storage exceeds provenance and counts") unless
  endpoint.include?("let provenance: FrameProvenance") &&
    endpoint.include?("let operationCount: UInt16") &&
    endpoint.include?("let positionedGlyphCount: UInt16")

profile = PROFILE_TEST.read
fail_check("profile paths do not join one shared lowering call") unless
  profile.scan(/RenderProducer\.produce\(/).length == 1 &&
    profile.scan(/produceProfile\(/).length == 3

sink = SINK_TEST.read
imports = sink.each_line.each_with_object([]) do |line, values|
  imported = line[/\Aimport\s+(\w+)/, 1]
  values << imported if imported
end
fail_check("Render Core consumer imports producer authority") unless
  (imports & %w[GiftUISemanticCore GiftUILayout GiftUIRenderLowering GiftUIExecution GiftUICapabilities]).empty?
fail_check("Render Core consumer does not exercise ordered values") unless
  sink.include?("sinkCarriesEmptyAndMultipleOperationStreamsInExactOrder") &&
    sink.include?("fillRect") && sink.include?("positionedGlyph")

puts "SPEC-008 consumer seams passed: one-shot offer, shared lowering, and Render-Core-only consumption retain no producer authority or operation borrow."
