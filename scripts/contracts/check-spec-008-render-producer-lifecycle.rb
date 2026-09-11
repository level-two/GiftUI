#!/usr/bin/env ruby
# frozen_string_literal: true

require "pathname"

ROOT = Pathname.new(File.expand_path("../..", __dir__))
SOURCE = ROOT.join("Sources/GiftUIRenderLowering/RenderProducer.swift")
TESTS = ROOT.join("Tests/GiftUIRenderLoweringTests/RenderPreflightTests.swift")

def fail_check(message)
  warn "SPEC-008 render producer lifecycle check failed: #{message}"
  exit 1
end

source = SOURCE.read
tests = TESTS.read
expected_imports = %w[GiftUI GiftUILayout GiftUIRenderCore GiftUISemanticCore GiftUITextResources]
fail_check("producer imports differ") unless source.scan(/^import (\w+)$/).flatten == expected_imports

required = [
  "package static func produce<Semantic, Layout, Metrics, Workspace, Sink>",
  "semantic: borrowing Semantic",
  "layout: borrowing Layout",
  "textMetrics: borrowing Metrics",
  "workspace: inout Workspace",
  "sink: inout Sink",
  "if workspace.isActive",
  "return .failure(.reentrancyViolation)",
  "guard workspace.acquire()",
  "return .failure(.invariantViolation)",
  "defer { workspace.reset() }",
  "let preflightResult = preflight(",
  "return stream(",
]
required.each do |fragment|
  fail_check("producer lifecycle lacks #{fragment}") unless source.include?(fragment)
end

active_check = source.index("if workspace.isActive")
acquire = source.index("workspace.acquire()")
preflight = source.index("let preflightResult = preflight(")
fail_check("reentry/acquire/preflight order differs") unless active_check < acquire && acquire < preflight
fail_check("producer retains dynamic state") if source.match?(/\b(?:Array|ContiguousArray|Set|Dictionary|String|Unsafe|class|actor)\b/)

%w[
  producerAcquiresRunsBothPassesAndResetsExactlyOnceOnEveryAcquiredExit
  producerRejectsReentryBeforeInputOrSinkAccessAndPreservesActiveAttempt
  producerMapsInactiveAcquireRefusalToInvariantWithoutResetOrInputAccess
].each do |name|
  fail_check("focused tests lack #{name}") unless tests.include?(name)
end

puts "SPEC-008 render producer lifecycle passed: reentry-first acquisition, two passes, and exact reset ownership."
