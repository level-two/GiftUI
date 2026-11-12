#!/usr/bin/env ruby
# frozen_string_literal: true

root = File.expand_path("../..", __dir__)
declaration = File.read(File.join(root, "Sources/GiftUI/DeclarativeView.swift"))
builder_sources = %w[Button.swift LayoutContainers.swift].map do |name|
  File.read(File.join(root, "Sources/GiftUI", name))
end.join("\n")

def fail_check(message)
  warn "SPEC-006 action/view surface check failed: #{message}"
  exit 1
end

required = [
  "public protocol GiftUIAction: RawRepresentable, Equatable, Sendable",
  "where RawValue == UInt16 {}",
  "public protocol View<Domain>",
  "associatedtype Domain: _GiftUIReadDomain",
  "associatedtype Body: View",
  "func _giftUIEvaluate(read: borrowing _GiftUIFrameRead<Domain>)",
  "throws(_GiftUIAccessFailure) -> Body",
  "func _giftUITraverse<Visitor: _GiftUISemanticTraversalVisitor & ~Copyable & ~Escapable>",
  "where Visitor.Domain == Domain",
  "visitor.visitCustomView(self) {",
  "_giftUIEvaluate(read: read)",
  "extension Never: View",
  "public typealias Body = Never",
]
missing = required.reject { |fragment| declaration.include?(fragment) }
missing << "@ViewBuilder" unless builder_sources.include?("@ViewBuilder")
fail_check("missing exact fragments #{missing.inspect}") unless missing.empty?

forbidden = {
  /\b(?:actionDomainID|actionDomainIdentifier|numericDomain)\b/i => "public numeric action domain",
  /\b(?:handler|callable|modelTarget|targetGeneration)\b/ => "downstream action machinery",
  /\b(?:Task|MainActor|Any|Mirror|ObjectiveC)\b/ => "runtime-only facility",
  /\bViewVisitor\b|\b_visit\b/ => "proof-of-concept traversal compatibility",
}
forbidden.each do |pattern, label|
  fail_check("surface contains #{label}") if declaration.match?(pattern)
end

puts "SPEC-006 action/view surface passed: UInt16 action domain and default custom traversal witness."
