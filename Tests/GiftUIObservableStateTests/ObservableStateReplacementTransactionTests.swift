import GiftUI
import GiftUIExecution
import Testing

@testable import GiftUIObservableState

private final class ReplacementFixtureModel: _GiftUIObservableReference {
    enum AttachmentBehavior {
        case matching
        case nilReturn
        case mismatchedReturn
        case reportThenMatching
    }

    let behavior: AttachmentBehavior
    private(set) var attachment: _GiftUIObservationAttachment?
    private(set) var reportOutcome: _GiftUIObservableChangeReportOutcome?
    private(set) var detachments: [_GiftUIObservationAttachment] = []

    init(behavior: AttachmentBehavior = .matching) {
        self.behavior = behavior
    }

    func _giftUIAttachChangeSink(
        _ sink: consuming _GiftUIObservableChangeSink
    ) -> _GiftUIObservationAttachment? {
        attachment = sink.attachment
        switch behavior {
        case .matching:
            return sink.attachment
        case .nilReturn:
            return nil
        case .mismatchedReturn:
            return _GiftUIObservationAttachment(
                slot: sink.attachment.slot,
                generation: sink.attachment.generation &+ 1
            )
        case .reportThenMatching:
            reportOutcome = sink.reportChange()
            return sink.attachment
        }
    }

    func _giftUIDetachChangeSink(
        _ attachment: _GiftUIObservationAttachment
    ) {
        detachments.append(attachment)
    }
}

private final class ReplacementTransactionBox {
    var transaction: ObservableStateReplacementTransaction

    init(_ transaction: ObservableStateReplacementTransaction) {
        self.transaction = transaction
    }
}

private func makeTransaction(
    dirty: Bool = false
) -> (
    ObservableStateAttachmentGenerationAllocator,
    ObservableStateAttachmentReservation,
    ObservableStateReplacementTransaction
) {
    var allocator = ObservableStateAttachmentGenerationAllocator()
    guard case .success(let live) = allocator.reserve(slot: 3) else {
        fatalError("fixture live reservation failed")
    }
    return (
        allocator,
        live,
        ObservableStateReplacementTransaction(
            liveReservation: live,
            isDirty: dirty
        )
    )
}

private func beginValidReplacement(
    _ transaction: inout ObservableStateReplacementTransaction,
    allocator: inout ObservableStateAttachmentGenerationAllocator
) -> ObservableStateAttachmentReservation {
    #expect(
        transaction.beginReplacement(
            executionPhase: .mutating,
            isCompatible: true,
            candidateAlreadyOwned: false,
            registrationCapacityAvailable: true,
            replacementStagingAvailable: true,
            slot: 3,
            allocator: &allocator
        ) == nil
    )
    return transaction.pendingReservation!
}

private func attach(
    _ model: ReplacementFixtureModel,
    to box: ReplacementTransactionBox
) -> _GiftUIObservationAttachment? {
    let pending = box.transaction.pendingReservation!
    return model._giftUIAttachChangeSink(
        _GiftUIObservableChangeSink(
            attachment: pending.attachment,
            reportRoute: { attachment in
                let failure = box.transaction.acceptCandidateReport(attachment)
                return failure == .staleAttachment
                    ? .staleAttachment
                    : .invariantViolation
            }
        )
    )
}

@Test
func successfulReplacementCommitsFreshRouteDetachesFormerAndStaysDirty() {
    var (allocator, former, transaction) = makeTransaction()
    let formerModel = ReplacementFixtureModel()
    let candidate = ReplacementFixtureModel()
    _ = beginValidReplacement(&transaction, allocator: &allocator)
    let box = ReplacementTransactionBox(transaction)

    let returned = attach(candidate, to: box)
    #expect(box.transaction.acceptAttachmentReturn(returned) == nil)
    guard case .success(let commit) = box.transaction.commit() else {
        Issue.record("valid replacement did not commit")
        return
    }
    formerModel._giftUIDetachChangeSink(commit.formerAttachment)

    #expect(commit.formerAttachment == former.attachment)
    #expect(commit.activeReservation == box.transaction.liveReservation)
    #expect(commit.activeReservation.targetGeneration != former.targetGeneration)
    #expect(formerModel.detachments == [former.attachment])
    #expect(box.transaction.acceptLiveReport(former.attachment) == .staleAttachment)
    #expect(
        box.transaction.acceptLiveReport(commit.activeReservation.attachment)
            == nil
    )
    #expect(box.transaction.isDirty)

    let simulatedLaterDerivationFailure = ObservableStateError.invariantViolation
    #expect(simulatedLaterDerivationFailure == .invariantViolation)
    #expect(box.transaction.liveReservation == commit.activeReservation)
    #expect(box.transaction.isDirty)
}

