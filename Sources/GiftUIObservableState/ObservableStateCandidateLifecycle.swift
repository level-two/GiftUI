import GiftUIExecution

struct ObservableStateCandidateLifecycle: Equatable, Sendable {
    private enum State: UInt8, Equatable, Sendable {
        case inactive = 0
        case active = 1
    }

    private let limits: ObservableStateLimits
    private var state: State
    private var reservedLocationCount: UInt16
    private var reservedRegistrationCount: UInt16
    private var stagedAssociationCount: UInt16
    private var hasAssociationChanges: Bool
    private var firstFailure: ObservableStateError?

    init(limits: ObservableStateLimits) {
        self.limits = limits
        state = .inactive
        reservedLocationCount = 0
        reservedRegistrationCount = 0
        stagedAssociationCount = 0
        hasAssociationChanges = false
        firstFailure = nil
    }

    var isActive: Bool {
        state == .active
    }

    var failure: ObservableStateError? {
        firstFailure
    }

    mutating func beginCandidate(
        phase: ExecutionPhase,
        liveLocationCount: UInt16,
        registrationCount: UInt16
    ) -> ObservableStateResult {
        guard state == .inactive else {
            return .failure(.reentrancyViolation)
        }
        guard phase == .deriving else {
            return .failure(.invalidPhaseContained)
        }
        guard liveLocationCount <= limits.maximumLocations else {
            return .failure(.invariantViolation)
        }
        guard registrationCount <= limits.maximumRegistrations else {
            return .failure(.invariantViolation)
        }

        state = .active
        reservedLocationCount = liveLocationCount
        reservedRegistrationCount = registrationCount
        stagedAssociationCount = 0
        hasAssociationChanges = false
        firstFailure = nil
        return .success(.candidateStarted)
    }

    mutating func reserveEncounter(
        requiresNewLocation: Bool,
        requiresNewRegistration: Bool,
        changesAssociationSet: Bool
    ) -> ObservableStateError? {
        guard state == .active else {
            return .invalidPhaseSafetyNotProven
        }
        if let firstFailure {
            return firstFailure
        }

        guard let nextAssociationCount = checkedSuccessor(stagedAssociationCount),
            nextAssociationCount <= limits.maximumStagedAssociations
        else {
            return record(.associationStagingCapacityExhausted)
        }

        var nextLocationCount = reservedLocationCount
        if requiresNewLocation {
            guard let successor = checkedSuccessor(nextLocationCount),
                successor <= limits.maximumLocations
            else {
                return record(.locationCapacityExhausted)
            }
            nextLocationCount = successor
        }

        var nextRegistrationCount = reservedRegistrationCount
        if requiresNewRegistration {
            guard let successor = checkedSuccessor(nextRegistrationCount),
                successor <= limits.maximumRegistrations
            else {
                return record(.registrationCapacityExhausted)
            }
            nextRegistrationCount = successor
        }

        stagedAssociationCount = nextAssociationCount
        reservedLocationCount = nextLocationCount
        reservedRegistrationCount = nextRegistrationCount
        hasAssociationChanges = hasAssociationChanges || changesAssociationSet
        return nil
    }

    mutating func recordFailure(_ error: ObservableStateError) {
        _ = record(error)
    }

    mutating func finishCandidate(
        _ disposition: ObservableStateCandidateDisposition,
        phase: ExecutionPhase,
        publicationInvariantSatisfied: Bool = true
    ) -> ObservableStateResult {
        guard state == .active else {
            return .failure(.invalidPhaseSafetyNotProven)
        }

        switch disposition {
        case .discard:
            guard phase == .deriving || phase == .publishing else {
                return .failure(.invalidPhaseSafetyNotProven)
            }
            resetCandidate()
            return .success(.candidateDiscarded)
        case .publish:
            guard phase == .publishing else {
                return .failure(.invalidPhaseSafetyNotProven)
            }
            guard firstFailure == nil, publicationInvariantSatisfied else {
                resetCandidate()
                return .failure(.invariantViolation)
            }
            let result: ObservableStateResult =
                hasAssociationChanges
                ? .success(.associationsCommitted)
                : .success(.unchanged)
            resetCandidate()
            return result
        }
    }

    private func checkedSuccessor(_ value: UInt16) -> UInt16? {
        let successor = value.addingReportingOverflow(1)
        return successor.overflow ? nil : successor.partialValue
    }

    private mutating func record(
        _ error: ObservableStateError
    ) -> ObservableStateError {
        if firstFailure == nil {
            firstFailure = error
        }
        return firstFailure!
    }

    private mutating func resetCandidate() {
        state = .inactive
        reservedLocationCount = 0
        reservedRegistrationCount = 0
        stagedAssociationCount = 0
        hasAssociationChanges = false
        firstFailure = nil
    }
}
