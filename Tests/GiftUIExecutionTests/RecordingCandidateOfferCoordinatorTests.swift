import GiftUI
import GiftUIRenderCore
import Testing

@testable import GiftUIExecution

private let offerRect = Rect(
    origin: Point(x: 0, y: 0),
    size: Size(width: 4, height: 4)!
)!

private let offerHeader = RenderPlanHeader(
    surfaceBounds: offerRect,
    damageBounds: offerRect,
    operationCount: 0,
    positionedGlyphCount: 0,
    maximumObservedClipDepth: 1
)

@Test
func candidateAllocationUsesExactPublicationAndRecoveryPhases() {
    for origin in [RecordingCandidateOrigin.newPublication, .unchangedRecovery] {
        var coordinator = makeOfferCoordinator()
        let outcome = coordinator.prepareAndOffer(
            origin: origin,
            cycle: RunCycleID(rawValue: 2),
            semanticRevision: SemanticRevision(rawValue: 3),
            body: completeEmptyOffer
        )
        guard case .offered(let reservation, let result) = outcome else {
            Issue.record("candidate was not offered from \(origin)")
            continue
        }
        #expect(
            reservation.provenance
                == FrameProvenance(
                    cycle: RunCycleID(rawValue: 2),
                    semanticRevision: SemanticRevision(rawValue: 3),
                    candidateFrame: CandidateFrameID(rawValue: 0)
                )
        )
        #expect(reservation.presentationRevision == PresentationRevision(rawValue: 0))
        #expect(result == FrameOfferResult(disposition: .accepted, failure: nil))
        #expect(coordinator.offerCallCount == 1)
        #expect(coordinator.endpoint.bodyCallCount == 1)
    }
}

@Test
func candidateAndPresentationExhaustionFailBeforeOfferAtExactPhase() {
    let origins: [RecordingCandidateOrigin] = [.newPublication, .unchangedRecovery]
    for origin in origins {
        var candidateFailure = makeOfferCoordinator(
            candidates: CandidateFrameIDAllocator(nextRawValue: nil)
        )
        let candidateOutcome = candidateFailure.prepareAndOffer(
            origin: origin,
            cycle: RunCycleID(rawValue: 4),
            semanticRevision: SemanticRevision(rawValue: 5),
            body: completeEmptyOffer
        )
        assertOfferFailure(
            candidateOutcome,
            phase: origin.allocationPhase,
            candidate: nil,
            failure: .execution(.identityExhausted),
            disposition: .notProduced
        )
        #expect(candidateFailure.offerCallCount == 0)
        #expect(candidateFailure.endpoint.bodyCallCount == 0)

        var presentationFailure = makeOfferCoordinator(
            presentations: PresentationRevisionAllocator(nextRawValue: nil)
        )
        let presentationOutcome = presentationFailure.prepareAndOffer(
            origin: origin,
            cycle: RunCycleID(rawValue: 4),
            semanticRevision: SemanticRevision(rawValue: 5),
            body: completeEmptyOffer
        )
        assertOfferFailure(
            presentationOutcome,
            phase: origin.allocationPhase,
            candidate: CandidateFrameID(rawValue: 0),
            failure: .execution(.identityExhausted),
            disposition: .aborted
        )
        #expect(presentationFailure.offerCallCount == 0)
        #expect(presentationFailure.endpoint.bodyCallCount == 0)
    }
}

