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

private final class OfferHealthBox {
    var value = GiftUIOperationalHealth()

    func record(
        _ fact: GiftUIFailureFact,
        resultingState: GiftUIOperationalHealthState
    ) {
        value.recordFailure(fact, resultingState: resultingState)
    }
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
    var streamCompleted = false
    var presentationResponsibilityAccepted = false
    var retainedProducerError: RenderProductionError?
    var reservationResult: DisplayReservationResult
    private(set) var reservationArguments:
        (
            RasterSurfaceDescriptor,
            UInt32,
            UInt16
        )?
    private(set) var discardCount = 0
    private(set) var cancelCount = 0
    private(set) var forcedFinishCount = 0
    let healthBox = OfferHealthBox()

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
        if case .reserved = reservationResult {
            isIdleForOffer = false
        }
        return reservationResult
    }

    mutating func cancelReservedFrame() {
        cancelCount += 1
        isIdleForOffer = true
    }

    mutating func finishTransferredFrameIfNeeded() {
        forcedFinishCount += 1
        streamCompleted = true
        isIdleForOffer = true
    }

    borrowing func health() -> GiftUIOperationalHealth {
        healthBox.value
    }

    mutating func retainProducerError(_ error: RenderProductionError) {
        retainedProducerError = error
    }

    mutating func begin(_ header: RenderPlanHeader) -> Bool { true }
    mutating func fillRect(_ operation: FillRectOperation) -> Bool { true }
    mutating func beginPositionedGlyphs(
        _ operation: PositionedGlyphOperationHeader
    ) -> Bool { true }
    mutating func positionedGlyph(_ glyph: PositionedGlyph) -> Bool { true }
    mutating func endPositionedGlyphs() -> Bool { true }
    mutating func finish() -> Bool {
        streamCompleted = true
        isIdleForOffer = true
        return true
    }
    mutating func discard() { discardCount += 1 }
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
        _ = sink.finish()
        return .complete
    }

    #expect(result == FrameOfferResult(disposition: .accepted, failure: nil)!)
    #expect(bodyCalls == 1)
    #expect(endpoint.bodyCallCount == 1)
    #expect(endpoint.reservationCallCount == 1)
    #expect(endpoint.sink.discardCount == 0)
    #expect(endpoint.sink.cancelCount == 0)
}

