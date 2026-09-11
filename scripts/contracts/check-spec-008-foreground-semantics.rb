#!/usr/bin/env ruby
# frozen_string_literal: true

require "pathname"

ROOT = Pathname.new(File.expand_path("../..", __dir__))
SOURCE = ROOT.join("Sources/GiftUIRenderLowering/RenderStreaming.swift").read
TEST = ROOT.join("Tests/GiftUIRenderLoweringTests/RenderPreflightTests.swift").read
VALUES_TEST = ROOT.join("Tests/GiftUIRenderLoweringTests/RenderProductionValueTests.swift").read

def fail_check(message)
  warn "SPEC-008 foreground semantics check failed: #{message}"
  exit 1
end

required_order = [
  "workspace.currentForeground == nil",
  "workspace.pushForeground(rootForeground)",
  "sink.begin(preflight.header)",
]
locations = required_order.map { |fragment| SOURCE.index(fragment) }
fail_check("root foreground initialization is incomplete") if locations.any?(&:nil?)
fail_check("root foreground must be pushed before begin") unless locations == locations.sort

%w[
  workspace.pushForeground(color)
  workspace.currentForeground
  workspace.popForeground()
].each do |fragment|
  fail_check("scoped foreground handling lacks #{fragment}") unless SOURCE.include?(fragment)
end
fail_check("scoped foreground restoration is missing") unless
  SOURCE.include?("workspace.currentForeground == inheritedForeground")
recursive_signature = SOURCE[/mutating func stream<.*?\) -> Bool/m]
fail_check("recursive stream signature is missing") unless recursive_signature
fail_check("streaming retains foreground in recursive call frames") if
  recursive_signature.include?("foreground:")
fail_check("nested style golden is missing") unless
  TEST.include?(
    "foregroundStackUsesInnermostColorRestoresSiblingsAndOrdersNestedBackgrounds"
  )
fail_check("workspace refusal/high-water coverage is missing") unless
  VALUES_TEST.include?("foregroundHighWater") &&
    VALUES_TEST.include?("fullPush") && VALUES_TEST.include?("emptyPop")

puts "SPEC-008 foreground semantics passed: caller-owned LIFO style resolution and restoration."
