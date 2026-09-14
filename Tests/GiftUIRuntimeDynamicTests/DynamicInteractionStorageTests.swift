import GiftUI
import GiftUIExecution
import GiftUIInteraction
import Testing

@testable import GiftUIRuntimeDynamic

@Test func dynamicInteractionStorageAcceptsExactLimitsAndRejectsFirstExcess() {
    var state = DynamicInteractionState<UInt16>(
        candidateRecords: DynamicInteractionCandidateStorage(capacity: 2),
        candidateHitRegions: DynamicInteractionHitStorage(capacity: 2),
        candidateCommittedRecords: DynamicInteractionCommittedStorage(capacity: 2),
        committedRecords: DynamicInteractionCommittedStorage(capacity: 2),
        committedHitRegions: DynamicInteractionHitStorage(capacity: 2)
    )
    let limits = InteractionLimits(maximumActions: 2, maximumHitRegions: 2)!
    #expect(state.beginCandidate(limits: limits) == nil)
    #expect(append(identity: 1, paintOrder: 0, to: &state) == .requiresGeneration)
    #expect(append(identity: 2, paintOrder: 1, to: &state) == .requiresGeneration)
    #expect(append(identity: 3, paintOrder: 2, to: &state) == .failure(.capacityExhausted))
}

@Test func dynamicInteractionStorageCommitsAndResetsWithinItsBound() {
    var state = DynamicInteractionState<UInt16>(
        candidateRecords: DynamicInteractionCandidateStorage(capacity: 1),
        candidateHitRegions: DynamicInteractionHitStorage(capacity: 1),
        candidateCommittedRecords: DynamicInteractionCommittedStorage(capacity: 1),
        committedRecords: DynamicInteractionCommittedStorage(capacity: 1),
        committedHitRegions: DynamicInteractionHitStorage(capacity: 1)
    )
    let limits = InteractionLimits(maximumActions: 1, maximumHitRegions: 1)!
    #expect(state.beginCandidate(limits: limits) == nil)
    #expect(append(identity: 7, paintOrder: 0, to: &state) == .requiresGeneration)
    #expect(state.assignGeneration(ActionGeneration(rawValue: 9), to: 7) == nil)
    #expect(state.finishCandidate() == nil)
    state.resolveCandidate(.commit(PresentationRevision(rawValue: 4)))
    #expect(state.committedRecordCount == 1)
    #expect(state.committedHitRegionCount == 1)
    #expect(state.committedRecord(at: 0)?.identity == 7)

    #expect(state.beginCandidate(limits: limits) == nil)
    state.resolveCandidate(.discard)
    #expect(state.committedRecordCount == 1)
}

private func append(
    identity: UInt16,
    paintOrder: UInt16,
    to state: inout DynamicInteractionState<UInt16>
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
