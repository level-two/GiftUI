#!/usr/bin/env ruby
# frozen_string_literal: true

require "pathname"

ROOT = Pathname.new(File.expand_path("../..", __dir__))
SOURCE = ROOT.join("Sources/GiftUIExecution/RecordingFrameEndpoint.swift")
TEST = ROOT.join("Tests/GiftUIExecutionTests/RecordingFrameEndpointTests.swift")

def fail_check(message)
  warn "SPEC-009 recording endpoint check failed: #{message}"
  exit 1
end

source = SOURCE.read
tests = TEST.read

fail_check("recording endpoint imports differ") unless source.scan(/^import (\S+)/).flatten == ["GiftUIRenderCore"]
fail_check("recording endpoint must remain internal") if source.match?(
  /\b(?:package|public|open) (?:struct|enum|protocol) Recording(?:AcceptedFrame|FrameSink|SynchronousFrameEndpoint)/
)

%w[
  SynchronousFrameEndpoint
  RenderOperationSink
  maximumDownstreamSlots
  occupiedDownstreamSlots
  bodyCallCount
  reservationOutstanding
  reservationWasMade
  retainedProducerError
  acceptedFrame
  vocabularyViolated
  beginOfferBorrow
  poisonAfterReturn
  recordProducerError
  invalidEnvelope
  backpressured
].each do |fragment|
  fail_check("recording endpoint lacks #{fragment}") unless source.include?(fragment)
end

reservation_index = source.index("reservationOutstanding = true")
body_index = source.index("let streamResult = body(&sink)")
poison_index = source.index("sink.poisonAfterReturn()")
release_index = source.index("reservationOutstanding = false", poison_index || 0)
unless reservation_index && body_index && poison_index && release_index &&
    reservation_index < body_index && body_index < poison_index && poison_index < release_index
  fail_check("reservation, body, poisoning, or release order differs")
end

%w[
  endpointReservesBeforeConsumptionAndRetainsOnlyAcceptedDerivedFrame
  invalidEnvelopeAndFullCapacityNeverCallBody
  operationVocabularyViolationCannotBecomeAccepted
  exactProducerErrorIsRetainedAcrossFailedOffer
  everyNonacceptedBodyResultReleasesAllCandidateData
].each do |name|
  fail_check("recording endpoint fixture lacks #{name}") unless tests.include?(name)
end

forbidden = /\b(?:String|Array|ContiguousArray|Dictionary|Set|Any|any|Mirror|Task|actor|async|await|throw|fatalError|GiftUISemanticCore|GiftUILayout|GiftUIObservableState|GiftUIInteraction|GiftUIRuntime|GiftUIBackend|GiftUIPlatform)\b/
fail_check("recording endpoint selects dynamic storage or a prohibited owner") if source.match?(forbidden)

puts "SPEC-009 recording endpoint passed: pre-consumption reservation, bounded vocabulary, exact producer error retention, borrow poisoning, and candidate cleanup are covered."
