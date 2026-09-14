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

private struct RootFailureTranscript: Equatable {
    let incompatible: ObservableStateResult
    let duplicateOwner: ObservableStateResult
    let registrationCapacity: ObservableStateResult
    let replacementCapacity: ObservableStateResult
    let nextReplacement: ObservableStateResult
    let nextGeneration: ObservableTargetGeneration?
    let exhaustedReplacement: ObservableStateResult
    let preservedExhaustedGeneration: ObservableTargetGeneration?
    let preservedExhaustedIdentity: UInt8?
    let exhaustedInitial: ObservableStateResult
}

private func dynamicRootFailureTranscript() -> RootFailureTranscript {
    let root = DynamicObservableRootAdapter<DynamicRootTranscriptModel, UInt32>(
        capacity: 1
    )
    var state = State(wrappedValue: DynamicRootTranscriptModel(identity: 10))
    _ = root.beginCandidate()
    _ = root.encounter(
        structuralIdentity: 0x5341_0200,
        declarationOrdinal: 0,
        state: &state,
        replacementRoute: { _ in }
    )
    _ = root.finishCandidate(.publish)
    root.setExecutionPhase(.mutating)
    let incompatible = root.replace(
        with: DynamicRootTranscriptModel(identity: 11),
        isCompatible: false
    )
    let duplicateOwner = root.replace(
        with: DynamicRootTranscriptModel(identity: 12),
        candidateAlreadyOwned: true
    )
    let registrationCapacity = root.replace(
        with: DynamicRootTranscriptModel(identity: 13),
        registrationCapacityAvailable: false
    )
    let replacementCapacity = root.replace(
        with: DynamicRootTranscriptModel(identity: 14),
        replacementStagingAvailable: false
    )
    let nextReplacement = root.replace(
        with: DynamicRootTranscriptModel(identity: 15)
    )
    let nextGeneration = root.targetGeneration(
        structuralIdentity: 0x5341_0200,
        declarationOrdinal: 0
    )

    let exhausted = DynamicObservableRootAdapter<
        DynamicRootTranscriptModel,
        UInt32
    >(capacity: 1, firstGeneration: UInt32.max)
    var exhaustedState = State(
        wrappedValue: DynamicRootTranscriptModel(identity: 20)
    )
    _ = exhausted.beginCandidate()
    _ = exhausted.encounter(
        structuralIdentity: 0x5341_0201,
        declarationOrdinal: 0,
        state: &exhaustedState,
        replacementRoute: { _ in }
    )
    _ = exhausted.finishCandidate(.publish)
    exhausted.setExecutionPhase(.mutating)
    let exhaustedReplacement = exhausted.replace(
        with: DynamicRootTranscriptModel(identity: 21)
    )
    let preservedExhaustedGeneration = exhausted.targetGeneration(
        structuralIdentity: 0x5341_0201,
        declarationOrdinal: 0
    )

    let initiallyExhausted = DynamicObservableRootAdapter<
        DynamicRootTranscriptModel,
        UInt32
    >(capacity: 1, firstGeneration: nil)
    var rejectedState = State(
        wrappedValue: DynamicRootTranscriptModel(identity: 30)
    )
    _ = initiallyExhausted.beginCandidate()
    let exhaustedInitial = initiallyExhausted.encounter(
        structuralIdentity: 0x5341_0202,
        declarationOrdinal: 0,
        state: &rejectedState,
        replacementRoute: { _ in }
    )

    return RootFailureTranscript(
        incompatible: incompatible,
        duplicateOwner: duplicateOwner,
        registrationCapacity: registrationCapacity,
        replacementCapacity: replacementCapacity,
        nextReplacement: nextReplacement,
        nextGeneration: nextGeneration,
        exhaustedReplacement: exhaustedReplacement,
        preservedExhaustedGeneration: preservedExhaustedGeneration,
        preservedExhaustedIdentity: exhausted.withModel { $0.identity },
        exhaustedInitial: exhaustedInitial
    )
}

