#!/usr/bin/env ruby
# frozen_string_literal: true

root = File.expand_path("../..", __dir__)
declaration_path = File.join(root, "Sources/GiftUI/DeclarativeView.swift")
source = File.read(declaration_path)
failures = []

required_fragments = [
  "public protocol _GiftUISemanticPrimitivePayload {}",
  "public protocol _GiftUISemanticActionPayload {",
  "associatedtype Action: GiftUIAction",
  "var _giftUIAction: Action { get }",
  "public protocol _GiftUISemanticModifierPayload {}",
  "mutating func visitCustomView<Declaration: View>(",
  "mutating func visitEmpty()",
  "mutating func visitFixed<A: View, B: View>(",
  "mutating func visitConditionalFirst<First: View, Second: View>(",
  "mutating func visitConditionalSecond<First: View, Second: View>(",
  "mutating func visitOptionalAbsent<Content: View>(_ content: Content.Type)",
  "mutating func visitOptionalPresent<Content: View>(",
  "mutating func visitPrimitive<Payload: _GiftUISemanticPrimitivePayload>(",
  "mutating func visitActionPrimitive<Payload: _GiftUISemanticActionPayload>(",
  "Payload: _GiftUISemanticModifierPayload"
]

required_fragments.each do |fragment|
  failures << "missing traversal fragment: #{fragment}" unless source.include?(fragment)
end

if source.scan(/func _giftUITraverse</).length != 9
  failures << "expected one View requirement/default and seven wrapper traversal witnesses"
end

if source.scan(/func _giftUITraverse<Visitor:/).length != 9
  failures << "a second traversal requirement or witness spelling is present"
end

allowed_source_paths = [
  "Sources/GiftUI/DeclarativeView.swift",
  "Sources/GiftUISemanticCore/GiftUISemanticCore.swift"
]
Dir.glob(File.join(root, "Sources/**/*.swift")).sort.each do |absolute|
  relative = absolute.delete_prefix("#{root}/")
  next if allowed_source_paths.include?(relative)

  text = File.read(absolute)
  next unless text.match?(/_GiftUISemantic|_giftUITraverse/)

  failures << "underscored traversal reference outside the source allow-list: #{relative}"
end

forbidden_patterns = {
  /\bAny\b/ => "traversal must not use Any",
  /\bany\s+View\b/ => "traversal must not use a View existential",
  /\bMirror\b/ => "traversal must not use reflection",
  /\bViewVisitor\b|\b_visit\b/ => "retired traversal surface is present"
}
forbidden_patterns.each do |pattern, message|
  failures << message if source.match?(pattern)
end

if source.include?("public protocol _GiftUIObservableStateHost")
  failures << "SPEC-010-owned state-host declarations were introduced by SPEC-006"
end

if failures.empty?
  puts "SPEC-006 non-stateful traversal surface check passed; SPEC-010 state-host seam remains pending"
  exit 0
end

warn "SPEC-006 traversal surface check failed:"
failures.each { |failure| warn "- #{failure}" }
exit 1
