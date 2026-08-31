#!/usr/bin/env ruby
# frozen_string_literal: true

def fail_check(message)
  warn "SPEC-003 semantic suite normalization failed: #{message}"
  exit 1
end

raw_path, transcript_path = ARGV
fail_check("usage: #{File.basename($PROGRAM_NAME)} <raw-log> <transcript>") unless
  raw_path && transcript_path && ARGV.length == 2

begin
  raw = File.read(raw_path)
rescue Errno::ENOENT => error
  fail_check(error.message)
end

tests = raw.scan(%r{^Test Case '-\[(.+)\]' passed \([^)]+\)\.$}).flatten.sort
fail_check("no passing XCTest cases found") if tests.empty?
counts = tests.each_with_object(Hash.new(0)) { |test, result| result[test] += 1 }
duplicates = counts.select { |_test, count| count != 1 }
fail_check("duplicate test cases: #{duplicates.keys.join(', ')}") unless duplicates.empty?

required_coverage = {
  "facts" => /test(?:ConditionID|FailureFact|Outcome)/,
  "containment" => /test(?:Containment|UnknownProducer|Propagation|ExplicitProvenScope)/,
  "annotations" => /test(?:Annotations|Annotation|ThirdAnnotation)/,
  "policy-validation-results" => /test(?:Residual|PacedRetry|SafetyNotProven|ContainedFailure|FixturePolicy|UnexpectedPolicy|UnlistedPolicy)/,
  "health" => /test(?:OperationalHealth|OperationalRecord|FailureRecord|HealthCounters|QuiescedHealth)/,
  "diagnostic-isolation" => /test(?:DiagnosticConfiguration|CallbackAndInterrupt)/,
  "exhaustion" => /test(?:ThirdAnnotation|InvalidAttemptRange|CountersSaturate|FullBufferDrops|DroppedRecordCounter)/,
  "foundation-owner-mapping" => /GiftUIFoundationFailureAdapterTests/,
  "capability-owner-mapping" => /CapabilityFailureAdapterTests/
}.freeze

missing = required_coverage.reject do |_category, pattern|
  tests.any? { |test| pattern.match?(test) }
end
fail_check("missing semantic categories: #{missing.keys.join(', ')}") unless missing.empty?

File.open(transcript_path, "w") do |file|
  file.puts("schema_version\t1")
  required_coverage.each_key { |category| file.puts("coverage\t#{category}") }
  tests.each { |test| file.puts("pass\t#{test}") }
end

puts "SPEC-003 semantic suite normalized: #{tests.length} tests, #{required_coverage.length} categories."
