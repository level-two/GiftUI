import GiftUIExecution
import Testing

@testable import GiftUIObservableState

private let liveTarget = ObservableTargetGeneration(rawValue: 12)
private let candidateTarget = ObservableTargetGeneration(rawValue: 13)

@Test
func liveLookupRequiresTheCompleteExactKeyAndNeverMaterializes() {
    let empty = ObservableStateTargetLookupSlot<UInt16>()
    #expect(
        empty.targetGeneration(
            structuralIdentity: 4,
            declarationOrdinal: 2
        ) == nil
    )

    let live = ObservableStateTargetLookupSlot(
        liveIdentity: UInt16(4),
        ordinal: 2,
        generation: liveTarget
    )
    #expect(
        live.targetGeneration(
            structuralIdentity: 4,
            declarationOrdinal: 2
        ) == liveTarget
    )
    #expect(
        live.targetGeneration(
            structuralIdentity: 5,
            declarationOrdinal: 2
        ) == nil
    )
    #expect(
        live.targetGeneration(
            structuralIdentity: 4,
            declarationOrdinal: 3
        ) == nil
    )
    #expect(
        live.publishableTargetGeneration(
            structuralIdentity: 4,
            declarationOrdinal: 2
        ) == nil
    )
}

@Test
func preservedTargetIsPublishableOnlyAfterSuccessfulEncounter() {
    var lookup = ObservableStateTargetLookupSlot(
        liveIdentity: UInt16(8),
        ordinal: 0,
        generation: liveTarget
    )
    #expect(lookup.beginCandidate() == nil)
    #expect(
        lookup.publishableTargetGeneration(
            structuralIdentity: 8,
            declarationOrdinal: 0
        ) == nil
    )
    #expect(
        lookup.recordSuccessfulEncounter(
            identity: 8,
            ordinal: 0,
            candidateOnlyGeneration: nil
        ) == .success(.preserved)
    )
    #expect(
        lookup.publishableTargetGeneration(
            structuralIdentity: 8,
            declarationOrdinal: 0
        ) == liveTarget
    )
    #expect(lookup.finishCandidate(.discard) == nil)
    #expect(
        lookup.targetGeneration(
            structuralIdentity: 8,
            declarationOrdinal: 0
        ) == liveTarget
    )
    #expect(
        lookup.publishableTargetGeneration(
            structuralIdentity: 8,
            declarationOrdinal: 0
        ) == nil
    )
}

@Test
func candidateOnlyTargetBecomesLiveOnlyOnPublication() {
    var lookup = ObservableStateTargetLookupSlot<UInt16>()
    #expect(lookup.beginCandidate() == nil)
    #expect(
        lookup.recordSuccessfulEncounter(
            identity: 21,
            ordinal: 1,
            candidateOnlyGeneration: candidateTarget
        ) == .success(.materialized)
    )
    #expect(
        lookup.targetGeneration(
            structuralIdentity: 21,
            declarationOrdinal: 1
        ) == nil
    )
    #expect(
        lookup.publishableTargetGeneration(
            structuralIdentity: 21,
            declarationOrdinal: 1
        ) == candidateTarget
    )
    #expect(
        lookup.publishableTargetGeneration(
            structuralIdentity: 21,
            declarationOrdinal: 2
        ) == nil
    )

    #expect(lookup.finishCandidate(.publish) == nil)
    #expect(
        lookup.targetGeneration(
            structuralIdentity: 21,
            declarationOrdinal: 1
        ) == candidateTarget
    )
    #expect(
        lookup.publishableTargetGeneration(
            structuralIdentity: 21,
            declarationOrdinal: 1
        ) == nil
    )
}

@Test
func discardedCandidateNeverBecomesLiveAndWorkspaceIsReusable() {
    var lookup = ObservableStateTargetLookupSlot<UInt16>()
    #expect(lookup.beginCandidate() == nil)
    #expect(
        lookup.recordSuccessfulEncounter(
            identity: 34,
            ordinal: 3,
            candidateOnlyGeneration: candidateTarget
        ) == .success(.materialized)
    )
    #expect(lookup.finishCandidate(.discard) == nil)
    #expect(
        lookup.targetGeneration(
            structuralIdentity: 34,
            declarationOrdinal: 3
        ) == nil
    )

    #expect(lookup.beginCandidate() == nil)
    #expect(
        lookup.recordSuccessfulEncounter(
            identity: 34,
            ordinal: 3,
            candidateOnlyGeneration: liveTarget
        ) == .success(.materialized)
    )
    #expect(lookup.finishCandidate(.publish) == nil)
    #expect(
        lookup.targetGeneration(
            structuralIdentity: 34,
            declarationOrdinal: 3
        ) == liveTarget
    )
}
