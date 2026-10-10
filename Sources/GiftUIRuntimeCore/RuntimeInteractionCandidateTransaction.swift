import GiftUI
import GiftUIExecution
import GiftUIInteraction
import GiftUIObservableState

package protocol RuntimeInteractionCaptureCancellation {
    mutating func cancelAllInteractionCaptures()
}

extension RuntimeInteractionCandidateTransaction {
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

}
