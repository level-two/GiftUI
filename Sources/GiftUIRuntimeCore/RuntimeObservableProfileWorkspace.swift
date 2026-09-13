import GiftUI
import GiftUIExecution
import GiftUIObservableState

package struct RuntimeObservableProfileSlot<Identity>: Equatable, Sendable
where Identity: Equatable & Sendable {
    package var identity: Identity?
    package var declarationOrdinal: UInt16
    package var generation: ObservableTargetGeneration?
    package var candidateGeneration: ObservableTargetGeneration?
    package var wasEncountered: Bool

    package init(
        identity: Identity? = nil,
        declarationOrdinal: UInt16 = 0,
        generation: ObservableTargetGeneration? = nil,
        candidateGeneration: ObservableTargetGeneration? = nil,
        wasEncountered: Bool = false
    ) {
        self.identity = identity
        self.declarationOrdinal = declarationOrdinal
        self.generation = generation
        self.candidateGeneration = candidateGeneration
        self.wasEncountered = wasEncountered
    }
}

package protocol RuntimeObservableProfileSlotStorage {
    associatedtype Identity: Equatable & Sendable

    var capacity: UInt16 { get }
    borrowing func slot(
        at index: UInt16
    ) -> RuntimeObservableProfileSlot<Identity>?
    mutating func update(
        _ slot: RuntimeObservableProfileSlot<Identity>,
        at index: UInt16
    ) -> Bool
}

package struct RuntimeObservableProfileWorkspace<Storage>:
    ObservableStateReconciler, ObservableStateTargetView
where Storage: RuntimeObservableProfileSlotStorage {
    package typealias StructuralIdentity = Storage.Identity

    private var storage: Storage
    private var isCandidateActive: Bool
    private var nextGeneration: UInt32?

    package init(storage: consuming Storage, firstGeneration: UInt32 = 1) {
        self.storage = consume storage
        isCandidateActive = false
        nextGeneration = firstGeneration == 0 ? nil : firstGeneration
    }

    package mutating func beginCandidate() -> ObservableStateResult {
        guard !isCandidateActive else { return .failure(.reentrancyViolation) }
        isCandidateActive = true
        for index in 0 ..< storage.capacity {
            guard var slot = storage.slot(at: index) else {
                return .failure(.invariantViolation)
            }
            slot.wasEncountered = false
            slot.candidateGeneration = nil
            guard storage.update(slot, at: index) else {
                return .failure(.invariantViolation)
            }
        }
        return .success(.candidateStarted)
    }

    package mutating func encounter<Model: _GiftUIObservableReference>(
        structuralIdentity: Storage.Identity,
        declarationOrdinal: UInt16,
        state: inout State<Model>
    ) -> ObservableStateResult {
        _ = state
        guard isCandidateActive else {
            return .failure(.invalidPhaseSafetyNotProven)
        }

        for index in 0 ..< storage.capacity {
            guard var slot = storage.slot(at: index) else {
                return .failure(.invariantViolation)
            }
            if slot.identity == structuralIdentity,
                slot.declarationOrdinal == declarationOrdinal,
                slot.generation != nil
            {
                slot.wasEncountered = true
                guard storage.update(slot, at: index) else {
                    return .failure(.invariantViolation)
                }
                return .success(.preserved)
            }
        }

        var availableIndex: UInt16?
        for index in 0 ..< storage.capacity {
            guard let slot = storage.slot(at: index) else {
                return .failure(.invariantViolation)
            }
            if slot.identity == nil {
                availableIndex = index
                break
            }
        }
        guard let availableIndex else {
            return .failure(.locationCapacityExhausted)
        }
        guard let generation = reserveGeneration() else {
            return .failure(.registrationGenerationExhausted)
        }
        guard var slot = storage.slot(at: availableIndex) else {
            return .failure(.invariantViolation)
        }
        slot.identity = structuralIdentity
        slot.declarationOrdinal = declarationOrdinal
        slot.candidateGeneration = generation
        slot.wasEncountered = true
        guard storage.update(slot, at: availableIndex) else {
            return .failure(.invariantViolation)
        }
        return .success(.materialized)
    }

    package mutating func finishCandidate(
        _ disposition: ObservableStateCandidateDisposition
    ) -> ObservableStateResult {
        guard isCandidateActive else {
            return .failure(.invalidPhaseSafetyNotProven)
        }
        defer { isCandidateActive = false }

        var changed = false
        for index in 0 ..< storage.capacity {
            guard var slot = storage.slot(at: index) else {
                return .failure(.invariantViolation)
            }
            switch disposition {
            case .discard:
                if slot.generation == nil, slot.candidateGeneration != nil {
                    slot = RuntimeObservableProfileSlot<Storage.Identity>()
                } else {
                    slot.candidateGeneration = nil
                    slot.wasEncountered = false
                }
            case .publish:
                if !slot.wasEncountered, slot.generation != nil {
                    slot = RuntimeObservableProfileSlot<Storage.Identity>()
                    changed = true
                } else if let generation = slot.candidateGeneration {
                    slot.generation = generation
                    slot.candidateGeneration = nil
                    slot.wasEncountered = false
                    changed = true
                } else {
                    slot.wasEncountered = false
                }
            }
            guard storage.update(slot, at: index) else {
                return .failure(.invariantViolation)
            }
        }

        if disposition == .discard {
            return .success(.candidateDiscarded)
        }
        return changed ? .success(.associationsCommitted) : .success(.unchanged)
    }

    package borrowing func targetGeneration(
        structuralIdentity: Storage.Identity,
        declarationOrdinal: UInt16
    ) -> ObservableTargetGeneration? {
        matching(structuralIdentity, declarationOrdinal)?.generation
    }

    package borrowing func publishableTargetGeneration(
        structuralIdentity: Storage.Identity,
        declarationOrdinal: UInt16
    ) -> ObservableTargetGeneration? {
        guard
            let slot = matching(structuralIdentity, declarationOrdinal),
            slot.wasEncountered
        else { return nil }
        return slot.candidateGeneration ?? slot.generation
    }

    private borrowing func matching(
        _ identity: Storage.Identity,
        _ declarationOrdinal: UInt16
    ) -> RuntimeObservableProfileSlot<Storage.Identity>? {
        for index in 0 ..< storage.capacity {
            guard let slot = storage.slot(at: index) else { return nil }
            if slot.identity == identity,
                slot.declarationOrdinal == declarationOrdinal
            {
                return slot
            }
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
