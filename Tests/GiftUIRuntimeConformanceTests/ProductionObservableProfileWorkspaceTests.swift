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
