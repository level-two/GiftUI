import GiftUI
import GiftUIExecution
import GiftUIInteraction
import GiftUIObservableState

package protocol RuntimeInteractionCaptureCancellation {
    mutating func cancelAllInteractionCaptures()
}

package struct RuntimeActionGenerationAllocator<Identity>: RuntimeActionGenerationSource
where Identity: Equatable & Sendable {
    private var allocator: ActionGenerationAllocator
    private var pendingReservationCount: UInt32
    package private(set) var committedReservationCount: UInt32
    package private(set) var retiredReservationCount: UInt32

    package init() {
        allocator = ActionGenerationAllocator()
        pendingReservationCount = 0
        committedReservationCount = 0
        retiredReservationCount = 0
    }

    package mutating func generation(for identity: Identity) -> ActionGeneration? {
        _ = identity
        guard let generation = allocator.reserve() else { return nil }
        let next = pendingReservationCount.addingReportingOverflow(1)
        guard !next.overflow else { return nil }
        pendingReservationCount = next.partialValue
        return generation
    }

    package mutating func resolveCandidate(committed: Bool) {
        if committed {
            committedReservationCount = adding(
                pendingReservationCount,
                to: committedReservationCount
            )
        } else {
            retiredReservationCount = adding(
                pendingReservationCount,
                to: retiredReservationCount
            )
        }
        pendingReservationCount = 0
    }

    private func adding(_ count: UInt32, to total: UInt32) -> UInt32 {
        let next = total.addingReportingOverflow(count)
        return next.overflow ? UInt32.max : next.partialValue
    }
}

package enum RuntimeInteractionCandidateResolution: Equatable, Sendable {
    case committed(PresentationRevision)
    case discarded
}

package enum RuntimeInteractionCandidateTransaction {
    package static func build<
        Occurrences, Interaction, Observable, Generations, Captures
    >(
        occurrences: borrowing Occurrences,
        limits: InteractionLimits,
        rootIdentity: Occurrences.Identity,
        rootStateOrdinal: UInt16,
        interaction: inout Interaction,
        observable: inout Observable,
        generations: inout Generations,
        captures: inout Captures
    ) -> RuntimeInteractionCandidateBuildResult
    where
        Occurrences: RuntimeInteractionOccurrenceView,
        Interaction: InteractionCandidateBuilder,
        Observable: ObservableStateReconciler & ObservableStateTargetView,
        Generations: RuntimeActionGenerationSource,
        Captures: RuntimeInteractionCaptureCancellation,
        Occurrences.Identity == Interaction.Identity,
        Occurrences.Identity == Observable.StructuralIdentity,
        Occurrences.Identity == Generations.Identity
    {
        let result = RuntimeInteractionCandidateCoordinator.build(
            occurrences: occurrences,
            limits: limits,
            rootIdentity: rootIdentity,
            rootStateOrdinal: rootStateOrdinal,
            interaction: &interaction,
            observable: &observable,
            generations: &generations
        )
        if result == .executionFailure(.identityExhausted) {
            captures.cancelAllInteractionCaptures()
        }
        return result
    }

    package static func resolve<Interaction, Generations>(
        offer: FrameOfferResult,
        presentationRevision: PresentationRevision,
        interaction: inout Interaction,
        generations: inout Generations
    ) -> RuntimeInteractionCandidateResolution
    where
        Interaction: InteractionCandidateBuilder,
        Generations: RuntimeActionGenerationSource,
        Interaction.Identity == Generations.Identity
    {
        guard offer.disposition == .accepted else {
            interaction.resolveCandidate(.discard)
            generations.resolveCandidate(committed: false)
            return .discarded
        }
        interaction.resolveCandidate(.commit(presentationRevision))
        generations.resolveCandidate(committed: true)
        return .committed(presentationRevision)
    }
}
