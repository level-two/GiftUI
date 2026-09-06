#!/usr/bin/env ruby
# frozen_string_literal: true

require "pathname"

ROOT = Pathname.new(File.expand_path("../..", __dir__))
SOURCE = ROOT.join("Sources/GiftUISemanticCore/SemanticRenderView.swift")

def fail_check(message)
  warn "SPEC-008 semantic render view check failed: #{message}"
  exit 1
end

source = SOURCE.read
fail_check("semantic render view must import only GiftUI") unless source.scan(/^import (\w+)$/).flatten == %w[GiftUI]

%w[SemanticRenderScope SemanticRenderView].each do |name|
  declarations = Dir[ROOT.join("Sources/**/*.swift")].select do |path|
    File.read(path).match?(/package (?:enum|protocol) #{name}\b/)
  end
  fail_check("#{name} ownership differs: #{declarations}") unless declarations == [SOURCE.to_s]
end

required_fragments = [
  "case structural",
  "case clipBoundary",
  "case text",
  "case foregroundStyle(Color)",
  "case background(Color)",
  "associatedtype Identity: Equatable, Sendable",
  "var rootIdentity: Identity { get }",
  "var semanticScopeCount: UInt16 { get }",
  "func scope(at identity: Identity) -> SemanticRenderScope?",
  "func layoutIdentity(for identity: Identity) -> Identity?",
  "func childCount(of identity: Identity) -> UInt16?",
  "func child(of identity: Identity, at index: UInt16) -> Identity?",
]
required_fragments.each do |fragment|
  fail_check("semantic render view lacks #{fragment}") unless source.include?(fragment)
end

forbidden = /\b(?:public|open|Any|String|Array|ContiguousArray|class|actor|GiftUILayout|GiftUIRenderCore|GiftUIRenderLowering|GiftUIFailureCore|GiftUICapabilities)\b/
fail_check("semantic render view contains public, dynamic, or upward coupling") if source.match?(forbidden)

puts "SPEC-008 semantic render view ownership passed: five scopes and six exact view requirements."
