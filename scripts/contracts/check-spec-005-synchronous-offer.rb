#!/usr/bin/env ruby
# frozen_string_literal: true

root = File.expand_path("../..", __dir__)
path = File.join(
  root,
  "Tests/GiftUIReferenceTextResourcesTests/SynchronousOfferTests.swift"
)
source = File.read(path)

def fail_check(message)
  warn "SPEC-005 synchronous offer check failed: #{message}"
  exit 1
end

%w[
  ContractLocalSynchronousOffer FontInstanceID GlyphID Point borrowing
  withPayload UnsafeRawBufferPointer EmptyOfferFixture
  payloadInvocationCount borrowIsActive
].each do |fragment|
  fail_check("offer fixture lacks #{fragment}") unless source.include?(fragment)
end
%w[Paint Clip RenderOperation ordering capacity].each do |fragment|
  fail_check("offer fixture introduces prohibited #{fragment}") if source.include?(fragment)
end
fail_check("offer fixture must cover four focused cases") unless
  source.scan(/^func (?:synchronousOffer|invalidAndUnavailable)/).length == 4

puts "SPEC-005 synchronous offer check passed: nominal IDs and point only, nested exact-once borrow, no production render policy."
