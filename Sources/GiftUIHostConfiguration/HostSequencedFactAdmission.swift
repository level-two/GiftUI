package enum HostFactProducerCategory: UInt8, Equatable, Sendable {
    case transition = 0
    case bootstrap = 1
    case action = 2
}

package struct HostFactProducerLimits: Equatable, Sendable {
    package let transition: UInt16
    package let bootstrap: UInt16
    package let action: UInt16

    package init?(transition: UInt16, bootstrap: UInt16, action: UInt16) {
        guard transition > 0, bootstrap > 0, action > 0 else { return nil }
        self.transition = transition
        self.bootstrap = bootstrap
        self.action = action
    }

    func limit(for category: HostFactProducerCategory) -> UInt16 {
        switch category {
        case .transition: transition
        case .bootstrap: bootstrap
        case .action: action
        }
    }
}

package enum HostFactAdmissionRejection: UInt8, Equatable, Sendable {
    case snapshotCapacityExhausted = 0
    case compactCapacityExhausted = 1
    case reservedFailureCapacityExhausted = 2
    case producerCategoryExhausted = 3
    case sequenceExhausted = 4
    case unavailable = 5
}

package enum HostFactAdmissionOutcome: Equatable, Sendable {
    case accepted(sequence: UInt32)
    case rejected(HostFactAdmissionRejection)
}

package enum HostSequencedFactKind: UInt8, Equatable, Sendable {
    case snapshot = 0
    case compact = 1
    case reservedFailure = 2
}

package struct HostSequencedFact<Fact: Sendable>: Sendable {
    package let sequence: UInt32
    package let value: Fact
}

package enum HostSealedFact<Snapshot, Compact, Failure>: Sendable
where Snapshot: Sendable, Compact: Sendable, Failure: Sendable {
    case snapshot(HostSequencedFact<Snapshot>)
    case compact(HostSequencedFact<Compact>)
    case reservedFailure(HostSequencedFact<Failure>)

    package var kind: HostSequencedFactKind {
        switch self {
        case .snapshot: .snapshot
        case .compact: .compact
        case .reservedFailure: .reservedFailure
        }
    }

    package var sequence: UInt32 {
        switch self {
        case .snapshot(let fact): fact.sequence
        case .compact(let fact): fact.sequence
        case .reservedFailure(let fact): fact.sequence
        }
    }
}

