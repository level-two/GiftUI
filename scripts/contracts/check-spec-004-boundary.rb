#!/usr/bin/env ruby
# frozen_string_literal: true

require "json"
require "yaml"

ROOT = File.expand_path("../..", __dir__)
SOURCE_ROOT = File.join(ROOT, "Sources/GiftUICapabilities")
CONTRACT_PATH = File.join(ROOT, "Tests/ContractFixtures/SPEC004/target-boundaries.yaml")

def fail_check(message)
  warn "SPEC-004 boundary check failed: #{message}"
  exit 1
end

unless ARGV.length == 5
  fail_check("expected capability interface, product links, dependency scan, and GiftUI public/package interfaces")
end
interface_path, links_path, dependencies_path, giftui_public_path, giftui_package_path = ARGV

begin
  sources = Dir.glob(File.join(SOURCE_ROOT, "**/*.swift")).sort.map { |path| File.read(path) }.join("\n")
  interface = File.read(interface_path)
  links = File.read(links_path)
  dependencies = JSON.parse(File.read(dependencies_path))
  giftui_interfaces = File.read(giftui_public_path) + "\n" + File.read(giftui_package_path)
  contract = YAML.safe_load(File.read(CONTRACT_PATH), aliases: false)
rescue Errno::ENOENT, JSON::ParserError, Psych::Exception => error
  fail_check(error.message)
end

forbidden = contract.fetch("forbidden_capability_imports")
combined = sources + "\n" + interface
fail_check("capability source or interface contains @_exported import") if combined.match?(/@_exported\s+import/)

imports = combined.scan(/^\s*(?:@(?:_implementationOnly|_spi\([^)]*\))\s+)?import\s+([A-Za-z0-9_]+)/).flatten
forbidden_imports = imports & forbidden
fail_check("forbidden source/interface imports: #{forbidden_imports.sort.inspect}") unless forbidden_imports.empty?

main_module = dependencies.fetch("modules").find do |entry|
  entry["modulePath"] == "GiftUICapabilities.swiftmodule" ||
    entry["sourceFiles"]&.any? { |path| path.end_with?("/GiftUICapabilities.swift") }
end
fail_check("compiled dependency scan lacks GiftUICapabilities") unless main_module
compiled_imports = main_module.fetch("imports", []).map { |entry| entry.fetch("identifier") }
compiled_forbidden = compiled_imports & forbidden
fail_check("forbidden compiled imports: #{compiled_forbidden.sort.inspect}") unless compiled_forbidden.empty?

linked_basenames = links.each_line.each_with_object([]) do |line, names|
  next unless line.start_with?("\t")
  names << File.basename(line.strip.split.first)
end
forbidden_links = forbidden.select do |name|
  linked_basenames.any? { |basename| basename.match?(/\Alib#{Regexp.escape(name)}(?:\.|\z)/) }
end
fail_check("forbidden product links: #{forbidden_links.sort.inspect}") unless forbidden_links.empty?

if giftui_interfaces.match?(/@_exported\s+import\s+GiftUICapabilities/) ||
   giftui_interfaces.match?(/^\s*import\s+GiftUICapabilities/) ||
   giftui_interfaces.include?("GiftUICapabilities.")
  fail_check("GiftUI public/package interfaces re-export or reference GiftUICapabilities")
end

puts "SPEC-004 boundary check passed: source, compiled imports, product links, and " \
     "GiftUI interfaces preserve the foundational leaf."