@Test
func endpointRebindsEnvelopeOnlyWhileRasterSinkIsIdle() {
    let next = FrameProvenance(
        cycle: RunCycleID(rawValue: 11),
        semanticRevision: SemanticRevision(rawValue: 21),
        candidateFrame: CandidateFrameID(rawValue: 31)
    )
    var nonidle = makeOfferEndpoint(idle: false)
    let refused = nonidle.replaceEnvelopeValidator(ExactEnvelopeValidator(expected: next))
    #expect(!refused)
    #expect(
        nonidle.offer(provenance: next) { _ in
            Issue.record("Rejected envelope reached raster body")
            return .complete
        }
            == FrameOfferResult(disposition: .failed, failure: .invalidEnvelope)!
    )

    var idle = makeOfferEndpoint()
    let installed = idle.replaceEnvelopeValidator(ExactEnvelopeValidator(expected: next))
    #expect(installed)
    #expect(
        idle.offer(provenance: offerProvenance) { _ in
            Issue.record("Replaced envelope reached raster body")
            return .complete
        }
            == FrameOfferResult(disposition: .failed, failure: .invalidEnvelope)!
    )
    #expect(idle.reservationCallCount == 0)
    #expect(
        idle.offer(provenance: next) { sink in
            _ = sink.finish()
            return .complete
        } == FrameOfferResult(disposition: .accepted, failure: nil)!
    )
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
        name: "invalid-descriptor-failure",
        reservation: .failure(.invalidDescriptor),
        expected: FrameOfferResult(
            disposition: .failed,
            failure: .contractViolation
        )!,
        displayError: .invalidDescriptor
    ),
    ReservationMappingFixture(
        name: "invalid-reservation-failure",
        reservation: .failure(.invalidReservation),
        expected: FrameOfferResult(
            disposition: .failed,
            failure: .contractViolation
        )!,
        displayError: .invalidReservation
    ),
    ReservationMappingFixture(
        name: "capacity-failure",
        reservation: .failure(.capacityExhausted),
        expected: FrameOfferResult(
            disposition: .failed,
            failure: .contractViolation
        )!,
        displayError: .capacityExhausted
    ),
    ReservationMappingFixture(
        name: "arithmetic-failure",
        reservation: .failure(.arithmeticOverflow),
        expected: FrameOfferResult(
            disposition: .failed,
            failure: .contractViolation
        )!,
        displayError: .arithmeticOverflow
    ),
    ReservationMappingFixture(
        name: "transport-failure",
        reservation: .failure(.transportUnavailable),
        expected: FrameOfferResult(
            disposition: .failed,
            failure: .contractViolation
        )!,
        displayError: .transportUnavailable
    ),
    ReservationMappingFixture(
        name: "reentrancy-failure",
        reservation: .failure(.reentrancyViolation),
        expected: FrameOfferResult(
            disposition: .failed,
            failure: .contractViolation
        )!,
        displayError: .reentrancyViolation
    ),
    ReservationMappingFixture(
        name: "invariant-failure",
        reservation: .failure(.invariantViolation),
        expected: FrameOfferResult(
            disposition: .failed,
            failure: .contractViolation
        )!,
        displayError: .invariantViolation
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
    #expect(endpoint.sink.discardCount == 0)
    #expect(endpoint.sink.cancelCount == 0)
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

private struct PretransferStreamFixture: CustomTestStringConvertible {
    let name: String
    let stream: FrameStreamResult
    let producerError: RenderProductionError?
    let expected: FrameOfferResult

    var testDescription: String { name }
}

private let pretransferStreams = [
    PretransferStreamFixture(
        name: "producer-failed",
        stream: .producerFailed,
        producerError: .invalidInput,
        expected: FrameOfferResult(
            disposition: .failed,
            failure: .producerFailed
        )!
    ),
    PretransferStreamFixture(
        name: "insufficient-capacity",
        stream: .insufficientCapacity,
        producerError: .capacityExhausted,
        expected: FrameOfferResult(
            disposition: .failed,
            failure: .insufficientCapacity
        )!
    ),
    PretransferStreamFixture(
        name: "endpoint-refused",
        stream: .endpointRefused,
        producerError: .sinkRefused,
        expected: FrameOfferResult(
            disposition: .nonRetryableRefusal,
            failure: nil
        )!
    ),
    PretransferStreamFixture(
        name: "contract-violation",
        stream: .contractViolation,
        producerError: .invariantViolation,
        expected: FrameOfferResult(
            disposition: .failed,
            failure: .contractViolation
        )!
    ),
]

@Test(arguments: pretransferStreams)
private func pretransferBodyResultsDiscardAndCancelExactlyOnce(
    _ fixture: PretransferStreamFixture
) {
    var endpoint = makeOfferEndpoint()
    let result = endpoint.offer(provenance: offerProvenance) { sink in
        sink.retainedProducerError = fixture.producerError
        return fixture.stream
    }
    #expect(result == fixture.expected)
    #expect(endpoint.retainedProducerError == fixture.producerError)
    #expect(endpoint.sink.discardCount == 1)
    #expect(endpoint.sink.cancelCount == 1)
    #expect(endpoint.sink.forcedFinishCount == 0)
    #expect(endpoint.sink.isIdleForOffer)
}

private let everyStreamResult: [FrameStreamResult] = [
    .complete,
    .producerFailed,
    .insufficientCapacity,
    .endpointRefused,
    .contractViolation,
]

@Test(arguments: everyStreamResult)
func everyPosttransferBodyResultIsAcceptedAndMechanicallyFinished(
    _ stream: FrameStreamResult
) {
    var endpoint = makeOfferEndpoint()
    let result = endpoint.offer(provenance: offerProvenance) { sink in
        sink.presentationResponsibilityAccepted = true
        sink.retainedProducerError =
            stream == .complete ? nil : .invariantViolation
        if stream == .complete {
            _ = sink.finish()
        }
        return stream
    }
    #expect(result == FrameOfferResult(disposition: .accepted, failure: nil)!)
    #expect(endpoint.sink.discardCount == 0)
    #expect(endpoint.sink.cancelCount == 0)
    #expect(endpoint.sink.forcedFinishCount == (stream == .complete ? 0 : 1))
    #expect(endpoint.sink.streamCompleted)
    #expect(endpoint.sink.isIdleForOffer)
    if stream != .complete {
        #expect(endpoint.retainedProducerError == .invariantViolation)
    }
}

@Test
func incompleteCompleteResultIsContractViolationAndCancellable() {
    var endpoint = makeOfferEndpoint()
    let result = endpoint.offer(provenance: offerProvenance) { _ in .complete }
    #expect(
        result
            == FrameOfferResult(
                disposition: .failed,
                failure: .contractViolation
            )!
    )
    #expect(endpoint.sink.discardCount == 1)
    #expect(endpoint.sink.cancelCount == 1)
    #expect(endpoint.sink.forcedFinishCount == 0)
}

