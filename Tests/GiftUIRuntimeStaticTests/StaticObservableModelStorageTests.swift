import GiftUI
import Testing

@testable import GiftUIRuntimeStatic

private struct StaticStorageModel: _GiftUIObservableReference {
    let identity: UInt8

    mutating func _giftUIAttachChangeSink(
        _ sink: consuming _GiftUIObservableChangeSink
    ) -> _GiftUIObservationAttachment? {
        sink.attachment
    }

    mutating func _giftUIDetachChangeSink(
        _ attachment: _GiftUIObservationAttachment
    ) {}
}

@Test func staticModelStorageBindsAttemptLocallyAndPreservesFirstInitializer() {
    var storage = StaticObservableModelStorage<StaticStorageModel>()
    var routedReplacement: StaticStorageModel?

    let first = storage.withBoundState(
        State(wrappedValue: StaticStorageModel(identity: 1)),
        replacementRoute: { routedReplacement = $0 },
        body: { state in
            state.wrappedValue.identity
        }
    )
    guard case .bound(let firstOperation, let firstIdentity) = first else {
        Issue.record("first static binding failed")
        return
    }
    #expect(firstOperation == .materialized)
    #expect(firstIdentity == 1)
    let isOccupied = storage.isOccupied
    #expect(isOccupied)

    let repeated = storage.withBoundState(
        State(wrappedValue: StaticStorageModel(identity: 2)),
        replacementRoute: { routedReplacement = $0 },
        body: { state in
            let preservedIdentity = state.wrappedValue.identity
            state.wrappedValue = StaticStorageModel(identity: 3)
            return preservedIdentity
        }
    )
    guard case .bound(let repeatedOperation, let repeatedIdentity) = repeated else {
        Issue.record("repeated static binding failed")
        return
    }
    #expect(repeatedOperation == .preserved)
    #expect(repeatedIdentity == 1)
    #expect(routedReplacement?.identity == 3)
    #expect(storage.withModel { $0.identity } == 1)
}

@Test func staticModelStorageOwnsOnlyInlineTypedOptionalStorage() {
    #expect(
        MemoryLayout<StaticObservableModelStorage<StaticStorageModel>>.stride
            == MemoryLayout<(StaticStorageModel?, StaticStorageModel?)>.stride
    )
}

@Test func staticModelStorageStagesReplacementApartFromTheLiveModel() {
    var storage = StaticObservableModelStorage<StaticStorageModel>()
    _ = storage.withBoundState(
        State(wrappedValue: StaticStorageModel(identity: 1)),
        replacementRoute: { _ in },
        body: { _ in () }
    )

    let stagedFirst = storage.stageReplacement(StaticStorageModel(identity: 2))
    #expect(stagedFirst)
    let hasFirstCandidate = storage.hasStagedReplacement
    #expect(hasFirstCandidate)
    let stagedSecond = storage.stageReplacement(StaticStorageModel(identity: 3))
    #expect(!stagedSecond)
    #expect(storage.withModel { $0.identity } == 1)
    let former = storage.commitReplacement()
    #expect(former?.identity == 1)
    #expect(storage.withModel { $0.identity } == 2)
    let hasCommittedCandidate = storage.hasStagedReplacement
    #expect(!hasCommittedCandidate)

    let stagedDiscard = storage.stageReplacement(StaticStorageModel(identity: 4))
    #expect(stagedDiscard)
    let discarded = storage.discardReplacement()
    #expect(discarded?.identity == 4)
    #expect(storage.withModel { $0.identity } == 2)
}
