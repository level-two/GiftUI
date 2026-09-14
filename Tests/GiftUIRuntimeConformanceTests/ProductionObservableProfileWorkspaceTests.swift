import GiftUI
import GiftUIExecution
import GiftUIObservableState
import Testing

@testable import GiftUIRuntimeCore
@testable import GiftUIRuntimeDynamic
@testable import GiftUIRuntimeStatic

private struct ProductionIdentity: Equatable, Sendable {
    let rawValue: UInt16
}

private struct ProductionModel: _GiftUIObservableReference {
    mutating func _giftUIAttachChangeSink(
        _ sink: consuming _GiftUIObservableChangeSink
    ) -> _GiftUIObservationAttachment? {
        sink.attachment
    }

    mutating func _giftUIDetachChangeSink(
        _ attachment: _GiftUIObservationAttachment
    ) {}
}

private struct ProductionWorkspaceTranscript: Equatable {
    let begin: ObservableStateResult
    let encounter: ObservableStateResult
    let candidateGeneration: ObservableTargetGeneration?
    let publish: ObservableStateResult
    let committedGeneration: ObservableTargetGeneration?
}

private struct ProductionReplacementGenerationTranscript: Equatable {
    let initial: ObservableTargetGeneration?
    let discarded: RuntimeObservableReplacementReservationResult
    let afterDiscard: ObservableTargetGeneration?
    let committed: RuntimeObservableReplacementReservationResult
    let commit: ObservableStateResult
    let afterCommit: ObservableTargetGeneration?
    let reinserted: ObservableTargetGeneration?
}

private func productionTranscript<Storage>(
    _ storage: consuming Storage
) -> ProductionWorkspaceTranscript
where
    Storage: RuntimeObservableProfileSlotStorage,
    Storage.Identity == ProductionIdentity
{
    let identity = ProductionIdentity(rawValue: 1)
    var model = State(wrappedValue: ProductionModel())
    var workspace = RuntimeObservableProfileWorkspace(storage: consume storage)
    let begin = workspace.beginCandidate()
    let encounter = workspace.encounter(
        structuralIdentity: identity,
        declarationOrdinal: 0,
        state: &model
    )
    let candidate = workspace.publishableTargetGeneration(
        structuralIdentity: identity,
        declarationOrdinal: 0
    )
    let publish = workspace.finishCandidate(.publish)
    return ProductionWorkspaceTranscript(
        begin: begin,
        encounter: encounter,
        candidateGeneration: candidate,
        publish: publish,
        committedGeneration: workspace.targetGeneration(
            structuralIdentity: identity,
            declarationOrdinal: 0
        )
    )
}

private func replacementGenerationTranscript<Storage>(
    _ storage: consuming Storage
) -> ProductionReplacementGenerationTranscript
where
    Storage: RuntimeObservableProfileSlotStorage,
    Storage.Identity == ProductionIdentity
{
    let identity = ProductionIdentity(rawValue: 9)
    var model = State(wrappedValue: ProductionModel())
    var workspace = RuntimeObservableProfileWorkspace(storage: consume storage)
    _ = workspace.beginCandidate()
    _ = workspace.encounter(
        structuralIdentity: identity,
        declarationOrdinal: 0,
        state: &model
    )
    _ = workspace.finishCandidate(.publish)
    let initial = workspace.targetGeneration(
        structuralIdentity: identity,
        declarationOrdinal: 0
    )
    let discarded = workspace.beginReplacement(
        structuralIdentity: identity,
        declarationOrdinal: 0
    )
    _ = workspace.finishReplacement(commit: false)
    let afterDiscard = workspace.targetGeneration(
        structuralIdentity: identity,
        declarationOrdinal: 0
    )
    let committed = workspace.beginReplacement(
        structuralIdentity: identity,
        declarationOrdinal: 0
    )
    let commit = workspace.finishReplacement(commit: true)
    let afterCommit = workspace.targetGeneration(
        structuralIdentity: identity,
        declarationOrdinal: 0
    )
    _ = workspace.beginCandidate()
    _ = workspace.finishCandidate(.publish)
    _ = workspace.beginCandidate()
    _ = workspace.encounter(
        structuralIdentity: identity,
        declarationOrdinal: 0,
        state: &model
    )
    _ = workspace.finishCandidate(.publish)
    return ProductionReplacementGenerationTranscript(
        initial: initial,
        discarded: discarded,
        afterDiscard: afterDiscard,
        committed: committed,
        commit: commit,
        afterCommit: afterCommit,
        reinserted: workspace.targetGeneration(
            structuralIdentity: identity,
            declarationOrdinal: 0
        )
    )
}

