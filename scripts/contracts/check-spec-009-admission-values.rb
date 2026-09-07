#!/usr/bin/env ruby
# frozen_string_literal: true

require "pathname"

ROOT = Pathname.new(File.expand_path("../..", __dir__))
SOURCE = ROOT.join("Sources/GiftUIExecution/AdmissionValues.swift")

def fail_check(message)
  warn "SPEC-009 admission value check failed: #{message}"
  exit 1
end

source = SOURCE.read
fail_check("admission imports differ") unless source.scan(/^import (\w+)$/).flatten == %w[GiftUI]

required_declarations = %w[
  AdmissionKind ExecutionAdmissionResult ExecutionAdmissionOutcome
  ExecutionAdmissionSink ExecutionOpportunityRunner AdmissionSummary
  ExecutionActionView CapturedAction
]
required_declarations.each do |name|
  matches = Dir[ROOT.join("Sources/**/*.swift")].select do |path|
    File.read(path).match?(/package (?:struct|enum|protocol) #{name}\b/)
  end
  fail_check("#{name} ownership differs: #{matches}") unless matches == [SOURCE.to_s]
end

required_fragments = [
  "associatedtype StateChangeFact: Sendable",
  "associatedtype CompletionFact: Sendable",
  "submit(pointer: NormalizedPointerEvent) -> ExecutionAdmissionOutcome",
  "associatedtype OwnerFailure: Equatable & Sendable",
  "mutating func runOpportunity() -> RunCycleResult<OwnerFailure>",
  "associatedtype Identity: Equatable, Sendable",
  "package struct CapturedAction<Identity>: Equatable, Sendable",
  "where Identity: Equatable & Sendable",
  "package let identity: Identity",
  "package let generation: ActionGeneration",
]
required_fragments.each do |fragment|
  fail_check("admission values lack #{fragment}") unless source.include?(fragment)
end

capture = source[/package struct CapturedAction<Identity>.*?^}/m]
fail_check("captured action declaration is missing") unless capture
stored = capture.scan(/^\s*package let ([^\n]+)$/).flatten
fail_check("captured action storage differs: #{stored}") unless stored == ["identity: Identity", "generation: ActionGeneration"]

forbidden = /\b(?:public|open|any|Any|String|Array|ContiguousArray|class|actor|closure|callable|handler|model|targetGeneration|GiftUISemanticCore|GiftUILayout|GiftUIRenderLowering|GiftUIFailureCore|GiftUICapabilities|GiftUIRuntime)\b/
fail_check("admission values contain existential, retained payload, profile, or upward coupling") if source.match?(forbidden)

puts "SPEC-009 admission values passed: typed producer seams, bounded summary, and identity-generation-only capture."
