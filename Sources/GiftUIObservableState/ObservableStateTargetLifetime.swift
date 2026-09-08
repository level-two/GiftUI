import GiftUI
import GiftUIExecution

protocol ObservableStateInteractionCandidateDiscarder {
    mutating func discardInteractionCandidate()
}

struct ObservableStateTargetLifetimeCleanup: Equatable, Sendable {
    let attachmentToDetach: _GiftUIObservationAttachment?
    let retiredGeneration: ObservableTargetGeneration?
}

enum ObservableStateTargetLifetimeFinishResult: Equatable, Sendable {
    case success(ObservableStateTargetLifetimeCleanup)
    case failure(ObservableStateError)
}

struct ObservableStateTargetLifetime<StructuralIdentity>: Equatable, Sendable
where StructuralIdentity: Equatable & Sendable {
    private enum Encounter: Equatable, Sendable {
        case none
        case preserved
        case candidateOnly
    }

    private var lookup: ObservableStateTargetLookupSlot<StructuralIdentity>
    private var liveReservation: ObservableStateAttachmentReservation?
    private var candidateReservation: ObservableStateAttachmentReservation?
    private var encounter: Encounter = .none
    private var isCandidateActive = false

    init() {
        lookup = ObservableStateTargetLookupSlot()
        liveReservation = nil
    }

    init(
        liveIdentity: StructuralIdentity,
        ordinal: UInt16,
        reservation: ObservableStateAttachmentReservation
    ) {
        lookup = ObservableStateTargetLookupSlot(
            liveIdentity: liveIdentity,
            ordinal: ordinal,
            generation: reservation.targetGeneration
        )
        liveReservation = reservation
    }

    mutating func beginCandidate() -> ObservableStateError? {
        guard !isCandidateActive else { return .reentrancyViolation }
        if let failure = lookup.beginCandidate() { return failure }
        candidateReservation = nil
        encounter = .none
        isCandidateActive = true
        return nil
    }

    mutating func recordPreservedEncounter(
        identity: StructuralIdentity,
        ordinal: UInt16
    ) -> ObservableStateResult {
        guard isCandidateActive else {
            return .failure(.invariantViolation)
        }
        let result = lookup.recordSuccessfulEncounter(
            identity: identity,
            ordinal: ordinal,
            candidateOnlyGeneration: nil
        )
        if result == .success(.preserved) { encounter = .preserved }
        return result
    }

    mutating func recordCandidateOnlyEncounter(
        identity: StructuralIdentity,
        ordinal: UInt16,
        reservation: ObservableStateAttachmentReservation
    ) -> ObservableStateResult {
        guard isCandidateActive else {
            return .failure(.invariantViolation)
        }
        let result = lookup.recordSuccessfulEncounter(
            identity: identity,
            ordinal: ordinal,
            candidateOnlyGeneration: reservation.targetGeneration
        )
        if result == .success(.materialized) {
            candidateReservation = reservation
            encounter = .candidateOnly
        }
        return result
    }

    borrowing func buildInteractionCandidate<Result>(
        _ body: (borrowing ObservableStateTargetLookupSlot<StructuralIdentity>) -> Result
    ) -> Result {
        body(lookup)
    }

    borrowing func targetGeneration(
        identity: StructuralIdentity,
        ordinal: UInt16
    ) -> ObservableTargetGeneration? {
        lookup.targetGeneration(
            structuralIdentity: identity,
            declarationOrdinal: ordinal
        )
    }

    mutating func finishCandidate<Discarder>(
        _ disposition: ObservableStateCandidateDisposition,
        interaction: inout Discarder
    ) -> ObservableStateTargetLifetimeFinishResult
    where Discarder: ObservableStateInteractionCandidateDiscarder {
        guard isCandidateActive else {
            return .failure(.invariantViolation)
        }

        let cleanup: ObservableStateTargetLifetimeCleanup
        switch disposition {
        case .discard:
            let retired = candidateReservation
            cleanup = ObservableStateTargetLifetimeCleanup(
                attachmentToDetach: retired?.attachment,
                retiredGeneration: retired?.targetGeneration
            )
            interaction.discardInteractionCandidate()
        case .publish:
            switch encounter {
            case .none:
                cleanup = ObservableStateTargetLifetimeCleanup(
                    attachmentToDetach: liveReservation?.attachment,
                    retiredGeneration: liveReservation?.targetGeneration
                )
                liveReservation = nil
            case .preserved:
                cleanup = ObservableStateTargetLifetimeCleanup(
                    attachmentToDetach: nil,
                    retiredGeneration: nil
                )
            case .candidateOnly:
                liveReservation = candidateReservation
                cleanup = ObservableStateTargetLifetimeCleanup(
                    attachmentToDetach: nil,
                    retiredGeneration: nil
                )
            }
        }

        if let failure = lookup.finishCandidate(disposition) {
            return .failure(failure)
        }
        candidateReservation = nil
        encounter = .none
        isCandidateActive = false
        return .success(cleanup)
    }
}
