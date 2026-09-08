import GiftUI
import Testing

@testable import GiftUIExecution

private let transactionLimits = ExecutionLimits(
    maximumInputEvents: 2,
    maximumStateChangeFacts: 2,
    maximumCompletionFacts: 1,
    maximumSemanticActions: 1,
    maximumActiveInputSources: 1,
    maximumCommittedActions: 2
)!

private func transactionPointer(
    source: UInt16,
    sequence: UInt32,
    ordinal: UInt32 = 0
) -> NormalizedPointerEvent {
    NormalizedPointerEvent(
        phase: ordinal == 0 ? .down : .move,
        position: Point(x: 1, y: 1),
        source: InputSourceID(rawValue: source),
        sequence: PointerSequenceID(rawValue: sequence),
        ordinal: InputOrdinal(rawValue: ordinal),
        presentationRevision: PresentationRevision(rawValue: 1)
    )
}

private func finish(
    _ transaction: inout ExecutionAdmissionSealTransaction,
    batchReservationAvailable: Bool = true
) -> Result<ExecutionAdmissionSealSelection, ExecutionAdmissionSealFailureResult> {
    transaction.finish(
        pendingStateChangeFacts: 1,
        pendingCompletionFacts: 1,
        includesDirtyRederivation: true,
        includesPresentationRecovery: true,
        batchReservationAvailable: batchReservationAvailable
    )
}

@Test
func everySealReservationFailureHasZeroCountsAndCancelsNothing() {
    let pointer = transactionPointer(source: 1, sequence: 0)

    var transitionFailure = ExecutionAdmissionSealTransaction(
        limits: transactionLimits
    )!
    let transitionBegan = transitionFailure.begin()
    let transitionStaged = transitionFailure.stagePointer(
        pointer,
        provenanceValid: true,
        createsActivation: true,
        transitionReservationAvailable: false
    )
    #expect(transitionBegan)
    #expect(!transitionStaged)
    guard case .failure(let transitionResult) = finish(&transitionFailure)
    else {
        Issue.record("transition reservation unexpectedly succeeded")
        return
    }
    assertZeroFailure(transitionResult, cancellation: nil)

    var batchFailure = ExecutionAdmissionSealTransaction(
        limits: transactionLimits
    )!
    let batchBegan = batchFailure.begin()
    let batchStaged = batchFailure.stagePointer(
        pointer,
        provenanceValid: true,
        createsActivation: true,
        transitionReservationAvailable: true
    )
    #expect(batchBegan)
    #expect(batchStaged)
    guard
        case .failure(let batchResult) = finish(
            &batchFailure,
            batchReservationAvailable: false
        )
    else {
        Issue.record("batch reservation unexpectedly succeeded")
        return
    }
    assertZeroFailure(batchResult, cancellation: nil)
}

@Test
func staleOrMalformedPointerCancelsOnlyItsCompleteSequence() {
    let unrelated = transactionPointer(source: 1, sequence: 0)
    let rejected = transactionPointer(source: 2, sequence: 7)
    let rejectedSuffix = transactionPointer(
        source: 2,
        sequence: 7,
        ordinal: 1
    )
    var queued = [unrelated, rejected, rejectedSuffix]
    var transaction = ExecutionAdmissionSealTransaction(
        limits: transactionLimits
    )!

    let began = transaction.begin()
    let stagedUnrelated = transaction.stagePointer(
        unrelated,
        provenanceValid: true,
        createsActivation: false,
        transitionReservationAvailable: true
    )
    let stagedRejected = transaction.stagePointer(
        rejected,
        provenanceValid: false,
        createsActivation: true,
        transitionReservationAvailable: true
    )
    #expect(began)
    #expect(stagedUnrelated)
    #expect(!stagedRejected)
    guard case .failure(let result) = finish(&transaction) else {
        Issue.record("invalid provenance unexpectedly sealed")
        return
    }
    let cancellation = CancelledInputSequence(
        source: rejected.source,
        sequence: rejected.sequence
    )
    assertZeroFailure(result, cancellation: cancellation)
    queued.removeAll {
        $0.source == cancellation.source
            && $0.sequence == cancellation.sequence
    }
    #expect(queued == [unrelated])
}

