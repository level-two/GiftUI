import GiftUI
import GiftUICapabilities
import GiftUIDisplayCore
import GiftUIExecution
import GiftUIFailureCore
import GiftUIRasterCore
import GiftUIRenderCore
import GiftUISurfaceCore
import GiftUITextResources
import Testing

@testable import GiftUIBackendIntegration

private struct ExactEnvelopeValidator: RasterFrameEnvelopeValidator {
    let expected: FrameProvenance

    borrowing func accepts(_ provenance: FrameProvenance) -> Bool {
        provenance == expected
    }
}

private struct OfferMetrics: CanonicalTextMetricsView {
    var descriptor: TextResourceDescriptor { fatalError("compile-only") }
    func instance(at index: UInt16) -> FontInstanceDescriptor? { nil }
    func mapping(
        at index: UInt16,
        in instance: FontInstanceID
    ) -> ScalarGlyphMappingRecord? { nil }
    func mapScalar(
        _ scalarValue: UInt32,
        in instance: FontInstanceID
    ) -> GlyphMapping? { nil }
    func metrics(
        for glyph: GlyphID,
        in instance: FontInstanceID
    ) -> GlyphMetrics? { nil }
}

private struct OfferRaster: TextRasterResourceView {
    var descriptor: TextResourceDescriptor { fatalError("compile-only") }
    func realization(at index: UInt16) -> RasterRealizationDescriptor? { nil }
    func record(
        for glyph: GlyphID,
        realization: RasterRealizationID
    ) -> GlyphRasterRecord? { nil }
    func isPayloadAvailable(for realization: RasterRealizationID) -> Bool { true }
    func withPayload<Result>(
        for record: GlyphRasterRecord,
        realization: RasterRealizationID,
        _ body: (UnsafeRawBufferPointer) throws -> Result
    ) rethrows -> Result? { nil }
}

private struct OfferSessionSink: RasterOfferSessionSink {
    let capacity = RenderSinkCapacity(
        maximumOperations: 1,
        maximumPositionedGlyphs: 1
    )
    let descriptor: RasterSurfaceDescriptor
    let payloadLimits: RasterPayloadLimits
    var failure: RasterBackendError?
    var isIdleForOffer = true
    var reservationResult: DisplayReservationResult
    private(set) var reservationArguments:
        (
            RasterSurfaceDescriptor,
            UInt32,
            UInt16
        )?
    private(set) var resolutionCalls = 0
    private(set) var observedStreamResult: FrameStreamResult?

    mutating func reserveFrame(
        descriptor: RasterSurfaceDescriptor,
        payloadCapacityBytes: UInt32,
        regionCapacity: UInt16
    ) -> DisplayReservationResult {
        reservationArguments = (
            descriptor,
            payloadCapacityBytes,
            regionCapacity
        )
        return reservationResult
    }

    mutating func resolveAfterBody(
        _ result: FrameStreamResult
    ) -> FrameOfferResult {
        resolutionCalls += 1
        observedStreamResult = result
        if result == .complete {
            return FrameOfferResult(disposition: .accepted, failure: nil)!
        }
        return FrameOfferResult(
            disposition: .failed,
            failure: .contractViolation
        )!
    }

    borrowing func health() -> GiftUIOperationalHealth {
        GiftUIOperationalHealth()
    }

    mutating func begin(_ header: RenderPlanHeader) -> Bool { true }
    mutating func fillRect(_ operation: FillRectOperation) -> Bool { true }
    mutating func beginPositionedGlyphs(
        _ operation: PositionedGlyphOperationHeader
    ) -> Bool { true }
    mutating func positionedGlyph(_ glyph: PositionedGlyph) -> Bool { true }
    mutating func endPositionedGlyphs() -> Bool { true }
    mutating func finish() -> Bool { true }
    mutating func discard() {}
    mutating func straightLineStroke<Stroke: StraightLineStrokeView>(
        _ stroke: borrowing Stroke
    ) -> Bool { true }
}

private let offerProvenance = FrameProvenance(
    cycle: RunCycleID(rawValue: 10),
    semanticRevision: SemanticRevision(rawValue: 20),
    candidateFrame: CandidateFrameID(rawValue: 30)
)

private func makeOfferEndpoint(
    reservation: DisplayReservationResult = .reserved(
        DisplayReservationID(rawValue: 9)
    ),
    idle: Bool = true,
    validator: ExactEnvelopeValidator? = nil
) -> OneShotRasterBackendEndpoint<
    OfferSessionSink,
    OfferMetrics,
    OfferRaster,
    ExactEnvelopeValidator
> {
    var sink = OfferSessionSink(
        descriptor: descriptor(),
        payloadLimits: limits(),
        reservationResult: reservation
    )
    sink.isIdleForOffer = idle
    return OneShotRasterBackendEndpoint(
        effectivePresentation: effective(),
        descriptor: descriptor(),
        payloadLimits: limits(),
        textMetrics: OfferMetrics(),
        textRaster: OfferRaster(),
        textRasterRealization: RasterRealizationID(rawValue: 0),
        envelopeValidator: validator
            ?? ExactEnvelopeValidator(expected: offerProvenance),
        sink: sink,
        startupFailure: nil
    )!
}

