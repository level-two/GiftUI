#!/usr/bin/env ruby
# frozen_string_literal: true

require "pathname"

ROOT = Pathname.new(File.expand_path("../..", __dir__))
SOURCE = ROOT.join("Sources/GiftUIExecution/WakeValues.swift")

def fail_check(message)
  warn "SPEC-009 wake value check failed: #{message}"
  exit 1
end

source = SOURCE.read
fail_check("wake values must not import another owner") unless source.scan(/^import (\w+)$/).empty?

required_fragments = [
  "package struct ExecutionWakeReasons: OptionSet, Equatable, Sendable",
  "self.rawValue = rawValue & 0x07",
  "package static let admittedWork = Self(rawValue: 0x01)",
  "package static let semanticDirty = Self(rawValue: 0x02)",
  "package static let presentationPending = Self(rawValue: 0x04)",
  "package protocol ExecutionWakeRequester",
  "mutating func requestWake(for reasons: ExecutionWakeReasons)",
  "package struct PresentationPendingIntent: Equatable, Sendable",
  "package let semanticRevision: SemanticRevision",
  "package let retryableRefusalCount: UInt8",
]
required_fragments.each do |fragment|
  fail_check("wake values lack #{fragment}") unless source.include?(fragment)
end

stored_properties = source.each_line.each_with_object([]) do |line, properties|
  properties << line.strip if line.match?(/^\s*package let /)
end
expected_properties = [
  "package let rawValue: UInt8",
  "package let semanticRevision: SemanticRevision",
  "package let retryableRefusalCount: UInt8",
]
fail_check("wake value storage differs") unless stored_properties == expected_properties

forbidden = /\b(?:public|open|Any|String|Array|ContiguousArray|class|actor|View|SemanticRenderView|RenderOperationSink|callable|handler|model|workspace|operation|sink|frame|targetGeneration)\b/
fail_check("wake values retain forbidden payload or authority") if source.match?(forbidden)

puts "SPEC-009 wake values passed: masked reasons, request seam, and two-field pending intent."
