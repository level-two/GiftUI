#!/usr/bin/env ruby
# frozen_string_literal: true

root = File.expand_path("../..", __dir__)
source_path = File.join(root, "Sources/GiftUI/DeclarativeView.swift")
source = File.read(source_path)
failures = []

required_fragments = [
  "public static func buildBlock() -> EmptyView",
  "public static func buildBlock<Content: View>(_ content: Content) -> Content",
  "public static func buildBlock<A: View, B: View>(",
  ") -> TupleView3<A, B, C>",
  ") -> TupleView4<A, B, C, D>",
  ") -> TupleView5<A, B, C, D, E>",
  "public static func buildEither<A: View, B: View>(",
  "public static func buildOptional<Content: View>(",
  "public struct EmptyView: View",
  "public struct TupleView<A: View, B: View>: View",
  "public struct TupleView3<A: View, B: View, C: View>: View",
  "public struct TupleView4<A: View, B: View, C: View, D: View>: View",
  "public struct TupleView5<A: View, B: View, C: View, D: View, E: View>: View",
  "public struct ConditionalContent<First: View, Second: View>: View",
  "public struct OptionalContent<Content: View>: View",
  "package init(first: First)",
  "package init(second: Second)",
  "visitor.visitEmpty()",
  "visitor.visitConditionalFirst(content, second: Second.self)",
  "visitor.visitConditionalSecond(first: First.self, content)",
  "visitor.visitOptionalAbsent(Content.self)",
  "visitor.visitOptionalPresent(content)"
]

required_fragments.each do |fragment|
  failures << "missing approved builder/wrapper fragment: #{fragment}" unless source.include?(fragment)
end

forbidden_patterns = {
  /static func buildArray/ => "ViewBuilder must not provide dynamic-array lowering",
  /public\s+(?:let|var)\s+(?:a|b|c|d|e|storage|content)\b/ =>
    "wrapper storage must not be ordinary public API",
  /public\s+init\s*\(/ => "wrapper construction must not be ordinary public API",
  /\bAnyView\b/ => "the bounded builder must not add type erasure"
}

forbidden_patterns.each do |pattern, message|
  failures << message if source.match?(pattern)
end

unless source.scan(/package init\b/).length == 8
  failures << "expected exactly eight package wrapper initializers"
end

unless source.scan(/visitor\.visitFixed\(/).length == 4
  failures << "expected one fixed traversal dispatch per tuple wrapper"
end

unless source.scan(/fatalError\("(?:EmptyView|TupleView\d*|ConditionalContent|OptionalContent) has no view body"\)/).length == 7
  failures << "every structural wrapper must reject body evaluation"
end

if failures.empty?
  puts "SPEC-006 builder/wrapper surface check passed"
  exit 0
end

warn "SPEC-006 builder/wrapper surface check failed:"
failures.each { |failure| warn "- #{failure}" }
exit 1
