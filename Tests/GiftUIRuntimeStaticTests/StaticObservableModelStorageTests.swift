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
            == MemoryLayout<StaticStorageModel?>.stride
    )
}
