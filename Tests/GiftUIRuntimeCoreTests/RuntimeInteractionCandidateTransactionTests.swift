import GiftUI
import GiftUIExecution
import GiftUIInteraction
import GiftUIObservableState
import Testing

@testable import GiftUIRuntimeCore

private let transactionBounds = Rect(
    origin: Point(x: 0, y: 0),
    size: Size(width: 10, height: 10)!
)!

private struct TransactionOccurrenceView: RuntimeInteractionOccurrenceView {
    let values: [RuntimeInteractionOccurrence<UInt16>]

    var interactionOccurrenceCount: UInt16 { UInt16(values.count) }

    func interactionOccurrence(
        at index: UInt16
    ) -> RuntimeInteractionOccurrence<UInt16>? {
        guard Int(index) < values.count else { return nil }
        return values[Int(index)]
    }
}

private struct TransactionCaptureCancellation:
    RuntimeInteractionCaptureCancellation
{
    private(set) var cancellationCount = 0

    mutating func cancelAllInteractionCaptures() {
        cancellationCount += 1
    }
}

private final class TransactionObservable:
    ObservableStateReconciler, ObservableStateTargetView
{
    let generation: ObservableTargetGeneration
    private(set) var discardCount = 0

    init(generation: ObservableTargetGeneration) {
        self.generation = generation
    }

    func beginCandidate() -> ObservableStateResult { .success(.candidateStarted) }

    func encounter<Model: _GiftUIObservableReference>(
        structuralIdentity: UInt16,
        declarationOrdinal: UInt16,
        state: inout State<Model>
    ) -> ObservableStateResult {
        _ = structuralIdentity
        _ = declarationOrdinal
        _ = state
        return .success(.preserved)
    }

    func finishCandidate(
        _ disposition: ObservableStateCandidateDisposition
    ) -> ObservableStateResult {
        if disposition == .discard { discardCount += 1 }
        return .success(disposition == .discard ? .candidateDiscarded : .unchanged)
    }

    func targetGeneration(
        structuralIdentity: UInt16,
        declarationOrdinal: UInt16
    ) -> ObservableTargetGeneration? {
        _ = structuralIdentity
        _ = declarationOrdinal
        return generation
    }

    func publishableTargetGeneration(
        structuralIdentity: UInt16,
        declarationOrdinal: UInt16
    ) -> ObservableTargetGeneration? {
        _ = structuralIdentity
        _ = declarationOrdinal
        return generation
    }
}

private struct TransactionInteraction: InteractionCandidateBuilder {
    var appendResults: [InteractionCandidateAppendResult]
    private(set) var assigned: [ActionGeneration] = []
    private(set) var resolutions: [InteractionCandidateDisposition] = []

    mutating func beginCandidate(limits: InteractionLimits) -> InteractionError? {
        _ = limits
        return nil
    }

    mutating func append(
        identity: UInt16,
        isEnabled: Bool,
        bounds: Rect,
        clip: Rect,
        paintOrder: UInt16,
        action: BoundedApplicationAction,
        targetGeneration: ObservableTargetGeneration
    ) -> InteractionCandidateAppendResult {
        _ = identity
        _ = isEnabled
        _ = bounds
        _ = clip
        _ = paintOrder
        _ = action
        _ = targetGeneration
        return appendResults.removeFirst()
    }

    mutating func assignGeneration(
        _ generation: ActionGeneration,
        to identity: UInt16
    ) -> InteractionError? {
        _ = identity
        assigned.append(generation)
        return nil
    }

    mutating func finishCandidate() -> InteractionError? { nil }

    mutating func resolveCandidate(
        _ disposition: InteractionCandidateDisposition
    ) {
        resolutions.append(disposition)
    }
}

private struct ExhaustedGenerationSource: RuntimeActionGenerationSource {
    mutating func generation(for identity: UInt16) -> ActionGeneration? {
        _ = identity
        return nil
    }

    mutating func resolveCandidate(committed: Bool) {
        #expect(!committed)
    }
}

private func transactionOccurrence(
    identity: UInt16
) -> RuntimeInteractionOccurrence<UInt16> {
    RuntimeInteractionOccurrence(
        identity: identity,
        isEnabled: true,
        bounds: transactionBounds,
        clip: transactionBounds,
        paintOrder: identity - 1,
        action: BoundedApplicationAction(code: identity)
    )
}

