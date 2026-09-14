import GiftUI
import GiftUIExecution
import GiftUIObservableState
import Testing

@testable import GiftUIRuntimeStatic

private struct StaticRootModel: _GiftUIObservableReference {
    let identity: UInt8
    private(set) var attachment: _GiftUIObservationAttachment?

    init(identity: UInt8) {
        self.identity = identity
    }

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

@Test func staticRootAdapterValidatesBeforeSpendingAReplacementGeneration() {
    var root = StaticObservableRootAdapter<StaticRootModel, UInt32>(
        structuralIdentity: 0x5341_0003,
        declarationOrdinal: 0
    )
    _ = root.beginCandidate()
    _ = root.withEncounter(
        state: State(wrappedValue: StaticRootModel(identity: 7)),
        replacementRoute: { _ in },
        reportRoute: { _ in .staleAttachment },
        body: { _ in () }
    )
    _ = root.finishCandidate(.publish)

    #expect(
        root.replace(
            with: StaticRootModel(identity: 8),
            reportRoute: { _ in .staleAttachment }
        ) == .failure(.invalidPhaseContained)
    )
    root.setExecutionPhase(.mutating)
    #expect(
        root.replace(
            with: StaticRootModel(identity: 9),
            reportRoute: { _ in .staleAttachment }
        ) == .success(.replaced)
    )
    #expect(root.withModel { $0.identity } == 9)
    #expect(root.targetGeneration() == ObservableTargetGeneration(rawValue: 1))
}

@Test func staticRootAdapterRetiresAnInitialRegistrationOnDiscard() {
    var root = StaticObservableRootAdapter<StaticRootModel, UInt32>(
        structuralIdentity: 0x5341_0004,
        declarationOrdinal: 0
    )
    _ = root.beginCandidate()
    _ = root.withEncounter(
        state: State(wrappedValue: StaticRootModel(identity: 11)),
        replacementRoute: { _ in },
        reportRoute: { _ in .staleAttachment },
        body: { _ in () }
    )

    #expect(root.finishCandidate(.discard) == .success(.candidateDiscarded))
    let isActive = root.isActive
    #expect(!isActive)
    #expect(root.withModel { $0.identity } == nil)
    #expect(root.targetGeneration() == nil)
}

@Test func staticRootAdapterJoinsGeneratedIdentityBindingAndReplacement() {
    var root = StaticObservableRootAdapter<StaticRootModel, UInt32>(
        structuralIdentity: 0x5341_0001,
        declarationOrdinal: 0
    )

    #expect(root.beginCandidate() == .success(.candidateStarted))
    let first = root.withEncounter(
        state: State(wrappedValue: StaticRootModel(identity: 1)),
        replacementRoute: { _ in },
        reportRoute: { _ in .staleAttachment },
        body: { $0.wrappedValue.identity }
    )
    guard case .bound(.success(.materialized), let firstIdentity) = first else {
        Issue.record("Static root did not materialize")
        return
    }
    #expect(firstIdentity == 1)
    #expect(root.finishCandidate(.publish) == .success(.associationsCommitted))
    #expect(root.targetGeneration() == ObservableTargetGeneration(rawValue: 0))
    let isInitiallyActive = root.isActive
    #expect(isInitiallyActive)

    #expect(root.beginCandidate() == .success(.candidateStarted))
    let repeated = root.withEncounter(
        state: State(wrappedValue: StaticRootModel(identity: 2)),
        replacementRoute: { _ in },
        reportRoute: { _ in .staleAttachment },
        body: { $0.wrappedValue.identity }
    )
    guard case .bound(.success(.preserved), let repeatedIdentity) = repeated else {
        Issue.record("Static root did not preserve")
        return
    }
    #expect(repeatedIdentity == 1)
    #expect(root.finishCandidate(.publish) == .success(.unchanged))

    root.setExecutionPhase(.mutating)
    guard let initialAttachment = root.liveAttachment() else {
        Issue.record("Static root omitted its live attachment")
        return
    }
    #expect(root.acceptReport(initialAttachment) == .dirtied)
    #expect(
        root.replace(
            with: StaticRootModel(identity: 3),
            reportRoute: { _ in .staleAttachment }
        ) == .success(.replaced)
    )
    #expect(root.withModel { $0.identity } == 3)
    #expect(root.targetGeneration() == ObservableTargetGeneration(rawValue: 1))
    let isReplacementActive = root.isActive
    let isReplacementDirty = root.isDirty
    #expect(isReplacementActive)
    #expect(isReplacementDirty)
    #expect(root.acceptReport(initialAttachment) == .staleAttachment)
}

