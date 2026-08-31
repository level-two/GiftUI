#!/usr/bin/env ruby
# frozen_string_literal: true

def fail_check(message)
  warn "SPEC-004 static-path check failed: #{message}"
  exit 1
end

fail_check("expected allocation output, semantic transcript, and production symbols") unless ARGV.length == 3
allocation_path, semantic_path, symbols_path = ARGV
allocation = File.readlines(allocation_path, chomp: true)
semantic = File.readlines(semantic_path, chomp: true)
symbols = File.read(symbols_path)

fail_check("allocation count is not exactly zero") unless allocation.grep(/^allocation_count=/) == ["allocation_count=0"]
checksum = allocation.grep(/^checksum=/)
fail_check("allocation probe checksum is missing or duplicated") unless checksum.length == 1

instrumentation = semantic.select { |line| line.include?("\tinstrumentation\t") }
expected = {
  "instrumentation-widest-resolver-path" => [44, 1],
  "instrumentation-early-negative-path" => [8, 1],
  "instrumentation-repeated-snapshot-access" => [0, 0],
}
observed = {}
instrumentation.each do |line|
  id, _domain, _inputs, outputs = line.split("\t", 4)
  words = outputs.split(",").map { |word| Integer(word, 10) }
  observed[id] = [words.fetch(0), id.include?("snapshot") ? words.fetch(1) : words.fetch(6)]
end
fail_check("instrumentation row set differs: #{observed.keys.sort.inspect}") unless observed.keys.sort == expected.keys.sort
expected.each do |id, values|
  fail_check("#{id} counts differ: #{observed.fetch(id).inspect}") unless observed.fetch(id) == values
  fail_check("#{id} exceeds 96 primitive operations") if observed.fetch(id).first > 96
end

fail_check("production image retains resolver instrumentation") if
  symbols.match?(/instrumentation|operationcounts/i)

puts "SPEC-004 static-path check passed: zero allocations, bounded success/negative paths, zero snapshot reinvocation, clean production symbols."
