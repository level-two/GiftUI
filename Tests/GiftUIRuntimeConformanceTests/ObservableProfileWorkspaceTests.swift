import GiftUI
import GiftUIExecution
import GiftUIObservableState
import Testing

private struct ProfileIdentity: Equatable, Sendable {
    let rawValue: UInt16
}

private struct ProfileSlot: Equatable, Sendable {
    var identity: ProfileIdentity?
    var ordinal: UInt16
    var generation: ObservableTargetGeneration?
    var candidateGeneration: ObservableTargetGeneration?
    var seen: Bool

    static let empty = Self(
        identity: nil,
        ordinal: 0,
        generation: nil,
        candidateGeneration: nil,
        seen: false
    )
}

private protocol ProfileSlotStorage {
    var capacity: UInt16 { get }
    func slot(at index: UInt16) -> ProfileSlot?
    mutating func update(_ slot: ProfileSlot, at index: UInt16) -> Bool
}

private struct DynamicProfileSlots: ProfileSlotStorage {
    private var slots: [ProfileSlot]

    init(capacity: UInt16) {
        slots = [ProfileSlot](repeating: .empty, count: Int(capacity))
    }

    var capacity: UInt16 { UInt16(slots.count) }

    func slot(at index: UInt16) -> ProfileSlot? {
        guard Int(index) < slots.count else { return nil }
        return slots[Int(index)]
    }

    mutating func update(_ slot: ProfileSlot, at index: UInt16) -> Bool {
        guard Int(index) < slots.count else { return false }
        slots[Int(index)] = slot
        return true
    }
}

private struct StaticProfileSlots: ProfileSlotStorage {
    private var first = ProfileSlot.empty
    private var second = ProfileSlot.empty

    var capacity: UInt16 { 2 }

    func slot(at index: UInt16) -> ProfileSlot? {
        switch index {
        case 0: first
        case 1: second
        default: nil
        }
    }

    mutating func update(_ slot: ProfileSlot, at index: UInt16) -> Bool {
        switch index {
        case 0:
            first = slot
            return true
        case 1:
            second = slot
            return true
        default:
            return false
        }
    }
}

private struct ProfileWorkspace<Storage>: ObservableStateReconciler,
    ObservableStateTargetView