package struct HostSequencedFactAdmission<Snapshot, Compact, Failure>: ~Copyable
where Snapshot: Sendable, Compact: Sendable, Failure: Sendable {
    package static var compactCapacity: UInt16 { 32 }

    private let producerLimits: HostFactProducerLimits
    private var nextSequence: UInt32?
    private var activeSnapshot: HostSequencedFact<Snapshot>?
    private var activeCompact = HostCompactFactRing<Compact>()
    private var activeFailure: HostSequencedFact<Failure>?
    private var sealedSnapshot: HostSequencedFact<Snapshot>?
    private var sealedCompact = HostCompactFactRing<Compact>()
    private var sealedFailure: HostSequencedFact<Failure>?
    private var producerCounts = HostFactProducerCounts()
    private var hasSealedBatch = false
    private var isAvailable = true

    package init?(
        producerLimits: HostFactProducerLimits,
        nextSequence: UInt32 = 1
    ) {
        guard nextSequence > 0 else { return nil }
        self.producerLimits = producerLimits
        self.nextSequence = nextSequence
    }

    package var pendingSnapshotCount: UInt8 {
        activeSnapshot == nil ? 0 : 1
    }

    package var pendingCompactCount: UInt16 { activeCompact.count }

    package var pendingReservedFailureCount: UInt8 {
        activeFailure == nil ? 0 : 1
    }

    package var sealedCount: UInt16 {
        UInt16(sealedSnapshot == nil ? 0 : 1)
            + sealedCompact.count
            + UInt16(sealedFailure == nil ? 0 : 1)
    }

    package mutating func admitSnapshot(
        _ value: consuming Snapshot,
        category: HostFactProducerCategory
    ) -> HostFactAdmissionOutcome {
        guard isAvailable else { return .rejected(.unavailable) }
        guard producerCounts.canAccept(category, limits: producerLimits) else {
            return .rejected(.producerCategoryExhausted)
        }
        guard activeSnapshot == nil else {
            return .rejected(.snapshotCapacityExhausted)
        }
        guard let sequence = reserveSequence() else {
            return .rejected(.sequenceExhausted)
        }
        activeSnapshot = HostSequencedFact(sequence: sequence, value: value)
        producerCounts.record(category)
        return .accepted(sequence: sequence)
    }

    package mutating func admitCompact(
        _ value: consuming Compact,
        category: HostFactProducerCategory
    ) -> HostFactAdmissionOutcome {
        guard isAvailable else { return .rejected(.unavailable) }
        guard producerCounts.canAccept(category, limits: producerLimits) else {
            return .rejected(.producerCategoryExhausted)
        }
        guard activeCompact.count < Self.compactCapacity else {
            return .rejected(.compactCapacityExhausted)
        }
        guard let sequence = reserveSequence() else {
            return .rejected(.sequenceExhausted)
        }
        guard activeCompact.append(HostSequencedFact(sequence: sequence, value: value)) else {
            return .rejected(.compactCapacityExhausted)
        }
        producerCounts.record(category)
        return .accepted(sequence: sequence)
    }

    package mutating func admitReservedFailure(
        _ value: consuming Failure
    ) -> HostFactAdmissionOutcome {
        guard isAvailable else { return .rejected(.unavailable) }
        guard activeFailure == nil else {
            return .rejected(.reservedFailureCapacityExhausted)
        }
        guard let sequence = reserveSequence() else {
            return .rejected(.sequenceExhausted)
        }
        activeFailure = HostSequencedFact(sequence: sequence, value: value)
        return .accepted(sequence: sequence)
    }

    package mutating func seal() -> Bool {
        guard isAvailable, !hasSealedBatch else { return false }
        guard activeSnapshot != nil || activeCompact.count > 0 || activeFailure != nil else {
            return false
        }
        sealedSnapshot = activeSnapshot
        sealedCompact = activeCompact
        sealedFailure = activeFailure
        activeSnapshot = nil
        activeCompact = HostCompactFactRing()
        activeFailure = nil
        producerCounts = HostFactProducerCounts()
        hasSealedBatch = true
        return true
    }

    package mutating func takeNextSealed() -> HostSealedFact<Snapshot, Compact, Failure>? {
        guard hasSealedBatch else { return nil }
        let snapshotSequence = sealedSnapshot?.sequence
        let compactSequence = sealedCompact.first?.sequence
        let failureSequence = sealedFailure?.sequence
        guard let next = minimum(snapshotSequence, compactSequence, failureSequence) else {
            hasSealedBatch = false
            return nil
        }

        if snapshotSequence == next, let fact = sealedSnapshot.take() {
            finishSealedBatchIfEmpty()
            return .snapshot(fact)
        }
        if compactSequence == next, let fact = sealedCompact.takeFirst() {
            finishSealedBatchIfEmpty()
            return .compact(fact)
        }
        if failureSequence == next, let fact = sealedFailure.take() {
            finishSealedBatchIfEmpty()
            return .reservedFailure(fact)
        }
        return nil
    }

    package mutating func quiesce() {
        isAvailable = false
    }

    package mutating func discardAll() {
        isAvailable = false
        activeSnapshot = nil
        activeCompact = HostCompactFactRing()
        activeFailure = nil
        sealedSnapshot = nil
        sealedCompact = HostCompactFactRing()
        sealedFailure = nil
        producerCounts = HostFactProducerCounts()
        hasSealedBatch = false
    }

    private mutating func reserveSequence() -> UInt32? {
        guard let sequence = nextSequence else { return nil }
        nextSequence = sequence == .max ? nil : sequence + 1
        return sequence
    }

    private mutating func finishSealedBatchIfEmpty() {
        if sealedCount == 0 { hasSealedBatch = false }
    }

    private func minimum(_ first: UInt32?, _ second: UInt32?, _ third: UInt32?) -> UInt32? {
        var result = first
        if let second, result == nil || second < result! { result = second }
        if let third, result == nil || third < result! { result = third }
        return result
    }
}

