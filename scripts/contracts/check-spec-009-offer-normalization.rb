#!/usr/bin/env ruby
# frozen_string_literal: true

require "pathname"

ROOT = Pathname.new(File.expand_path("../..", __dir__))
SOURCE = ROOT.join("Sources/GiftUIExecution/FrameOfferNormalization.swift")
TEST = ROOT.join("Tests/GiftUIExecutionTests/FrameOfferNormalizationTests.swift")

def fail_check(message)
  warn "SPEC-009 offer normalization check failed: #{message}"
  exit 1
end

source = SOURCE.read
tests = TEST.read

fail_check("offer normalization imports differ") unless source.scan(/^import (\S+)/).flatten == ["GiftUIRenderCore"]
fail_check("offer normalization must remain internal") if source.match?(
  /\b(?:package|public|open) (?:struct|enum|protocol) Recording(?:FrameBodyObservation|NormalizedOffer|RenderProductionAdapter|FrameOfferNormalizer)/
)

%w[
  wasCalled
  streamResult
  retainedError
  notCalled
  capacityExhausted
  sinkRefused
  invariantViolation
  producerFailed
  insufficientCapacity
  endpointRefused
  contractViolation
  renderProduction
  nonRetryableRefusal
  renderProducer
  endpoint
  backpressured
  retryableRefusal
].each do |fragment|
  fail_check("offer normalization lacks #{fragment}") unless source.include?(fragment)
end

%w[
  productionAdapterPreservesEveryExactRenderError
  noBodyRowsNormalizeExactEndpointOutcomesAndOrigins
  everyBodyObservationAndEndpointPairingNormalizesExhaustively
  observationRejectsCalledAndPayloadContradictions
].each do |name|
  fail_check("offer normalization fixture lacks #{name}") unless tests.include?(name)
end

forbidden = /\b(?:String|Array|ContiguousArray|Dictionary|Set|Any|any|Mirror|Task|actor|async|await|throw|fatalError|GiftUISemanticCore|GiftUILayout|GiftUIObservableState|GiftUIInteraction|GiftUIRuntime|GiftUIBackend|GiftUIPlatform|GiftUIFailureCore)\b/
fail_check("offer normalization selects dynamic storage or a prohibited owner") if source.match?(forbidden)

puts "SPEC-009 offer normalization passed: exact render errors, all endpoint/body pairings, illegal-pair collapse, and distinct refusal origins are covered."
