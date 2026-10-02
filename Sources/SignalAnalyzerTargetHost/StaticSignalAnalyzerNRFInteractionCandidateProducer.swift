import GiftUIExecution
import GiftUIInteraction
import GiftUIRuntimeCore
import GiftUIRuntimeStatic

package enum StaticSignalAnalyzerNRFInteractionCandidateResult: Equatable, Sendable {
    case ready
    case interaction(InteractionError)
    case identityExhausted
}

/// Builds the six generated action records against the currently bound
/// observable target. The caller resolves the ready candidate after offer.
package enum StaticSignalAnalyzerNRFInteractionCandidateProducer {
    package static func build(
        occurrences: borrowing StaticSignalAnalyzerNRFInteractionOccurrences,
        targetGeneration: ObservableTargetGeneration,
        limits: InteractionLimits,
        interaction: inout StaticInteractionState<UInt32>,
        generations: inout RuntimeActionGenerationAllocator<UInt32>
    ) -> StaticSignalAnalyzerNRFInteractionCandidateResult {
        var target = StaticSignalAnalyzerNRFInteractionTargetProjection(
            generation: targetGeneration)
        switch RuntimeInteractionCandidateCoordinator.build(
            occurrences: occurrences, limits: limits, rootIdentity: 0, rootStateOrdinal: 0,
            interaction: &interaction, observable: &target, generations: &generations)
        {
        case .ready: return .ready
        case .ownerFailure(.interaction(let error)): return .interaction(error)
        case .executionFailure(.identityExhausted): return .identityExhausted
        default: return .interaction(.invariantViolation)
        }
    }
}
