#!/usr/bin/env ruby
# frozen_string_literal: true

root = File.expand_path("../..", __dir__)
macro = File.read(File.join(root, "Sources/GiftUIMacros/ObservableStateHostMacro.swift"))
declarations = File.read(File.join(root, "Sources/GiftUI/DeclarativeView.swift"))
integration = File.read(File.join(root, "Tests/GiftUITests/DeclarativeViewTests.swift"))

def fail_check(message)
  warn "SPEC-010 generated traversal check failed: #{message}"
  exit 1
end

required_visitor = [
  "mutating func visitStatefulCustomView<",
  "Declaration: View & _GiftUIObservableStateHost",
  "_ declaration: borrowing Declaration",
  "body: (borrowing Declaration) -> Declaration.Body",
]
missing_visitor = required_visitor.reject { |fragment| declarations.include?(fragment) }
fail_check("SPEC-006 visitor signature differs: #{missing_visitor.inspect}") unless missing_visitor.empty?

required_generation = [
  "func _giftUITraverse<Visitor: _GiftUISemanticTraversalVisitor>",
  "visitor.visitStatefulCustomView(self) { declaration in",
  "declaration.body",
]
missing_generation = required_generation.reject { |fragment| macro.include?(fragment) }
fail_check("generated traversal witness differs: #{missing_generation.inspect}") unless missing_generation.empty?

fail_check("stateful integration host is not macro-generated") unless
  integration.match?(/@ObservableStateHost\s+private struct StatefulRootView: View/)
fail_check("stateful integration does not exercise generated traversal") unless
  integration.include?("StatefulRootView()._giftUITraverse(&visitor)")
fail_check("stateful integration retained a manual host witness") if
  integration.match?(/struct StatefulRootView.*?_giftUIVisitObservableStateDeclarations/m)

application_sources = Dir.glob(File.join(root, "Sources/**/*.swift")).reject do |path|
  path.include?("/Sources/GiftUI/") || path.include?("/Sources/GiftUIMacros/")
end
manual_application_witnesses = application_sources.select do |path|
  File.read(path).include?("func _giftUITraverse<")
end
fail_check("maintained application source has handwritten traversal: #{manual_application_witnesses.inspect}") unless
  manual_application_witnesses.empty?

puts "SPEC-010 generated traversal passed: exact stateful category, generated witness, and no application override."
