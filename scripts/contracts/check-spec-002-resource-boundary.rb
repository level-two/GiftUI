#!/usr/bin/env ruby
# frozen_string_literal: true

ROOT = File.expand_path("../..", __dir__)
SOURCE = File.join(ROOT, "Sources/GiftUI/GiftUI.swift")
FORBIDDEN_SOURCE = {
  "reflection" => /\b(?:Mirror|_typeByName)\b/,
  "runtime discovery" => /\b(?:dlsym|dlopen|NSClassFromString)\b/,
  "Objective-C" => /\b(?:NSObject|@objc|ObjectiveC)\b/,
  "Task" => /\bTask\b/,
  "MainActor" => /\bMainActor\b/,
  "allocation API" => /\b(?:malloc|calloc|realloc|UnsafeMutablePointer\.allocate)\b/,
}.freeze
FORBIDDEN_SYMBOLS = %w[
  malloc
  calloc
  realloc
  free
  posix_memalign
  swift_slowAlloc
  swift_allocObject
  swift_bridgeObjectRetain
  swift_task_alloc
  swift_getTypeByName
  objc_msgSend
].freeze

def fail_check(message)
  warn "SPEC-002 resource boundary check failed: #{message}"
  exit 1
end

mode = :symbols
if ARGV.first == "--ir"
  mode = :ir
  ARGV.shift
end
fail_check("expected one evidence path") unless ARGV.length == 1

begin
  source = File.read(SOURCE)
  evidence = File.read(ARGV.fetch(0))
rescue Errno::ENOENT => error
  fail_check(error.message)
end

found_source = FORBIDDEN_SOURCE.keys.select { |name| source.match?(FORBIDDEN_SOURCE.fetch(name)) }
fail_check("Foundation source contains forbidden facilities #{found_source.inspect}") unless found_source.empty?

if mode == :ir
  evidence = evidence[/define [^{]+exercise[^\{]*\{(.*?)^\}/m, 1]
  fail_check("optimized IR lacks the operation exercise function") unless evidence
end

found_symbols = FORBIDDEN_SYMBOLS.select do |symbol|
  evidence.each_line.any? { |line| line.match?(/(?:_|\b)#{Regexp.escape(symbol)}\b/) }
end
fail_check("operation evidence references forbidden symbols #{found_symbols.inspect}") unless found_symbols.empty?

puts "SPEC-002 resource boundary check passed: no forbidden source facility or operation-path symbol."
