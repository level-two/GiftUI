#!/usr/bin/env ruby
# frozen_string_literal: true

require "pathname"

ROOT = Pathname.new(File.expand_path("../..", __dir__))
SOURCE = ROOT.join("Sources/GiftUIObservableState/ObservableStateBindingDecorator.swift")
ROOT_SCOPE = ROOT.join("Sources/GiftUIObservableState/ObservableStateRootScope.swift")
BINDING = ROOT.join("Sources/GiftUIObservableState/ObservableSemanticBodyBinding.swift")
TEST = ROOT.join("Tests/GiftUIObservableStateTests/ObservableStateBindingDecoratorTests.swift")

def fail_check(message)
  warn "SPEC-010 binding decorator check failed: #{message}"
  exit 1
end

source = SOURCE.read
root_scope = ROOT_SCOPE.read
binding = BINDING.read
tests = TEST.read
target_sources = Dir[ROOT.join("Sources/GiftUIObservableState/**/*.swift")]
target_imports = target_sources.flat_map do |path|
  File.readlines(path).map { |line| line[/^import (\w+)$/, 1] }.compact
end.uniq.sort
expected_imports = %w[GiftUI GiftUIExecution GiftUISemanticCore]
fail_check("observable-state target imports differ: #{target_imports}") unless
  target_imports == expected_imports

fail_check("binding decorator no longer aliases the borrowed root scope") unless
  source.include?("package typealias ObservableStateBindingDecorator<") &&
    source.include?("= ObservableStateRootScope<Model, Identity>") &&
    source.include?("Model: ObservableStateModel & ~Copyable")

required_root_scope = [
  "package borrowing func withBoundDeclaration<Declaration: _GiftUIObservableStateHost, Result>",
  "var transient = copy declaration",
  "transient._giftUIVisitObservableStateDeclarations(&visitor)",
  "if let failure = visitor.failure { throw failure }",
  "return try body(transient)",
  "guard failure == nil else { return }",
]
required_root_scope.each do |fragment|
  fail_check("root scope binding lacks #{fragment}") unless root_scope.include?(fragment)
end

required_binding = [
  "package struct ObservableSemanticBodyBinding<",
  "package borrowing func evaluateStateful<",
  "guard root.belongs(to: models)",
  "root.withBoundDeclaration(declaration, identity: structuralIdentity)",
  "try body(bound, read)",
]
required_binding.each do |fragment|
  fail_check("observable body binding lacks #{fragment}") unless binding.include?(fragment)
end

fail_check("binding decorator alias stores a declaration") if
  source.match?(/^\s*(?:package |private )?(?:let|var) declaration:/)
fail_check("root scope stores a declaration") if
  root_scope.match?(/^\s*(?:package |private )?(?:let|var) declaration:/)

forbidden = /\b(?:String|Array|ContiguousArray|Dictionary|Set|Any|any|Mirror|Task|actor|async|await|throw|GiftUIFailureCore|GiftUIRuntime|GiftUIBackend|GiftUIPlatform)\b/
fail_check("binding alias/body bridge contains reflection, dynamic storage, suspension, or prohibited owner") if
  [source, binding].any? { |text| text.match?(forbidden) }

fail_check("fixture must use generated host witness") unless tests.include?("@ObservableStateHost")
fail_check("fixture hand-authors generated witness") if tests.include?("_giftUIVisitObservableStateDeclarations")

puts "SPEC-010 binding decorator passed: generated lexical visits bind one transient copy before one body call."
