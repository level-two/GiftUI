#!/usr/bin/env ruby
# frozen_string_literal: true

require "pathname"

ROOT = Pathname.new(File.expand_path("../..", __dir__))
FIXTURES = ROOT.join("Tests/GiftUIRenderLoweringTests/DirectRenderViewFixtures.swift")
TESTS = ROOT.join("Tests/GiftUIRenderLoweringTests/DirectRenderViewFixtureTests.swift")

def fail_check(message)
  warn "SPEC-008 direct render view check failed: #{message}"
  exit 1
end

source = FIXTURES.read + TESTS.read
required = %w[
  RenderFixtureIdentity DirectSemanticRenderView DirectResolvedRenderLayoutView
  unequalRoot duplicateIdentity missingScope invalidModifierArity
  prohibitedTextChild missingTransparentMapping missingBounds missingClip
  missingLine missingGlyph lineGap glyphLineMismatch glyphIndexGap
]
required.each do |fragment|
  fail_check("fixture corpus lacks #{fragment}") unless source.include?(fragment)
end

forbidden = /(?:Unsafe|hashValue|withUnsafeBytes|MemoryLayout|ObjectIdentifier)/
fail_check("fixtures compare representation, pointer, hash, or layout identity") if source.match?(forbidden)

puts "SPEC-008 direct render views passed: symbolic valid, structural, lookup, and index fixtures."
