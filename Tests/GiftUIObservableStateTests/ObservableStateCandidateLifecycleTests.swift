import GiftUIExecution
import Testing

@testable import GiftUIObservableState

private struct FixtureCandidateKey: Equatable, Sendable {
    let identity: UInt16
    let ordinal: UInt16
}

private struct FixtureFiniteCandidateStorage: Equatable, Sendable {
    private(set) var lifecycle: ObservableStateCandidateLifecycle
    private(set) var first: FixtureCandidateKey?
    private(set) var second: FixtureCandidateKey?

    init(limits: ObservableStateLimits) {
        lifecycle = ObservableStateCandidateLifecycle(limits: limits)
        first = nil
        second = nil
    }

    mutating func begin(
        phase: ExecutionPhase = .deriving,
        liveLocationCount: UInt16 = 0,
        registrationCount: UInt16 = 0
    ) -> ObservableStateResult {
        first = nil
        second = nil
        return lifecycle.beginCandidate(
            phase: phase,
            liveLocationCount: liveLocationCount,
            registrationCount: registrationCount
        )
    }

    mutating func encounter(
        _ key: FixtureCandidateKey,
        requiresNewLocation: Bool,
        requiresNewRegistration: Bool,
        changesAssociationSet: Bool
    ) -> ObservableStateError? {
        if let error = lifecycle.reserveEncounter(
            requiresNewLocation: requiresNewLocation,
            requiresNewRegistration: requiresNewRegistration,
            changesAssociationSet: changesAssociationSet
        ) {
            return error
        }
        if first == nil {
            first = key
        } else if second == nil {
            second = key
        } else {
            lifecycle.recordFailure(.associationStagingCapacityExhausted)
            return lifecycle.failure
        }
        return nil
    }

    mutating func finish(
        _ disposition: ObservableStateCandidateDisposition,
        phase: ExecutionPhase,
        publicationInvariantSatisfied: Bool = true
    ) -> ObservableStateResult {
        let result = lifecycle.finishCandidate(
            disposition,
            phase: phase,
            publicationInvariantSatisfied: publicationInvariantSatisfied
        )
        first = nil
        second = nil
        return result
    }

    mutating func recordFailure(_ error: ObservableStateError) {
        lifecycle.recordFailure(error)
    }

    mutating func reserveAfterFailure() -> ObservableStateError? {
        lifecycle.reserveEncounter(
            requiresNewLocation: false,
            requiresNewRegistration: false,
            changesAssociationSet: false
        )
    }
}

private let twoSlotLimits = ObservableStateLimits(
    maximumLocations: 2,
    maximumRegistrations: 2,
    maximumStagedAssociations: 2
)!

@Test
func candidateBeginsOnlyDuringDerivingAndRejectsNestedEntry() {
    for phase in ExecutionPhase.allFixtureCases where phase != .deriving {
        var storage = FixtureFiniteCandidateStorage(limits: twoSlotLimits)
        #expect(storage.begin(phase: phase) == .failure(.invalidPhaseContained))
        #expect(storage.lifecycle.isActive == false)
    }

    var storage = FixtureFiniteCandidateStorage(limits: twoSlotLimits)
    #expect(storage.begin() == .success(.candidateStarted))
    #expect(storage.begin() == .failure(.reentrancyViolation))
    #expect(storage.lifecycle.isActive)
}

@Test
func encounterReservesEveryResourceBeforeRecordingTheKey() {
    var storage = FixtureFiniteCandidateStorage(limits: twoSlotLimits)
    let first = FixtureCandidateKey(identity: 1, ordinal: 0)
    let second = FixtureCandidateKey(identity: 2, ordinal: 0)

    #expect(storage.begin() == .success(.candidateStarted))
    #expect(
        storage.encounter(
            first,
            requiresNewLocation: true,
            requiresNewRegistration: true,
            changesAssociationSet: true
        ) == nil
    )
    #expect(
        storage.encounter(
            second,
            requiresNewLocation: true,
            requiresNewRegistration: true,
            changesAssociationSet: true
        ) == nil
    )
    #expect(storage.first == first)
    #expect(storage.second == second)
    #expect(
        storage.finish(.publish, phase: .publishing)
            == .success(.associationsCommitted)
    )
}

