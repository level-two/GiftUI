import GiftUI
import GiftUIExecution
import GiftUIInteraction
import GiftUIRuntimeCore
import GiftUIRuntimeStatic

/// Scoped access to the generated interaction and input fields while the
/// observable model is borrowed for presentation derivation. This value
/// cannot escape the owner's synchronous model-borrow callback.
package struct StaticSignalAnalyzerNRFPresentationCommitter: ~Copyable {
    private let targetGeneration: ObservableTargetGeneration
    private let interaction: UnsafeMutablePointer<StaticInteractionState<UInt32>>
    private let generations: UnsafeMutablePointer<RuntimeActionGenerationAllocator<UInt32>>
    private let input: UnsafeMutablePointer<StaticSignalAnalyzerNRFApplicationInputOwner>

    package init(
        targetGeneration: ObservableTargetGeneration,
        interaction: UnsafeMutablePointer<StaticInteractionState<UInt32>>,
        generations: UnsafeMutablePointer<RuntimeActionGenerationAllocator<UInt32>>,
        input: UnsafeMutablePointer<StaticSignalAnalyzerNRFApplicationInputOwner>
    ) {
        self.targetGeneration = targetGeneration
        self.interaction = interaction
        self.generations = generations
        self.input = input
    }

    package mutating func build(
        occurrences: borrowing StaticSignalAnalyzerNRFInteractionOccurrences,
        limits: InteractionLimits
    ) -> StaticSignalAnalyzerNRFInteractionCandidateResult {
        StaticSignalAnalyzerNRFInteractionCandidateProducer.build(
            occurrences: occurrences,
            targetGeneration: targetGeneration,
            limits: limits,
            interaction: &interaction.pointee,
            generations: &generations.pointee
        )
    }

    package mutating func resolve(
        offer: FrameOfferResult,
        presentationRevision: PresentationRevision
    ) -> RuntimeInteractionCandidateResolution {
        guard interaction.pointee.candidateIsReadyForOffer else {
            return .discarded
        }
        let resolution = RuntimeInteractionCandidateTransaction.resolve(
            offer: offer,
            presentationRevision: presentationRevision,
            interaction: &interaction.pointee,
            generations: &generations.pointee
        )
        if case .committed(let revision) = resolution {
            input.pointee.installPhysicalPresentation(rawValue: revision.rawValue)
        }
        return resolution
    }
}
