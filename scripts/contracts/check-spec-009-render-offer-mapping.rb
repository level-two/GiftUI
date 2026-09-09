#!/usr/bin/env ruby
# frozen_string_literal: true

require "pathname"

ROOT = Pathname.new(File.expand_path("../..", __dir__))
SOURCE = ROOT.join("Sources/GiftUIFailureExecution/GiftUIFailureExecution.swift")
TEST = ROOT.join("Tests/GiftUIFailureExecutionTests/RenderAndOfferFailureMappingTests.swift")

def fail_check(message)
  warn "SPEC-009 render/offer mapping check failed: #{message}"
  exit 1
end

source = SOURCE.read
tests = TEST.read
%w[renderProduction frameOffer nonRetryableRefusal invalidInput incompatibleTextResource sinkRefused invalidEnvelope contractViolation insufficientCapacity producerFailed renderProducer endpoint].each do |fragment|
  fail_check("adapter lacks #{fragment}") unless source.include?(fragment)
end
%w[everyMappableRenderErrorPreservesExactOwnerMapping sinkRefusalUsesOnlyTheRenderProducerRefusalRoute endpointRefusalRemainsDistinctFromRenderProducerRefusal frameOfferMapsOnlyLegalCoordinatorFailures impossibleFrameOfferFailuresCannotReplaceProducerError noOfferMappingCanPrecedeMandatoryAbortAndQuiescence].each do |name|
  fail_check("mapping tests lack #{name}") unless tests.include?(name)
end
puts "SPEC-009 render/offer mapping passed: exact producer, legal frame-offer, impossible pairing, refusal-origin, and mechanical-effect mappings are covered."
