import GiftUI

package struct ObservableStateLimits: Equatable, Sendable {
    package let maximumLocations: UInt16
    package let maximumRegistrations: UInt16
    package let maximumStagedAssociations: UInt16

    package init?(
        maximumLocations: UInt16,
        maximumRegistrations: UInt16,
        maximumStagedAssociations: UInt16
    ) {
        guard maximumLocations > 0,
            maximumRegistrations >= maximumLocations,
            maximumStagedAssociations >= maximumLocations
        else { return nil }

        self.maximumLocations = maximumLocations
        self.maximumRegistrations = maximumRegistrations
        self.maximumStagedAssociations = maximumStagedAssociations
    }
}

package enum ObservableStateError: UInt8, Error, Equatable, Sendable {
    case locationCapacityExhausted = 0
    case registrationCapacityExhausted = 1
    case associationStagingCapacityExhausted = 2
    case replacementStagingCapacityExhausted = 3
    case registrationGenerationExhausted = 4
    case duplicateOwner = 5
    case incompatibleAssociation = 6
    case staleAttachment = 7
    case invalidPhaseContained = 8
    case invalidPhaseSafetyNotProven = 9
    case reentrancyViolation = 10
    case invariantViolation = 11
    case modelCapacityExhausted = 12
    case ownerCapacityExhausted = 13
    case retainedModel = 14
    case modelGenerationExhausted = 15
    case staleModel = 16
    case modelReadOutOfBounds = 17

    package init(accessFailure: _GiftUIAccessFailure) {
        switch accessFailure {
        case .invalidPhase: self = .invalidPhaseSafetyNotProven
        case .wrongOwner, .wrongSchema, .staleModel: self = .staleModel
        case .outOfBounds: self = .modelReadOutOfBounds
        }
    }
}

package enum ObservableStateOperational: UInt8, Equatable, Sendable {
    case unchanged = 0
    case candidateStarted = 1
    case materialized = 2
    case preserved = 3
    case candidateDiscarded = 4
    case associationsCommitted = 5
    case replaced = 6
    case dirtied = 7
    case coalesced = 8
}

package enum ObservableStateResult: Equatable, Sendable {
    case success(ObservableStateOperational)
    case failure(ObservableStateError)
}

package enum ObservableStateCandidateDisposition: UInt8, Equatable, Sendable {
    case publish = 0
    case discard = 1
}
