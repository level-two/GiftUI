import GiftUI
import GiftUIExecution
import GiftUIObservableState
import Testing

@testable import GiftUIRuntimeDynamic
@testable import GiftUIRuntimeStatic

private final class DynamicRootTranscriptModel: _GiftUIObservableReference {
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

    func report() -> _GiftUIObservableChangeReportOutcome? {
        sink?.reportChange()
    }
}

private struct StaticRootTranscriptModel: _GiftUIObservableReference {
    let identity: UInt8
    private(set) var attachment: _GiftUIObservationAttachment?

    mutating func _giftUIAttachChangeSink(
        _ sink: consuming _GiftUIObservableChangeSink
    ) -> _GiftUIObservationAttachment? {
        attachment = sink.attachment
        return attachment
    }

    mutating func _giftUIDetachChangeSink(
        _ attachment: _GiftUIObservationAttachment
    ) {
        guard self.attachment == attachment else { return }
        self.attachment = nil
    }
}

private struct RootLifecycleTranscript: Equatable {
    let initial: ObservableStateResult
    let initialGeneration: ObservableTargetGeneration?
    let initialReport: _GiftUIObservableChangeReportOutcome?
    let repeated: ObservableStateResult
    let repeatedIdentity: UInt8?
    let replacement: ObservableStateResult
    let replacementGeneration: ObservableTargetGeneration?
    let replacementReport: _GiftUIObservableChangeReportOutcome?
    let removal: ObservableStateResult
    let isActiveAfterRemoval: Bool
    let reinserted: ObservableStateResult
    let reinsertedGeneration: ObservableTargetGeneration?
    let reinsertedIdentity: UInt8?
    let isActiveAfterReinsertion: Bool
    let isDirtyAfterReinsertion: Bool
}

private func dynamicRootLifecycleTranscript() -> RootLifecycleTranscript {
    let root = DynamicObservableRootAdapter<DynamicRootTranscriptModel, UInt32>(
        capacity: 1
    )
    let initialModel = DynamicRootTranscriptModel(identity: 1)
    var initialState = State(wrappedValue: initialModel)
    _ = root.beginCandidate()
    let initial = root.encounter(
        structuralIdentity: 0x5341_0100,
        declarationOrdinal: 0,
        state: &initialState,
        replacementRoute: { _ in }
    )
    _ = root.finishCandidate(.publish)
    let initialGeneration = root.targetGeneration(
        structuralIdentity: 0x5341_0100,
        declarationOrdinal: 0
    )
    root.setExecutionPhase(.mutating)
    let initialReport = initialModel.report()

    var repeatedState = State(
        wrappedValue: DynamicRootTranscriptModel(identity: 2)
    )
    _ = root.beginCandidate()
    let repeated = root.encounter(
        structuralIdentity: 0x5341_0100,
        declarationOrdinal: 0,
        state: &repeatedState,
        replacementRoute: { _ in }
    )
    _ = root.finishCandidate(.publish)
    let repeatedIdentity = root.withModel { $0.identity }

    let replacementModel = DynamicRootTranscriptModel(identity: 3)
    let replacement = root.replace(with: replacementModel)
    let replacementGeneration = root.targetGeneration(
        structuralIdentity: 0x5341_0100,
        declarationOrdinal: 0
    )
    let replacementReport = replacementModel.report()

    _ = root.beginCandidate()
    let removal = root.finishCandidate(.publish)
    let isActiveAfterRemoval = root.isActive

    var reinsertedState = State(
        wrappedValue: DynamicRootTranscriptModel(identity: 4)
    )
    _ = root.beginCandidate()
    let reinserted = root.encounter(
        structuralIdentity: 0x5341_0100,
        declarationOrdinal: 0,
        state: &reinsertedState,
        replacementRoute: { _ in }
    )
    _ = root.finishCandidate(.publish)
    let reinsertedGeneration = root.targetGeneration(
        structuralIdentity: 0x5341_0100,
        declarationOrdinal: 0
    )

    return RootLifecycleTranscript(
        initial: initial,
        initialGeneration: initialGeneration,
        initialReport: initialReport,
        repeated: repeated,
        repeatedIdentity: repeatedIdentity,
        replacement: replacement,
        replacementGeneration: replacementGeneration,
        replacementReport: replacementReport,
        removal: removal,
        isActiveAfterRemoval: isActiveAfterRemoval,
        reinserted: reinserted,
        reinsertedGeneration: reinsertedGeneration,
        reinsertedIdentity: root.withModel { $0.identity },
        isActiveAfterReinsertion: root.isActive,
        isDirtyAfterReinsertion: root.isDirty
    )
}

