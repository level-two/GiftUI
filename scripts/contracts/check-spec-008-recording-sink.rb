#!/usr/bin/env ruby
# frozen_string_literal: true

require "pathname"

ROOT = Pathname.new(File.expand_path("../..", __dir__))
SOURCE = ROOT.join("Sources/GiftUIRenderCore/RenderRecordingSink.swift")

def fail_check(message)
  warn "SPEC-008 recording sink check failed: #{message}"
  exit 1
end

source = SOURCE.read
required = [
  "package enum RenderRecordingEvent: Equatable, Sendable",
  "case begin(RenderPlanHeader)",
  "case fillRect(FillRectOperation)",
  "case beginPositionedGlyphs(PositionedGlyphOperationHeader)",
  "case positionedGlyph(PositionedGlyph)",
  "case endPositionedGlyphs",
  "case finish",
  "package protocol RenderRecordingStorage",
  "package struct RenderRecordingSink<Storage>: RenderOperationSink",
  "package private(set) var attemptedCalls = RenderSinkAttemptCounts()",
  "mutating func beginRecording(_ event: borrowing RenderRecordingEvent) -> Bool",
  "mutating func stage(_ event: borrowing RenderRecordingEvent) -> Bool",
  "mutating func publishRecording() -> Bool",
  "mutating func discardRecording()",
]
required.each do |fragment|
  fail_check("source lacks #{fragment}") unless source.include?(fragment)
end

forbidden = /\b(?:String|Array|ContiguousArray|Unsafe|pointer|serialize|GiftUISemanticCore|GiftUILayout|GiftUIRenderLowering|GiftUIFailureCore|GiftUICapabilities)\b/
fail_check("source contains dynamic storage, serialization, or owner coupling") if source.match?(forbidden)
fail_check("source must not import another module") if source.match?(/^import /)

event_cases = source[/package enum RenderRecordingEvent.*?^}/m].scan(/^    case /).count
fail_check("event vocabulary is not the exact six cases") unless event_cases == 6

puts "SPEC-008 recording sink passed: closed events, caller storage, fixed counters."
