#!/usr/bin/env ruby
# frozen_string_literal: true

require "pathname"

ROOT = Pathname.new(File.expand_path("../..", __dir__))
SOURCE = ROOT.join("Sources/GiftUIObservableState/ObservableStateTargetLookupSlot.swift")
TEST = ROOT.join("Tests/GiftUIObservableStateTests/ObservableStateTargetLookupSlotTests.swift")

def fail_check(message)
  warn "SPEC-010 target lookup check failed: #{message}"
  exit 1
end

source = SOURCE.read
tests = TEST.read

fail_check("target lookup imports differ") unless source.scan(/^import (\S+)/).flatten == ["GiftUIExecution"]
fail_check("target lookup must remain internal") if source.match?(
  /\b(?:package|public|open) struct ObservableStateTargetLookupSlot/
)

%w[
  ObservableStateTargetView
  case inactive
  case open
  case preserved
  case candidateOnly
  recordSuccessfulEncounter
  candidateOnlyGeneration
  targetGeneration
  publishableTargetGeneration
  finishCandidate
].each do |fragment|
  fail_check("target lookup lacks #{fragment}") unless source.include?(fragment)
end
fail_check("live lookup must borrow") unless source.include?(
  "borrowing func targetGeneration"
)
fail_check("publishable lookup must borrow") unless source.include?(
  "borrowing func publishableTargetGeneration"
)

%w[
  liveLookupRequiresTheCompleteExactKeyAndNeverMaterializes
  preservedTargetIsPublishableOnlyAfterSuccessfulEncounter
  candidateOnlyTargetBecomesLiveOnlyOnPublication
  discardedCandidateNeverBecomesLiveAndWorkspaceIsReusable
].each do |name|
  fail_check("target lookup fixture lacks #{name}") unless tests.include?(name)
end

forbidden = /\b(?:Model|Attachment|Sink|Handler|Callable|Array|ContiguousArray|Dictionary|Set|Any|any|Mirror|Task|actor|async|await|throw|fatalError|GiftUIFailureCore|GiftUIRuntime|GiftUIBackend|GiftUIPlatform)\b/
fail_check("target lookup retains a model or selects prohibited storage") if source.match?(forbidden)

puts "SPEC-010 target lookup passed: exact borrowed live/publishable timing, preservation, publication, and discard are covered."
