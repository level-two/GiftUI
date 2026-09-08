#!/usr/bin/env ruby
# frozen_string_literal: true

require "pathname"

ROOT = Pathname.new(File.expand_path("../..", __dir__))
SOURCE = ROOT.join("Sources/GiftUIObservableState/ObservableStateAttachmentGenerationAllocator.swift")
TEST = ROOT.join("Tests/GiftUIObservableStateTests/ObservableStateAttachmentGenerationAllocatorTests.swift")

def fail_check(message)
  warn "SPEC-010 attachment generation check failed: #{message}"
  exit 1
end

source = SOURCE.read
tests = TEST.read

imports = source.scan(/^import (\S+)/).flatten
fail_check("allocator imports differ") unless imports == %w[GiftUI GiftUIExecution]
fail_check("allocator must remain internal") if source.match?(
  /\b(?:package|public|open) (?:struct|enum) ObservableStateAttachment/
)

%w[
  ObservableStateAttachmentReservation
  ObservableStateAttachmentReservationResult
  ObservableStateAttachmentGenerationAllocator
  nextGeneration
  addingReportingOverflow
  registrationGenerationExhausted
  _GiftUIObservationAttachment
  ObservableTargetGeneration
].each do |fragment|
  fail_check("allocator lacks #{fragment}") unless source.include?(fragment)
end

%w[
  attachmentGenerationsBeginAtZeroAndAdvanceRuntimeWide
  recycledSlotIsProtectedByTheCompleteFreshAttachment
  generationMaximumIsIssuedOnceThenExhaustionIsPermanent
  initialAndReplacementExhaustionFailClosed
  allocatorAndReservationAreFiniteSendableValues
].each do |name|
  fail_check("allocator fixture lacks #{name}") unless tests.include?(name)
end

forbidden = /\b(?:Array|ContiguousArray|Dictionary|Set|Any|any|Mirror|Task|actor|async|await|throw|fatalError|GiftUIFailureCore|GiftUIRuntime|GiftUIBackend|GiftUIPlatform)\b/
fail_check("allocator selects storage or a prohibited owner") if source.match?(forbidden)

puts "SPEC-010 attachment generations passed: zero-first allocation, slot-safe freshness, permanent exhaustion, and fail-closed reuse are covered."
