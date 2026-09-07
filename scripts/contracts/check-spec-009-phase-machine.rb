#!/usr/bin/env ruby
# frozen_string_literal: true

require "pathname"

ROOT = Pathname.new(File.expand_path("../..", __dir__))
SOURCE = ROOT.join("Sources/GiftUIExecution/ExecutionPhaseMachine.swift")

def fail_check(message)
  warn "SPEC-009 phase machine check failed: #{message}"
  exit 1
end

source = SOURCE.read
fail_check("phase machine imports another owner") unless source.scan(/^import (\w+)$/).empty?
fail_check("phase machine declaration differs") unless source.include?("package struct ExecutionPhaseMachine: Equatable, Sendable")

legal_edges = [
  ".idle, .admitting",
  ".admitting, .mutating",
  ".admitting, .finalizing",
  ".mutating, .deriving",
  ".mutating, .finalizing",
  ".deriving, .publishing",
  ".deriving, .offering",
  ".deriving, .finalizing",
  ".publishing, .offering",
  ".publishing, .finalizing",
  ".offering, .finalizing",
  ".finalizing, .idle",
]
legal_edges.each do |edge|
  fail_check("phase machine lacks edge #{edge}") unless source.include?(edge)
end

fail_check("nested entry does not fail before reservation") unless
  source.index("guard phase == .idle else { return .reentrancyViolation }") <
    source.index("guard let reservedCycle = allocator.reserve()")
fail_check("idle cleanup differs") unless source.include?("cycle = nil") && source.include?("candidateFrame = nil")
fail_check("phase machine can suspend") if source.match?(/\b(?:async|await|Task|continuation)\b/)
forbidden = /\b(?:public|open|String|Array|ContiguousArray|class|actor|GiftUISemanticCore|GiftUILayout|GiftUIRenderLowering|GiftUIFailureCore|GiftUICapabilities|GiftUIRuntime)\b/
fail_check("phase machine contains dynamic or upward coupling") if source.match?(forbidden)

puts "SPEC-009 phase machine passed: exact forward graph, nested-entry guard, and bounded context."
