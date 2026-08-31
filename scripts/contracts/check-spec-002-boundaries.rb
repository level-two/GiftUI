#!/usr/bin/env ruby
# frozen_string_literal: true

require "json"
require "yaml"

ROOT = File.expand_path("../..", __dir__)
ALLOW_LIST_PATH = File.join(
  ROOT,
  "Tests/ContractFixtures/SPEC002/target-dependencies.yaml"
)
PROTECTED_FIXTURES = {
  "GiftUI" => [
    "Tests/ContractFixtures/SPEC002/fixture-manifest.tsv",
    "import-giftui",
    "forbidden-runtime-import",
  ],
  "GiftUIFailureCore" => [
    "Tests/ContractFixtures/SPEC003/fixture-manifest.tsv",
    "import-failure-core",
    "forbidden-giftui-import",
  ],
  "GiftUICapabilities" => [
    "Tests/ContractFixtures/SPEC004/fixture-manifest.tsv",
    "import-capabilities",
    "forbidden-giftui-import",
  ],
}.freeze
FORBIDDEN_GIFTUI_MODULES = %w[
  GiftUIFailureCore
  GiftUIFailureDiagnostics
  GiftUIFailureExecution
  GiftUICapabilities
  GiftUIExecutionContract
  GiftUISemantics
  GiftUILayout
  GiftUIRender
  GiftUIRuntimeDynamic
  GiftUIRuntimeStatic
  GiftUIBackend
  GiftUIPlatform
  GiftUIDriver
  GiftUIHost
].freeze

def fail_check(message)
  warn "SPEC-002 boundary check failed: #{message}"
  exit 1
end

unless ARGV.length == 5
  fail_check("expected package JSON, GiftUI public/package interfaces, dependency scan, and product links")
end
package_path, public_path, package_interface_path, scan_path, links_path = ARGV

begin
  package = JSON.parse(File.read(package_path))
  allow_list = YAML.safe_load(File.read(ALLOW_LIST_PATH), aliases: false)
  public_interface = File.read(public_path)
  package_interface = File.read(package_interface_path)
  dependency_scan = JSON.parse(File.read(scan_path))
  product_links = File.read(links_path)
rescue Errno::ENOENT, JSON::ParserError, Psych::Exception => error
  fail_check(error.message)
end

targets = package.fetch("targets")
target_names = targets.map { |target| target.fetch("name") }
expected_targets = allow_list.fetch("targets")
unless target_names.sort == expected_targets.keys.sort
  fail_check("package and allow-list target sets differ")
end

targets.each do |target|
  name = target.fetch("name")
  expected = expected_targets.fetch(name)
  dependency_names = expected.fetch("dependencies")
  directory = target.fetch("type") == "test" ? File.join(ROOT, "Tests", name) : File.join(ROOT, "Sources", name)
  source_paths = Dir.glob(File.join(directory, "**/*.swift")).sort
  fail_check("#{name} has no auditable Swift source directory") if source_paths.empty?

  source = source_paths.map { |path| File.read(path) }.join("\n")
  fail_check("#{name} contains an exported import") if source.match?(/@_exported\s+import/)
  imports = source.scan(/^\s*(?:@testable\s+)?(?:@(?:_implementationOnly|_spi\([^)]*\))\s+)?import\s+([A-Za-z0-9_]+)/).flatten
  package_imports = imports & target_names
  undeclared = package_imports - dependency_names
  fail_check("#{name} source imports undeclared package targets #{undeclared.sort.inspect}") unless undeclared.empty?
end

combined_interface = public_interface + "\n" + package_interface
if combined_interface.match?(/@_exported\s+import/) ||
   combined_interface.match?(/^\s*import\s+(?:#{FORBIDDEN_GIFTUI_MODULES.join("|")})\b/) ||
   FORBIDDEN_GIFTUI_MODULES.any? { |name| combined_interface.include?("#{name}.") }
  fail_check("GiftUI public/package interfaces import, re-export, or reference a prohibited module")
end

giftui_module = dependency_scan.fetch("modules").find do |entry|
  entry["modulePath"] == "GiftUI.swiftmodule" ||
    entry["sourceFiles"]&.any? { |path| path.end_with?("/Sources/GiftUI/GiftUI.swift") }
end
fail_check("compiled dependency scan lacks GiftUI") unless giftui_module
compiled_imports = giftui_module.fetch("imports", []).map { |entry| entry.fetch("identifier") }
compiled_forbidden = compiled_imports & FORBIDDEN_GIFTUI_MODULES
fail_check("GiftUI has forbidden compiled imports #{compiled_forbidden.sort.inspect}") unless compiled_forbidden.empty?

linked_basenames = product_links.each_line.each_with_object([]) do |line, names|
  next unless line.start_with?("\t")
  names << File.basename(line.strip.split.first)
end
forbidden_links = FORBIDDEN_GIFTUI_MODULES.select do |name|
  linked_basenames.any? { |basename| basename.match?(/\Alib#{Regexp.escape(name)}(?:\.|\z)/) }
end
fail_check("GiftUI has forbidden product links #{forbidden_links.sort.inspect}") unless forbidden_links.empty?

PROTECTED_FIXTURES.each do |owner, (relative_path, positive_id, forbidden_id)|
  rows = File.readlines(File.join(ROOT, relative_path), chomp: true).reject do |line|
    line.empty? || line.start_with?("#")
  end.map { |line| line.split("\t") }
  positive = rows.any? { |row| row[0] == positive_id && row[1] == "pass" }
  forbidden = rows.any? { |row| row[0] == forbidden_id && row[1] == "fail" }
  fail_check("#{owner} lacks its positive import fixture") unless positive
  fail_check("#{owner} lacks its forbidden import fixture") unless forbidden
end

puts "SPEC-002 boundary check passed: #{target_names.length} target source trees, " \
     "declared source imports, GiftUI interfaces/compiled dependencies/product links, " \
     "and three protected-owner fixture pairs."
