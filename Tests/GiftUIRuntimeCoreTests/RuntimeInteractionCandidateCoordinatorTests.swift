import GiftUI
import GiftUIExecution
import GiftUIInteraction
import GiftUIObservableState
import Testing

@testable import GiftUIRuntimeCore

private let interactionBounds = Rect(
    origin: Point(x: 0, y: 0),
    size: Size(width: 20, height: 10)!
)!

private enum CandidateEvent: Equatable {
    case began
    case appended(UInt16, UInt16, UInt32)
    case assigned(UInt16, UInt32)
    case finished
    case discarded
}

private struct CandidateOccurrenceView: RuntimeInteractionOccurrenceView {
    let occurrences: [RuntimeInteractionOccurrence<UInt16>]

    var interactionOccurrenceCount: UInt16 { UInt16(occurrences.count) }

    func interactionOccurrence(
        at index: UInt16
    ) -> RuntimeInteractionOccurrence<UInt16>? {
        guard Int(index) < occurrences.count else { return nil }
        return occurrences[Int(index)]
    }
}

private struct CandidateGenerationSource: RuntimeActionGenerationSource {
    var values: [UInt16: ActionGeneration]
    private(set) var resolutions: [Bool] = []

    mutating func generation(for identity: UInt16) -> ActionGeneration? {
        values[identity]
    }

    mutating func resolveCandidate(committed: Bool) {
        resolutions.append(committed)
    }
}

private struct CandidateInteraction: InteractionCandidateBuilder {
    var appendResults: [InteractionCandidateAppendResult]
    private(set) var events: [CandidateEvent] = []

    mutating func beginCandidate(limits: InteractionLimits) -> InteractionError? {
        _ = limits
        events.append(.began)
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
        #expect(bounds == interactionBounds)
        #expect(clip == interactionBounds)
        #expect(isEnabled)
        #expect(paintOrder < 2)
        events.append(.appended(identity, action.code, targetGeneration.rawValue))
        return appendResults.removeFirst()
    }

    mutating func assignGeneration(
        _ generation: ActionGeneration,
        to identity: UInt16
    ) -> InteractionError? {
        events.append(.assigned(identity, generation.rawValue))
        return nil
    }

    mutating func finishCandidate() -> InteractionError? {
        events.append(.finished)
        return nil
    }

    mutating func resolveCandidate(
        _ disposition: InteractionCandidateDisposition
    ) {
        if case .discard = disposition { events.append(.discarded) }
    }
}

private final class CandidateObservable:
    ObservableStateReconciler, ObservableStateTargetView
{
    var publishableGeneration: ObservableTargetGeneration?
    private(set) var targetReadCount = 0
    private(set) var discardCount = 0

    init(publishableGeneration: ObservableTargetGeneration?) {
        self.publishableGeneration = publishableGeneration
    }

    func beginCandidate() -> ObservableStateResult {
        .success(.candidateStarted)
    }

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
        if disposition == .discard {
            discardCount += 1
            return .success(.candidateDiscarded)
        }
        return .success(.associationsCommitted)
    }

    func targetGeneration(
        structuralIdentity: UInt16,
        declarationOrdinal: UInt16
    ) -> ObservableTargetGeneration? {
        _ = structuralIdentity
        _ = declarationOrdinal
        return nil
    }

    func publishableTargetGeneration(
        structuralIdentity: UInt16,
        declarationOrdinal: UInt16
    ) -> ObservableTargetGeneration? {
        #expect(structuralIdentity == 90)
        #expect(declarationOrdinal == 0)
        targetReadCount += 1
        return publishableGeneration
    }
}

private func occurrence(
    identity: UInt16,
    paintOrder: UInt16,
    action: UInt16
) -> RuntimeInteractionOccurrence<UInt16> {
    RuntimeInteractionOccurrence(
        identity: identity,
        isEnabled: true,
        bounds: interactionBounds,
        clip: interactionBounds,
        paintOrder: paintOrder,
        action: BoundedApplicationAction(code: action)
    )
}

@Test
func candidateBuildBindsOnePublishableGenerationBeforeEveryAppend() {
    let occurrences = CandidateOccurrenceView(
        occurrences: [
            occurrence(identity: 1, paintOrder: 0, action: 3),
            occurrence(identity: 2, paintOrder: 1, action: 5),
        ]
    )
    var interaction = CandidateInteraction(
        appendResults: [.requiresGeneration, .preserved]
    )
    var observable = CandidateObservable(
        publishableGeneration: ObservableTargetGeneration(rawValue: 44)
    )
    var generations = CandidateGenerationSource(
        values: [1: ActionGeneration(rawValue: 70)]
    )

    let result = RuntimeInteractionCandidateCoordinator.build(
        occurrences: occurrences,
        limits: InteractionLimits(maximumActions: 2, maximumHitRegions: 2)!,
        rootIdentity: 90,
        rootStateOrdinal: 0,
        interaction: &interaction,
        observable: &observable,
        generations: &generations
    )

    #expect(result == .ready)
    #expect(observable.targetReadCount == 1)
    #expect(observable.discardCount == 0)
    #expect(
        interaction.events == [
            .began,
            .appended(1, 3, 44),
            .assigned(1, 70),
            .appended(2, 5, 44),
            .finished,
        ]
    )
}

@Test
func missingPublishableGenerationDiscardsBothCandidatesExactlyOnce() {
    let occurrences = CandidateOccurrenceView(
        occurrences: [occurrence(identity: 1, paintOrder: 0, action: 3)]
    )
    var interaction = CandidateInteraction(appendResults: [.requiresGeneration])
    var observable = CandidateObservable(publishableGeneration: nil)
    var generations = CandidateGenerationSource(values: [:])

    let result = RuntimeInteractionCandidateCoordinator.build(
        occurrences: occurrences,
        limits: InteractionLimits(maximumActions: 1, maximumHitRegions: 1)!,
        rootIdentity: 90,
        rootStateOrdinal: 0,
        interaction: &interaction,
        observable: &observable,
        generations: &generations
    )

    #expect(result == .ownerFailure(.interaction(.missingModelTarget)))
    #expect(interaction.events == [.began, .discarded])
    #expect(observable.targetReadCount == 1)
    #expect(observable.discardCount == 1)
}

@Test
func changedPublishableGenerationIsNeverReplacedWithFormerLiveValue() {
    let occurrences = CandidateOccurrenceView(
        occurrences: [occurrence(identity: 1, paintOrder: 0, action: 3)]
    )
    var interaction = CandidateInteraction(appendResults: [.requiresGeneration])
    var observable = CandidateObservable(
        publishableGeneration: ObservableTargetGeneration(rawValue: 92)
    )
    var generations = CandidateGenerationSource(
        values: [1: ActionGeneration(rawValue: 8)]
    )

    #expect(
        RuntimeInteractionCandidateCoordinator.build(
            occurrences: occurrences,
            limits: InteractionLimits(maximumActions: 1, maximumHitRegions: 1)!,
            rootIdentity: 90,
            rootStateOrdinal: 0,
            interaction: &interaction,
            observable: &observable,
            generations: &generations
        ) == .ready
    )
    #expect(interaction.events.contains(.appended(1, 3, 92)))
    #expect(!interaction.events.contains(.appended(1, 3, 91)))
}
