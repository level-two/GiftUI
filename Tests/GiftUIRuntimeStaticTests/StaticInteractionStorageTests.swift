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

@Test func sixSlotInteractionPreservesCommittedRoutingAfterExcessCandidate() {
    #expect(StaticSixInteractionCandidateStorage<UInt16>(capacity: 0) == nil)
    #expect(StaticSixInteractionCandidateStorage<UInt16>(capacity: 7) == nil)
    #expect(StaticSixInteractionCommittedStorage<UInt16>(capacity: 7) == nil)
    #expect(StaticSixInteractionHitStorage<UInt16>(capacity: 7) == nil)
    #expect(
        MemoryLayout<StaticSixInteractionState<UInt16>>.stride
            < MemoryLayout<StaticInteractionState<UInt16>>.stride
    )
    var state = StaticSixInteractionState<UInt16>(
        candidateRecords: StaticSixInteractionCandidateStorage(capacity: 6)!,
        candidateHitRegions: StaticSixInteractionHitStorage(capacity: 6)!,
        candidateCommittedRecords: StaticSixInteractionCommittedStorage(capacity: 6)!,
        committedRecords: StaticSixInteractionCommittedStorage(capacity: 6)!,
        committedHitRegions: StaticSixInteractionHitStorage(capacity: 6)!
    )
    let limits = InteractionLimits(maximumActions: 6, maximumHitRegions: 6)!
    let bounds = Rect(origin: Point(x: 0, y: 0), size: Size(width: 8, height: 8)!)!
    #expect(state.beginCandidate(limits: limits) == nil)
    for identity: UInt16 in 1 ... 6 {
        #expect(
            state.append(
                identity: identity, isEnabled: true, bounds: bounds, clip: bounds,
                paintOrder: identity - 1, action: BoundedApplicationAction(code: 1),
                targetGeneration: ObservableTargetGeneration(rawValue: 1)
            ) == .requiresGeneration
        )
        #expect(
            state.assignGeneration(ActionGeneration(rawValue: UInt32(identity)), to: identity)
                == nil)
    }
    #expect(state.finishCandidate() == nil)
    state.resolveCandidate(.commit(PresentationRevision(rawValue: 4)))
    #expect(state.committedRecordCount == 6)
    #expect(state.beginCandidate(limits: limits) == nil)
    for identity: UInt16 in 11 ... 17 {
        let result = state.append(
            identity: identity, isEnabled: true, bounds: bounds, clip: bounds,
            paintOrder: identity - 11, action: BoundedApplicationAction(code: 2),
            targetGeneration: ObservableTargetGeneration(rawValue: 2)
        )
        #expect(result == (identity == 17 ? .failure(.capacityExhausted) : .requiresGeneration))
    }
    state.resolveCandidate(.discard)
    #expect(state.committedRevision == PresentationRevision(rawValue: 4))
    #expect(state.committedRecordCount == 6)
    #expect(
        state.resolveDown(at: Point(x: 2, y: 2))
            == .captured(CapturedAction(identity: 6, generation: ActionGeneration(rawValue: 6)))
    )
}

@Test(
    "Static independently undersized interaction stores reject before publication",
    arguments: 0 ..< 5)
func staticUnequalInteractionStoreCapacity(store: Int) {
    let capacities: [UInt16] = (0 ..< 5).map { $0 == store ? 1 : 2 }
    var state = StaticInteractionState<UInt16>(
        candidateRecords: StaticInteractionCandidateStorage(capacity: capacities[0])!,
        candidateHitRegions: StaticInteractionHitStorage(capacity: capacities[1])!,
        candidateCommittedRecords: StaticInteractionCommittedStorage(capacity: capacities[2])!,
        committedRecords: StaticInteractionCommittedStorage(capacity: capacities[3])!,
        committedHitRegions: StaticInteractionHitStorage(capacity: capacities[4])!
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
