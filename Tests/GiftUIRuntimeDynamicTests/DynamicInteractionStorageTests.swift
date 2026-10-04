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

@Test(
    "Dynamic independently undersized interaction stores reject before publication",
    arguments: 0 ..< 5)
func dynamicUnequalInteractionStoreCapacity(store: Int) {
    let capacities: [UInt16] = (0 ..< 5).map { $0 == store ? 1 : 2 }
    var state = DynamicInteractionState<UInt16>(
        candidateRecords: DynamicInteractionCandidateStorage(capacity: capacities[0]),
        candidateHitRegions: DynamicInteractionHitStorage(capacity: capacities[1]),
        candidateCommittedRecords: DynamicInteractionCommittedStorage(capacity: capacities[2]),
        committedRecords: DynamicInteractionCommittedStorage(capacity: capacities[3]),
        committedHitRegions: DynamicInteractionHitStorage(capacity: capacities[4])
    )
    let result = state.beginCandidate(
        limits: InteractionLimits(maximumActions: 2, maximumHitRegions: 2)!)
    if store == 2 {
        #expect(result == nil)
        for identity: UInt16 in 1 ... 2 {
            #expect(
                append(identity: identity, paintOrder: identity - 1, to: &state)
                    == .requiresGeneration)
            #expect(
                state.assignGeneration(ActionGeneration(rawValue: UInt32(identity)), to: identity)
                    == nil)
        }
        #expect(state.finishCandidate() == .capacityExhausted)
        state.resolveCandidate(.commit(PresentationRevision(rawValue: 1)))
        state.resolveCandidate(.discard)
    } else {
        #expect(result == .capacityExhausted)
    }
    #expect(state.committedRecordCount == 0)
    #expect(state.committedHitRegionCount == 0)
    #expect(state.committedRevision == nil)
    #expect(
        state.beginCandidate(limits: InteractionLimits(maximumActions: 1, maximumHitRegions: 1)!)
            == nil)
    #expect(append(identity: 7, paintOrder: 0, to: &state) == .requiresGeneration)
    #expect(state.assignGeneration(ActionGeneration(rawValue: 9), to: 7) == nil)
    #expect(state.finishCandidate() == nil)
    state.resolveCandidate(.commit(PresentationRevision(rawValue: 4)))
    #expect(state.committedRecord(at: 0)?.identity == 7)
}
