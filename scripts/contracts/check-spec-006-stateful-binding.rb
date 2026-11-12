#!/usr/bin/env ruby
# frozen_string_literal: true

require "pathname"

ROOT = Pathname.new(File.expand_path("../..", __dir__))
SOURCE = ROOT.join("Sources/GiftUISemanticCore/GiftUISemanticCore.swift")
DECORATOR = ROOT.join("Sources/GiftUIObservableState/ObservableSemanticBodyBinding.swift")
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
]
required_source.each do |fragment|
  fail_check("Semantic Core lacks #{fragment}") unless source.include?(fragment)
end

fail_check("observable owner does not implement the downward hook") unless decorator.include?("package struct ObservableSemanticBodyBinding<") && decorator.include?("SemanticStatefulBinding")
fail_check("stateful bridge does not bind before evaluating the body") unless decorator.include?("root.withBoundDeclaration(declaration, identity: structuralIdentity)")
fail_check("stateful bridge does not stage the body after binding") unless decorator.include?("if let failure = beforeBody() { return .semanticFailure(failure) }")
fail_check("stateful bridge does not evaluate the bound declaration in the model read scope") unless decorator.include?("try body(bound, read)")
fail_check("Semantic Core does not route stateful traversal through the bridge") unless source.include?("stateBinding.evaluateStateful(")
fail_check("stateful fixture is not macro generated") unless tests.include?("@ObservableStateHost")
fail_check("stateful fixture lacks lexical binding transcript") unless tests.include?('["bind:0", "bind:1", "body"]')
fail_check("stateful fixture does not compare ordinary semantics") unless tests.include?("ordinarySink.committedEvents.map(\\.kind)")

puts "SPEC-006 stateful binding passed: downward generic hook, owner decorator, lexical bind-before-body, and unchanged semantic result."
