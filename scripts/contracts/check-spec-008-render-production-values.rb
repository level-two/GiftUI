#!/usr/bin/env ruby
# frozen_string_literal: true

require "pathname"

ROOT = Pathname.new(File.expand_path("../..", __dir__))
SOURCE = ROOT.join("Sources/GiftUIRenderLowering/RenderProductionValues.swift")

def fail_check(message)
  warn "SPEC-008 render production value check failed: #{message}"
  exit 1
end

source = SOURCE.read
fail_check("lowering value imports differ") unless source.scan(/^import (\w+)$/).flatten == %w[GiftUIRenderCore]

%w[RenderLimits RenderWorkspaceCapacity RenderWorkspaceVisit RenderProductionResult RenderProductionWorkspace].each do |name|
  declarations = Dir[ROOT.join("Sources/**/*.swift")].select do |path|
    File.read(path).match?(/package (?:struct|enum|protocol) #{name}\b/)
  end
  fail_check("#{name} ownership differs: #{declarations}") unless declarations == [SOURCE.to_s]
end

required_fragments = [
  "package let maximumOperations: UInt16",
  "package let maximumPositionedGlyphs: UInt16",
  "package let maximumClipDepth: UInt16",
  "package let maximumSemanticScopes: UInt16",
  "package let maximumLayoutScopes: UInt16",
  "package let maximumTraversalDepth: UInt16",
  "package let maximumTextLines: UInt16",
  "case first = 0",
  "case repeated = 1",
  "case invalid = 2",
  "case success(RenderPlanHeader)",
  "case failure(RenderProductionError)",
  "associatedtype Identity: Equatable, Sendable",
  "var capacity: RenderLimits { get }",
  "var structuralCapacity: RenderWorkspaceCapacity { get }",
  "var isActive: Bool { get }",
  "mutating func acquire() -> Bool",
  "mutating func visitSemanticScope(at ordinal: UInt16)",
  "mutating func visitLayoutScope(at ordinal: UInt16)",
  "mutating func reset()",
]
required_fragments.each do |fragment|
  fail_check("lowering values lack #{fragment}") unless source.include?(fragment)
end

forbidden = /\b(?:public|open|String|Array|ContiguousArray|class|actor|GiftUIFailureCore|GiftUIExecution|GiftUICapabilities)\b/
fail_check("lowering values contain public, dynamic, or prohibited owner coupling") if source.match?(forbidden)

puts "SPEC-008 render production values passed: exact limits, result, and bounded workspace seam."
