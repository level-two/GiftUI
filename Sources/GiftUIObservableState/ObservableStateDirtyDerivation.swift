import GiftUIExecution

struct ObservableStateDirtyLocations: OptionSet, Equatable, Sendable {
    let rawValue: UInt8

    init(rawValue: UInt8) {
        self.rawValue = rawValue & 0x03
    }

    static let first = Self(rawValue: 0x01)
    static let second = Self(rawValue: 0x02)
}

struct ObservableStateDirtyDerivation<Requester>: Sendable
where Requester: ExecutionWakeRequester & Sendable {
    private(set) var dirtyLocations: ObservableStateDirtyLocations = []
    private(set) var representedDirtyLocations: ObservableStateDirtyLocations = []
    private(set) var mutationFrozen = false
    private(set) var completeRootDerivationCount: UInt16 = 0
    private(set) var lastDerivedLocationCount: UInt16 = 0
    private(set) var appliedMutationCount: UInt16 = 0
    private(set) var semanticWakeOutstanding = false
    private(set) var requester: Requester

    init(requester: Requester) {
        self.requester = requester
    }

    mutating func recordChangedMutation(
        at location: ObservableStateDirtyLocations
    ) -> ObservableStateResult {
        guard !mutationFrozen else {
            return .failure(.invalidPhaseSafetyNotProven)
        }
        let (count, overflow) = appliedMutationCount.addingReportingOverflow(1)
        guard !overflow else { return .failure(.invariantViolation) }
        appliedMutationCount = count

        guard !dirtyLocations.contains(location) else {
            return .success(.coalesced)
        }
        dirtyLocations.formUnion(location)
        requestSemanticWakeIfNeeded()
        return .success(.dirtied)
    }

    mutating func takeWakeAtIdle() -> ExecutionWakeReasons? {
        guard semanticWakeOutstanding else { return nil }
        semanticWakeOutstanding = false
        return .semanticDirty
    }

    mutating func freezeAndDeriveCompleteRoot() -> ExecutionError? {
        guard !mutationFrozen else { return .reentrancyViolation }
        mutationFrozen = true
        representedDirtyLocations = dirtyLocations
        guard !representedDirtyLocations.isEmpty else {
            lastDerivedLocationCount = 0
            return nil
        }

        let (count, overflow) = completeRootDerivationCount.addingReportingOverflow(1)
        guard !overflow else { return .invariantViolation }
        completeRootDerivationCount = count
        lastDerivedLocationCount = 2
        return nil
    }

    mutating func finishDerivation(published: Bool) -> ExecutionError? {
        guard mutationFrozen else { return .invalidPhase }
        if published {
            dirtyLocations.subtract(representedDirtyLocations)
        } else if !dirtyLocations.isEmpty {
            requestSemanticWakeIfNeeded()
        }
        representedDirtyLocations = []
        mutationFrozen = false
        return nil
    }

    func finishFrame(accepted: Bool) -> ObservableStateDirtyLocations {
        _ = accepted
        return dirtyLocations
    }

    private mutating func requestSemanticWakeIfNeeded() {
        guard !semanticWakeOutstanding else { return }
        semanticWakeOutstanding = true
        requester.requestWake(for: .semanticDirty)
    }
}
