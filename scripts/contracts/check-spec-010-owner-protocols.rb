#!/usr/bin/env ruby
# frozen_string_literal: true

require "pathname"

ROOT = Pathname.new(File.expand_path("../..", __dir__))
SOURCE = ROOT.join("Sources/GiftUIObservableState/ObservableStateProtocols.swift")
TEST = ROOT.join("Tests/GiftUIObservableStateTests/ObservableStateProtocolTests.swift")

def fail_check(message)
  warn "SPEC-010 owner protocol check failed: #{message}"
  exit 1
end

source = SOURCE.read
tests = TEST.read
fail_check("owner protocol imports differ") unless source.scan(/^import (\w+)$/).flatten == %w[GiftUI GiftUIExecution]

%w[ObservableStateReconciler ObservableStateMutationOwner ObservableStateTargetView].each do |name|
  matches = Dir[ROOT.join("Sources/**/*.swift")].select do |path|
    File.read(path).match?(/package protocol #{name}\b/)
  end
  fail_check("#{name} ownership differs: #{matches}") unless matches == [SOURCE.to_s]
end

required_fragments = [
  "associatedtype StructuralIdentity: Equatable & Sendable",
  "mutating func beginCandidate() -> ObservableStateResult",
  "structuralIdentity: StructuralIdentity",
  "declarationOrdinal: UInt16",
  "state: inout State<Model>",
  "with candidate: consuming Model",
  "attachment: _GiftUIObservationAttachment",
  "borrowing func targetGeneration(",
  "borrowing func publishableTargetGeneration(",
  ") -> ObservableTargetGeneration?",
]
required_fragments.each do |fragment|
  fail_check("owner protocols lack #{fragment}") unless source.include?(fragment)
end

forbidden_surface = /\b(?:public|open|Any|any|String|Array|Dictionary|class|actor|Task|throw|GiftUIFailureCore|GiftUIRuntime|GiftUIBackend|GiftUIPlatform)\b/
fail_check("owner protocols contain a forbidden surface or facility") if source.match?(forbidden_surface)

logical_fields = %w[
  FixtureLiveLocationFields FixtureRegistrationFields
  FixtureCandidateAssociationFields FixtureReplacementFields
  FixtureRuntimeBookkeeping
]
logical_fields.each do |name|
  fail_check("fixture lacks #{name}") unless tests.include?("private struct #{name}")
end

target_view = source[/package protocol ObservableStateTargetView.*?^}/m]
fail_check("target view is missing") unless target_view
forbidden_view = /\b(?:Model|State|Attachment|Sink|replace|acceptReport|mutating)\b/
fail_check("target view exposes model, attachment, sink, or mutation") if target_view.match?(forbidden_view)

puts "SPEC-010 owner protocols passed: exact typed operations, opaque target views, and five logical storage families."