private let impossiblePretransferStreams = [
    PretransferStreamFixture(
        name: "producer-without-error",
        stream: .producerFailed,
        producerError: nil,
        expected: FrameOfferResult(
            disposition: .failed,
            failure: .contractViolation
        )!
    ),
    PretransferStreamFixture(
        name: "capacity-with-wrong-error",
        stream: .insufficientCapacity,
        producerError: .invalidInput,
        expected: FrameOfferResult(
            disposition: .failed,
            failure: .contractViolation
        )!
    ),
    PretransferStreamFixture(
        name: "refusal-without-sink-error",
        stream: .endpointRefused,
        producerError: nil,
        expected: FrameOfferResult(
            disposition: .failed,
            failure: .contractViolation
        )!
    ),
]

@Test(arguments: impossiblePretransferStreams)
private func impossiblePretransferResultsBecomeContractViolations(
    _ fixture: PretransferStreamFixture
) {
    var endpoint = makeOfferEndpoint()
    let result = endpoint.offer(provenance: offerProvenance) { sink in
        sink.retainedProducerError = fixture.producerError
        return fixture.stream
    }
    #expect(result == fixture.expected)
    #expect(endpoint.sink.discardCount == 1)
    #expect(endpoint.sink.cancelCount == 1)
    #expect(endpoint.sink.forcedFinishCount == 0)
}

@Test
func endpointProjectsLiveTargetOwnedHealthWithoutCaching() {
    let endpoint = makeOfferEndpoint()
    #expect(endpoint.health() == GiftUIOperationalHealth())

    let mapping = RasterBackendOwnerFailureAdapter.map(
        DisplayTargetError.transportUnavailable,
        at: .postAcceptance
    )
    endpoint.sink.healthBox.record(
        mapping.fact,
        resultingState: .unavailable
    )
    let unavailable = endpoint.health()
    #expect(unavailable.state == .unavailable)
    #expect(unavailable.failureCount == 1)
    #expect(unavailable.transitionCount == 1)

    let invariant = RasterBackendOwnerFailureAdapter.map(
        DisplayTargetError.invariantViolation,
        at: .postAcceptance
    )
    endpoint.sink.healthBox.record(
        invariant.fact,
        resultingState: .quiesced
    )
    let quiesced = endpoint.health()
    #expect(quiesced.state == .quiesced)
    #expect(quiesced.failureCount == 2)
    #expect(quiesced.transitionCount == 2)
}

@Test
func diagnosticSelectionCannotChangeOfferOrHealth() {
    let selections = [
        GiftUIDiagnosticSelection(
            kindMask: 0,
            originMask: 0,
            minimumSeverity: .critical
        ),
        GiftUIDiagnosticSelection(
            kindMask: .max,
            originMask: .max,
            minimumSeverity: .debug
        ),
    ]
    for selection in selections {
        _ = selection
        var endpoint = makeOfferEndpoint()
        let result = endpoint.offer(provenance: offerProvenance) { sink in
            _ = sink.finish()
            return .complete
        }
        #expect(
            result == FrameOfferResult(disposition: .accepted, failure: nil)!
        )
        #expect(endpoint.health() == GiftUIOperationalHealth())
        #expect(endpoint.bodyCallCount == 1)
    }
}
