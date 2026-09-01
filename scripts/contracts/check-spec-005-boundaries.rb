#!/usr/bin/env ruby
# frozen_string_literal: true

require "json"
require "yaml"

ROOT = File.expand_path("../..", __dir__)
SOURCE_ROOT = File.join(ROOT, "Sources/GiftUITextResources")
CONTRACT_PATH = File.join(ROOT, "Tests/ContractFixtures/SPEC005/target-boundaries.yaml")

def fail_check(message)
  warn "SPEC-005 boundary check failed: #{message}"
  exit 1
end

unless ARGV.length == 6
  fail_check("expected text public/package interfaces, GiftUI public/package interfaces, and both dependency scans")
end
text_public_path, text_package_path, giftui_public_path, giftui_package_path,
  text_dependencies_path, giftui_dependencies_path = ARGV

begin
  sources = Dir.glob(File.join(SOURCE_ROOT, "**/*.swift")).sort.map { |path| File.read(path) }.join("\n")
  text_interfaces = File.read(text_public_path) + "\n" + File.read(text_package_path)
  giftui_interfaces = File.read(giftui_public_path) + "\n" + File.read(giftui_package_path)
  text_dependencies = JSON.parse(File.read(text_dependencies_path))
  giftui_dependencies = JSON.parse(File.read(giftui_dependencies_path))
  contract = YAML.safe_load(File.read(CONTRACT_PATH), aliases: false)
rescue Errno::ENOENT, JSON::ParserError, Psych::Exception => error
  fail_check(error.message)
end

forbidden = contract.fetch("forbidden_text_resource_imports")
combined = sources + "\n" + text_interfaces
fail_check("text-resource source/interface contains @_exported import") if combined.match?(/@_exported\s+import/)

source_imports = sources.scan(/^\s*import\s+([A-Za-z0-9_]+)/).flatten
fail_check("text-resource source imports differ: #{source_imports.inspect}") unless source_imports == ["GiftUI"]
interface_imports = text_interfaces.scan(/^\s*(?:@_exported\s+)?import\s+([A-Za-z0-9_]+)/).flatten
forbidden_interfaces = interface_imports & forbidden
fail_check("forbidden text-resource interface imports: #{forbidden_interfaces.sort.inspect}") unless forbidden_interfaces.empty?

find_module = lambda do |scan, name, source_suffix|
  scan.fetch("modules").find do |entry|
    entry["modulePath"] == "#{name}.swiftmodule" ||
      entry["sourceFiles"]&.any? { |path| path.end_with?(source_suffix) }
  end
end

text_module = find_module.call(text_dependencies, "GiftUITextResources", "/Sources/GiftUITextResources/GiftUITextResources.swift")
fail_check("compiled dependency scan lacks GiftUITextResources") unless text_module
text_imports = text_module.fetch("imports", []).map { |entry| entry.fetch("identifier") }
fail_check("compiled text-resource dependency lacks GiftUI") unless text_imports.include?("GiftUI")
compiled_forbidden = text_imports & forbidden
fail_check("forbidden compiled text-resource imports: #{compiled_forbidden.sort.inspect}") unless compiled_forbidden.empty?

giftui_module = find_module.call(giftui_dependencies, "GiftUI", "/Sources/GiftUI/GiftUI.swift")
fail_check("compiled dependency scan lacks GiftUI") unless giftui_module
giftui_imports = giftui_module.fetch("imports", []).map { |entry| entry.fetch("identifier") }
fail_check("GiftUI compiled dependency includes GiftUITextResources") if giftui_imports.include?("GiftUITextResources")

if giftui_interfaces.match?(/@_exported\s+import\s+GiftUITextResources/) ||
   giftui_interfaces.match?(/^\s*import\s+GiftUITextResources/) ||
   giftui_interfaces.include?("GiftUITextResources.")
  fail_check("GiftUI public/package interfaces re-export or reference GiftUITextResources")
end

identity_names = contract.fetch("identity_owners")
parallel = []
Dir.glob(File.join(ROOT, "Sources", "**/*.swift")).sort.each do |path|
  next if path.start_with?(SOURCE_ROOT + File::SEPARATOR)

  File.foreach(path).with_index(1) do |line, line_number|
    identity_names.each do |name|
      if line.match?(/\b(?:struct|enum|class|typealias)\s+#{Regexp.escape(name)}\b/)
        parallel << "#{path.delete_prefix(ROOT + '/')}:#{line_number}:#{name}"
      end
    end
  end
end
fail_check("parallel or translated identity declaration: #{parallel.join(', ')}") unless parallel.empty?

puts "SPEC-005 boundary check passed: source/interface/compiled dependencies, " \
     "GiftUI non-re-export, and nominal identity ownership are exact."
