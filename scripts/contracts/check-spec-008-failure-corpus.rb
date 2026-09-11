#!/usr/bin/env ruby
# frozen_string_literal: true

require "pathname"

ROOT = Pathname.new(File.expand_path("../..", __dir__))
TESTS = ROOT.join("Tests/GiftUIRenderLoweringTests/RenderPreflightTests.swift").read
DIRECT = ROOT.join("Tests/GiftUIRenderLoweringTests/DirectRenderViewFixtureTests.swift").read
MAPPING = ROOT.join("Tests/GiftUIRenderFailureAdapterTests/RenderFailureAdapterTests.swift").read
PREFLIGHT = ROOT.join("Sources/GiftUIRenderLowering/RenderPreflight.swift").read
STREAMING = ROOT.join("Sources/GiftUIRenderLowering/RenderStreaming.swift").read

def fail_check(message)
  warn "SPEC-008 failure corpus check failed: #{message}"
  exit 1
end

required_tests = %w[
  preflightValidatesTheCompleteViewsAndBuildsTheExactHeaderWithoutEmission
  preflightChecksDeclaredStructuralAndSinkCapacityAtExactBoundaries
  preflightRejectsRootOrdinalSnapshotAndResourceDisagreementExactly
  everyDirectSemanticAndLayoutMismatchFailsBeforeBegin
  everyIndependentRenderAndStructuralCapacityFailsOneOverBeforeBegin
  streamingDistinguishesBeginRefusalFromPostBeginInvariantFailure
  streamingDiscardsWhenSnapshotChangesAfterTheLastOperation
  producerAcquiresRunsBothPassesAndResetsExactlyOnceOnEveryAcquiredExit
  producerRejectsReentryBeforeInputOrSinkAccessAndPreservesActiveAttempt
  producerMapsInactiveAcquireRefusalToInvariantWithoutResetOrInputAccess
  constructibleFailurePrecedenceFollowsTheExactClosedOrder
  everyPostBeginSinkAndForegroundRefusalDiscardsOnceAndResets
]
required_tests.each do |name|
  fail_check("missing focused test #{name}") unless TESTS.include?("func #{name}()")
end

fail_check("semantic/layout malformed constructors are incomplete") unless
  DIRECT.include?("directViewsRepresentEveryRequiredStructuralMalformedInput") &&
    DIRECT.include?("directLayoutsRepresentEveryRequiredLookupAndIndexDisagreement")
fail_check("all seven local mappings are not tested") unless
  MAPPING.include?("everyRenderProductionErrorMapsToItsExactOwnerFact")

%w[
  maximumSemanticScopes: 4
  maximumLayoutScopes: 1
  maximumTraversalDepth: 4
  maximumTextLines: 1
  maximumOperations: 1
  maximumPositionedGlyphs: 1
  maximumClipDepth: 1
].each do |fragment|
  fail_check("missing one-over boundary #{fragment}") unless TESTS.include?(fragment)
end

fail_check("mismatch matrix does not preserve pre-begin atomicity") unless
  TESTS.scan("#expect(sink.operationCallCount == 0)").length >= 4 &&
    TESTS.scan("#expect(sink.discardCount == 0)").length >= 4
fail_check("preflight visit accounting is absent") unless
  TESTS.include?("workspace.semanticVisitCalls == 5") &&
    TESTS.include?("workspace.layoutVisitCalls == 5") &&
    TESTS.include?("workspace.firstLayoutVisits == 2")
fail_check("preflight touches visit sets during streaming") if
  STREAMING.include?("visitSemanticScope") || STREAMING.include?("visitLayoutScope")
fail_check("checked arithmetic audit differs") unless
  PREFLIGHT.scan(/LayoutGeometry\.intersection\(/).length == 3 &&
    PREFLIGHT.scan(/return (?:\.failure\()?\.arithmeticOverflow\)?/).length == 3
fail_check("snapshot checks are not on both sides of streaming") unless
  STREAMING.scan("snapshotsMatch(").length == 2
fail_check("post-begin discard coverage differs") unless STREAMING.scan("sink.discard()").length >= 4

puts "SPEC-008 failure corpus passed: mismatches, seven independent capacities, failures, snapshots, lifecycle, and mappings"
