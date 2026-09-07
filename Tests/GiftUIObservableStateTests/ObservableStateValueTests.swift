import Testing

@testable import GiftUIObservableState

private func requireSendable<Value: Sendable>(_: Value.Type) {}

@Test
func observableStateLimitsValidateEveryRequiredRelation() {
    let equalToLimit = ObservableStateLimits(
        maximumLocations: 2,
        maximumRegistrations: 2,
        maximumStagedAssociations: 2
    )
    #expect(equalToLimit?.maximumLocations == 2)
    #expect(equalToLimit?.maximumRegistrations == 2)
    #expect(equalToLimit?.maximumStagedAssociations == 2)

    #expect(
        ObservableStateLimits(
            maximumLocations: 0,
            maximumRegistrations: 2,
            maximumStagedAssociations: 2
        ) == nil
    )
    #expect(
        ObservableStateLimits(
            maximumLocations: 2,
            maximumRegistrations: 1,
            maximumStagedAssociations: 2
        ) == nil
    )
    #expect(
        ObservableStateLimits(
            maximumLocations: 2,
            maximumRegistrations: 2,
            maximumStagedAssociations: 1
        ) == nil
    )
    #expect(
        ObservableStateLimits(
            maximumLocations: .max,
            maximumRegistrations: .max,
            maximumStagedAssociations: .max
        ) != nil
    )
}

@Test
func observableStateErrorsHaveExactClosedRawValues() {
    let cases: [(ObservableStateError, UInt8)] = [
        (.locationCapacityExhausted, 0),
        (.registrationCapacityExhausted, 1),
        (.associationStagingCapacityExhausted, 2),
        (.replacementStagingCapacityExhausted, 3),
        (.registrationGenerationExhausted, 4),
        (.duplicateOwner, 5),
        (.incompatibleAssociation, 6),
        (.staleAttachment, 7),
        (.invalidPhaseContained, 8),
        (.invalidPhaseSafetyNotProven, 9),
        (.reentrancyViolation, 10),
        (.invariantViolation, 11),
    ]

    for (value, rawValue) in cases {
        #expect(value.rawValue == rawValue)
        #expect(ObservableStateError(rawValue: rawValue) == value)
    }
    #expect(ObservableStateError(rawValue: 12) == nil)
    #expect(ObservableStateError(rawValue: .max) == nil)
}

@Test
func observableStateOperationalValuesHaveExactClosedRawValues() {
    let cases: [(ObservableStateOperational, UInt8)] = [
        (.unchanged, 0),
        (.candidateStarted, 1),
        (.materialized, 2),
        (.preserved, 3),
        (.candidateDiscarded, 4),
        (.associationsCommitted, 5),
        (.replaced, 6),
        (.dirtied, 7),
        (.coalesced, 8),
    ]

    for (value, rawValue) in cases {
        #expect(value.rawValue == rawValue)
        #expect(ObservableStateOperational(rawValue: rawValue) == value)
    }
    #expect(ObservableStateOperational(rawValue: 9) == nil)
    #expect(ObservableStateOperational(rawValue: .max) == nil)
}

@Test
func candidateDispositionsHaveExactClosedRawValues() {
    #expect(ObservableStateCandidateDisposition.publish.rawValue == 0)
    #expect(ObservableStateCandidateDisposition.discard.rawValue == 1)
    #expect(ObservableStateCandidateDisposition(rawValue: 2) == nil)
    #expect(ObservableStateCandidateDisposition(rawValue: .max) == nil)
}

@Test
func resultPreservesEveryExactSuccessAndFailureValue() {
    let operationSuccesses: [ObservableStateOperational] = [
        .candidateStarted,
        .materialized,
        .preserved,
        .candidateDiscarded,
        .associationsCommitted,
        .unchanged,
        .replaced,
        .dirtied,
        .coalesced,
    ]
    for value in operationSuccesses {
        #expect(ObservableStateResult.success(value) == .success(value))
    }

    for rawValue in UInt8(0) ... UInt8(11) {
        let error = ObservableStateError(rawValue: rawValue)!
        #expect(ObservableStateResult.failure(error) == .failure(error))
    }
}

@Test
func ownerValuesHaveBoundedLayoutsAndSendableEvidence() {
    #expect(MemoryLayout<ObservableStateLimits>.size == 6)
    #expect(MemoryLayout<ObservableStateLimits>.stride == 6)
    #expect(MemoryLayout<ObservableStateError>.size == 1)
    #expect(MemoryLayout<ObservableStateOperational>.size == 1)
    #expect(MemoryLayout<ObservableStateResult>.size == 1)
    #expect(MemoryLayout<ObservableStateCandidateDisposition>.size == 1)

    requireSendable(ObservableStateLimits.self)
    requireSendable(ObservableStateError.self)
    requireSendable(ObservableStateOperational.self)
    requireSendable(ObservableStateResult.self)
    requireSendable(ObservableStateCandidateDisposition.self)
}