where Storage: ProfileSlotStorage {
    private var storage: Storage
    private var active = false
    private var nextGeneration: UInt32?

    init(storage: Storage, nextGeneration: UInt32? = 1) {
        self.storage = storage
        self.nextGeneration = nextGeneration
    }

    mutating func beginCandidate() -> ObservableStateResult {
        guard !active else { return .failure(.reentrancyViolation) }
        active = true
        for index in 0 ..< storage.capacity {
            guard var slot = storage.slot(at: index) else {
                return .failure(.invariantViolation)
            }
            slot.seen = false
            slot.candidateGeneration = nil
            guard storage.update(slot, at: index) else {
                return .failure(.invariantViolation)
            }
        }
        return .success(.candidateStarted)
    }

    mutating func encounter<Model: _GiftUIObservableReference>(
        structuralIdentity: ProfileIdentity,
        declarationOrdinal: UInt16,
        state: inout State<Model>
    ) -> ObservableStateResult {
        _ = state
        guard active else { return .failure(.invalidPhaseSafetyNotProven) }

        for index in 0 ..< storage.capacity {
            guard var slot = storage.slot(at: index) else {
                return .failure(.invariantViolation)
            }
            if slot.identity == structuralIdentity,
                slot.ordinal == declarationOrdinal,
                slot.generation != nil
            {
                slot.seen = true
                guard storage.update(slot, at: index) else {
                    return .failure(.invariantViolation)
                }
                return .success(.preserved)
            }
        }

        var emptyIndex: UInt16?
        for index in 0 ..< storage.capacity {
            guard let slot = storage.slot(at: index) else {
                return .failure(.invariantViolation)
            }
            if slot.identity == nil {
                emptyIndex = index
                break
            }
        }
        guard let emptyIndex else { return .failure(.locationCapacityExhausted) }
        guard let generation = reserveGeneration() else {
            return .failure(.registrationGenerationExhausted)
        }
        guard var slot = storage.slot(at: emptyIndex) else {
            return .failure(.invariantViolation)
        }
        slot.identity = structuralIdentity
        slot.ordinal = declarationOrdinal
        slot.candidateGeneration = generation
        slot.seen = true
        guard storage.update(slot, at: emptyIndex) else {
            return .failure(.invariantViolation)
        }
        return .success(.materialized)
    }

    mutating func finishCandidate(
        _ disposition: ObservableStateCandidateDisposition
    ) -> ObservableStateResult {
        guard active else { return .failure(.invalidPhaseSafetyNotProven) }
        defer { active = false }
        var changed = false
        for index in 0 ..< storage.capacity {
            guard var slot = storage.slot(at: index) else {
                return .failure(.invariantViolation)
            }
            switch disposition {
            case .discard:
                if slot.generation == nil, slot.candidateGeneration != nil {
                    slot = .empty
                } else {
                    slot.candidateGeneration = nil
                    slot.seen = false
                }
            case .publish:
                if !slot.seen, slot.generation != nil {
                    slot = .empty
                    changed = true
                } else if let generation = slot.candidateGeneration {
                    slot.generation = generation
                    slot.candidateGeneration = nil
                    slot.seen = false
                    changed = true
                } else {
                    slot.seen = false
                }
            }
            guard storage.update(slot, at: index) else {
                return .failure(.invariantViolation)
            }
        }
        if disposition == .discard { return .success(.candidateDiscarded) }
        return changed ? .success(.associationsCommitted) : .success(.unchanged)
    }

    func targetGeneration(
        structuralIdentity: ProfileIdentity,
        declarationOrdinal: UInt16
    ) -> ObservableTargetGeneration? {
        matching(structuralIdentity, declarationOrdinal)?.generation
    }

    func publishableTargetGeneration(
        structuralIdentity: ProfileIdentity,
        declarationOrdinal: UInt16
    ) -> ObservableTargetGeneration? {
        guard let slot = matching(structuralIdentity, declarationOrdinal), slot.seen else {
            return nil
        }
        return slot.candidateGeneration ?? slot.generation
    }

    private func matching(
        _ identity: ProfileIdentity,
        _ ordinal: UInt16
    ) -> ProfileSlot? {
        for index in 0 ..< storage.capacity {
            guard let slot = storage.slot(at: index) else { return nil }
            if slot.identity == identity, slot.ordinal == ordinal { return slot }
        }
        return nil
    }

    private mutating func reserveGeneration() -> ObservableTargetGeneration? {
        guard let current = nextGeneration else { return nil }
        let next = current.addingReportingOverflow(1)
        nextGeneration = next.overflow ? nil : next.partialValue
        return ObservableTargetGeneration(rawValue: current)
    }
}

private struct ProfileModel: _GiftUIObservableReference {
    mutating func _giftUIAttachChangeSink(
        _ sink: consuming _GiftUIObservableChangeSink
    ) -> _GiftUIObservationAttachment? {
        sink.attachment
    }

    mutating func _giftUIDetachChangeSink(
        _ attachment: _GiftUIObservationAttachment
    ) {}
}

private struct ProfileTranscript: Equatable {
    let initial: ObservableStateResult
    let firstGeneration: ObservableTargetGeneration?
    let published: ObservableStateResult
    let preserved: ObservableStateResult
    let preservedGeneration: ObservableTargetGeneration?
    let secondOrdinal: ObservableStateResult
    let secondGeneration: ObservableTargetGeneration?
    let removedFirstGeneration: ObservableTargetGeneration?
}

