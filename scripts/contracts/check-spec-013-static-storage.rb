#!/usr/bin/env ruby
# frozen_string_literal: true

require "pathname"

ROOT = Pathname.new(File.expand_path("../..", __dir__))
STORAGE = ROOT.join("Sources/GiftUIRuntimeStatic/StaticProfileStorage.swift")
FIXTURE = ROOT.join(
  "Tests/GiftUIRuntimeStaticTests/GeneratedStaticProfileFixture.swift"
)

def fail_check(message)
  warn "SPEC-013 Static storage check failed: #{message}"
  exit 1
end

storage = STORAGE.read
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
  fail_check("production source contains #{name}") if storage.match?(pattern)
end

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
     "51 fixed counters, shared ownership/reset registry, and no dynamic storage facility."
