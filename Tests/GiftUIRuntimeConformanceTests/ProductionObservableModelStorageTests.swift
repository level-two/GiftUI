import GiftUI
import GiftUIObservableState
import Testing

@testable import GiftUIRuntimeDynamic
@testable import GiftUIRuntimeStatic

private struct ProfileBoundModel: _GiftUIObservableReference {
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

private struct ProductionModelStorageTranscript: Equatable {
    let firstOperation: ObservableStateOperational
    let firstReadIdentity: UInt8
    let repeatedOperation: ObservableStateOperational
    let repeatedReadIdentity: UInt8
    let routedReplacementIdentity: UInt8?
    let storedIdentity: UInt8?
}

private func dynamicModelStorageTranscript() -> ProductionModelStorageTranscript {
    let storage = DynamicObservableModelStorage<ProfileBoundModel>()
    var routedReplacement: ProfileBoundModel?
    var first = State(wrappedValue: ProfileBoundModel(identity: 1))
    let firstResult = storage.bind(&first) { routedReplacement = $0 }
    let firstIdentity = first.wrappedValue.identity
    var repeated = State(wrappedValue: ProfileBoundModel(identity: 2))
    let repeatedResult = storage.bind(&repeated) { routedReplacement = $0 }
    let repeatedIdentity = repeated.wrappedValue.identity
    repeated.wrappedValue = ProfileBoundModel(identity: 3)

    return ProductionModelStorageTranscript(
        firstOperation: operation(firstResult),
        firstReadIdentity: firstIdentity,
        repeatedOperation: operation(repeatedResult),
        repeatedReadIdentity: repeatedIdentity,
        routedReplacementIdentity: routedReplacement?.identity,
        storedIdentity: storage.withModel { $0.identity }
    )
}

private func staticModelStorageTranscript() -> ProductionModelStorageTranscript {
    var storage = StaticObservableModelStorage<ProfileBoundModel>()
    var routedReplacement: ProfileBoundModel?
    let first = storage.withBoundState(
        State(wrappedValue: ProfileBoundModel(identity: 1)),
        replacementRoute: { routedReplacement = $0 },
        body: { state in state.wrappedValue.identity }
    )
    let repeated = storage.withBoundState(
        State(wrappedValue: ProfileBoundModel(identity: 2)),
        replacementRoute: { routedReplacement = $0 },
        body: { state in
            let identity = state.wrappedValue.identity
            state.wrappedValue = ProfileBoundModel(identity: 3)
            return identity
        }
    )
    let (firstOperation, firstIdentity) = bound(first)
    let (repeatedOperation, repeatedIdentity) = bound(repeated)

    return ProductionModelStorageTranscript(
        firstOperation: firstOperation,
        firstReadIdentity: firstIdentity,
        repeatedOperation: repeatedOperation,
        repeatedReadIdentity: repeatedIdentity,
        routedReplacementIdentity: routedReplacement?.identity,
        storedIdentity: storage.withModel { $0.identity }
    )
}

private func operation(_ result: ObservableStateResult) -> ObservableStateOperational {
    guard case .success(let operation) = result else {
        Issue.record("model storage binding failed: \(result)")
        return .unchanged
    }
    return operation
}

private func bound(
    _ result: StaticObservableModelBindingOutcome<UInt8>
) -> (ObservableStateOperational, UInt8) {
    guard case .bound(let operation, let identity) = result else {
        Issue.record("static model storage binding failed")
        return (.unchanged, 0)
    }
    return (operation, identity)
}

@Test func productionModelStorageBindingsAreProfileEquivalent() {
    let dynamic = dynamicModelStorageTranscript()
    let fixed = staticModelStorageTranscript()

    #expect(dynamic == fixed)
    #expect(dynamic.firstOperation == .materialized)
    #expect(dynamic.firstReadIdentity == 1)
    #expect(dynamic.repeatedOperation == .preserved)
    #expect(dynamic.repeatedReadIdentity == 1)
    #expect(dynamic.routedReplacementIdentity == 3)
    #expect(dynamic.storedIdentity == 1)
}
