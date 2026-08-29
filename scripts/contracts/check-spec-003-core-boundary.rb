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

fail_check("expected interface, product-link, and undefined-symbol paths") unless ARGV.length == 3
interface_path, links_path, symbols_path = ARGV

begin
  sources = Dir.glob(File.join(SOURCE_ROOT, "**/*.swift")).sort.map { |path| File.read(path) }.join("\n")
  interface = File.read(interface_path)
  links = File.read(links_path)
  symbols = File.read(symbols_path)
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

forbidden_value_tokens = {
  "string" => /\b(?:Swift\.)?String\b/,
  "array" => /\b(?:Swift\.)?Array\s*</,
  "dictionary" => /\b(?:Swift\.)?Dictionary\s*</,
  "set" => /\b(?:Swift\.)?Set\s*</,
  "existential" => /\bany\s+[A-Za-z_]/,
  "platform-native error" => /\b(?:NSError|CFError|Error)\b/,
  "reflection" => /\b(?:Mirror|_typeByName)\b/,
  "exception" => /\b(?:throw|throws|rethrows|catch)\b/,
}.freeze
found_tokens = forbidden_value_tokens.keys.select { |name| combined.match?(forbidden_value_tokens.fetch(name)) }
fail_check("forbidden common-value facilities: #{found_tokens.inspect}") unless found_tokens.empty?

closure_storage = sources.each_line.select do |line|
  line.match?(/\b(?:let|var)\b.*:\s*(?:@escaping\s*)?\([^)]*\)\s*->/)
end
fail_check("closure storage is forbidden") unless closure_storage.empty?

forbidden_binary_symbols = %w[
  _malloc
  _calloc
  _realloc
  _swift_slowAlloc
  _swift_allocObject
  _swift_bridgeObjectRetain
].select { |symbol| symbols.include?(symbol) }
fail_check("forbidden instance-allocation symbols: #{forbidden_binary_symbols.inspect}") unless forbidden_binary_symbols.empty?

outcome_contract = interface.include?("public enum GiftUIOutcome<Success>") &&
  interface.include?("case success(Success)")
fail_check("generic success payload is not retained as caller-owned Success") unless outcome_contract

puts "SPEC-003 Core boundary check passed: no re-export, upward import, forbidden product link, " \
     "common reference facility, closure storage, or instance-allocation symbol; generic Success remains caller-owned."
