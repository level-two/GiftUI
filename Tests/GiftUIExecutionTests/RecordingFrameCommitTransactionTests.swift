import GiftUI
import Testing

@testable import GiftUIExecution

private let priorPresentationState = RecordingPresentationState(
    presentationRevision: PresentationRevision(rawValue: 4),
    logicalFrameToken: 10,
    hitGeometryToken: 11,
    actionTableToken: 12,
    routingToken: 13
)

private let stagedPresentationState = RecordingPresentationState(
    presentationRevision: PresentationRevision(rawValue: 5),
    logicalFrameToken: 20,
    hitGeometryToken: 21,
    actionTableToken: 22,
    routingToken: 23
)

@Test
func acceptedOfferCommitsEveryCoupledFieldAtomically() {
    var transaction = makeFrameCommitTransaction()
    #expect(
        transaction.stage(
            candidate: CandidateFrameID(rawValue: 7),
            state: stagedPresentationState
        ) == nil
    )
    let outcome = transaction.finish(
        normalizedOffer: .accepted,
        completeConsumptionAndReservation: true,
        irreversibleOutputObserved: true
    )

    #expect(outcome == .committed(stagedPresentationState))
    #expect(transaction.committedState == stagedPresentationState)
    #expect(transaction.stagedState == nil)
    #expect(transaction.stagedCandidate == nil)
    #expect(!transaction.candidateAborted)
    #expect(transaction.endpointHealth == .accepted)
    #expect(transaction.publishedSemanticRevision == SemanticRevision(rawValue: 9))
}

@Test
func everyNonacceptedResultAbortsAllStagedStateAndPreservesPriorRouting() {
    let outcomes: [RecordingNormalizedOffer] = [
        .operational(.backpressured),
        .operational(.retryableRefusal),
        .failure(.renderProduction(.invalidInput)),
        .failure(.frameOffer(.invalidEnvelope)),
        .failure(.nonRetryableRefusal(.renderProducer)),
        .failure(.nonRetryableRefusal(.endpoint)),
    ]

    for normalized in outcomes {
        var transaction = makeFrameCommitTransaction()
        #expect(
            transaction.stage(
                candidate: CandidateFrameID(rawValue: 7),
                state: stagedPresentationState
            ) == nil
        )
        let outcome = transaction.finish(
            normalizedOffer: normalized,
            completeConsumptionAndReservation: true,
            irreversibleOutputObserved: false
        )

        #expect(outcome == .aborted(normalized))
        #expect(transaction.committedState == priorPresentationState)
        #expect(transaction.publishedSemanticRevision == SemanticRevision(rawValue: 9))
        #expect(transaction.stagedState == nil)
        #expect(transaction.stagedCandidate == nil)
        #expect(transaction.candidateAborted)
        #expect(transaction.endpointHealth == .ready)
    }
}

@Test
func incompleteAcceptedOfferCannotPublishAnyCoupledField() {
    var transaction = makeFrameCommitTransaction()
    #expect(
        transaction.stage(
            candidate: CandidateFrameID(rawValue: 7),
            state: stagedPresentationState
        ) == nil
    )
    #expect(
        transaction.finish(
            normalizedOffer: .accepted,
            completeConsumptionAndReservation: false,
            irreversibleOutputObserved: false
        ) == .failure(.frameOffer(.contractViolation))
    )
    #expect(transaction.committedState == priorPresentationState)
    #expect(transaction.publishedSemanticRevision == SemanticRevision(rawValue: 9))
    #expect(transaction.stagedState == nil)
    #expect(transaction.candidateAborted)
    #expect(transaction.endpointHealth == .unavailable)
}

@Test
func irreversibleOutputCanFinishOnlyAsAcceptedEndpointHealth() {
    let nonaccepted: [RecordingNormalizedOffer] = [
        .operational(.backpressured),
        .operational(.retryableRefusal),
        .failure(.frameOffer(.contractViolation)),
    ]

    for normalized in nonaccepted {
        var transaction = makeFrameCommitTransaction()
        _ = transaction.stage(
            candidate: CandidateFrameID(rawValue: 7),
            state: stagedPresentationState
        )
        #expect(
            transaction.finish(
                normalizedOffer: normalized,
                completeConsumptionAndReservation: true,
                irreversibleOutputObserved: true
            ) == .failure(.frameOffer(.contractViolation))
        )
        #expect(transaction.endpointHealth == .unavailable)
        #expect(transaction.committedState == priorPresentationState)
        #expect(transaction.candidateAborted)
    }
}

@Test
func transactionStagesAndFinishesExactlyOnce() {
    var transaction = makeFrameCommitTransaction()
    #expect(
        transaction.stage(
            candidate: CandidateFrameID(rawValue: 7),
            state: stagedPresentationState
        ) == nil
    )
    #expect(
        transaction.stage(
            candidate: CandidateFrameID(rawValue: 8),
            state: stagedPresentationState
        ) == .reentrancyViolation
    )
    _ = transaction.finish(
        normalizedOffer: .operational(.backpressured),
        completeConsumptionAndReservation: true,
        irreversibleOutputObserved: false
    )
    #expect(
        transaction.finish(
            normalizedOffer: .accepted,
            completeConsumptionAndReservation: true,
            irreversibleOutputObserved: false
        ) == .failure(.execution(.invalidPhase))
    )
}

private func makeFrameCommitTransaction() -> RecordingFrameCommitTransaction {
    RecordingFrameCommitTransaction(
        publishedSemanticRevision: SemanticRevision(rawValue: 9),
        committedState: priorPresentationState
    )
}