private struct HostFactProducerCounts: Sendable {
    var transition: UInt16 = 0
    var bootstrap: UInt16 = 0
    var action: UInt16 = 0

    func canAccept(
        _ category: HostFactProducerCategory,
        limits: HostFactProducerLimits
    ) -> Bool {
        count(for: category) < limits.limit(for: category)
    }

    mutating func record(_ category: HostFactProducerCategory) {
        switch category {
        case .transition: transition += 1
        case .bootstrap: bootstrap += 1
        case .action: action += 1
        }
    }

    private func count(for category: HostFactProducerCategory) -> UInt16 {
        switch category {
        case .transition: transition
        case .bootstrap: bootstrap
        case .action: action
        }
    }
}

private struct HostCompactFactRing<Fact: Sendable>: Sendable {
    private typealias Entry = HostSequencedFact<Fact>
    private var values:
        (
            Entry?, Entry?, Entry?, Entry?, Entry?, Entry?, Entry?, Entry?,
            Entry?, Entry?, Entry?, Entry?, Entry?, Entry?, Entry?, Entry?,
            Entry?, Entry?, Entry?, Entry?, Entry?, Entry?, Entry?, Entry?,
            Entry?, Entry?, Entry?, Entry?, Entry?, Entry?, Entry?, Entry?
        )
    private var head: Int = 0
    private var tail: Int = 0
    private(set) var count: UInt16 = 0

    init() {
        values = (
            nil, nil, nil, nil, nil, nil, nil, nil,
            nil, nil, nil, nil, nil, nil, nil, nil,
            nil, nil, nil, nil, nil, nil, nil, nil,
            nil, nil, nil, nil, nil, nil, nil, nil
        )
    }

    var first: HostSequencedFact<Fact>? {
        count == 0 ? nil : value(at: head)
    }

    mutating func append(_ fact: consuming HostSequencedFact<Fact>) -> Bool {
        guard count < 32 else { return false }
        set(fact, at: tail)
        tail = (tail + 1) % 32
        count += 1
        return true
    }

    mutating func takeFirst() -> HostSequencedFact<Fact>? {
        guard count > 0 else { return nil }
        let fact = value(at: head)
        set(nil, at: head)
        head = (head + 1) % 32
        count -= 1
        return fact
    }

    private func value(at index: Int) -> Entry? {
        switch index {
        case 0: values.0
        case 1: values.1
        case 2: values.2
        case 3: values.3
        case 4: values.4
        case 5: values.5
        case 6: values.6
        case 7: values.7
        case 8: values.8
        case 9: values.9
        case 10: values.10
        case 11: values.11
        case 12: values.12
        case 13: values.13
        case 14: values.14
        case 15: values.15
        case 16: values.16
        case 17: values.17
        case 18: values.18
        case 19: values.19
        case 20: values.20
        case 21: values.21
        case 22: values.22
        case 23: values.23
        case 24: values.24
        case 25: values.25
        case 26: values.26
        case 27: values.27
        case 28: values.28
        case 29: values.29
        case 30: values.30
        case 31: values.31
        default: nil
        }
    }

    private mutating func set(_ value: Entry?, at index: Int) {
        switch index {
        case 0: values.0 = value
        case 1: values.1 = value
        case 2: values.2 = value
        case 3: values.3 = value
        case 4: values.4 = value
        case 5: values.5 = value
        case 6: values.6 = value
        case 7: values.7 = value
        case 8: values.8 = value
        case 9: values.9 = value
        case 10: values.10 = value
        case 11: values.11 = value
        case 12: values.12 = value
        case 13: values.13 = value
        case 14: values.14 = value
        case 15: values.15 = value
        case 16: values.16 = value
        case 17: values.17 = value
        case 18: values.18 = value
        case 19: values.19 = value
        case 20: values.20 = value
        case 21: values.21 = value
        case 22: values.22 = value
        case 23: values.23 = value
        case 24: values.24 = value
        case 25: values.25 = value
        case 26: values.26 = value
        case 27: values.27 = value
        case 28: values.28 = value
        case 29: values.29 = value
        case 30: values.30 = value
        case 31: values.31 = value
        default: break
        }
    }
}
