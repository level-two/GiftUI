import GiftUI
import GiftUIRenderCore
import Testing

@testable import GiftUIExecution

private let endpointRect = Rect(
    origin: Point(x: 0, y: 0),
    size: Size(width: 10, height: 10)!
)!

private let endpointHeader = RenderPlanHeader(
    surfaceBounds: endpointRect,
    damageBounds: endpointRect,
    operationCount: 1,
    positionedGlyphCount: 0,
    maximumObservedClipDepth: 1
)

private let emptyEndpointHeader = RenderPlanHeader(
    surfaceBounds: endpointRect,
    damageBounds: endpointRect,
    operationCount: 0,
    positionedGlyphCount: 0,
    maximumObservedClipDepth: 1
)

private let endpointFill = FillRectOperation(
    bounds: endpointRect,
    clip: endpointRect,
    color: .red
)

private let endpointProvenance = FrameProvenance(
    cycle: RunCycleID(rawValue: 4),
    semanticRevision: SemanticRevision(rawValue: 5),
    candidateFrame: CandidateFrameID(rawValue: 6)
)

@Test
func endpointReservesBeforeConsumptionAndRetainsOnlyAcceptedDerivedFrame() {
    var endpoint = makeEndpoint(maximumDownstreamSlots: 1)
    let result = endpoint.offer(provenance: endpointProvenance) { sink in
        #expect(sink.reservationWasMade)
        let began = sink.begin(endpointHeader)
        let filled = sink.fillRect(endpointFill)
        let finished = sink.finish()
        #expect(began)
        #expect(filled)
        #expect(finished)
        return .complete
    }

    #expect(result == FrameOfferResult(disposition: .accepted, failure: nil))
    #expect(endpoint.bodyCallCount == 1)
    #expect(endpoint.occupiedDownstreamSlots == 1)
    #expect(!endpoint.reservationOutstanding)
    #expect(
        endpoint.acceptedFrame
            == RecordingAcceptedFrame(
                provenance: endpointProvenance,
                operationCount: 1,
                positionedGlyphCount: 0
            )
    )
    let acceptedBorrowStillWorks = endpoint.probeSinkAfterReturn(emptyEndpointHeader)
    #expect(!acceptedBorrowStillWorks)

    var secondBodyCalled = false
    let second = endpoint.offer(provenance: endpointProvenance) { _ in
        secondBodyCalled = true
        return .complete
    }
    #expect(second == FrameOfferResult(disposition: .backpressured, failure: nil))
    #expect(!secondBodyCalled)
    #expect(endpoint.bodyCallCount == 1)
}

@Test
func invalidEnvelopeAndFullCapacityNeverCallBody() {
    var invalid = makeEndpoint(maximumDownstreamSlots: 1)
    invalid.acceptsEnvelope = false
    var invalidBodyCalled = false
    #expect(
        invalid.offer(provenance: endpointProvenance) { _ in
            invalidBodyCalled = true
            return .complete
        } == FrameOfferResult(disposition: .failed, failure: .invalidEnvelope)
    )
    #expect(!invalidBodyCalled)
    #expect(invalid.bodyCallCount == 0)
    #expect(invalid.acceptedFrame == nil)
}

@Test
func operationVocabularyViolationCannotBecomeAccepted() {
    var endpoint = makeEndpoint(maximumDownstreamSlots: 1)
    let result = endpoint.offer(provenance: endpointProvenance) { sink in
        let began = sink.begin(emptyEndpointHeader)
        let filled = sink.fillRect(endpointFill)
        let finished = sink.finish()
        #expect(began)
        #expect(!filled)
        #expect(finished)
        return .complete
    }

    #expect(
        result
            == FrameOfferResult(
                disposition: .failed,
                failure: .contractViolation
            )
    )
    #expect(endpoint.acceptedFrame == nil)
    #expect(endpoint.occupiedDownstreamSlots == 0)
    #expect(!endpoint.reservationOutstanding)
}

@Test
func exactProducerErrorIsRetainedAcrossFailedOffer() {
    var endpoint = makeEndpoint(maximumDownstreamSlots: 1)
    let result = endpoint.offer(provenance: endpointProvenance) { sink in
        sink.recordProducerError(.incompatibleTextResource)
        return .producerFailed
    }

    #expect(
        result
            == FrameOfferResult(
                disposition: .failed,
                failure: .producerFailed
            )
    )
    #expect(endpoint.retainedProducerError == .incompatibleTextResource)
    #expect(endpoint.acceptedFrame == nil)
    #expect(endpoint.occupiedDownstreamSlots == 0)
    #expect(!endpoint.reservationOutstanding)
    let failedBorrowStillWorks = endpoint.probeSinkAfterReturn(emptyEndpointHeader)
    #expect(!failedBorrowStillWorks)
}

@Test
func everyNonacceptedBodyResultReleasesAllCandidateData() {
    let rows: [(FrameStreamResult, RenderProductionError?, FrameOfferResult)] = [
        (
            .producerFailed,
            .invalidInput,
            FrameOfferResult(disposition: .failed, failure: .producerFailed)!
        ),
        (
            .insufficientCapacity,
            .capacityExhausted,
            FrameOfferResult(disposition: .failed, failure: .insufficientCapacity)!
        ),
        (
            .endpointRefused,
            .sinkRefused,
            FrameOfferResult(disposition: .nonRetryableRefusal, failure: nil)!
        ),
        (
            .contractViolation,
            .invariantViolation,
            FrameOfferResult(disposition: .failed, failure: .contractViolation)!
        ),
    ]

    for (streamResult, producerError, expected) in rows {
        var endpoint = makeEndpoint(maximumDownstreamSlots: 1)
        let result = endpoint.offer(provenance: endpointProvenance) { sink in
            if let producerError { sink.recordProducerError(producerError) }
            return streamResult
        }
        #expect(result == expected)
        #expect(endpoint.acceptedFrame == nil)
        #expect(endpoint.occupiedDownstreamSlots == 0)
        #expect(!endpoint.reservationOutstanding)
        #expect(!endpoint.sink.reservationWasMade)
        let borrowStillWorks = endpoint.probeSinkAfterReturn(emptyEndpointHeader)
        #expect(!borrowStillWorks)
    }
}

private func makeEndpoint(
    maximumDownstreamSlots: UInt16
) -> RecordingSynchronousFrameEndpoint {
    RecordingSynchronousFrameEndpoint(
        maximumDownstreamSlots: maximumDownstreamSlots,
        sinkCapacity: RenderSinkCapacity(
            maximumOperations: 2,
            maximumPositionedGlyphs: 2
        )
    )!
}