@Test
func allocatorReservesOnlyReplacementsAndAcceptedOfferCommitsExactRevision() {
    let occurrences = TransactionOccurrenceView(
        values: [transactionOccurrence(identity: 1), transactionOccurrence(identity: 2)]
    )
    var interaction = TransactionInteraction(
        appendResults: [.preserved, .requiresGeneration]
    )
    var observable = TransactionObservable(
        generation: ObservableTargetGeneration(rawValue: 12)
    )
    var generations = RuntimeActionGenerationAllocator<UInt16>()
    var captures = TransactionCaptureCancellation()

    #expect(
        RuntimeInteractionCandidateTransaction.build(
            occurrences: occurrences,
            limits: InteractionLimits(maximumActions: 2, maximumHitRegions: 2)!,
            rootIdentity: 9,
            rootStateOrdinal: 0,
            interaction: &interaction,
            observable: &observable,
            generations: &generations,
            captures: &captures
        ) == .ready
    )
    #expect(interaction.assigned == [ActionGeneration(rawValue: 0)])
    #expect(captures.cancellationCount == 0)

    let offer = FrameOfferResult(disposition: .accepted, failure: nil)!
    let revision = PresentationRevision(rawValue: 33)
    #expect(
        RuntimeInteractionCandidateTransaction.resolve(
            offer: offer,
            presentationRevision: revision,
            interaction: &interaction,
            generations: &generations
        ) == .committed(revision)
    )
    #expect(interaction.resolutions == [.commit(revision)])
    #expect(generations.committedReservationCount == 1)
    #expect(generations.retiredReservationCount == 0)
}

@Test
func refusedOfferDiscardsAndPermanentlyRetiresCandidateGeneration() {
    let occurrences = TransactionOccurrenceView(
        values: [transactionOccurrence(identity: 1)]
    )
    var interaction = TransactionInteraction(appendResults: [.requiresGeneration])
    var observable = TransactionObservable(
        generation: ObservableTargetGeneration(rawValue: 12)
    )
    var generations = RuntimeActionGenerationAllocator<UInt16>()
    var captures = TransactionCaptureCancellation()

    #expect(
        RuntimeInteractionCandidateTransaction.build(
            occurrences: occurrences,
            limits: InteractionLimits(maximumActions: 1, maximumHitRegions: 1)!,
            rootIdentity: 9,
            rootStateOrdinal: 0,
            interaction: &interaction,
            observable: &observable,
            generations: &generations,
            captures: &captures
        ) == .ready
    )
    #expect(interaction.assigned == [ActionGeneration(rawValue: 0)])
    let refusal = FrameOfferResult(disposition: .backpressured, failure: nil)!
    #expect(
        RuntimeInteractionCandidateTransaction.resolve(
            offer: refusal,
            presentationRevision: PresentationRevision(rawValue: 30),
            interaction: &interaction,
            generations: &generations
        ) == .discarded
    )
    #expect(interaction.resolutions == [.discard])
    #expect(generations.retiredReservationCount == 1)

    interaction = TransactionInteraction(appendResults: [.requiresGeneration])
    #expect(
        RuntimeInteractionCandidateTransaction.build(
            occurrences: occurrences,
            limits: InteractionLimits(maximumActions: 1, maximumHitRegions: 1)!,
            rootIdentity: 9,
            rootStateOrdinal: 0,
            interaction: &interaction,
            observable: &observable,
            generations: &generations,
            captures: &captures
        ) == .ready
    )
    #expect(interaction.assigned == [ActionGeneration(rawValue: 1)])
}

@Test
func generationExhaustionDiscardsCandidatesAndCancelsAllCaptures() {
    let occurrences = TransactionOccurrenceView(
        values: [transactionOccurrence(identity: 1)]
    )
    var interaction = TransactionInteraction(appendResults: [.requiresGeneration])
    var observable = TransactionObservable(
        generation: ObservableTargetGeneration(rawValue: 12)
    )
    var generations = ExhaustedGenerationSource()
    var captures = TransactionCaptureCancellation()

    #expect(
        RuntimeInteractionCandidateTransaction.build(
            occurrences: occurrences,
            limits: InteractionLimits(maximumActions: 1, maximumHitRegions: 1)!,
            rootIdentity: 9,
            rootStateOrdinal: 0,
            interaction: &interaction,
            observable: &observable,
            generations: &generations,
            captures: &captures
        ) == .executionFailure(.identityExhausted)
    )
    #expect(interaction.resolutions == [.discard])
    #expect(observable.discardCount == 1)
    #expect(captures.cancellationCount == 1)
}
