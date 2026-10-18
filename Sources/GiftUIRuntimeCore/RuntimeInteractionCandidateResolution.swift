import GiftUI
import GiftUIExecution
import GiftUIInteraction

package protocol RuntimeActionGenerationSource {
    associatedtype Identity: Equatable & Sendable

    mutating func generation(for identity: Identity) -> ActionGeneration?
    mutating func resolveCandidate(committed: Bool)
}

@usableFromInline
package struct RuntimeActionGenerationAllocator<Identity>: RuntimeActionGenerationSource
where Identity: Equatable & Sendable {
    private var allocator: ActionGenerationAllocator
    @usableFromInline
    internal var pendingReservationCount: UInt32
    @usableFromInline
    package internal(set) var committedReservationCount: UInt32
    @usableFromInline
    package internal(set) var retiredReservationCount: UInt32

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

    @inlinable
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

    @inlinable
    internal func adding(_ count: UInt32, to total: UInt32) -> UInt32 {
        let next = total.addingReportingOverflow(count)
        return next.overflow ? UInt32.max : next.partialValue
    }
}

package enum RuntimeInteractionCandidateResolution: Equatable, Sendable {
    case committed(PresentationRevision)
    case discarded
}

package enum RuntimeInteractionCandidateTransaction {
    package static func resolve<Interaction, Generations>(
        offer: FrameOfferResult,
        presentationRevision: PresentationRevision,
        interaction: inout Interaction,
        generations: inout Generations
    ) -> RuntimeInteractionCandidateResolution
    where
        Interaction: InteractionCandidateBuilder & ~Copyable & ~Escapable,
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
