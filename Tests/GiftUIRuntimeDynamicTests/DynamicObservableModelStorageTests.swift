import GiftUI
import Testing

@testable import GiftUIRuntimeDynamic

private final class DynamicStorageModel: _GiftUIObservableReference {
    let identity: UInt8

    init(identity: UInt8) {
        self.identity = identity
    }

    func _giftUIAttachChangeSink(
        _ sink: consuming _GiftUIObservableChangeSink
    ) -> _GiftUIObservationAttachment? {
        sink.attachment
    }

    func _giftUIDetachChangeSink(
        _ attachment: _GiftUIObservationAttachment
    ) {}
}

@Test func dynamicModelStoragePreservesTheFirstInitializerAndRoutesReplacement() {
    let firstModel = DynamicStorageModel(identity: 1)
    let repeatedInitializer = DynamicStorageModel(identity: 2)
    let replacement = DynamicStorageModel(identity: 3)
    let storage = DynamicObservableModelStorage<DynamicStorageModel>()
    var first = State(wrappedValue: firstModel)
    var routedReplacement: DynamicStorageModel?

    #expect(
        storage.bind(&first) { routedReplacement = $0 }
            == .success(.materialized)
    )
    #expect(storage.isOccupied)
    #expect(first.wrappedValue === firstModel)

    var repeated = State(wrappedValue: repeatedInitializer)
    #expect(
        storage.bind(&repeated) { routedReplacement = $0 }
            == .success(.preserved)
    )
    #expect(repeated.wrappedValue === firstModel)
    #expect(repeated.wrappedValue !== repeatedInitializer)

    repeated.wrappedValue = replacement
    #expect(routedReplacement === replacement)
    #expect(repeated.wrappedValue === firstModel)
    #expect(storage.withModel { $0.identity } == 1)
}

@Test func dynamicModelStorageRejectsRebindingTheSameTransientWrapper() {
    let storage = DynamicObservableModelStorage<DynamicStorageModel>()
    var state = State(wrappedValue: DynamicStorageModel(identity: 4))

    #expect(storage.bind(&state) { _ in } == .success(.materialized))
    #expect(storage.bind(&state) { _ in } == .failure(.invariantViolation))
    #expect(storage.withModel { $0.identity } == 4)
}

@Test func dynamicModelStorageStagesReplacementApartFromTheLiveModel() {
    let storage = DynamicObservableModelStorage<DynamicStorageModel>()
    var state = State(wrappedValue: DynamicStorageModel(identity: 1))
    #expect(
        storage.bind(&state, replacementRoute: { _ in })
            == .success(.materialized)
    )

    #expect(storage.stageReplacement(DynamicStorageModel(identity: 2)))
    #expect(storage.hasStagedReplacement)
    #expect(!storage.stageReplacement(DynamicStorageModel(identity: 3)))
    #expect(storage.withModel { $0.identity } == 1)
    let former = storage.commitReplacement()
    #expect(former?.identity == 1)
    #expect(storage.withModel { $0.identity } == 2)
    #expect(!storage.hasStagedReplacement)

    #expect(storage.stageReplacement(DynamicStorageModel(identity: 4)))
    #expect(storage.discardReplacement()?.identity == 4)
    #expect(storage.withModel { $0.identity } == 2)
}
