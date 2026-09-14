import GiftUI
import GiftUIExecution
import GiftUIObservableState
import Testing

@testable import GiftUIRuntimeDynamic

private final class DynamicRootModel: _GiftUIObservableReference {
    let identity: UInt8
    private var sink: _GiftUIObservableChangeSink?

    init(identity: UInt8) {
        self.identity = identity
    }

    func _giftUIAttachChangeSink(
        _ sink: consuming _GiftUIObservableChangeSink
    ) -> _GiftUIObservationAttachment? {
        let attachment = sink.attachment
        self.sink = consume sink
        return attachment
    }

    func _giftUIDetachChangeSink(
        _ attachment: _GiftUIObservationAttachment
    ) {
        guard sink?.attachment == attachment else { return }
        sink = nil
    }

    func reportChange() -> _GiftUIObservableChangeReportOutcome? {
        sink?.reportChange()
    }
}

@Test func dynamicRootAdapterJoinsGenerationBindingAndPublishedRemoval() {
    let adapter = DynamicObservableRootAdapter<DynamicRootModel, UInt16>(capacity: 1)
    let firstModel = DynamicRootModel(identity: 1)
    var first = State(wrappedValue: firstModel)

    #expect(adapter.beginCandidate() == .success(.candidateStarted))
    #expect(
        adapter.encounter(
            structuralIdentity: 7,
            declarationOrdinal: 0,
            state: &first,
            replacementRoute: { _ in }
        ) == .success(.materialized)
    )
    #expect(adapter.finishCandidate(.publish) == .success(.associationsCommitted))
    #expect(
        adapter.targetGeneration(structuralIdentity: 7, declarationOrdinal: 0)
            == ObservableTargetGeneration(rawValue: 0)
    )
    #expect(adapter.withModel { $0.identity } == 1)

    var repeated = State(wrappedValue: DynamicRootModel(identity: 2))
    #expect(adapter.beginCandidate() == .success(.candidateStarted))
    #expect(
        adapter.encounter(
            structuralIdentity: 7,
            declarationOrdinal: 0,
            state: &repeated,
            replacementRoute: { _ in }
        ) == .success(.preserved)
    )
    #expect(adapter.finishCandidate(.publish) == .success(.unchanged))
    #expect(adapter.withModel { $0.identity } == 1)

    adapter.setExecutionPhase(.mutating)
    #expect(firstModel.reportChange() == .dirtied)
    #expect(adapter.isDirty)

    #expect(adapter.beginCandidate() == .success(.candidateStarted))
    #expect(adapter.finishCandidate(.publish) == .success(.associationsCommitted))
    #expect(!adapter.isActive)
    #expect(adapter.withModel { $0.identity } == nil)
    #expect(firstModel.reportChange() == nil)
}

@Test func dynamicRootAdapterRetiresAnInitialRegistrationOnDiscard() {
    let adapter = DynamicObservableRootAdapter<DynamicRootModel, UInt16>(capacity: 1)
    let model = DynamicRootModel(identity: 3)
    var state = State(wrappedValue: model)

    #expect(adapter.beginCandidate() == .success(.candidateStarted))
    #expect(
        adapter.encounter(
            structuralIdentity: 11,
            declarationOrdinal: 0,
            state: &state,
            replacementRoute: { _ in }
        ) == .success(.materialized)
    )
    #expect(adapter.finishCandidate(.discard) == .success(.candidateDiscarded))
    #expect(!adapter.isActive)
    #expect(model.reportChange() == nil)
    #expect(
        adapter.targetGeneration(structuralIdentity: 11, declarationOrdinal: 0)
            == nil
    )
}
