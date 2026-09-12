#!/usr/bin/env ruby
# frozen_string_literal: true

require "json"
require "yaml"

ROOT = File.expand_path("../..", __dir__)

def fail_check(message)
  warn "SPEC-010 macro boundary check failed: #{message}"
  exit 1
end

package = File.read(File.join(ROOT, "Package.swift"))
resolved = JSON.parse(File.read(File.join(ROOT, "Package.resolved")))
graph = YAML.safe_load(
  File.read(File.join(ROOT, "Tests/ContractFixtures/SPEC002/target-dependencies.yaml")),
  aliases: false
).fetch("targets")
declaration = File.read(File.join(ROOT, "Sources/GiftUI/ObservableState.swift"))
macro_sources = Dir.glob(File.join(ROOT, "Sources/GiftUIMacros/*.swift")).sort
fail_check("macro target source is missing") if macro_sources.empty?
macro_source = macro_sources.map { |path| File.read(path) }.join("\n")

required_package_fragments = [
  "import CompilerPluginSupport",
  ".package(\n            url: \"https://github.com/swiftlang/swift-syntax.git\",\n            exact: \"603.0.2\"",
  ".macro(\n            name: \"GiftUIMacros\"",
  ".target(name: \"GiftUI\", dependencies: [\"GiftUIMacros\"])",
]
missing_package = required_package_fragments.reject { |fragment| package.include?(fragment) }
fail_check("package declaration differs: #{missing_package.inspect}") unless missing_package.empty?
fail_check("macro target became a product") if package.match?(/\.library\([^\n]*GiftUIMacros/)

pin = resolved.fetch("pins").find { |candidate| candidate["identity"] == "swift-syntax" }
fail_check("swift-syntax pin is missing") unless pin
fail_check("swift-syntax version differs") unless pin.dig("state", "version") == "603.0.2"

macro_graph = graph.fetch("GiftUIMacros")
fail_check("macro target type differs") unless macro_graph.fetch("type") == "macro"
fail_check("macro target has internal runtime edges") unless macro_graph.fetch("dependencies").empty?
expected_external = %w[
  SwiftCompilerPlugin@swift-syntax
  SwiftDiagnostics@swift-syntax
  SwiftSyntax@swift-syntax
  SwiftSyntaxBuilder@swift-syntax
  SwiftSyntaxMacros@swift-syntax
]
fail_check("macro compiler-support edges differ") unless
  macro_graph.fetch("external_dependencies") == expected_external
fail_check("GiftUI does not name its host macro build edge") unless
  graph.fetch("GiftUI").fetch("dependencies") == ["GiftUIMacros"]
macro_consumers = graph.each_with_object([]) do |(name, declaration), consumers|
  consumers << name if declaration.fetch("dependencies").include?("GiftUIMacros")
end.sort
fail_check("macro consumers differ") unless macro_consumers == %w[GiftUI GiftUIMacrosTests]

owner_graph = graph.fetch("GiftUIObservableState")
fail_check("observable owner type differs") unless owner_graph.fetch("type") == "regular"
fail_check("observable owner dependencies differ") unless
  owner_graph.fetch("dependencies") == %w[GiftUI GiftUIExecution GiftUISemanticCore]
fail_check("observable tests dependencies differ") unless
  graph.fetch("GiftUIObservableStateTests").fetch("dependencies") ==
    %w[GiftUI GiftUIExecution GiftUIObservableState GiftUISemanticCore]
fail_check("observable failure adapter dependencies differ") unless
  graph.fetch("GiftUIObservableStateFailureAdapterFixture").fetch("dependencies") ==
    %w[GiftUIFailureCore GiftUIObservableState]

owner_sources = Dir.glob(File.join(ROOT, "Sources/GiftUIObservableState/*.swift")).sort
fail_check("observable owner source is missing") if owner_sources.empty?
owner_imports = owner_sources.flat_map { |path| File.read(path).scan(/^import (\w+)/).flatten }.uniq.sort
fail_check("observable owner imports differ: #{owner_imports.inspect}") unless
  owner_imports == %w[GiftUI GiftUIExecution GiftUISemanticCore]

required_declaration_fragments = [
  "@attached(\n    member,\n    names: named(_giftUIVisitObservableStateDeclarations), named(_giftUITraverse)\n)",
  "@attached(extension, conformances: _GiftUIObservableStateHost)",
  "public macro ObservableStateHost() =\n    #externalMacro(",
  "module: \"GiftUIMacros\"",
  "type: \"ObservableStateHostMacro\"",
]
missing_declarations = required_declaration_fragments.reject do |fragment|
  declaration.include?(fragment)
end
fail_check("macro declaration differs: #{missing_declarations.inspect}") unless missing_declarations.empty?

required_generation = [
  "public struct ObservableStateHostMacro: MemberMacro, ExtensionMacro",
  "visitor.visit(&_\\(name), declarationOrdinal: \\(offset))",
  "visitor.visitStatefulCustomView(self)",
  "_GiftUIObservableStateHost",
  "count > Int(UInt16.max)",
]
missing_generation = required_generation.reject { |fragment| macro_source.include?(fragment) }
fail_check("macro generation differs: #{missing_generation.inspect}") unless missing_generation.empty?

forbidden = /import\s+(?:GiftUI|GiftUIRuntime|GiftUIInteraction|Foundation|Observation)|\b(?:Any|Mirror|TaskLocal)\b/
fail_check("macro target contains a forbidden target/runtime mechanism") if macro_source.match?(forbidden)

puts "SPEC-010 target boundary passed: pinned host-only macro, exact observable owner graph, and bounded deterministic generation."
