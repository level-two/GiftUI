#!/usr/bin/env ruby
# frozen_string_literal: true

require "pathname"

ROOT = Pathname.new(File.expand_path("../..", __dir__))
SOURCE = ROOT.join("Sources/GiftUIExecution/PointerActionCapture.swift")
TEST = ROOT.join("Tests/GiftUIExecutionTests/PointerActionCaptureTests.swift")

def fail_check(message)
  warn "SPEC-009 pointer capture check failed: #{message}"
  exit 1
end

source = SOURCE.read
tests = TEST.read
fail_check("pointer capture imports differ") unless source.scan(/^import (\w+)$/).flatten == %w[GiftUI]

required = [
  "private(set) var captured: CapturedAction<Identity>?",
  "captured = nil",
  "actionView.hit(at: point)",
  "actionView.generation(for: identity)",
  "actionView.isEnabled(identity) == true",
  "provenanceValid, generationUnambiguous",
  "actionView.hit(at: point) == captured.identity",
  "== captured.generation",
  "defer { captured = nil }",
]
required.each do |fragment|
  fail_check("pointer capture lacks #{fragment}") unless source.include?(fragment)
end

%w[
  downCapturesOnlyExactCurrentEnabledRecord
  movementCancellationClearsCaptureWithoutCandidate
  releaseFormsCandidateOnlyAfterCompleteRevalidation
  unrelatedCommitPreservesStableIdentityGenerationCapture
  everyReleaseInvalidationCancelsWithoutRetargeting
  aNewDownClearsOlderCaptureBeforeHitResolution
].each do |name|
  fail_check("pointer fixture lacks #{name}") unless tests.include?(name)
end

forbidden = /\b(?:Any|any|String|Array|Dictionary|Task|actor|async|await|throw|actionValue|targetGeneration|callable|handler|model|revision|GiftUISemanticCore|GiftUILayout|GiftUIObservableState|Backend|Platform)\b/
fail_check("pointer capture retains payload or prohibited authority") if source.match?(forbidden)

puts "SPEC-009 pointer capture passed: exact down capture, movement cancellation, release revalidation, and no retargeting are covered."
