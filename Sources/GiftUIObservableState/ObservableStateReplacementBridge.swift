import GiftUI
import GiftUIExecution

package struct ObservableStateReplacementBridgeCommit: Equatable, Sendable {
    package let formerAttachment: _GiftUIObservationAttachment
    package let activeAttachment: _GiftUIObservationAttachment
    package let targetGeneration: ObservableTargetGeneration
}

package enum ObservableStateReplacementBridgeCommitResult: Equatable, Sendable {
    case success(ObservableStateReplacementBridgeCommit)
    case failure(ObservableStateError)
}

package struct ObservableStateReplacementBridge {
    private var transaction: ObservableStateReplacementTransaction

    package init(
        liveAttachment: _GiftUIObservationAttachment,
        isDirty: Bool
    ) {
        transaction = ObservableStateReplacementTransaction(
            liveReservation: ObservableStateAttachmentReservation(
                attachment: liveAttachment
            ),
            isDirty: isDirty
        )
    }

    package var liveAttachment: _GiftUIObservationAttachment {
        transaction.liveReservation.attachment
    }

    package var isDirty: Bool {
        transaction.isDirty
    }

    package var pendingAttachment: _GiftUIObservationAttachment? {
        transaction.pendingReservation?.attachment
    }

    package mutating func beginReplacement(
        executionPhase: ExecutionPhase,
        isCompatible: Bool,
        candidateAlreadyOwned: Bool,
        registrationCapacityAvailable: Bool,
        replacementStagingAvailable: Bool,
        slot: UInt16,
        candidateGeneration: ObservableTargetGeneration
    ) -> ObservableStateError? {
        var allocator = ObservableStateAttachmentGenerationAllocator(
            nextGeneration: candidateGeneration.rawValue
        )
        return transaction.beginReplacement(
            executionPhase: executionPhase,
            isCompatible: isCompatible,
            candidateAlreadyOwned: candidateAlreadyOwned,
            registrationCapacityAvailable: registrationCapacityAvailable,
            replacementStagingAvailable: replacementStagingAvailable,
            slot: slot,
            allocator: &allocator
        )
    }

    package mutating func acceptCandidateReport(
        _ attachment: _GiftUIObservationAttachment
    ) -> _GiftUIObservableChangeReportOutcome {
        let failure = transaction.acceptCandidateReport(attachment)
        return failure == .staleAttachment ? .staleAttachment : .invariantViolation
    }

    package mutating func acceptAttachmentReturn(
        _ returned: _GiftUIObservationAttachment?
    ) -> ObservableStateError? {
        transaction.acceptAttachmentReturn(returned)
    }

    package mutating func commit()
        -> ObservableStateReplacementBridgeCommitResult
    {
        switch transaction.commit() {
        case .success(let commit):
            return .success(
                ObservableStateReplacementBridgeCommit(
                    formerAttachment: commit.formerAttachment,
                    activeAttachment: commit.activeReservation.attachment,
                    targetGeneration: commit.activeReservation.targetGeneration
                )
            )
        case .failure(let failure):
            return .failure(failure)
        }
    }

    package mutating func discardCandidate() -> _GiftUIObservationAttachment? {
        transaction.discardCandidate()
    }

    package mutating func acceptLiveReport(
        _ attachment: _GiftUIObservationAttachment,
        executionPhase: ExecutionPhase
    ) -> _GiftUIObservableChangeReportOutcome {
        transaction.acceptLiveReport(
            attachment,
            executionPhase: executionPhase
        )
    }

    package mutating func clearDirtyAfterPublication() {
        transaction.clearDirtyAfterPublication()
    }

    package mutating func retireLive() -> ObservableStateError? {
        transaction.retireLive()
    }
}