private func staticRootLifecycleTranscript() -> RootLifecycleTranscript {
    var root = StaticObservableRootAdapter<StaticRootTranscriptModel, UInt32>(
        structuralIdentity: 0x5341_0100,
        declarationOrdinal: 0
    )
    _ = root.beginCandidate()
    let initial = normalize(
        root.withEncounter(
            state: State(wrappedValue: StaticRootTranscriptModel(identity: 1)),
            replacementRoute: { _ in },
            reportRoute: { _ in .staleAttachment },
            body: { _ in () }
        )
    )
    _ = root.finishCandidate(.publish)
    let initialGeneration = root.targetGeneration()
    root.setExecutionPhase(.mutating)
    let initialReport = root.liveAttachment().map { root.acceptReport($0) }

    _ = root.beginCandidate()
    let repeated = normalize(
        root.withEncounter(
            state: State(wrappedValue: StaticRootTranscriptModel(identity: 2)),
            replacementRoute: { _ in },
            reportRoute: { _ in .staleAttachment },
            body: { _ in () }
        )
    )
    _ = root.finishCandidate(.publish)
    let repeatedIdentity = root.withModel { $0.identity }

    let replacement = root.replace(
        with: StaticRootTranscriptModel(identity: 3),
        reportRoute: { _ in .staleAttachment }
    )
    let replacementGeneration = root.targetGeneration()
    let replacementReport = root.liveAttachment().map { root.acceptReport($0) }

    _ = root.beginCandidate()
    let removal = root.finishCandidate(.publish)
    let isActiveAfterRemoval = root.isActive

    _ = root.beginCandidate()
    let reinserted = normalize(
        root.withEncounter(
            state: State(wrappedValue: StaticRootTranscriptModel(identity: 4)),
            replacementRoute: { _ in },
            reportRoute: { _ in .staleAttachment },
            body: { _ in () }
        )
    )
    _ = root.finishCandidate(.publish)

    return RootLifecycleTranscript(
        initial: initial,
        initialGeneration: initialGeneration,
        initialReport: initialReport,
        repeated: repeated,
        repeatedIdentity: repeatedIdentity,
        replacement: replacement,
        replacementGeneration: replacementGeneration,
        replacementReport: replacementReport,
        removal: removal,
        isActiveAfterRemoval: isActiveAfterRemoval,
        reinserted: reinserted,
        reinsertedGeneration: root.targetGeneration(),
        reinsertedIdentity: root.withModel { $0.identity },
        isActiveAfterReinsertion: root.isActive,
        isDirtyAfterReinsertion: root.isDirty
    )
}

private func normalize(
    _ outcome: StaticObservableRootBindingOutcome<Void>
) -> ObservableStateResult {
    switch outcome {
    case .bound(let result, ()): result
    case .failure(let failure): .failure(failure)
    }
}

@Test func productionObservableRootsHaveEqualLifecycleTranscripts() {
    let dynamic = dynamicRootLifecycleTranscript()
    let fixed = staticRootLifecycleTranscript()

    #expect(dynamic == fixed)
    #expect(dynamic.initial == .success(.materialized))
    #expect(dynamic.initialGeneration == ObservableTargetGeneration(rawValue: 0))
    #expect(dynamic.initialReport == .dirtied)
    #expect(dynamic.repeated == .success(.preserved))
    #expect(dynamic.repeatedIdentity == 1)
    #expect(dynamic.replacement == .success(.replaced))
    #expect(dynamic.replacementGeneration == ObservableTargetGeneration(rawValue: 1))
    #expect(dynamic.replacementReport == .coalesced)
    #expect(dynamic.removal == .success(.associationsCommitted))
    #expect(!dynamic.isActiveAfterRemoval)
    #expect(dynamic.reinserted == .success(.materialized))
    #expect(dynamic.reinsertedGeneration == ObservableTargetGeneration(rawValue: 2))
    #expect(dynamic.reinsertedIdentity == 4)
    #expect(dynamic.isActiveAfterReinsertion)
    #expect(!dynamic.isDirtyAfterReinsertion)
}
