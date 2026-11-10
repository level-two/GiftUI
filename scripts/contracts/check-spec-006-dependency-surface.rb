#!/usr/bin/env ruby
# frozen_string_literal: true

require "pathname"
require "digest"

ROOT = Pathname.new(File.expand_path("../..", __dir__))
SEMANTIC = ROOT.join("Sources/GiftUISemanticCore/GiftUISemanticCore.swift")
SURFACE = ROOT.join("Tests/ContractFixtures/SPEC006/semantic-surface-allowlist.tsv")
PACKAGE_INTERFACE = ROOT.join("Tests/ContractFixtures/SPEC006/compiled-package-interface.allowlist.swiftinterface")
UNDERSCORED = ROOT.join("Tests/ContractFixtures/SPEC006/underscored-reference-allowlist.tsv")
PACKAGE = ROOT.join("Package.swift")

def fail_check(message)
  warn "SPEC-006 dependency surface check failed: #{message}"
  exit 1
end

def table(path, width)
  path.each_line.each_with_object([]) do |line, result|
    next if line.start_with?("#") || line.strip.empty?

    fields = line.chomp.split("\t", -1)
    fail_check("#{path.basename} row width differs") unless fields.length == width
    result << fields
  end
end

def normalized_interface(path)
  path.each_line.reject { |line| line.start_with?("// swift-") }.join
end

source = SEMANTIC.read
fail_check("Semantic Core imports differ") unless source.scan(/^import (\S+)/).flatten == ["GiftUI"]

forbidden = /\b(?:Any|any|Mirror|Task|MainActor|actor|async|await|@objc|NSObject|Selector|String|Array|ContiguousArray|Dictionary|Set|GiftUIBackend|GiftUIPlatform|GiftUIDriver|GiftUIRuntimeDynamic|GiftUIRuntimeStatic)\b/
fail_check("Semantic Core uses a forbidden production surface") if source.match?(forbidden)

declared = source.scan(/^(package|public) (struct|enum|protocol|func) ([A-Za-z_][A-Za-z0-9_]*)/)
allowed = table(SURFACE, 3)
fail_check("Semantic Core declaration surface differs") unless declared == allowed

allowed_underscored = table(UNDERSCORED, 3).map(&:first).sort
actual_underscored = source.scan(/\b_GiftUI[A-Za-z0-9_]+\b|\b_giftUITraverse\b/).uniq.sort
unexpected_source = actual_underscored - allowed_underscored
fail_check("underscored source references are unlisted: #{unexpected_source}") unless unexpected_source.empty?

package = PACKAGE.read
semantic_target = package[/\.target\(\s*name: "GiftUISemanticCore",(.*?)\n\s*\),/m, 1]
fail_check("Semantic Core target declaration differs") unless semantic_target
dependency_list = semantic_target[/dependencies:\s*\[(.*?)\]/m, 1]
fail_check("Semantic Core dependency list differs") unless dependency_list
dependencies = dependency_list.scan(/"([A-Za-z0-9_]+)"/).flatten
fail_check("Semantic Core target dependencies differ") unless dependencies == ["GiftUI"]

expected_package_interface = normalized_interface(PACKAGE_INTERFACE)
fail_check("compiled package interface allowlist is empty") if expected_package_interface.empty?

arguments = ARGV.dup
if arguments.empty?
  puts "SPEC-006 dependency surface passed: exact leaf edge, declaration surface, underscored allowlist, and forbidden-surface scans are clean."
  exit 0
end

fail_check("usage: check-spec-006-dependency-surface.rb --giftui-interface PATH --semantic-interface PATH --output PATH") unless arguments.length == 6
options = arguments.each_slice(2).to_h
giftui_interface = Pathname.new(options.fetch("--giftui-interface"))
semantic_interface = Pathname.new(options.fetch("--semantic-interface"))
output = Pathname.new(options.fetch("--output"))
fail_check("GiftUI interface missing") unless giftui_interface.file?
fail_check("Semantic Core interface missing") unless semantic_interface.file?

compiled_underscored = (giftui_interface.read + semantic_interface.read)
  .scan(/\b_GiftUI[A-Za-z0-9_]+\b|\b_giftUITraverse\b/).uniq.sort
unexpected = compiled_underscored - allowed_underscored
fail_check("compiled interface has unexpected underscored references: #{unexpected}") unless unexpected.empty?

actual_package_interface = normalized_interface(semantic_interface)
unless actual_package_interface == expected_package_interface
  fail_check(
    "complete Semantic Core package interface/member inventory differs " \
    "from the approved Swift 6.4 snapshot"
  )
end

package_api_declarations = actual_package_interface.scan(/^package\s+(?:func|struct|enum|protocol|class|typealias)\b/).length
package_api_members = actual_package_interface.scan(/^[ \t]+(?:package|case)\s+/).length

output.write([
  "schema_version=1",
  "semantic_dependencies=GiftUI",
  "semantic_declarations=#{declared.length}",
  "underscored_allowlist=#{allowed_underscored.length}",
  "compiled_underscored=#{compiled_underscored.length}",
  "compiled_package_interface_sha256=#{Digest::SHA256.hexdigest(actual_package_interface)}",
  "package_api_declarations=#{package_api_declarations}",
  "package_api_members=#{package_api_members}",
  "package_api_inventory=complete-exact-interface-snapshot",
  "forbidden_production_uses=0",
  "runtime_profile_targets=downstream",
  "migration_inventory=separately-verified",
].join("\n") + "\n")
puts "SPEC-006 compiled dependency surface report written: #{output}"