@Test
func semanticActionOverflowCancelsAffectedSequenceAndNoActivationEscapes() {
    let first = transactionPointer(source: 1, sequence: 0)
    let overflow = transactionPointer(source: 1, sequence: 1)
    var transaction = ExecutionAdmissionSealTransaction(
        limits: transactionLimits
    )!

    let began = transaction.begin()
    let stagedFirst = transaction.stagePointer(
        first,
        provenanceValid: true,
        createsActivation: true,
        transitionReservationAvailable: true
    )
    let stagedOverflow = transaction.stagePointer(
        overflow,
        provenanceValid: true,
        createsActivation: true,
        transitionReservationAvailable: true
    )
    #expect(began)
    #expect(stagedFirst)
    #expect(!stagedOverflow)
    #expect(transaction.stagedInputCount == 0)
    #expect(transaction.stagedActivationCount == 0)

    guard case .failure(let result) = finish(&transaction) else {
        Issue.record("action overflow unexpectedly sealed")
        return
    }
    assertZeroFailure(
        result,
        cancellation: CancelledInputSequence(
            source: overflow.source,
            sequence: overflow.sequence
        )
    )
}

@Test
func firstSealFailureIsStickyAcrossLaterFaults() {
    let rejected = transactionPointer(source: 3, sequence: 9)
    var transaction = ExecutionAdmissionSealTransaction(
        limits: transactionLimits
    )!
    let began = transaction.begin()
    let firstStage = transaction.stagePointer(
        rejected,
        provenanceValid: false,
        createsActivation: false,
        transitionReservationAvailable: true
    )
    let laterStage = transaction.stagePointer(
        rejected,
        provenanceValid: true,
        createsActivation: false,
        transitionReservationAvailable: false
    )
    #expect(began)
    #expect(!firstStage)
    #expect(!laterStage)
    guard case .failure(let result) = finish(&transaction) else {
        Issue.record("failed transaction unexpectedly sealed")
        return
    }
    #expect(result.failure == .invalidProvenance)
}

@Test
func finalizationMakesFailedWorkspaceCleanlyReusable() {
    let pointer = transactionPointer(source: 1, sequence: 0)
    var transaction = ExecutionAdmissionSealTransaction(
        limits: transactionLimits
    )!
    let firstBegin = transaction.begin()
    let rejectedStage = transaction.stagePointer(
        pointer,
        provenanceValid: false,
        createsActivation: false,
        transitionReservationAvailable: true
    )
    #expect(firstBegin)
    #expect(!rejectedStage)
    _ = finish(&transaction)
    #expect(!transaction.isActive)
    #expect(transaction.firstFailure == nil)
    let secondBegin = transaction.begin()
    let acceptedStage = transaction.stagePointer(
        pointer,
        provenanceValid: true,
        createsActivation: true,
        transitionReservationAvailable: true
    )
    #expect(secondBegin)
    #expect(acceptedStage)
    guard case .success(let selection) = finish(&transaction) else {
        Issue.record("clean reused transaction failed")
        return
    }
    #expect(selection.summary.inputEventCount == 1)
    #expect(selection.summary.semanticActionCount == 1)
}

private func assertZeroFailure(
    _ result: ExecutionAdmissionSealFailureResult,
    cancellation: CancelledInputSequence?
) {
    #expect(result.failure == .capacityExhausted || result.failure == .invalidProvenance)
    #expect(result.cancelledSequence == cancellation)
    #expect(result.summary.inputEventCount == 0)
    #expect(result.summary.stateChangeFactCount == 0)
    #expect(result.summary.completionFactCount == 0)
    #expect(result.summary.semanticActionCount == 0)
    #expect(!result.summary.includesDirtyRederivation)
    #expect(!result.summary.includesPresentationRecovery)
}