private func staticRootFailureTranscript() -> RootFailureTranscript {
    var root = StaticObservableRootAdapter<StaticRootTranscriptModel, UInt32>(
        structuralIdentity: 0x5341_0200,
        declarationOrdinal: 0
    )
    _ = root.beginCandidate()
    _ = root.withEncounter(
        state: State(wrappedValue: StaticRootTranscriptModel(identity: 10)),
        replacementRoute: { _ in },
        reportRoute: { _ in .staleAttachment },
        body: { _ in () }
    )
    _ = root.finishCandidate(.publish)
    root.setExecutionPhase(.mutating)
    let incompatible = root.replace(
        with: StaticRootTranscriptModel(identity: 11),
        reportRoute: { _ in .staleAttachment },
        isCompatible: false
    )
    let duplicateOwner = root.replace(
        with: StaticRootTranscriptModel(identity: 12),
        reportRoute: { _ in .staleAttachment },
        candidateAlreadyOwned: true
    )
    let registrationCapacity = root.replace(
        with: StaticRootTranscriptModel(identity: 13),
        reportRoute: { _ in .staleAttachment },
        registrationCapacityAvailable: false
    )
    let replacementCapacity = root.replace(
        with: StaticRootTranscriptModel(identity: 14),
        reportRoute: { _ in .staleAttachment },
        replacementStagingAvailable: false
    )
    let nextReplacement = root.replace(
        with: StaticRootTranscriptModel(identity: 15),
        reportRoute: { _ in .staleAttachment }
    )
    let nextGeneration = root.targetGeneration()

    var exhausted = StaticObservableRootAdapter<
        StaticRootTranscriptModel,
        UInt32
    >(
        structuralIdentity: 0x5341_0201,
        declarationOrdinal: 0,
        firstGeneration: UInt32.max
    )
    _ = exhausted.beginCandidate()
    _ = exhausted.withEncounter(
        state: State(wrappedValue: StaticRootTranscriptModel(identity: 20)),
        replacementRoute: { _ in },
        reportRoute: { _ in .staleAttachment },
        body: { _ in () }
    )
    _ = exhausted.finishCandidate(.publish)
    exhausted.setExecutionPhase(.mutating)
    let exhaustedReplacement = exhausted.replace(
        with: StaticRootTranscriptModel(identity: 21),
        reportRoute: { _ in .staleAttachment }
    )

    var initiallyExhausted = StaticObservableRootAdapter<
        StaticRootTranscriptModel,
        UInt32
    >(
        structuralIdentity: 0x5341_0202,
        declarationOrdinal: 0,
        firstGeneration: nil
    )
    _ = initiallyExhausted.beginCandidate()
    let exhaustedInitial = normalize(
        initiallyExhausted.withEncounter(
            state: State(wrappedValue: StaticRootTranscriptModel(identity: 30)),
            replacementRoute: { _ in },
            reportRoute: { _ in .staleAttachment },
            body: { _ in () }
        )
    )

    return RootFailureTranscript(
        incompatible: incompatible,
        duplicateOwner: duplicateOwner,
        registrationCapacity: registrationCapacity,
        replacementCapacity: replacementCapacity,
        nextReplacement: nextReplacement,
        nextGeneration: nextGeneration,
        exhaustedReplacement: exhaustedReplacement,
        preservedExhaustedGeneration: exhausted.targetGeneration(),
        preservedExhaustedIdentity: exhausted.withModel { $0.identity },
        exhaustedInitial: exhaustedInitial
    )
}

@Test func productionObservableRootsHaveEqualFailureTranscripts() {
    let dynamic = dynamicRootFailureTranscript()
    let fixed = staticRootFailureTranscript()

    #expect(dynamic == fixed)
    #expect(dynamic.incompatible == .failure(.incompatibleAssociation))
    #expect(dynamic.duplicateOwner == .failure(.duplicateOwner))
    #expect(dynamic.registrationCapacity == .failure(.registrationCapacityExhausted))
    #expect(dynamic.replacementCapacity == .failure(.replacementStagingCapacityExhausted))
    #expect(dynamic.nextReplacement == .success(.replaced))
    #expect(dynamic.nextGeneration == ObservableTargetGeneration(rawValue: 1))
    #expect(dynamic.exhaustedReplacement == .failure(.registrationGenerationExhausted))
    #expect(
        dynamic.preservedExhaustedGeneration
            == ObservableTargetGeneration(rawValue: UInt32.max)
    )
    #expect(dynamic.preservedExhaustedIdentity == 20)
    #expect(dynamic.exhaustedInitial == .failure(.registrationGenerationExhausted))
}