@Test
func everyPrecommitValidationOrReservationFailurePreservesFormerState() {
    let cases:
        [(
            ExecutionPhase, Bool, Bool, Bool, Bool,
            ObservableStateError
        )] = [
            (.deriving, true, false, true, true, .invalidPhaseContained),
            (.mutating, false, false, true, true, .incompatibleAssociation),
            (.mutating, true, true, true, true, .duplicateOwner),
            (.mutating, true, false, false, true, .registrationCapacityExhausted),
            (.mutating, true, false, true, false, .replacementStagingCapacityExhausted),
        ]

    for (phase, compatible, owned, registration, staging, expected) in cases {
        var (allocator, former, transaction) = makeTransaction()
        #expect(
            transaction.beginReplacement(
                executionPhase: phase,
                isCompatible: compatible,
                candidateAlreadyOwned: owned,
                registrationCapacityAvailable: registration,
                replacementStagingAvailable: staging,
                slot: 3,
                allocator: &allocator
            ) == expected
        )
        #expect(transaction.liveReservation == former)
        #expect(transaction.acceptLiveReport(former.attachment) == nil)
        #expect(!transaction.isDirty)
        #expect(transaction.pendingReservation == nil)
    }

    var (_, former, exhausted) = makeTransaction()
    var exhaustedAllocator = ObservableStateAttachmentGenerationAllocator(
        nextGeneration: nil
    )
    #expect(
        exhausted.beginReplacement(
            executionPhase: .mutating,
            isCompatible: true,
            candidateAlreadyOwned: false,
            registrationCapacityAvailable: true,
            replacementStagingAvailable: true,
            slot: 3,
            allocator: &exhaustedAllocator
        ) == .registrationGenerationExhausted
    )
    #expect(exhausted.liveReservation == former)
    #expect(exhausted.acceptLiveReport(former.attachment) == nil)
}

@Test
func attachmentReturnFailureDiscardsCandidateAndPreservesFormer() {
    let cases: [(ReplacementFixtureModel.AttachmentBehavior, ObservableStateError)] = [
        (.nilReturn, .duplicateOwner),
        (.mismatchedReturn, .invariantViolation),
    ]
    for (behavior, expectedFailure) in cases {
        var (allocator, former, transaction) = makeTransaction(dirty: true)
        let candidate = ReplacementFixtureModel(behavior: behavior)
        let pending = beginValidReplacement(
            &transaction,
            allocator: &allocator
        )
        let box = ReplacementTransactionBox(transaction)

        let returned = attach(candidate, to: box)
        #expect(
            box.transaction.acceptAttachmentReturn(returned)
                == expectedFailure
        )
        #expect(box.transaction.commit() == .failure(expectedFailure))
        let discarded = box.transaction.discardCandidate()
        candidate._giftUIDetachChangeSink(discarded!)

        #expect(discarded == pending.attachment)
        #expect(candidate.detachments == [pending.attachment])
        #expect(box.transaction.liveReservation == former)
        #expect(box.transaction.acceptLiveReport(former.attachment) == nil)
        #expect(box.transaction.isDirty)
    }
}

@Test
func reportDuringAttachmentPoisonsMatchingReturnAndPreservesFormer() {
    var (allocator, former, transaction) = makeTransaction()
    let candidate = ReplacementFixtureModel(behavior: .reportThenMatching)
    let pending = beginValidReplacement(&transaction, allocator: &allocator)
    let box = ReplacementTransactionBox(transaction)

    let returned = attach(candidate, to: box)
    #expect(candidate.reportOutcome == .staleAttachment)
    #expect(
        box.transaction.acceptAttachmentReturn(returned) == .staleAttachment
    )
    #expect(box.transaction.commit() == .failure(.staleAttachment))
    let discarded = box.transaction.discardCandidate()
    candidate._giftUIDetachChangeSink(discarded!)

    #expect(discarded == pending.attachment)
    #expect(box.transaction.liveReservation == former)
    #expect(box.transaction.acceptLiveReport(former.attachment) == nil)
    #expect(!box.transaction.isDirty)
}
