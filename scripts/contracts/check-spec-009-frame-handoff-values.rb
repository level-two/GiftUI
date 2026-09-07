#!/usr/bin/env ruby
# frozen_string_literal: true

require "pathname"

ROOT = Pathname.new(File.expand_path("../..", __dir__))
SOURCE = ROOT.join("Sources/GiftUIExecution/FrameHandoffValues.swift")

def fail_check(message)
  warn "SPEC-009 frame handoff value check failed: #{message}"
  exit 1
end

source = SOURCE.read
fail_check("frame handoff imports differ") unless source.scan(/^import (\w+)$/).flatten == %w[GiftUIRenderCore]

required_declarations = %w[
  FrameProvenance FrameOfferDisposition LogicalFrameDisposition
  FrameStreamResult FrameOfferResult FrameOfferFailure FrameRefusalOrigin
  SynchronousFrameEndpoint
]
required_declarations.each do |name|
  matches = Dir[ROOT.join("Sources/**/*.swift")].select do |path|
    File.read(path).match?(/package (?:struct|enum|protocol) #{name}\b/)
  end
  fail_check("#{name} ownership differs: #{matches}") unless matches == [SOURCE.to_s]
end

required_fragments = [
  "guard (disposition == .failed) == (failure != nil) else { return nil }",
  "associatedtype Sink: RenderOperationSink",
  "body: (inout Sink) -> FrameStreamResult",
  ") -> FrameOfferResult",
]
required_fragments.each do |fragment|
  fail_check("frame handoff values lack #{fragment}") unless source.include?(fragment)
end

fail_check("endpoint body became escaping") if source.include?("@escaping")
forbidden = /\b(?:public|open|Any|String|Array|ContiguousArray|class|actor|GiftUISemanticCore|GiftUILayout|GiftUIRenderLowering|GiftUIFailureCore|GiftUICapabilities|GiftUIRuntime)\b/
fail_check("frame handoff values contain public, dynamic, or upward coupling") if source.match?(forbidden)

puts "SPEC-009 frame handoff values passed: exact provenance, dispositions, failures, and synchronous endpoint."
