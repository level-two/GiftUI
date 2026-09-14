import GiftUI
import GiftUIExecution
import GiftUIInteraction
import Testing

@testable import GiftUIRuntimeStatic

@Test func staticInteractionStorageUsesFixedSlotsAtExactLimits() {
    #expect(StaticInteractionCandidateStorage<UInt16>(capacity: 0) == nil)
    #expect(StaticInteractionCandidateStorage<UInt16>(capacity: 33) == nil)

    var state = StaticInteractionState<UInt16>(
        candidateRecords: StaticInteractionCandidateStorage(capacity: 2)!,
        candidateHitRegions: StaticInteractionHitStorage(capacity: 2)!,
        candidateCommittedRecords: StaticInteractionCommittedStorage(capacity: 2)!,
        committedRecords: StaticInteractionCommittedStorage(capacity: 2)!,
        committedHitRegions: StaticInteractionHitStorage(capacity: 2)!
    )
    let limits = InteractionLimits(maximumActions: 2, maximumHitRegions: 2)!
    #expect(state.beginCandidate(limits: limits) == nil)
    #expect(append(identity: 1, paintOrder: 0, to: &state) == .requiresGeneration)
    #expect(append(identity: 2, paintOrder: 1, to: &state) == .requiresGeneration)
    #expect(append(identity: 3, paintOrder: 2, to: &state) == .failure(.capacityExhausted))
}

@Test func staticInteractionStorageCommitsAndDispatchesFromInlineState() {
    var state = StaticInteractionState<UInt16>(
        candidateRecords: StaticInteractionCandidateStorage(capacity: 1)!,
        candidateHitRegions: StaticInteractionHitStorage(capacity: 1)!,
        candidateCommittedRecords: StaticInteractionCommittedStorage(capacity: 1)!,
        committedRecords: StaticInteractionCommittedStorage(capacity: 1)!,
        committedHitRegions: StaticInteractionHitStorage(capacity: 1)!
    )
    let limits = InteractionLimits(maximumActions: 1, maximumHitRegions: 1)!
    #expect(state.beginCandidate(limits: limits) == nil)
    #expect(append(identity: 7, paintOrder: 0, to: &state) == .requiresGeneration)
    #expect(state.assignGeneration(ActionGeneration(rawValue: 9), to: 7) == nil)
    #expect(state.finishCandidate() == nil)
    state.resolveCandidate(.commit(PresentationRevision(rawValue: 4)))
    #expect(state.committedRecord(at: 0)?.identity == 7)
    #expect(
        state.resolveDown(at: Point(x: 2, y: 2))
            == .captured(
                CapturedAction(identity: 7, generation: ActionGeneration(rawValue: 9))
            )
    )
}

private func append(
    identity: UInt16,
    paintOrder: UInt16,
    to state: inout StaticInteractionState<UInt16>
) -> InteractionCandidateAppendResult {
    state.append(
        identity: identity,
        isEnabled: true,
        bounds: Rect(
            origin: Point(x: 0, y: 0),
            size: Size(width: 8, height: 8)!
        )!,
        clip: Rect(
            origin: Point(x: 0, y: 0),
            size: Size(width: 8, height: 8)!
        )!,
        paintOrder: paintOrder,
        action: BoundedApplicationAction(code: 1),
        targetGeneration: ObservableTargetGeneration(rawValue: 1)
    )
}
