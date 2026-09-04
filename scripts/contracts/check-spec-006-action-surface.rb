#!/usr/bin/env ruby
# frozen_string_literal: true

source = File.read(File.expand_path("../../Sources/GiftUI/DeclarativeView.swift", __dir__))

def fail_check(message)
  warn "SPEC-006 action/view surface check failed: #{message}"
  exit 1
end

required = [
  "public protocol GiftUIAction: RawRepresentable, Equatable, Sendable",
  "where RawValue == UInt16 {}",
  "public protocol View",
  "associatedtype Body: View",
  "@ViewBuilder",
  "func _giftUITraverse<Visitor: _GiftUISemanticTraversalVisitor>",
  "visitor.visitCustomView(self) { body }",
  "extension Never: View",
  "public typealias Body = Never",
]
missing = required.reject { |fragment| source.include?(fragment) }
fail_check("missing exact fragments #{missing.inspect}") unless missing.empty?

forbidden = {
  /\b(?:actionDomainID|actionDomainIdentifier|numericDomain)\b/i => "public numeric action domain",
  /\b(?:handler|callable|modelTarget|targetGeneration)\b/ => "downstream action machinery",
  /\b(?:Task|MainActor|Any|Mirror|ObjectiveC)\b/ => "runtime-only facility",
  /\bViewVisitor\b|\b_visit\b/ => "proof-of-concept traversal compatibility",
}
forbidden.each do |pattern, label|
  fail_check("surface contains #{label}") if source.match?(pattern)
end

puts "SPEC-006 action/view surface passed: UInt16 action domain and default custom traversal witness."
