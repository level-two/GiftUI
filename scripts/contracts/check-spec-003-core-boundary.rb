#!/usr/bin/env ruby
# frozen_string_literal: true

ROOT = File.expand_path("../..", __dir__)
SOURCE_ROOT = File.join(ROOT, "Sources/GiftUIFailureCore")
FORBIDDEN_MODULES = %w[
  GiftUI
  GiftUIFailureExecution
  GiftUIFailureDiagnostics
  GiftUICapabilities
  GiftUIExecutionContract
  GiftUIRuntimeDynamic
  GiftUIRuntimeStatic
  GiftUIBackend
  GiftUIPlatform
  GiftUIHost
].freeze

def fail_check(message)
  warn "SPEC-003 Core boundary check failed: #{message}"
  exit 1
end

fail_check("expected interface and product-link paths") unless ARGV.length == 2
interface_path, links_path = ARGV

begin
  sources = Dir.glob(File.join(SOURCE_ROOT, "**/*.swift")).sort.map { |path| File.read(path) }.join("\n")
  interface = File.read(interface_path)
  links = File.read(links_path)
rescue Errno::ENOENT => error
  fail_check(error.message)
end

combined = sources + "\n" + interface
fail_check("Core source or interface contains @_exported import") if combined.match?(/@_exported\s+import/)

imports = combined.scan(/^\s*(?:@(?:_implementationOnly|_spi\([^)]*\))\s+)?import\s+([A-Za-z0-9_]+)/).flatten
forbidden_imports = imports & FORBIDDEN_MODULES
fail_check("forbidden upward imports: #{forbidden_imports.sort.inspect}") unless forbidden_imports.empty?

linked_basenames = links.each_line.each_with_object([]) do |line, names|
  next unless line.start_with?("\t")
  names << File.basename(line.strip.split.first)
end
forbidden_links = FORBIDDEN_MODULES.select do |name|
  linked_basenames.any? { |basename| basename.match?(/\Alib#{Regexp.escape(name)}(?:\.|\z)/) }
end
fail_check("forbidden product links: #{forbidden_links.sort.inspect}") unless forbidden_links.empty?

puts "SPEC-003 Core boundary check passed: no re-export, upward import, or forbidden product link."
