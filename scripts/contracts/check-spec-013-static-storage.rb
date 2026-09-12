#!/usr/bin/env ruby
# frozen_string_literal: true

require "pathname"

ROOT = Pathname.new(File.expand_path("../..", __dir__))
STATIC_SOURCES = ROOT.join("Sources/GiftUIRuntimeStatic")
STORAGE = STATIC_SOURCES.join("StaticProfileStorage.swift")
FIXTURE = ROOT.join(
  "Tests/GiftUIRuntimeStaticTests/GeneratedStaticProfileFixture.swift"
)

def fail_check(message)
  warn "SPEC-013 Static storage check failed: #{message}"
  exit 1
end

storage = STORAGE.read
all_static_source = STATIC_SOURCES.glob("*.swift").sort.map(&:read).join("\n")
fixture = FIXTURE.read

forbidden = {
  "Array" => /\b(?:Array|ContiguousArray)\s*</,
  "Dictionary" => /\bDictionary\s*</,
  "Set" => /\bSet\s*</,
  "heap allocation" => /\.(?:allocate|deallocate)\s*\(/,
  "reference storage" => /\b(?:class|ManagedBuffer)\b/,
  "type erasure" => /\bAny\b/,
  "reflection" => /\bMirror\b/,
}
forbidden.each do |name, pattern|
  fail_check("production source contains #{name}") if all_static_source.match?(pattern)
end

occurrence = STATIC_SOURCES.join("StaticCanvasOccurrence.swift").read
fail_check("Static occurrence does not own inline optional capture") unless
  occurrence.include?("private var capture: Capture?")
fail_check("Static occurrence lacks success/throw release scope") unless
  occurrence.include?("defer { releaseIfLive() }")
fail_check("Static occurrence does not destroy stored capture") unless
  occurrence.include?("capture = nil")
fail_check("Static occurrence has a closure field") if occurrence.match?(/@escaping|->\s*Void/)

fail_check("fixed 51-counter tuple is missing") unless
  storage[/private typealias Storage = \((.*?)\n    \)/m, 1]&.scan(/UInt16/)&.length == 51
fail_check("all-storage counter reset is not fixed-size") unless
  storage.include?("current = StaticLimitCounters()")
fail_check("attempt-local reset does not use the shared ownership registry") unless
  storage.include?("if limit.family.isAttemptLocal")

region_names = %w[
  semanticCandidate semanticPublished layoutCandidate renderWorkspace
  canvasCallable pathWorkspace drawingPlan observableLive observableCandidate
  interactionCandidate interactionCommitted admissionQueue sealedBatch
  pointerState coordinatorState failureState
]
region_names.each do |name|
  declaration = /^    private var #{name}: UInt8 = 0$/
  fail_check("generated fixed region differs: #{name}") unless fixture.match?(declaration)
end
fail_check("generated fixed regions are not distinct") unless
  region_names.all? { |name| fixture.scan(/\b#{name}\b/).length >= 3 }

puts "SPEC-013 Static storage passed: 16 distinct generated inline regions, " \
     "51 fixed counters, scoped Canvas capture release, shared ownership/reset registry, " \
     "and no dynamic storage facility."