@Test
func facilityAndDirectContractFailuresNeverEnterOfferBody() {
    let rows: [(RecordingPreOfferCondition, CandidateFrameID?, LogicalFrameDisposition)] = [
        (.facilityUnavailableBeforeCandidate, nil, .notProduced),
        (.facilityUnavailableAfterCandidate, CandidateFrameID(rawValue: 0), .aborted),
        (.directContractFailure, CandidateFrameID(rawValue: 0), .aborted),
    ]

    for (condition, candidate, disposition) in rows {
        var coordinator = makeOfferCoordinator()
        let outcome = coordinator.prepareAndOffer(
            origin: .newPublication,
            cycle: RunCycleID(rawValue: 6),
            semanticRevision: SemanticRevision(rawValue: 7),
            condition: condition,
            body: completeEmptyOffer
        )
        let failure: RunCycleFailure<RecordingCycleOwnerFailure> =
            condition == .directContractFailure
            ? .frameOffer(.contractViolation)
            : .execution(.requiredFacilityUnavailable)
        assertOfferFailure(
            outcome,
            phase: .publishing,
            candidate: candidate,
            failure: failure,
            disposition: disposition
        )
        #expect(coordinator.offerCallCount == 0)
        #expect(coordinator.endpoint.bodyCallCount == 0)
    }
}

@Test
func invalidEnvelopeEntersOfferOnceButNeverCallsBody() {
    var coordinator = makeOfferCoordinator()
    let outcome = coordinator.prepareAndOffer(
        origin: .newPublication,
        cycle: RunCycleID(rawValue: 8),
        semanticRevision: SemanticRevision(rawValue: 9),
        envelopeValid: false,
        body: completeEmptyOffer
    )
    assertOfferFailure(
        outcome,
        phase: .offering,
        candidate: CandidateFrameID(rawValue: 0),
        failure: .frameOffer(.invalidEnvelope),
        disposition: .aborted
    )
    #expect(coordinator.offerCallCount == 1)
    #expect(coordinator.endpoint.bodyCallCount == 0)
}

@Test
func oneCandidateCanNeverInvokeOfferMoreThanOnce() {
    var coordinator = makeOfferCoordinator()
    _ = coordinator.prepareAndOffer(
        origin: .unchangedRecovery,
        cycle: RunCycleID(rawValue: 10),
        semanticRevision: SemanticRevision(rawValue: 11),
        body: completeEmptyOffer
    )
    let repeated = coordinator.prepareAndOffer(
        origin: .unchangedRecovery,
        cycle: RunCycleID(rawValue: 10),
        semanticRevision: SemanticRevision(rawValue: 11),
        body: completeEmptyOffer
    )
    assertOfferFailure(
        repeated,
        phase: .deriving,
        candidate: nil,
        failure: .execution(.reentrancyViolation),
        disposition: .notProduced
    )
    #expect(coordinator.offerCallCount == 1)
    #expect(coordinator.endpoint.bodyCallCount == 1)
}

private func completeEmptyOffer(
    _ sink: inout RecordingFrameSink
) -> FrameStreamResult {
    guard sink.begin(offerHeader), sink.finish() else {
        return .contractViolation
    }
    return .complete
}

private func makeOfferCoordinator(
    candidates: CandidateFrameIDAllocator = CandidateFrameIDAllocator(),
    presentations: PresentationRevisionAllocator = PresentationRevisionAllocator()
) -> RecordingCandidateOfferCoordinator {
    RecordingCandidateOfferCoordinator(
        candidates: candidates,
        presentations: presentations,
        endpoint: RecordingSynchronousFrameEndpoint(
            maximumDownstreamSlots: 2,
            sinkCapacity: RenderSinkCapacity(
                maximumOperations: 1,
                maximumPositionedGlyphs: 1
            )
        )!
    )
}

private func assertOfferFailure(
    _ outcome: RecordingCandidateOfferOutcome,
    phase: ExecutionPhase,
    candidate: CandidateFrameID?,
    failure: RunCycleFailure<RecordingCycleOwnerFailure>,
    disposition: LogicalFrameDisposition
) {
    guard case .failure(let context, let actualFailure, let actualDisposition) = outcome else {
        Issue.record("expected candidate offer failure")
        return
    }
    #expect(context.cycle != nil)
    #expect(context.semanticRevision != nil)
    #expect(context.candidateFrame == candidate)
    #expect(context.phase == phase)
    #expect(actualFailure == failure)
    #expect(actualDisposition == disposition)
}
