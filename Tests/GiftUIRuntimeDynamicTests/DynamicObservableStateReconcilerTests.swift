import GiftUI
import GiftUIObservableState
import Testing

@testable import GiftUIRuntimeDynamic

private final class ReconcilerModel: _GiftUIObservableReference {
    var value: UInt16
    private var sink: _GiftUIObservableChangeSink?

    init(value: UInt16) {
        self.value = value
    }

    func _giftUIAttachChangeSink(
        _ sink: consuming _GiftUIObservableChangeSink
    ) -> _GiftUIObservationAttachment? {
        let sink = consume sink
        let attachment = sink.attachment
        self.sink = consume sink
        return attachment
    }

    func _giftUIDetachChangeSink(_ attachment: _GiftUIObservationAttachment) {
        guard sink?.attachment == attachment else { return }
        sink = nil
    }
}

private final class OtherReconcilerModel: _GiftUIObservableReference {
    func _giftUIAttachChangeSink(
        _: consuming _GiftUIObservableChangeSink
    ) -> _GiftUIObservationAttachment? {
        nil
    }

    func _giftUIDetachChangeSink(_: _GiftUIObservationAttachment) {}
}

@Test func dynamicObservableStateReconcilerPublishesAndPreservesRoot() throws {
    let model = ReconcilerModel(value: 7)
    let root = DynamicObservableRootAdapter<ReconcilerModel, UInt16>(capacity: 1)
    var reconciler = DynamicObservableStateReconciler(root: root)
    var initialState = State(wrappedValue: model)

    #expect(reconciler.beginCandidate() == .success(.candidateStarted))
    #expect(
        reconciler.encounter(
            structuralIdentity: 3,
            declarationOrdinal: 0,
            state: &initialState
        ) == .success(.materialized)
    )
    #expect(reconciler.finishCandidate(.publish) == .success(.associationsCommitted))

    var preservedState = State(wrappedValue: model)
    #expect(reconciler.beginCandidate() == .success(.candidateStarted))
    #expect(
        reconciler.encounter(
            structuralIdentity: 3,
            declarationOrdinal: 0,
            state: &preservedState
        ) == .success(.preserved)
    )
    #expect(reconciler.finishCandidate(.publish) == .success(.unchanged))
    #expect(root.withModel { $0.value } == 7)
}

@Test func dynamicObservableStateReconcilerRejectsUnexpectedModelType() {
    let root = DynamicObservableRootAdapter<ReconcilerModel, UInt16>(capacity: 1)
    var reconciler = DynamicObservableStateReconciler(root: root)
    var state = State(wrappedValue: OtherReconcilerModel())

    #expect(reconciler.beginCandidate() == .success(.candidateStarted))
    #expect(
        reconciler.encounter(
            structuralIdentity: 3,
            declarationOrdinal: 0,
            state: &state
        ) == .failure(.invariantViolation)
    )
    #expect(reconciler.finishCandidate(.discard) == .success(.candidateDiscarded))
}
