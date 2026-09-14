#!/usr/bin/env ruby
# frozen_string_literal: true

require "pathname"

ROOT = Pathname.new(File.expand_path("../..", __dir__))
INSTRUMENTATION = ROOT.join("Tests/ContractFixtures/SPEC013/Instrumentation")
PROBE = INSTRUMENTATION.join("RuntimeProfileResourceProbe.swift")
TIMING_PROBE = INSTRUMENTATION.join("RuntimeProfileTimingProbe.swift")
VALUE_LAYOUT_PROBE = INSTRUMENTATION.join("RuntimeProfileValueLayoutProbe.swift")
INTERPOSER = INSTRUMENTATION.join("AllocationInterposer.c")
INTERPOSER_PROBE = INSTRUMENTATION.join("AllocationInterposerProbe.c")
METHODS = INSTRUMENTATION.join("resource-measurement-methods.tsv")

EXPECTED_MEASUREMENTS = %w[
  allocation-count peak-heap-bytes dynamic-allocator-bookkeeping stack-by-stage
  value-layout linked-symbols borrow-lifetime linked-sections generated-canvas-code
  greatest-inline-capture excluded-subsystems cycle-time
].freeze
EXPECTED_FIELDS = %w[
  stackConstruction stackAdmission stackDerivation stackCanvasInvocation stackRendering
  stackOffer stackFinalization heapAllocations peakHeapBytes dynamicAllocatorBookkeeping
  excludedTextResourceBytes excludedCapabilityBytes excludedBackendBytes excludedHostBytes
  generatedCanvasCodeBytes greatestInlineCaptureBytes linkedTextBytes linkedReadOnlyDataBytes
  linkedWritableDataBytes linkedBSSBytes linkedTotalImageBytes smallFixtureCycleTimeNanoseconds
  signalAnalyzerCycleTimeNanoseconds countersSaturated
].freeze

def fail_check(message)
  warn "SPEC-013 resource instrumentation check failed: #{message}"
  exit 1
end

rows = METHODS.each_line.each_with_object([]) do |line, result|
  next if line.start_with?("#") || line.strip.empty?

  fields = line.chomp.split("\t", -1)
  fail_check("measurement method row width differs") unless fields.length == 3
  result << fields
end
fail_check("measurement method set differs") unless rows.map(&:first) == EXPECTED_MEASUREMENTS
fail_check("measurement methods must name an execution scope") if rows.any? { |row| row[2].empty? }

probe = PROBE.read
EXPECTED_FIELDS.each do |field|
  fail_check("resource probe omits #{field}") unless probe.include?("var #{field}")
end
fail_check("resource probe contains dynamic storage") if probe.match?(/\b(Array|Dictionary|Set|String|Any)\b/)
fail_check("resource probe omits all seven stack stages") unless probe.scan(/^    case \w+$/).length == 7

timing_probe = TIMING_PROBE.read
fail_check("timing probe must use ContinuousClock") unless timing_probe.include?("ContinuousClock()")
fail_check("timing probe must report nanoseconds") unless timing_probe.include?("measureNanoseconds")
fail_check("timing probe must check integer overflow") unless timing_probe.include?("multipliedReportingOverflow") &&
  timing_probe.include?("addingReportingOverflow")

value_layout_probe = VALUE_LAYOUT_PROBE.read
%w[RuntimeProfileLimits RuntimeStorageCapacities RuntimeStorageByteCounts RuntimeStorageAudit RuntimeOwnerFailure].each do |type|
  fail_check("value-layout probe omits #{type}") unless value_layout_probe.include?("size(of: #{type}.self)")
end

interposer = INTERPOSER.read
%w[malloc calloc realloc free].each do |symbol|
  fail_check("allocation interposer omits #{symbol}") unless interposer.include?(
    "DYLD_INTERPOSE(giftui_counting_#{symbol}, #{symbol})"
  )
end
%w[count peak_bytes bookkeeping_bytes saturated].each do |metric|
  fail_check("allocation execution probe omits #{metric}") unless INTERPOSER_PROBE.read.include?(
    "giftui_allocation_probe_#{metric}()"
  )
end
%w[count peak_bytes bookkeeping_bytes saturated].each do |metric|
  fail_check("allocation interposer omits #{metric}") unless interposer.include?(
    "giftui_allocation_probe_#{metric}"
  )
end

puts "SPEC-013 resource instrumentation passed: 24 bounded fields and 12 explicit measurement methods."
