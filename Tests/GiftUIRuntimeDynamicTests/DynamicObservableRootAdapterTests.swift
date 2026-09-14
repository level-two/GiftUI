import GiftUI
import GiftUIExecution
import GiftUIObservableState
import Testing

@testable import GiftUIRuntimeDynamic

private final class DynamicRootModel: _GiftUIObservableReference {
    let identity: UInt8
    private var sink: _GiftUIObservableChangeSink?
    var reportDuringAttach = false

    init(identity: UInt8) {
        self.identity = identity
    }

    func _giftUIAttachChangeSink(
        _ sink: consuming _GiftUIObservableChangeSink
    ) -> _GiftUIObservationAttachment? {
        var installed = consume sink
        let attachment = installed.attachment
        if reportDuringAttach { _ = installed.reportChange() }
        self.sink = consume installed
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

@Test func dynamicRootAdapterCommitsAndDiscardsTheWorkspaceReplacementGeneration() {
    let adapter = DynamicObservableRootAdapter<DynamicRootModel, UInt16>(capacity: 1)
    var state = State(wrappedValue: DynamicRootModel(identity: 1))
    _ = adapter.beginCandidate()
    _ = adapter.encounter(
        structuralIdentity: 21,
        declarationOrdinal: 0,
        state: &state,
        replacementRoute: { _ in }
    )
    _ = adapter.finishCandidate(.publish)
    adapter.setExecutionPhase(.mutating)

    let poisoned = DynamicRootModel(identity: 2)
    poisoned.reportDuringAttach = true
    #expect(adapter.replace(with: poisoned) == .failure(.staleAttachment))
    #expect(adapter.withModel { $0.identity } == 1)
    #expect(
        adapter.targetGeneration(structuralIdentity: 21, declarationOrdinal: 0)
            == ObservableTargetGeneration(rawValue: 0)
    )

    #expect(
        adapter.replace(with: DynamicRootModel(identity: 3))
            == .success(.replaced)
    )
    #expect(adapter.withModel { $0.identity } == 3)
    #expect(
        adapter.targetGeneration(structuralIdentity: 21, declarationOrdinal: 0)
            == ObservableTargetGeneration(rawValue: 2)
    )
}

@Test func dynamicRootAdapterValidatesReplacementBeforeSpendingAGeneration() {
    let adapter = DynamicObservableRootAdapter<DynamicRootModel, UInt16>(capacity: 1)
    var state = State(wrappedValue: DynamicRootModel(identity: 4))
    _ = adapter.beginCandidate()
    _ = adapter.encounter(
        structuralIdentity: 22,
        declarationOrdinal: 0,
        state: &state,
        replacementRoute: { _ in }
    )
    _ = adapter.finishCandidate(.publish)

    #expect(
        adapter.replace(with: DynamicRootModel(identity: 5))
            == .failure(.invalidPhaseContained)
    )
    adapter.setExecutionPhase(.mutating)
    #expect(
        adapter.replace(with: DynamicRootModel(identity: 6))
            == .success(.replaced)
    )
    #expect(
        adapter.targetGeneration(structuralIdentity: 22, declarationOrdinal: 0)
            == ObservableTargetGeneration(rawValue: 1)
    )
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
