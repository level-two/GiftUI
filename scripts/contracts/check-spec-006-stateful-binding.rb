#!/usr/bin/env ruby
# frozen_string_literal: true

require "pathname"

ROOT = Pathname.new(File.expand_path("../..", __dir__))
SOURCE = ROOT.join("Sources/GiftUISemanticCore/GiftUISemanticCore.swift")
DECORATOR = ROOT.join("Sources/GiftUIObservableState/ObservableStateBindingDecorator.swift")
TEST = ROOT.join("Tests/GiftUISemanticCoreTests/SemanticExpansionTraversalTests.swift")

def fail_check(message)
  warn "SPEC-006 stateful binding check failed: #{message}"
  exit 1
end

source = SOURCE.read
decorator = DECORATOR.read
tests = TEST.read

fail_check("Semantic Core imports observable-state owner") if source.match?(/^import GiftUIObservableState$/)
required_source = [
  "package protocol SemanticStatefulBinding",
  "package enum BoundSemanticExpansionResult<BindingFailure>",
  "case semanticFailure(SemanticExpansionError)",
  "case bindingFailure(BindingFailure)",
  "package func expandSemanticTreeWithStateBinding<",
  "attempt.discardForOwnerFailure(workspace: &workspace, sink: &sink)",
  "bindingFailure = error",
  "attempt.stageBodyEvaluation(",
  "evaluatedBody = body(boundDeclaration)",
]
required_source.each do |fragment|
  fail_check("Semantic Core lacks #{fragment}") unless source.include?(fragment)
end

fail_check("observable owner does not supply the downward hook") unless decorator.include?("extension ObservableStateBindingDecorator: SemanticStatefulBinding")
fail_check("stateful fixture is not macro generated") unless tests.include?("@ObservableStateHost")
fail_check("stateful fixture lacks lexical binding transcript") unless tests.include?('["bind:0", "bind:1", "body"]')
fail_check("stateful fixture does not compare ordinary semantics") unless tests.include?("ordinarySink.committedEvents.map(\\.kind)")

puts "SPEC-006 stateful binding passed: downward generic hook, owner decorator, lexical bind-before-body, and unchanged semantic result."
