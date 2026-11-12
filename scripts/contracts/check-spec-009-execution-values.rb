#!/usr/bin/env ruby
# frozen_string_literal: true

require "pathname"

ROOT = Pathname.new(File.expand_path("../..", __dir__))
SOURCE = ROOT.join("Sources/GiftUIExecution/ExecutionValues.swift")
TARGET_GENERATION_SOURCE = ROOT.join("Sources/GiftUIExecution/ObservableTargetGeneration.swift")

def fail_check(message)
  warn "SPEC-009 execution value check failed: #{message}"
  exit 1
end

source = SOURCE.read
target_generation = TARGET_GENERATION_SOURCE.read
imports = (source + "\n" + target_generation).scan(/^import (\w+)$/).flatten.uniq.sort
fail_check("execution value imports differ") unless imports == %w[GiftUI GiftUIRenderCore]

identities = %w[
  RunCycleID SemanticRevision CandidateFrameID ActionGeneration
  ObservableTargetGeneration
]
identities.each do |name|
  declaration = "package struct #{name}: Equatable, Hashable, Sendable"
  declaration_source = name == "ObservableTargetGeneration" ? target_generation : source
  fail_check("#{name} declaration differs") unless declaration_source.include?(declaration)
end

required_fragments = [
  "package enum ExecutionPhase: UInt8, Equatable, Sendable",
  "case idle = 0",
  "case admitting = 1",
  "case mutating = 2",
  "case deriving = 3",
  "case publishing = 4",
  "case offering = 5",
  "case finalizing = 6",
  "package struct ExecutionLimits: Equatable, Sendable",
  "package struct ExecutionContext: Equatable, Sendable",
]
required_fragments.each do |fragment|
  fail_check("execution values lack #{fragment}") unless source.include?(fragment)
end

identity_bodies = identities.map do |name|
  declaration_source = name == "ObservableTargetGeneration" ? target_generation : source
  declaration_source[/package struct #{name}:.*?^}/m]
end
fail_check("an identity declaration is missing") if identity_bodies.any?(&:nil?)
identity_bodies.each do |body|
  fail_check("identity contains a sentinel or validation") if body.match?(/guard|nil|invalid|sentinel/)
  fail_check("identity raw storage differs") unless body.scan("package let rawValue: UInt32").length == 1
end

forbidden = /\b(?:public|open|Any|String|Array|ContiguousArray|class|actor|GiftUISemanticCore|GiftUILayout|GiftUIRenderLowering|GiftUIFailureCore|GiftUICapabilities|GiftUIRuntime)\b/
fail_check("execution values contain public, dynamic, or prohibited upward coupling") if source.match?(forbidden)

puts "SPEC-009 execution value ownership passed: five identities, seven phases, limits, and context."
