#!/usr/bin/env ruby
# frozen_string_literal: true

require "pathname"

ROOT = Pathname.new(File.expand_path("../..", __dir__))
SOURCE = ROOT.join("Sources/GiftUIRenderCore/RenderValues.swift")

def fail_check(message)
  warn "SPEC-008 Render Core value check failed: #{message}"
  exit 1
end

source = SOURCE.read
imports = source.scan(/^import (\w+)$/).flatten
fail_check("Render Core imports differ") unless imports == %w[GiftUI GiftUITextResources]

expected_declarations = %w[
  RenderSinkCapacity RenderPlanHeader PositionedGlyph FillRectOperation
  PositionedGlyphOperationHeader RenderProductionError
]
expected_declarations.each do |name|
  declarations = Dir[ROOT.join("Sources/**/*.swift")].select do |path|
    File.read(path).match?(/package (?:struct|enum) #{name}\b/)
  end
  fail_check("#{name} ownership differs: #{declarations}") unless declarations == [SOURCE.to_s]
end

required_fragments = [
  "case invalidInput = 0",
  "case arithmeticOverflow = 1",
  "case capacityExhausted = 2",
  "case incompatibleTextResource = 3",
  "case sinkRefused = 4",
  "case reentrancyViolation = 5",
  "case invariantViolation = 6",
  "package let instance: FontInstanceID",
  "package let glyph: GlyphID",
  "package let color: Color",
]
required_fragments.each do |fragment|
  fail_check("Render Core values lack #{fragment}") unless source.include?(fragment)
end

forbidden = /\b(?:Any|String|Array|ContiguousArray|class|actor|GiftUISemanticCore|GiftUILayout|GiftUIRenderLowering|GiftUIFailureCore|GiftUICapabilities)\b/
fail_check("Render Core values contain forbidden dynamic or owner coupling") if source.match?(forbidden)
fail_check("Render Core duplicates FontInstanceID") if source.match?(/struct FontInstanceID\b/)
fail_check("Render Core duplicates GlyphID") if source.match?(/struct GlyphID\b/)

puts "SPEC-008 Render Core value ownership passed: six closed values, two exact imports."
