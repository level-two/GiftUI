#!/usr/bin/env ruby
# frozen_string_literal: true

require "pathname"

ROOT = Pathname.new(File.expand_path("../..", __dir__))
SOURCE = ROOT.join("Sources/GiftUIObservableState/ObservableStateBindingDecorator.swift")
TEST = ROOT.join("Tests/GiftUIObservableStateTests/ObservableStateBindingDecoratorTests.swift")

def fail_check(message)
  warn "SPEC-010 binding decorator check failed: #{message}"
  exit 1
end

source = SOURCE.read
tests = TEST.read
fail_check("binding decorator imports differ") unless source.scan(/^import (\w+)$/).flatten == %w[GiftUI]

required = [
  "package struct ObservableStateBindingDecorator<Reconciler>",
  "where Reconciler: ObservableStateReconciler",
  "var transientDeclaration = copy declaration",
  "transientDeclaration._giftUIVisitObservableStateDeclarations(&visitor)",
  "reconciler = visitor.reconciler",
  "body(transientDeclaration)",
  "private struct BindingVisitor<Reconciler>",
  "_GiftUIObservableStateDeclarationVisitor",
  "guard failure == nil else { return }",
  "case .success(.materialized), .success(.preserved):",
  "failure = .invariantViolation",
  "failure = error",
]
required.each do |fragment|
  fail_check("binding decorator lacks #{fragment}") unless source.include?(fragment)
end

stored_declaration = source.match?(/^\s+(?:package |private )?(?:let|var) declaration:/)
fail_check("binding decorator retains a declaration") if stored_declaration

forbidden = /\b(?:String|Array|ContiguousArray|Dictionary|Set|Any|any|Mirror|Task|actor|async|await|throw|GiftUIFailureCore|GiftUIRuntime|GiftUIBackend|GiftUIPlatform)\b/
fail_check("binding decorator contains reflection, dynamic storage, suspension, or prohibited owner") if source.match?(forbidden)

fail_check("fixture must use generated host witness") unless tests.include?("@ObservableStateHost")
fail_check("fixture hand-authors generated witness") if tests.include?("_giftUIVisitObservableStateDeclarations")

puts "SPEC-010 binding decorator passed: generated lexical visits bind one transient copy before one body call."
