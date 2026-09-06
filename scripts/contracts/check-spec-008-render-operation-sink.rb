#!/usr/bin/env ruby
# frozen_string_literal: true

require "pathname"

ROOT = Pathname.new(File.expand_path("../..", __dir__))
SOURCE = ROOT.join("Sources/GiftUIRenderCore/RenderOperationSink.swift")

def fail_check(message)
  warn "SPEC-008 RenderOperationSink check failed: #{message}"
  exit 1
end

source = SOURCE.read
expected = <<~SWIFT
  package protocol RenderOperationSink {
      var capacity: RenderSinkCapacity { get }

      mutating func begin(_ header: RenderPlanHeader) -> Bool
      mutating func fillRect(_ operation: FillRectOperation) -> Bool
      mutating func beginPositionedGlyphs(
          _ operation: PositionedGlyphOperationHeader
      ) -> Bool
      mutating func positionedGlyph(_ glyph: PositionedGlyph) -> Bool
      mutating func endPositionedGlyphs() -> Bool
      mutating func finish() -> Bool
      mutating func discard()
  }
SWIFT

fail_check("protocol surface differs from the approved contract") unless source == expected

owners = Dir[ROOT.join("Sources/**/*.swift")].select do |path|
  File.read(path).match?(/protocol RenderOperationSink\b/)
end
fail_check("protocol ownership differs: #{owners}") unless owners == [SOURCE.to_s]

puts "SPEC-008 RenderOperationSink surface passed: exact ordered transport, one capacity getter."
