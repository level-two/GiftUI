import GiftUI
import GiftUIExecution
import GiftUIInteraction
import GiftUIObservableState

package struct RuntimeInteractionOccurrence<Identity>: Equatable, Sendable
where Identity: Equatable & Sendable {
    package let identity: Identity
    package let isEnabled: Bool
    package let bounds: Rect
    package let clip: Rect
    package let paintOrder: UInt16
    package let action: BoundedApplicationAction

    package init(
        identity: Identity,
        isEnabled: Bool,
        bounds: Rect,
        clip: Rect,
        paintOrder: UInt16,
        action: BoundedApplicationAction
    ) {
        self.identity = identity
        self.isEnabled = isEnabled
        self.bounds = bounds
        self.clip = clip
        self.paintOrder = paintOrder
        self.action = action
    }
}

package protocol RuntimeInteractionOccurrenceView {
    associatedtype Identity: Equatable & Sendable

    var interactionOccurrenceCount: UInt16 { get }
    borrowing func interactionOccurrence(
        at index: UInt16
    ) -> RuntimeInteractionOccurrence<Identity>?
}

package protocol RuntimeActionGenerationSource {
    associatedtype Identity: Equatable & Sendable

    mutating func generation(for identity: Identity) -> ActionGeneration?
}

package enum RuntimeInteractionCandidateBuildResult: Equatable, Sendable {
    case ready
    case ownerFailure(RuntimeOwnerFailure)
    case executionFailure(ExecutionError)
}

package enum RuntimeInteractionCandidateCoordinator {
    package static func build<Occurrences, Interaction, Observable, Generations>(
        occurrences: borrowing Occurrences,
        limits: InteractionLimits,
        rootIdentity: Occurrences.Identity,
        rootStateOrdinal: UInt16,
        interaction: inout Interaction,
        observable: inout Observable,
        generations: inout Generations
    ) -> RuntimeInteractionCandidateBuildResult
    where
        Occurrences: RuntimeInteractionOccurrenceView,
        Interaction: InteractionCandidateBuilder,
        Observable: ObservableStateReconciler & ObservableStateTargetView,
        Generations: RuntimeActionGenerationSource,
        Occurrences.Identity == Interaction.Identity,
        Occurrences.Identity == Observable.StructuralIdentity,
        Occurrences.Identity == Generations.Identity
    {
        if let error = interaction.beginCandidate(limits: limits) {
            discardObservableCandidate(&observable)
            return .ownerFailure(.interaction(error))
        }

        guard
            let targetGeneration = observable.publishableTargetGeneration(
                structuralIdentity: rootIdentity,
                declarationOrdinal: rootStateOrdinal
            )
        else {
            discardCandidates(interaction: &interaction, observable: &observable)
            return .ownerFailure(.interaction(.missingModelTarget))
        }

        var index: UInt16 = 0
        while index < occurrences.interactionOccurrenceCount {
            guard let occurrence = occurrences.interactionOccurrence(at: index) else {
                discardCandidates(interaction: &interaction, observable: &observable)
                return .ownerFailure(.interaction(.invalidIdentity))
            }
            switch interaction.append(
                identity: occurrence.identity,
                isEnabled: occurrence.isEnabled,
                bounds: occurrence.bounds,
                clip: occurrence.clip,
                paintOrder: occurrence.paintOrder,
                action: occurrence.action,
                targetGeneration: targetGeneration
            ) {
            case .preserved:
                break
            case .requiresGeneration:
                guard let generation = generations.generation(for: occurrence.identity) else {
                    discardCandidates(interaction: &interaction, observable: &observable)
                    return .executionFailure(.identityExhausted)
                }
                if let error = interaction.assignGeneration(
                    generation,
                    to: occurrence.identity
                ) {
                    discardCandidates(interaction: &interaction, observable: &observable)
                    return .ownerFailure(.interaction(error))
                }
            case .failure(let error):
                discardCandidates(interaction: &interaction, observable: &observable)
                return .ownerFailure(.interaction(error))
            }
            index += 1
        }

        if let error = interaction.finishCandidate() {
            discardCandidates(interaction: &interaction, observable: &observable)
            return .ownerFailure(.interaction(error))
        }
        return .ready
    }

    private static func discardCandidates<Interaction, Observable>(
        interaction: inout Interaction,
        observable: inout Observable
    )
    where
        Interaction: InteractionCandidateBuilder,
        Observable: ObservableStateReconciler
    {
        interaction.resolveCandidate(.discard)
        discardObservableCandidate(&observable)
    }

    private static func discardObservableCandidate<Observable>(
        _ observable: inout Observable
    ) where Observable: ObservableStateReconciler {
        _ = observable.finishCandidate(.discard)
    }
}
