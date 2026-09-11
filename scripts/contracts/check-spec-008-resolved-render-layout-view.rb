#!/usr/bin/env ruby
# frozen_string_literal: true

require "pathname"

ROOT = Pathname.new(File.expand_path("../..", __dir__))
SOURCE = ROOT.join("Sources/GiftUILayout/ResolvedRenderLayoutView.swift")

def fail_check(message)
  warn "SPEC-008 resolved render layout view check failed: #{message}"
  exit 1
end

source = SOURCE.read
imports = source.scan(/^import (\w+)$/).flatten
expected_imports = %w[GiftUI GiftUITextResources]
fail_check("imports differ: #{imports}") unless imports == expected_imports

%w[ResolvedRenderTextLine ResolvedRenderGlyph ResolvedRenderLayoutView].each do |name|
  declarations = Dir[ROOT.join("Sources/**/*.swift")].select do |path|
    File.read(path).match?(/package (?:struct|protocol) #{name}\b/)
  end
  fail_check("#{name} ownership differs: #{declarations}") unless declarations == [SOURCE.to_s]
end

required_fragments = [
  "package struct ResolvedRenderTextLine: Equatable, Sendable",
  "package struct ResolvedRenderGlyph: Equatable, Sendable",
  "package protocol ResolvedRenderLayoutView",
  "var rootIdentity: Identity { get }",
  "var layoutScopeCount: UInt16 { get }",
  "var rootBounds: Rect { get }",
  "func bounds(of identity: Identity) -> Rect?",
  "func clip(of identity: Identity) -> Rect?",
  "func textLineCount(of identity: Identity) -> UInt16?",
  "func glyph(of identity: Identity, at index: UInt16) -> ResolvedRenderGlyph?",
  "package protocol ResolvedRenderLayoutResultStorage: LayoutResultSink",
  "var renderView: RenderView { get }",
]
required_fragments.each do |fragment|
  fail_check("source lacks #{fragment}") unless source.include?(fragment)
end

forbidden = /\b(?:public|open|String|GiftUIRenderCore|GiftUIRenderLowering|GiftUIFailureCore|GiftUICapabilities)\b/
fail_check("source contains public, textual, rendering, failure, or capability coupling") if source.match?(forbidden)

puts "SPEC-008 resolved render layout view ownership passed: exact geometry, text, glyph, and identity projection."
