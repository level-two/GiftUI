import Testing

@testable import GiftUIExecution
@testable import GiftUIRenderCore

private struct ProbeSink: RenderOperationSink {
    var capacity = RenderSinkCapacity(maximumOperations: 1, maximumPositionedGlyphs: 1)

    mutating func idleCapacity() -> RenderSinkCapacity { capacity }
    mutating func begin(_ header: RenderPlanHeader) -> Bool { true }
    mutating func fillRect(_ operation: FillRectOperation) -> Bool { true }
    mutating func beginPositionedGlyphs(_ header: PositionedGlyphOperationHeader) -> Bool { true }
    mutating func positionedGlyph(_ glyph: PositionedGlyph) -> Bool { true }
    mutating func endPositionedGlyphs() -> Bool { true }
    mutating func finish() -> Bool { true }
    mutating func discard() {}
}

private struct MappingEndpoint: SynchronousFrameEndpoint {
    var sink = ProbeSink()
    var acceptsEnvelope = true
    var bodyCallCount: UInt8 = 0

    mutating func offer(
        provenance: FrameProvenance,
        body: (inout ProbeSink) -> FrameStreamResult
    ) -> FrameOfferResult {
        guard acceptsEnvelope else {
            return FrameOfferResult(disposition: .backpressured, failure: nil)!
        }
        bodyCallCount &+= 1
        switch body(&sink) {
        case .complete:
            return FrameOfferResult(disposition: .accepted, failure: nil)!
        case .producerFailed:
            return FrameOfferResult(disposition: .failed, failure: .producerFailed)!
        case .insufficientCapacity:
            return FrameOfferResult(disposition: .failed, failure: .insufficientCapacity)!
        case .endpointRefused:
            return FrameOfferResult(disposition: .nonRetryableRefusal, failure: nil)!
        case .contractViolation:
            return FrameOfferResult(disposition: .failed, failure: .contractViolation)!
        }
    }
}

private let provenance = FrameProvenance(
    cycle: RunCycleID(rawValue: 1),
    semanticRevision: SemanticRevision(rawValue: 2),
    candidateFrame: CandidateFrameID(rawValue: 3)
)

@Test
func frameHandoffValuesPreserveExactRawCasesAndLayouts() {
    #expect(FrameOfferDisposition.accepted.rawValue == 0)
    #expect(FrameOfferDisposition.backpressured.rawValue == 1)
    #expect(FrameOfferDisposition.retryableRefusal.rawValue == 2)
    #expect(FrameOfferDisposition.nonRetryableRefusal.rawValue == 3)
    #expect(FrameOfferDisposition.failed.rawValue == 4)
    #expect(LogicalFrameDisposition.notProduced.rawValue == 0)
    #expect(LogicalFrameDisposition.committed.rawValue == 1)
    #expect(LogicalFrameDisposition.aborted.rawValue == 2)
    #expect(FrameStreamResult.complete.rawValue == 0)
    #expect(FrameStreamResult.producerFailed.rawValue == 1)
    #expect(FrameStreamResult.insufficientCapacity.rawValue == 2)
    #expect(FrameStreamResult.endpointRefused.rawValue == 3)
    #expect(FrameStreamResult.contractViolation.rawValue == 4)
    #expect(FrameOfferFailure.invalidEnvelope.rawValue == 0)
    #expect(FrameOfferFailure.insufficientCapacity.rawValue == 1)
    #expect(FrameOfferFailure.producerFailed.rawValue == 2)
    #expect(FrameOfferFailure.contractViolation.rawValue == 3)
    #expect(FrameRefusalOrigin.renderProducer.rawValue == 0)
    #expect(FrameRefusalOrigin.endpoint.rawValue == 1)
    #expect(MemoryLayout<FrameProvenance>.size == 12)
    #expect(MemoryLayout<FrameOfferResult>.size <= 2)
}

@Test
func frameOfferResultRequiresFailureExactlyForFailedDisposition() {
    for disposition in [
        FrameOfferDisposition.accepted,
        .backpressured,
        .retryableRefusal,
        .nonRetryableRefusal,
    ] {
        #expect(FrameOfferResult(disposition: disposition, failure: nil) != nil)
        #expect(FrameOfferResult(disposition: disposition, failure: .contractViolation) == nil)
    }
    #expect(FrameOfferResult(disposition: .failed, failure: nil) == nil)
    for failure in [
        FrameOfferFailure.invalidEnvelope,
        .insufficientCapacity,
        .producerFailed,
        .contractViolation,
    ] {
        #expect(FrameOfferResult(disposition: .failed, failure: failure) != nil)
    }
}

@Test(arguments: [
    (FrameStreamResult.complete, FrameOfferDisposition.accepted, nil),
    (FrameStreamResult.producerFailed, .failed, FrameOfferFailure.producerFailed),
    (FrameStreamResult.insufficientCapacity, .failed, .insufficientCapacity),
    (FrameStreamResult.endpointRefused, .nonRetryableRefusal, nil),
    (FrameStreamResult.contractViolation, .failed, .contractViolation),
])
func synchronousEndpointCallsBodyOnceAndMapsItsResult(
    streamResult: FrameStreamResult,
    disposition: FrameOfferDisposition,
    failure: FrameOfferFailure?
) {
    var endpoint = MappingEndpoint()
    var closureCalls: UInt8 = 0

    let result = endpoint.offer(provenance: provenance) { _ in
        closureCalls &+= 1
        return streamResult
    }

    #expect(closureCalls == 1)
    #expect(endpoint.bodyCallCount == 1)
    #expect(result.disposition == disposition)
    #expect(result.failure == failure)
}

@Test
func synchronousEndpointBackpressureDoesNotCallBody() {
    var endpoint = MappingEndpoint(acceptsEnvelope: false)
    var closureCalls: UInt8 = 0

    let result = endpoint.offer(provenance: provenance) { _ in
        closureCalls &+= 1
        return .complete
    }

    #expect(closureCalls == 0)
    #expect(endpoint.bodyCallCount == 0)
    #expect(result.disposition == .backpressured)
    #expect(result.failure == nil)
}
