#!/usr/bin/env ruby
# frozen_string_literal: true

require "json"
require "open3"
require "pathname"

ROOT = Pathname.new(File.expand_path("../..", __dir__))

def fail_check(message)
  warn "SPEC-007 semantic boundary check failed: #{message}"
  exit 1
end

source = ROOT.join("Sources/GiftUISemanticCore/SemanticLayoutView.swift").read
view = source[/package protocol SemanticLayoutView \{(.*?)\n\}/m, 1]
fail_check("SemanticLayoutView declaration is missing") unless view

required = [
  "associatedtype Identity: Equatable, Sendable",
  "var rootIdentity: Identity { get }",
  "var scopeCount: UInt16 { get }",
  "func primitive(at identity: Identity) -> SemanticLayoutPrimitive?",
  "func childCount(of identity: Identity) -> UInt16?",
  "func modifierCount(of identity: Identity) -> UInt16?",
  "func textScalarCount(of identity: Identity) -> UInt16?",
]
required.each do |declaration|
  fail_check("layout view lacks #{declaration}") unless view.include?(declaration)
end

%w[Action Generation Model State Runtime Render Backend Platform AnyObject].each do |name|
  fail_check("layout view exposes forbidden #{name}") if view.match?(/\b#{name}\b/)
end
fail_check("layout view exposes an unrestricted existential") if view.match?(/\bany\s+/)

adapter = source[/package struct SemanticLayoutResultSink<Storage>:(.*?)\n\}/m, 1]
fail_check("semantic result adapter is missing") unless adapter
%w[Array Dictionary Set AnyHashable].each do |name|
  fail_check("adapter owns forbidden #{name} storage") if adapter.match?(/\b#{name}\b/)
end
fail_check("adapter declares collection storage") if adapter.match?(/\[[^\]]*\]/)

semantic_imports = Dir[ROOT.join("Sources/GiftUISemanticCore/**/*.swift")].flat_map do |path|
  File.readlines(path).map { |line| line[/\Aimport ([A-Za-z0-9_]+)/, 1] }.compact
end.uniq.sort
fail_check("Semantic Core imports differ: #{semantic_imports}") unless semantic_imports == ["GiftUI"]

layout_sources = Dir[ROOT.join("Sources/GiftUILayout/**/*.swift")].map { |path| File.read(path) }.join("\n")
%w[SemanticLayoutView SemanticLayoutPrimitive SemanticLayoutModifier].each do |name|
  fail_check("layout retains #{name} in stored state") if layout_sources.match?(/(?:let|var)\s+\w+\s*:\s*#{name}/)
end

package_json, package_error, package_status = Open3.capture3(
  "swift", "package", "--disable-sandbox", "dump-package", chdir: ROOT.to_s
)
fail_check("package dump failed: #{package_error}") unless package_status.success?
targets = JSON.parse(package_json).fetch("targets").to_h { |target| [target.fetch("name"), target] }
dependencies = targets.fetch("GiftUISemanticCore").fetch("dependencies", []).map do |dependency|
  declaration = dependency.fetch("byName", dependency.fetch("target", nil))
  declaration.is_a?(Array) ? declaration.first : declaration
end.compact
fail_check("Semantic Core dependency closure differs: #{dependencies}") unless dependencies == ["GiftUI"]

puts "SPEC-007 semantic boundary passed: exact borrowed surface, no adapter graph, and one-way source dependency closure."