@Test
func eachCandidateCapacityFailsBeforeTheRejectedAssociationIsRecorded() {
    var locationFull = FixtureFiniteCandidateStorage(limits: twoSlotLimits)
    #expect(locationFull.begin(liveLocationCount: 2) == .success(.candidateStarted))
    #expect(
        locationFull.encounter(
            FixtureCandidateKey(identity: 1, ordinal: 0),
            requiresNewLocation: true,
            requiresNewRegistration: false,
            changesAssociationSet: true
        ) == .locationCapacityExhausted
    )
    #expect(locationFull.first == nil)

    var registrationFull = FixtureFiniteCandidateStorage(limits: twoSlotLimits)
    #expect(registrationFull.begin(registrationCount: 2) == .success(.candidateStarted))
    #expect(
        registrationFull.encounter(
            FixtureCandidateKey(identity: 2, ordinal: 0),
            requiresNewLocation: false,
            requiresNewRegistration: true,
            changesAssociationSet: true
        ) == .registrationCapacityExhausted
    )
    #expect(registrationFull.first == nil)

    var associationFull = FixtureFiniteCandidateStorage(limits: twoSlotLimits)
    #expect(associationFull.begin() == .success(.candidateStarted))
    for identity in UInt16(1) ... UInt16(2) {
        #expect(
            associationFull.encounter(
                FixtureCandidateKey(identity: identity, ordinal: 0),
                requiresNewLocation: false,
                requiresNewRegistration: false,
                changesAssociationSet: false
            ) == nil
        )
    }
    #expect(
        associationFull.encounter(
            FixtureCandidateKey(identity: 3, ordinal: 0),
            requiresNewLocation: false,
            requiresNewRegistration: false,
            changesAssociationSet: false
        ) == .associationStagingCapacityExhausted
    )
}

@Test
func firstFailureIsStickyUntilDiscardCompletesCleanup() {
    var storage = FixtureFiniteCandidateStorage(limits: twoSlotLimits)
    #expect(storage.begin() == .success(.candidateStarted))
    storage.recordFailure(.duplicateOwner)
    storage.recordFailure(.incompatibleAssociation)
    #expect(storage.lifecycle.failure == .duplicateOwner)
    #expect(storage.reserveAfterFailure() == .duplicateOwner)
    #expect(storage.finish(.discard, phase: .deriving) == .success(.candidateDiscarded))
    #expect(storage.lifecycle.failure == nil)
}

@Test
func finishHasExactPublishDiscardAndInvariantResults() {
    var unchanged = FixtureFiniteCandidateStorage(limits: twoSlotLimits)
    #expect(unchanged.begin() == .success(.candidateStarted))
    #expect(unchanged.finish(.publish, phase: .publishing) == .success(.unchanged))

    var discarded = FixtureFiniteCandidateStorage(limits: twoSlotLimits)
    #expect(discarded.begin() == .success(.candidateStarted))
    #expect(discarded.finish(.discard, phase: .deriving) == .success(.candidateDiscarded))

    var invalidPublish = FixtureFiniteCandidateStorage(limits: twoSlotLimits)
    #expect(invalidPublish.begin() == .success(.candidateStarted))
    #expect(
        invalidPublish.finish(
            .publish,
            phase: .publishing,
            publicationInvariantSatisfied: false
        ) == .failure(.invariantViolation)
    )

    var noCandidate = FixtureFiniteCandidateStorage(limits: twoSlotLimits)
    #expect(
        noCandidate.finish(.discard, phase: .deriving)
            == .failure(.invalidPhaseSafetyNotProven)
    )
}

@Test
func completedCandidateStorageCanBeginACleanLaterAttempt() {
    var storage = FixtureFiniteCandidateStorage(limits: twoSlotLimits)
    #expect(storage.begin() == .success(.candidateStarted))
    #expect(storage.finish(.discard, phase: .deriving) == .success(.candidateDiscarded))
    #expect(storage.begin() == .success(.candidateStarted))
    #expect(storage.first == nil)
    #expect(storage.second == nil)
}

extension ExecutionPhase {
    fileprivate static let allFixtureCases: [ExecutionPhase] = [
        .idle,
        .admitting,
        .mutating,
        .deriving,
        .publishing,
        .offering,
        .finalizing,
    ]
}