@Test func staticRootAdapterPublishesRemovalAndFreshReinsertion() {
    var root = StaticObservableRootAdapter<StaticRootModel, UInt32>(
        structuralIdentity: 0x5341_0002,
        declarationOrdinal: 0
    )
    _ = root.beginCandidate()
    _ = root.withEncounter(
        state: State(wrappedValue: StaticRootModel(identity: 4)),
        replacementRoute: { _ in },
        reportRoute: { _ in .staleAttachment },
        body: { _ in () }
    )
    _ = root.finishCandidate(.publish)
    root.setExecutionPhase(.mutating)
    _ = root.replace(
        with: StaticRootModel(identity: 5),
        reportRoute: { _ in .staleAttachment }
    )

    _ = root.beginCandidate()
    #expect(root.finishCandidate(.publish) == .success(.associationsCommitted))
    let isActiveAfterRemoval = root.isActive
    #expect(!isActiveAfterRemoval)
    #expect(root.withModel { $0.identity } == nil)

    _ = root.beginCandidate()
    let reinserted = root.withEncounter(
        state: State(wrappedValue: StaticRootModel(identity: 6)),
        replacementRoute: { _ in },
        reportRoute: { _ in .staleAttachment },
        body: { $0.wrappedValue.identity }
    )
    guard case .bound(.success(.materialized), let identity) = reinserted else {
        Issue.record("Static root did not reinsert")
        return
    }
    #expect(identity == 6)
    #expect(root.finishCandidate(.publish) == .success(.associationsCommitted))
    #expect(root.targetGeneration() == ObservableTargetGeneration(rawValue: 2))
    let isReinsertedActive = root.isActive
    let isReinsertedDirty = root.isDirty
    #expect(isReinsertedActive)
    #expect(!isReinsertedDirty)
}

@Test func staticRootAdapterBorrowsOnlyTheMatchingTargetGeneration() {
    var root = StaticObservableRootAdapter<StaticRootModel, UInt32>(
        structuralIdentity: 0x5341_0005,
        declarationOrdinal: 0
    )
    _ = root.beginCandidate()
    _ = root.withEncounter(
        state: State(wrappedValue: StaticRootModel(identity: 12)),
        replacementRoute: { _ in },
        reportRoute: { _ in .staleAttachment },
        body: { _ in () }
    )
    _ = root.finishCandidate(.publish)

    var identities: [UInt8] = []
    #expect(
        !root.withModel(
            matching: ObservableTargetGeneration(rawValue: 1)
        ) { identities.append($0.identity) }
    )
    #expect(
        root.withModel(
            matching: ObservableTargetGeneration(rawValue: 0)
        ) { identities.append($0.identity) }
    )
    #expect(identities == [12])

    root.setExecutionPhase(.mutating)
    _ = root.replace(
        with: StaticRootModel(identity: 13),
        reportRoute: { _ in .staleAttachment }
    )
    #expect(
        !root.withModel(
            matching: ObservableTargetGeneration(rawValue: 0)
        ) { identities.append($0.identity) }
    )
    #expect(
        root.withModel(
            matching: ObservableTargetGeneration(rawValue: 1)
        ) { identities.append($0.identity) }
    )
    #expect(identities == [12, 13])
}
