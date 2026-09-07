#!/usr/bin/env ruby
# frozen_string_literal: true

VALUES = {
  "RunCycleID" => ["runCycleID", :exact, 4],
  "SemanticRevision" => ["semanticRevision", :exact, 4],
  "CandidateFrameID" => ["candidateFrameID", :exact, 4],
  "ActionGeneration" => ["actionGeneration", :exact, 4],
  "ObservableTargetGeneration" => ["observableTargetGeneration", :exact, 4],
  "ExecutionPhase" => ["executionPhase", :exact, 1],
  "ExecutionLimits" => ["executionLimits", :exact, 12],
  "ExecutionContext" => ["executionContext", :maximum, 24],
  "ExecutionWakeReasons" => ["wakeReasons", :exact, 1],
  "PresentationPendingIntent" => ["pendingIntent", :maximum, 8],
  "FrameProvenance" => ["frameProvenance", :exact, 12],
  "FrameOfferDisposition" => ["frameOfferDisposition", :exact, 1],
  "LogicalFrameDisposition" => ["logicalFrameDisposition", :exact, 1],
  "FrameStreamResult" => ["frameStreamResult", :exact, 1],
  "FrameOfferResult" => ["frameOfferResult", :maximum, 2],
  "FrameOfferFailure" => ["frameOfferFailure", :exact, 1],
  "FrameRefusalOrigin" => ["frameRefusalOrigin", :exact, 1],
  "AdmissionKind" => ["admissionKind", :exact, 1],
  "ExecutionAdmissionResult" => ["admissionResult", :exact, 1],
  "ExecutionAdmissionOutcome" => ["admissionOutcome", :maximum, 28],
  "AdmissionSummary" => ["admissionSummary", :maximum, 12],
  "CapturedAction<UInt32>" => ["capturedAction", :exact, 8],
  "ExecutionError" => ["executionError", :exact, 1],
  "SemanticCycleDisposition" => ["semanticDisposition", :exact, 1],
  "ExecutionOperational" => ["executionOperational", :exact, 1],
  "ExecutionOperationalEvents" => ["operationalEvents", :exact, 1],
  "PresentationIntentState" => ["presentationIntentState", :exact, 1],
  "ExecutionFixtureOwnerFailure" => ["ownerFailure", :maximum, 4],
  "RunCycleFailure<ExecutionFixtureOwnerFailure>" => ["runCycleFailure", :maximum, 8],
  "RunCycleSummary" => ["runCycleSummary", :maximum, 40],
  "RunCycleResult<ExecutionFixtureOwnerFailure>" => ["runCycleResult", :maximum, 72],
}.freeze

def fail_check(message)
  warn "SPEC-009 value layout check failed: #{message}"
  exit 1
end

fail_check("expected LLVM IR and output paths") unless ARGV.length == 2
ir = File.read(ARGV[0])
rows = VALUES.map do |name, (prefix, kind, bound)|
  body = ir[/define [^{]+#{prefix}Size[^\{]*\{(.*?)^\}/m, 1]
  fail_check("missing IR function #{prefix}Size") unless body
  value = body[/ret i32 ([0-9]+)/, 1]
  fail_check("#{prefix}Size is not a constant i32 return") unless value
  size = Integer(value, 10)
  if kind == :exact
    fail_check("#{name} size #{size} differs from #{bound}") unless size == bound
  else
    fail_check("#{name} size #{size} exceeds #{bound}") if size > bound
  end
  [name, size, kind, bound]
end

File.open(ARGV[1], "w") do |output|
  output.puts("value\tsize\trequirement\tbound")
  rows.each { |row| output.puts(row.join("\t")) }
end

puts "SPEC-009 value layouts passed: #{rows.length} complete execution values."