private struct FailedDerivationTranscript: Equatable {
    let replacement: ObservableStateResult
    let failedDerivation: ObservableStateResult
    let generation: ObservableTargetGeneration?
    let identity: UInt8?
    let isActive: Bool
    let isDirty: Bool
    let nextEncounter: ObservableStateResult
}

private func dynamicFailedDerivationTranscript() -> FailedDerivationTranscript {
    let root = DynamicObservableRootAdapter<DynamicRootTranscriptModel, UInt32>(
        capacity: 1
    )
    var initial = State(wrappedValue: DynamicRootTranscriptModel(identity: 40))
    _ = root.beginCandidate()
    _ = root.encounter(
        structuralIdentity: 0x5341_0300,
        declarationOrdinal: 0,
        state: &initial,
        replacementRoute: { _ in }
    )
    _ = root.finishCandidate(.publish)
    root.setExecutionPhase(.mutating)
    let replacement = root.replace(
        with: DynamicRootTranscriptModel(identity: 41)
    )

    _ = root.beginCandidate()
    let failedDerivation = root.finishCandidate(.discard)
    let generation = root.targetGeneration(
        structuralIdentity: 0x5341_0300,
        declarationOrdinal: 0
    )
    let identity = root.withModel { $0.identity }
    let isActive = root.isActive
    let isDirty = root.isDirty

    var next = State(wrappedValue: DynamicRootTranscriptModel(identity: 42))
    _ = root.beginCandidate()
    let nextEncounter = root.encounter(
        structuralIdentity: 0x5341_0300,
        declarationOrdinal: 0,
        state: &next,
        replacementRoute: { _ in }
    )

    return FailedDerivationTranscript(
        replacement: replacement,
        failedDerivation: failedDerivation,
        generation: generation,
        identity: identity,
        isActive: isActive,
        isDirty: isDirty,
        nextEncounter: nextEncounter
    )
}

private func staticFailedDerivationTranscript() -> FailedDerivationTranscript {
    var root = StaticObservableRootAdapter<StaticRootTranscriptModel, UInt32>(
        structuralIdentity: 0x5341_0300,
        declarationOrdinal: 0
    )
    _ = root.beginCandidate()
    _ = root.withEncounter(
        state: State(wrappedValue: StaticRootTranscriptModel(identity: 40)),
        replacementRoute: { _ in },
        reportRoute: { _ in .staleAttachment },
        body: { _ in () }
    )
    _ = root.finishCandidate(.publish)
    root.setExecutionPhase(.mutating)
    let replacement = root.replace(
        with: StaticRootTranscriptModel(identity: 41),
        reportRoute: { _ in .staleAttachment }
    )

    _ = root.beginCandidate()
    let failedDerivation = root.finishCandidate(.discard)
    let generation = root.targetGeneration()
    let identity = root.withModel { $0.identity }
    let isActive = root.isActive
    let isDirty = root.isDirty

    _ = root.beginCandidate()
    let nextEncounter = normalize(
        root.withEncounter(
            state: State(wrappedValue: StaticRootTranscriptModel(identity: 42)),
            replacementRoute: { _ in },
            reportRoute: { _ in .staleAttachment },
            body: { _ in () }
        )
    )

    return FailedDerivationTranscript(
        replacement: replacement,
        failedDerivation: failedDerivation,
        generation: generation,
        identity: identity,
        isActive: isActive,
        isDirty: isDirty,
        nextEncounter: nextEncounter
    )
}

@Test func failedDerivationPreservesCommittedReplacementInBothProfiles() {
    let dynamic = dynamicFailedDerivationTranscript()
    let fixed = staticFailedDerivationTranscript()

    #expect(dynamic == fixed)
    #expect(dynamic.replacement == .success(.replaced))
    #expect(dynamic.failedDerivation == .success(.candidateDiscarded))
    #expect(dynamic.generation == ObservableTargetGeneration(rawValue: 1))
    #expect(dynamic.identity == 41)
    #expect(dynamic.isActive)
    #expect(dynamic.isDirty)
    #expect(dynamic.nextEncounter == .success(.preserved))
}