private func runCorpus<Storage: ProfileSlotStorage>(
    storage: Storage
) -> ProfileTranscript {
    let identity = ProfileIdentity(rawValue: 7)
    var first = State(wrappedValue: ProfileModel())
    var second = State(wrappedValue: ProfileModel())
    var workspace = ProfileWorkspace(storage: storage)

    _ = workspace.beginCandidate()
    let initial = workspace.encounter(
        structuralIdentity: identity,
        declarationOrdinal: 0,
        state: &first
    )
    let firstGeneration = workspace.publishableTargetGeneration(
        structuralIdentity: identity,
        declarationOrdinal: 0
    )
    let published = workspace.finishCandidate(.publish)

    _ = workspace.beginCandidate()
    let preserved = workspace.encounter(
        structuralIdentity: identity,
        declarationOrdinal: 0,
        state: &first
    )
    let preservedGeneration = workspace.publishableTargetGeneration(
        structuralIdentity: identity,
        declarationOrdinal: 0
    )
    _ = workspace.finishCandidate(.publish)

    _ = workspace.beginCandidate()
    let secondOrdinal = workspace.encounter(
        structuralIdentity: identity,
        declarationOrdinal: 1,
        state: &second
    )
    let secondGeneration = workspace.publishableTargetGeneration(
        structuralIdentity: identity,
        declarationOrdinal: 1
    )
    _ = workspace.finishCandidate(.publish)

    return ProfileTranscript(
        initial: initial,
        firstGeneration: firstGeneration,
        published: published,
        preserved: preserved,
        preservedGeneration: preservedGeneration,
        secondOrdinal: secondOrdinal,
        secondGeneration: secondGeneration,
        removedFirstGeneration: workspace.targetGeneration(
            structuralIdentity: identity,
            declarationOrdinal: 0
        )
    )
}

@Test
func observableProfileWorkspacesProduceEqualFiniteTranscripts() {
    let dynamic = runCorpus(storage: DynamicProfileSlots(capacity: 2))
    let `static` = runCorpus(storage: StaticProfileSlots())

    #expect(dynamic == `static`)
    #expect(dynamic.initial == .success(.materialized))
    #expect(dynamic.firstGeneration == ObservableTargetGeneration(rawValue: 1))
    #expect(dynamic.published == .success(.associationsCommitted))
    #expect(dynamic.preserved == .success(.preserved))
    #expect(dynamic.preservedGeneration == dynamic.firstGeneration)
    #expect(dynamic.secondOrdinal == .success(.materialized))
    #expect(dynamic.secondGeneration == ObservableTargetGeneration(rawValue: 2))
    #expect(dynamic.removedFirstGeneration == nil)
}

@Test
func observableProfileWorkspacesRejectExactFirstExcessAndGenerationExhaustion() {
    let identity = ProfileIdentity(rawValue: 9)
    var first = State(wrappedValue: ProfileModel())
    var second = State(wrappedValue: ProfileModel())
    var dynamic = ProfileWorkspace(storage: DynamicProfileSlots(capacity: 1))
    #expect(dynamic.beginCandidate() == .success(.candidateStarted))
    #expect(
        dynamic.encounter(
            structuralIdentity: identity,
            declarationOrdinal: 0,
            state: &first
        ) == .success(.materialized)
    )
    #expect(
        dynamic.encounter(
            structuralIdentity: identity,
            declarationOrdinal: 1,
            state: &second
        ) == .failure(.locationCapacityExhausted)
    )

    var exhausted = ProfileWorkspace(
        storage: StaticProfileSlots(),
        nextGeneration: nil
    )
    #expect(exhausted.beginCandidate() == .success(.candidateStarted))
    #expect(
        exhausted.encounter(
            structuralIdentity: identity,
            declarationOrdinal: 0,
            state: &first
        ) == .failure(.registrationGenerationExhausted)
    )
}

@Test
func staticObservableProfileStorageIsFixedAndValueTyped() {
    #expect(MemoryLayout<StaticProfileSlots>.size <= 2 * MemoryLayout<ProfileSlot>.stride)
    #expect(MemoryLayout<StaticProfileSlots>.stride == 2 * MemoryLayout<ProfileSlot>.stride)
}
