import Testing

@testable import GiftUIHostConfiguration

private let analyzerProducerLimits = HostFactProducerLimits(
    transition: 20,
    bootstrap: 2,
    action: 6
)!

@Test func factProducerLimitsRejectZeroAndPreserveExactBounds() {
    #expect(HostFactProducerLimits(transition: 0, bootstrap: 2, action: 6) == nil)
    #expect(HostFactProducerLimits(transition: 20, bootstrap: 0, action: 6) == nil)
    #expect(HostFactProducerLimits(transition: 20, bootstrap: 2, action: 0) == nil)
    #expect(analyzerProducerLimits.transition == 20)
    #expect(analyzerProducerLimits.bootstrap == 2)
    #expect(analyzerProducerLimits.action == 6)
    #expect(HostSequencedFactAdmission<Int, Int, Int>.compactCapacity == 32)
}

@Test func completeTwentyTwoSixBurstUsesTwentyEightMonotonicSequences() {
    var admission = HostSequencedFactAdmission<Int, Int, Int>(
        producerLimits: analyzerProducerLimits
    )!
    var accepted: [UInt32] = []

    accepted.append(acceptedSequence(admission.admitSnapshot(0, category: .bootstrap)))
    accepted.append(acceptedSequence(admission.admitCompact(1, category: .bootstrap)))
    for value in 2 ..< 22 {
        accepted.append(acceptedSequence(admission.admitCompact(value, category: .transition)))
    }
    for value in 22 ..< 28 {
        accepted.append(acceptedSequence(admission.admitCompact(value, category: .action)))
    }

    #expect(accepted == Array(1 ... 28).map(UInt32.init))
    #expect(admission.pendingSnapshotCount == 1)
    #expect(admission.pendingCompactCount == 27)
    #expect(admission.pendingReservedFailureCount == 0)
    #expect(
        admission.admitCompact(28, category: .transition) == .rejected(.producerCategoryExhausted))
    #expect(
        admission.admitCompact(28, category: .bootstrap) == .rejected(.producerCategoryExhausted))
    #expect(admission.admitCompact(28, category: .action) == .rejected(.producerCategoryExhausted))
}

@Test func physicalCompactStoreAcceptsThirtyTwoAndRejectsThirtyThird() {
    let physicalLimits = HostFactProducerLimits(transition: 33, bootstrap: 1, action: 1)!
    var admission = HostSequencedFactAdmission<Int, Int, Int>(
        producerLimits: physicalLimits
    )!

    for value in 0 ..< 32 {
        #expect(
            admission.admitCompact(value, category: .transition)
                == .accepted(sequence: UInt32(value + 1))
        )
    }
    #expect(admission.pendingCompactCount == 32)
    #expect(
        admission.admitCompact(32, category: .transition)
            == .rejected(.compactCapacityExhausted)
    )
}

@Test func sealingMergesThreeStoresInSequenceAndDefersLaterAdmission() {
    var admission = HostSequencedFactAdmission<String, String, String>(
        producerLimits: analyzerProducerLimits
    )!
    #expect(admission.admitCompact("compact", category: .transition) == .accepted(sequence: 1))
    #expect(admission.admitReservedFailure("failure") == .accepted(sequence: 2))
    #expect(admission.admitSnapshot("snapshot", category: .bootstrap) == .accepted(sequence: 3))
    let firstSeal = admission.seal()
    #expect(firstSeal)
    #expect(admission.sealedCount == 3)

    #expect(admission.admitCompact("later", category: .transition) == .accepted(sequence: 4))
    let overlappingSeal = admission.seal()
    #expect(!overlappingSeal)
    #expect(take(&admission) == TakenFact(sequence: 1, kind: .compact, value: "compact"))
    #expect(
        take(&admission)
            == TakenFact(sequence: 2, kind: .reservedFailure, value: "failure")
    )
    #expect(take(&admission) == TakenFact(sequence: 3, kind: .snapshot, value: "snapshot"))
    let exhaustedFirstBatch = admission.takeNextSealed()
    #expect(exhaustedFirstBatch == nil)

    let secondSeal = admission.seal()
    #expect(secondSeal)
    #expect(take(&admission) == TakenFact(sequence: 4, kind: .compact, value: "later"))
    let exhaustedSecondBatch = admission.takeNextSealed()
    #expect(exhaustedSecondBatch == nil)
}

@Test func separateSnapshotAndFailureSlotsRejectWithoutConsumingSequence() {
    var admission = HostSequencedFactAdmission<Int, Int, Int>(
        producerLimits: analyzerProducerLimits
    )!
    #expect(admission.admitSnapshot(1, category: .bootstrap) == .accepted(sequence: 1))
    #expect(
        admission.admitSnapshot(2, category: .bootstrap)
            == .rejected(.snapshotCapacityExhausted)
    )
    #expect(admission.admitReservedFailure(3) == .accepted(sequence: 2))
    #expect(
        admission.admitReservedFailure(4)
            == .rejected(.reservedFailureCapacityExhausted)
    )
    #expect(admission.admitCompact(5, category: .transition) == .accepted(sequence: 3))
}

@Test func maximumSequenceIsAcceptedOnceAndNeverAliases() {
    var admission = HostSequencedFactAdmission<Int, Int, Int>(
        producerLimits: analyzerProducerLimits,
        nextSequence: .max
    )!
    #expect(admission.admitCompact(1, category: .transition) == .accepted(sequence: .max))
    #expect(admission.admitCompact(2, category: .transition) == .rejected(.sequenceExhausted))
    #expect(admission.pendingCompactCount == 1)
}

@Test func quiescenceRejectsNewFactsAndDiscardRemovesEveryStore() {
    var admission = HostSequencedFactAdmission<Int, Int, Int>(
        producerLimits: analyzerProducerLimits
    )!
    _ = admission.admitSnapshot(1, category: .bootstrap)
    _ = admission.admitCompact(2, category: .transition)
    _ = admission.admitReservedFailure(3)
    let didSeal = admission.seal()
    #expect(didSeal)
    _ = admission.admitCompact(4, category: .transition)

    admission.quiesce()
    #expect(admission.admitCompact(5, category: .transition) == .rejected(.unavailable))
    admission.discardAll()
    #expect(admission.pendingSnapshotCount == 0)
    #expect(admission.pendingCompactCount == 0)
    #expect(admission.pendingReservedFailureCount == 0)
    #expect(admission.sealedCount == 0)
    let discarded = admission.takeNextSealed()
    #expect(discarded == nil)
}

private func acceptedSequence(_ outcome: HostFactAdmissionOutcome) -> UInt32 {
    guard case .accepted(let sequence) = outcome else {
        Issue.record("expected accepted fact")
        return 0
    }
    return sequence
}

private struct TakenFact: Equatable {
    let sequence: UInt32
    let kind: HostSequencedFactKind
    let value: String
}

private func take(
    _ admission: inout HostSequencedFactAdmission<String, String, String>
) -> TakenFact? {
    guard let fact = admission.takeNextSealed() else { return nil }
    return switch fact {
    case .snapshot(let value):
        TakenFact(sequence: value.sequence, kind: .snapshot, value: value.value)
    case .compact(let value):
        TakenFact(sequence: value.sequence, kind: .compact, value: value.value)
    case .reservedFailure(let value):
        TakenFact(sequence: value.sequence, kind: .reservedFailure, value: value.value)
    }
}
