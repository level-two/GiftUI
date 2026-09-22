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
        if let error = interaction.beginCandidate(limits: limits) {
            return .interaction(error)
        }
        var index: UInt16 = 0
        while index < occurrences.interactionOccurrenceCount {
            guard let occurrence = occurrences.interactionOccurrence(at: index) else {
                return fail(.invalidIdentity, interaction: &interaction, generations: &generations)
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
                    interaction.resolveCandidate(.discard)
                    generations.resolveCandidate(committed: false)
                    return .identityExhausted
                }
                if let error = interaction.assignGeneration(
                    generation, to: occurrence.identity
                ) {
                    return fail(error, interaction: &interaction, generations: &generations)
                }
            case .failure(let error):
                return fail(error, interaction: &interaction, generations: &generations)
            }
            index += 1
        }
        if let error = interaction.finishCandidate() {
            return fail(error, interaction: &interaction, generations: &generations)
        }
        return .ready
    }

    private static func fail(
        _ error: InteractionError,
        interaction: inout StaticInteractionState<UInt32>,
        generations: inout RuntimeActionGenerationAllocator<UInt32>
    ) -> StaticSignalAnalyzerNRFInteractionCandidateResult {
        interaction.resolveCandidate(.discard)
        generations.resolveCandidate(committed: false)
        return .interaction(error)
    }
}
