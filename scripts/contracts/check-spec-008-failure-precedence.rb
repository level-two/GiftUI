#!/usr/bin/env ruby
# frozen_string_literal: true

require "pathname"

ROOT = Pathname.new(File.expand_path("../..", __dir__))
PRODUCER = ROOT.join("Sources/GiftUIRenderLowering/RenderProducer.swift").read
PREFLIGHT = ROOT.join("Sources/GiftUIRenderLowering/RenderPreflight.swift").read
STREAMING = ROOT.join("Sources/GiftUIRenderLowering/RenderStreaming.swift").read
ADAPTER = ROOT.join("Sources/GiftUIRenderFailureAdapterFixture/RenderFailureAdapter.swift").read
TEST = ROOT.join("Tests/GiftUIRenderLoweringTests/RenderPreflightTests.swift").read
RECORDING_TEST = ROOT.join("Tests/GiftUIRenderCoreTests/RenderRecordingSinkTests.swift").read

def fail_check(message)
  warn "SPEC-008 failure precedence check failed: #{message}"
  exit 1
end

active = PRODUCER.index("if workspace.isActive")
acquire = PRODUCER.index("workspace.acquire()")
preflight = PRODUCER.index("let preflightResult = preflight(")
fail_check("reentrancy is not checked before acquisition and input") unless
  active && acquire && preflight && active < acquire && acquire < preflight

invalid = PREFLIGHT.index("guard surfaceBounds.origin == Point(x: 0, y: 0)")
declared_capacity = PREFLIGHT.index("let structuralCapacity = workspace.structuralCapacity")
fail_check("invalid input does not precede declared capacity") unless
  invalid && declared_capacity && invalid < declared_capacity

intersection_branches = PREFLIGHT.scan(/LayoutGeometry\.intersection\(/).length
arithmetic_returns = PREFLIGHT.scan(/return (?:\.failure\()?\.arithmeticOverflow\)?/).length
fail_check("checked intersection coverage differs") unless intersection_branches == 3
fail_check("defensive arithmetic branches differ") unless arithmetic_returns == 3
fail_check("direct arithmetic mapping is missing") unless
  ADAPTER.include?("case .arithmeticOverflow:") &&
    ADAPTER.include?("condition: .arithmeticOverflow") &&
    ADAPTER.include?("origin: .foundation")

%w[
  constructibleFailurePrecedenceFollowsTheExactClosedOrder
  everyPostBeginSinkAndForegroundRefusalDiscardsOnceAndResets
].each do |name|
  fail_check("focused failure tests lack #{name}") unless TEST.include?(name)
end
fail_check("begin refusal path discards") if
  STREAMING[/guard sink\.begin\(preflight\.header\).*?\n\s*}/m]&.include?("discard")
fail_check("post-begin invariant path lacks discard") unless
  STREAMING.scan("sink.discard()").length >= 4
fail_check("recording atomicity coverage is missing") unless
  RECORDING_TEST.include?("recordingSinkRefusalPreservesCurrentAndDiscardClearsOnlyStaged") &&
    RECORDING_TEST.include?("recordingSinkPublishRefusalRequiresExplicitDiscard")

puts "SPEC-008 failure precedence passed: constructible order, defensive arithmetic, and atomic lifecycle."