@Test
func oneShotEndpointReservesExactSlotBeforeCallingBodyOnce() {
    var endpoint = makeOfferEndpoint()
    var bodyCalls = 0
    let result = endpoint.offer(provenance: offerProvenance) { sink in
        bodyCalls += 1
        #expect(sink.reservationArguments?.0 == descriptor())
        #expect(sink.reservationArguments?.1 == 48)
        #expect(sink.reservationArguments?.2 == 4)
        return .complete
    }

    #expect(result == FrameOfferResult(disposition: .accepted, failure: nil)!)
    #expect(bodyCalls == 1)
    #expect(endpoint.bodyCallCount == 1)
    #expect(endpoint.reservationCallCount == 1)
    #expect(endpoint.sink.resolutionCalls == 1)
    #expect(endpoint.sink.observedStreamResult == .complete)
}

private struct ReservationMappingFixture: CustomTestStringConvertible {
    let name: String
    let reservation: DisplayReservationResult
    let expected: FrameOfferResult
    let displayError: DisplayTargetError?

    var testDescription: String { name }
}

private let reservationMappings = [
    ReservationMappingFixture(
        name: "backpressured",
        reservation: .backpressured,
        expected: FrameOfferResult(disposition: .backpressured, failure: nil)!,
        displayError: nil
    ),
    ReservationMappingFixture(
        name: "retryable-refusal",
        reservation: .retryableRefusal,
        expected: FrameOfferResult(disposition: .retryableRefusal, failure: nil)!,
        displayError: nil
    ),
    ReservationMappingFixture(
        name: "nonretryable-refusal",
        reservation: .nonRetryableRefusal,
        expected: FrameOfferResult(disposition: .nonRetryableRefusal, failure: nil)!,
        displayError: nil
    ),
    ReservationMappingFixture(
        name: "display-failure",
        reservation: .failure(.transportUnavailable),
        expected: FrameOfferResult(
            disposition: .failed,
            failure: .contractViolation
        )!,
        displayError: .transportUnavailable
    ),
]

@Test(arguments: reservationMappings)
private func reservationOutcomesMapWithoutCallingBody(
    _ fixture: ReservationMappingFixture
) {
    var endpoint = makeOfferEndpoint(reservation: fixture.reservation)
    var bodyCalls = 0
    let result = endpoint.offer(provenance: offerProvenance) { _ in
        bodyCalls += 1
        return .complete
    }
    #expect(result == fixture.expected)
    #expect(bodyCalls == 0)
    #expect(endpoint.bodyCallCount == 0)
    #expect(endpoint.reservationCallCount == 1)
    #expect(endpoint.sink.resolutionCalls == 0)
    #expect(endpoint.lastDisplayError == fixture.displayError)
}

@Test
func invalidEnvelopeAndNonidleSinkExitBeforeReservationAndBody() {
    var invalid = makeOfferEndpoint()
    let badProvenance = FrameProvenance(
        cycle: RunCycleID(rawValue: 11),
        semanticRevision: offerProvenance.semanticRevision,
        candidateFrame: offerProvenance.candidateFrame
    )
    let invalidResult = invalid.offer(provenance: badProvenance) { _ in
        Issue.record("invalid envelope called body")
        return .complete
    }
    #expect(
        invalidResult
            == FrameOfferResult(
                disposition: .failed,
                failure: .invalidEnvelope
            )!
    )
    #expect(invalid.reservationCallCount == 0)

    var nonidle = makeOfferEndpoint(idle: false)
    let nonidleResult = nonidle.offer(provenance: offerProvenance) { _ in
        Issue.record("nonidle endpoint called body")
        return .complete
    }
    #expect(
        nonidleResult
            == FrameOfferResult(
                disposition: .failed,
                failure: .contractViolation
            )!
    )
    #expect(nonidle.reservationCallCount == 0)
    #expect(nonidle.bodyCallCount == 0)
}

@Test
func endpointConstructionRejectsStartupAndImmutableConfigurationMismatch() {
    let sink = OfferSessionSink(
        descriptor: descriptor(),
        payloadLimits: limits(),
        reservationResult: .backpressured
    )
    #expect(
        OneShotRasterBackendEndpoint(
            effectivePresentation: effective(),
            descriptor: descriptor(),
            payloadLimits: limits(),
            textMetrics: OfferMetrics(),
            textRaster: OfferRaster(),
            textRasterRealization: RasterRealizationID(rawValue: 0),
            envelopeValidator: ExactEnvelopeValidator(expected: offerProvenance),
            sink: sink,
            startupFailure: .capacityExhausted
        ) == nil
    )
    #expect(
        OneShotRasterBackendEndpoint(
            effectivePresentation: effective(requiredPayloadBytes: 47),
            descriptor: descriptor(),
            payloadLimits: limits(),
            textMetrics: OfferMetrics(),
            textRaster: OfferRaster(),
            textRasterRealization: RasterRealizationID(rawValue: 0),
            envelopeValidator: ExactEnvelopeValidator(expected: offerProvenance),
            sink: sink,
            startupFailure: nil
        ) == nil
    )
}
