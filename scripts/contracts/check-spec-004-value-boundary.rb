#!/usr/bin/env ruby
# frozen_string_literal: true

ROOT = File.expand_path("../..", __dir__)
SOURCE_ROOT = File.join(ROOT, "Sources/GiftUICapabilities")

def fail_check(message)
  warn "SPEC-004 value boundary check failed: #{message}"
  exit 1
end

if ARGV.first == "--source-only"
  fail_check("expected one regression source path") unless ARGV.length == 2
  source_paths = [ARGV.fetch(1)]
  interface = ""
  symbols = ""
elsif ARGV.first == "--binary-only"
  fail_check("expected one regression symbol path") unless ARGV.length == 2
  source_paths = []
  interface = ""
  begin
    symbols = File.read(ARGV.fetch(1))
  rescue Errno::ENOENT => error
    fail_check(error.message)
  end
else
  fail_check("expected interface and undefined-symbol paths") unless ARGV.length == 2
  source_paths = Dir.glob(File.join(SOURCE_ROOT, "**/*.swift")).sort
  begin
    interface = File.read(ARGV.fetch(0))
    symbols = File.read(ARGV.fetch(1))
  rescue Errno::ENOENT => error
    fail_check(error.message)
  end
end

begin
  sources = source_paths.map { |path| File.read(path) }.join("\n")
rescue Errno::ENOENT => error
  fail_check(error.message)
end
source_code = sources.each_line.map { |line| line.sub(%r{//.*\z}, "") }.join
combined = source_code + "\n" + interface

forbidden_tokens = {
  "string" => /\b(?:Swift\.)?String\b/,
  "array" => /\b(?:Swift\.)?Array\s*</,
  "dictionary" => /\b(?:Swift\.)?Dictionary\s*</,
  "set" => /\b(?:Swift\.)?Set\s*</,
  "existential" => /\bany\s+[A-Za-z_]/,
  "reflection" => /\b(?:Mirror|_typeByName)\b/,
  "exception" => /\b(?:throw|throws|rethrows|catch)\b/,
  "registry" => /\b(?:Registry|Registration|register|registered)\b/,
  "reference storage" => /\b(?:class|actor|weak|unowned)\b/,
  "heap provenance" => /\b(?:AnyObject|ManagedBuffer|Unmanaged|Unsafe(?:Mutable)?(?:Raw)?Pointer)\b/,
  "platform identity" => /\b(?:Device|Board|Platform|Driver|Controller|Transport)(?:ID|Name|Type|Kind)?\b/,
}.freeze
found_tokens = forbidden_tokens.keys.select do |name|
  combined.match?(forbidden_tokens.fetch(name))
end

array_literals = source_code.each_line.select { |line| line.match?(/=\s*\[/) }
found_tokens << "array literal" unless array_literals.empty?

closure_storage = source_code.each_line.select do |line|
  line.match?(/\b(?:let|var)\b.*:\s*(?:@escaping\s*)?\([^)]*\)\s*->/)
end
found_tokens << "closure storage" unless closure_storage.empty?

fail_check("forbidden value facilities: #{found_tokens.uniq.inspect}") unless found_tokens.empty?

forbidden_binary_patterns = {
  "malloc" => /(?:^|\s)_malloc$/,
  "calloc" => /(?:^|\s)_calloc$/,
  "realloc" => /(?:^|\s)_realloc$/,
  "Swift object allocation" => /_swift_(?:slowAlloc|allocObject)/,
  "Swift bridge retain" => /_swift_bridgeObjectRetain/,
  "String metadata" => /_\$sSS/,
  "Array metadata" => /_\$sSa/,
  "Dictionary metadata" => /_\$sSD/,
  "Set metadata" => /_\$sSh/,
}.freeze
found_symbols = forbidden_binary_patterns.keys.select do |name|
  symbols.match?(forbidden_binary_patterns.fetch(name))
end
fail_check("forbidden binary facilities: #{found_symbols.inspect}") unless found_symbols.empty?

puts "SPEC-004 value boundary check passed: no string, collection, closure, existential, " \
     "reflection, exception, registry, concrete identity, heap-provenance, or allocation facility."