@Test func productionObservableWorkspacesAreProfileEquivalent() {
    let dynamic = productionTranscript(
        DynamicObservableProfileSlotStorage<ProductionIdentity>(capacity: 1)
    )
    let fixed = productionTranscript(
        StaticObservableProfileSlotStorage<ProductionIdentity>()
    )
    #expect(dynamic == fixed)
    #expect(dynamic.begin == .success(.candidateStarted))
    #expect(dynamic.encounter == .success(.materialized))
    #expect(dynamic.publish == .success(.associationsCommitted))
    #expect(dynamic.candidateGeneration == ObservableTargetGeneration(rawValue: 0))
    #expect(dynamic.committedGeneration == dynamic.candidateGeneration)
}

@Test func productionReplacementGenerationsAreProfileEquivalentAndNeverAlias() {
    let dynamic = replacementGenerationTranscript(
        DynamicObservableProfileSlotStorage<ProductionIdentity>(capacity: 1)
    )
    let fixed = replacementGenerationTranscript(
        StaticObservableProfileSlotStorage<ProductionIdentity>()
    )

    #expect(dynamic == fixed)
    #expect(dynamic.initial == ObservableTargetGeneration(rawValue: 0))
    #expect(dynamic.discarded == .success(ObservableTargetGeneration(rawValue: 1)))
    #expect(dynamic.afterDiscard == dynamic.initial)
    #expect(dynamic.committed == .success(ObservableTargetGeneration(rawValue: 2)))
    #expect(dynamic.commit == .success(.replaced))
    #expect(dynamic.afterCommit == ObservableTargetGeneration(rawValue: 2))
    #expect(dynamic.reinserted == ObservableTargetGeneration(rawValue: 3))
}

@Test func productionReplacementGenerationExhaustionPreservesLiveGeneration() {
    let identity = ProductionIdentity(rawValue: 10)
    var model = State(wrappedValue: ProductionModel())
    var workspace = RuntimeObservableProfileWorkspace(
        storage: StaticObservableProfileSlotStorage<ProductionIdentity>(),
        firstGeneration: UInt32.max
    )
    _ = workspace.beginCandidate()
    _ = workspace.encounter(
        structuralIdentity: identity,
        declarationOrdinal: 0,
        state: &model
    )
    _ = workspace.finishCandidate(.publish)

    #expect(
        workspace.beginReplacement(
            structuralIdentity: identity,
            declarationOrdinal: 0
        ) == .failure(.registrationGenerationExhausted)
    )
    #expect(
        workspace.targetGeneration(
            structuralIdentity: identity,
            declarationOrdinal: 0
        ) == ObservableTargetGeneration(rawValue: UInt32.max)
    )
}

@Test func productionObservableWorkspaceRejectsGenerationExhaustionWithoutAZeroSentinel() {
    let identity = ProductionIdentity(rawValue: 3)
    var model = State(wrappedValue: ProductionModel())
    var workspace = RuntimeObservableProfileWorkspace(
        storage: StaticObservableProfileSlotStorage<ProductionIdentity>(),
        firstGeneration: nil
    )

    #expect(workspace.beginCandidate() == .success(.candidateStarted))
    #expect(
        workspace.encounter(
            structuralIdentity: identity,
            declarationOrdinal: 0,
            state: &model
        ) == .failure(.registrationGenerationExhausted)
    )
    #expect(
        workspace.publishableTargetGeneration(
            structuralIdentity: identity,
            declarationOrdinal: 0
        ) == nil
    )
}

@Test func productionObservableWorkspacesRejectFirstExcess() {
    let identity = ProductionIdentity(rawValue: 2)
    var first = State(wrappedValue: ProductionModel())
    var second = State(wrappedValue: ProductionModel())
    var workspace = RuntimeObservableProfileWorkspace(
        storage: DynamicObservableProfileSlotStorage<ProductionIdentity>(
            capacity: 1
        )
    )
    #expect(workspace.beginCandidate() == .success(.candidateStarted))
    #expect(
        workspace.encounter(
            structuralIdentity: identity,
            declarationOrdinal: 0,
            state: &first
        ) == .success(.materialized)
    )
    #expect(
        workspace.encounter(
            structuralIdentity: identity,
            declarationOrdinal: 1,
            state: &second
        ) == .failure(.locationCapacityExhausted)
    )
}

@Test func staticProductionObservableStorageIsInline() {
    #expect(
        MemoryLayout<StaticObservableProfileSlotStorage<ProductionIdentity>>.stride
            == MemoryLayout<RuntimeObservableProfileSlot<ProductionIdentity>>.stride
    )
}
