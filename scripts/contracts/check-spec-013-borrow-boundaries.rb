#!/usr/bin/env ruby
# frozen_string_literal: true

require "pathname"
require "yaml"

ROOT = Pathname.new(File.expand_path("../..", __dir__))
FIXTURE = ROOT.join("Tests/ContractFixtures/SPEC013/borrows.yaml")

def fail_check(message)
  warn "SPEC-013 borrow boundary check failed: #{message}"
  exit 1
end

expected_names = %w[
  canvas-callable-release
  path-typed-source-escape-rejected
  drawing-plan-discard
  operation-and-glyph-borrows
  resource-payload-poison
  action-and-model-borrows
  endpoint-payload-storage
  generated-observable-slot-coverage
  generated-canvas-callable-coverage
  static-forbidden-facilities
  dependency-direction
  typed-throws-negatives
]
cases = YAML.safe_load(FIXTURE.read, aliases: false).fetch("cases")
fail_check("canonical case set differs") unless cases.map { |item| item.fetch("name") } == expected_names

negative_rows = ROOT.join(
  "Tests/ContractFixtures/SPEC012/negative-compile-fixtures.tsv"
).each_line.reject { |line| line.start_with?("#") || line.strip.empty? }.map do |line|
  line.split("\t", 2).first
end
required_negatives = %w[
  path-copy path-consume path-escape path-async-escape
  missing-typed-throws unsupported-error
]
fail_check("typed-source negative set differs") unless (required_negatives - negative_rows).empty?

checks = {
  "Tests/GiftUIDrawingTests/CanvasPlanProducerTests.swift" => %w[
    canvasPlanProducerReleasesEachCallableOnceOnLaterThrowAndInvokesNoSuffix
    canvasPlanProducerDiscardsTheWholePlanOnTranslationOverflow
    refusalRecoveryUsesFreshCanvasRecordsAndRetainsOnlyPresentationIntent
  ],
  "Tests/GiftUIRenderLoweringTests/RenderViewBorrowTests.swift" => %w[
    renderViewBorrowRetainsNeitherAuthoritativeResult
  ],
  "Tests/GiftUIBackendIntegrationTests/RGB565TilePayloadEmitterTests.swift" => %w[
    oneShotProducerAndBorrowedOperationLeaveOnlyOwnedPayloadBytes
    tiledFillAndExactGlyphMatchFullSurfaceWithPainterOverwrite
  ],
  "Tests/GiftUIRuntimeCoreTests/RuntimeInteractionDispatcherTests.swift" => %w[
    dispatcherRevalidatesDecodesAndBorrowsCurrentModelExactlyOnce
    missingCommittedRecordCancelsWithoutConsultingTargetOrHandler
    targetDisappearingBeforeBorrowCancelsWithoutHandlerInvocation
  ],
  "Tests/GiftUIExecutionTests/RecordingFrameEndpointTests.swift" => %w[
    everyNonacceptedBodyResultReleasesAllCandidateData
  ],
  "Tests/GiftUIRuntimeStaticTests/StaticGeneratedMetadataTests.swift" => %w[
    generatedStaticMetadataBindsDenseSlotsActionsAndCanvasCoverage
    generatedStaticCanvasSwitchCoversEveryDeclaredID
    staticCanvasOccurrenceDestroysInlineCaptureAfterSuccessfulInvocation
    staticCanvasOccurrenceDestroysInlineCaptureAfterTypedThrow
    staticCanvasOccurrenceDiscardDestroysUninvokedCaptureExactlyOnce
  ],
}

checks.each do |relative, markers|
  path = ROOT.join(relative)
  fail_check("evidence source is missing: #{relative}") unless path.file?
  source = path.read
  markers.each do |marker|
    fail_check("#{relative} lacks #{marker}") unless source.include?(marker)
  end
end

%w[
  check-spec-012-declarations.sh
  check-spec-013-static-generated-fixture.rb
  check-spec-013-static-storage.rb
  check-spec-013-static-profiles.sh
  check-spec-013-module-contract.rb
].each do |name|
  path = ROOT.join("scripts/contracts", name)
  fail_check("required check is missing or not executable: #{name}") unless path.file? && path.executable?
end

puts "SPEC-013 borrow boundaries passed: twelve cases cover typed escapes, scoped payloads, generated tables, Static facilities, and dependency direction."
