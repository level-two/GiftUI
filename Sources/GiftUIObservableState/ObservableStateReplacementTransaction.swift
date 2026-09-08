import GiftUI
import GiftUIExecution

struct ObservableStateReplacementCommit: Equatable, Sendable {
    let formerAttachment: _GiftUIObservationAttachment
    let activeReservation: ObservableStateAttachmentReservation
}

enum ObservableStateReplacementCommitResult: Equatable, Sendable {
    case success(ObservableStateReplacementCommit)
    case failure(ObservableStateError)
}

struct ObservableStateReplacementTransaction: Equatable, Sendable {
    private enum Phase: UInt8, Equatable, Sendable {
        case idle = 0
        case attaching = 1
        case ready = 2
        case failed = 3
    }

    private(set) var liveReservation: ObservableStateAttachmentReservation
    private(set) var isDirty: Bool
    private var liveRegistration: ObservableStateRegistrationLifecycle
    private var candidateReservation: ObservableStateAttachmentReservation?
    private var candidateRegistration = ObservableStateRegistrationLifecycle()
    private var firstFailure: ObservableStateError?
    private var phase: Phase = .idle

    var pendingReservation: ObservableStateAttachmentReservation? {
        candidateReservation
    }

    init(
        liveReservation: ObservableStateAttachmentReservation,
        isDirty: Bool
    ) {
        self.liveReservation = liveReservation
        self.isDirty = isDirty
        liveRegistration = ObservableStateRegistrationLifecycle(
            activeAttachment: liveReservation.attachment
        )
    }

    mutating func beginReplacement(
        executionPhase: ExecutionPhase,
        isCompatible: Bool,
        candidateAlreadyOwned: Bool,
        registrationCapacityAvailable: Bool,
        replacementStagingAvailable: Bool,
        slot: UInt16,
        allocator: inout ObservableStateAttachmentGenerationAllocator
    ) -> ObservableStateError? {
        guard phase == .idle else { return .reentrancyViolation }
        guard executionPhase == .mutating else {
            return .invalidPhaseContained
        }
        guard isCompatible else { return .incompatibleAssociation }
        guard !candidateAlreadyOwned else { return .duplicateOwner }

        let allocation = allocator.reserve(slot: slot)
        guard case .success(let reservation) = allocation else {
            return .registrationGenerationExhausted
        }
        guard registrationCapacityAvailable else {
            return .registrationCapacityExhausted
        }
        guard replacementStagingAvailable else {
            return .replacementStagingCapacityExhausted
        }

        candidateReservation = reservation
        candidateRegistration = ObservableStateRegistrationLifecycle()
        guard
            candidateRegistration.beginAttachment(reservation.attachment)
                == nil
        else {
            candidateReservation = nil
            return .invariantViolation
        }
        firstFailure = nil
        phase = .attaching
        return nil
    }

    mutating func acceptCandidateReport(
        _ attachment: _GiftUIObservationAttachment
    ) -> ObservableStateError {
        guard phase == .attaching else {
            recordFailure(.staleAttachment)
            return .staleAttachment
        }
        let failure =
            candidateRegistration.acceptReport(attachment)
            ?? .invariantViolation
        recordFailure(failure)
        return failure
    }

    mutating func acceptAttachmentReturn(
        _ returned: _GiftUIObservationAttachment?
    ) -> ObservableStateError? {
        guard phase == .attaching else {
            recordFailure(.invariantViolation)
            return .invariantViolation
        }
        if let failure = candidateRegistration.acceptAttachmentReturn(returned) {
            recordFailure(failure)
            phase = .failed
            return firstFailure
        }
        phase = .ready
        return nil
    }

    mutating func commit() -> ObservableStateReplacementCommitResult {
        if let firstFailure {
            return .failure(firstFailure)
        }
        guard phase == .ready, let candidateReservation else {
            return .failure(.invariantViolation)
        }

        let formerAttachment = liveReservation.attachment
        if let failure = liveRegistration.retire(
            attachment: formerAttachment
        ) {
            recordFailure(failure)
            phase = .failed
            return .failure(firstFailure ?? failure)
        }

        liveReservation = candidateReservation
        liveRegistration = candidateRegistration
        isDirty = true
        resetCandidate()
        return .success(
            ObservableStateReplacementCommit(
                formerAttachment: formerAttachment,
                activeReservation: liveReservation
            )
        )
    }

    mutating func discardCandidate() -> _GiftUIObservationAttachment? {
        let attachment = candidateReservation?.attachment
        resetCandidate()
        return attachment
    }

    mutating func acceptLiveReport(
        _ attachment: _GiftUIObservationAttachment
    ) -> ObservableStateError? {
        liveRegistration.acceptReport(attachment)
    }

    private mutating func recordFailure(_ failure: ObservableStateError) {
        guard firstFailure == nil else { return }
        firstFailure = failure
    }

    private mutating func resetCandidate() {
        candidateReservation = nil
        candidateRegistration = ObservableStateRegistrationLifecycle()
        firstFailure = nil
        phase = .idle
    }
}
