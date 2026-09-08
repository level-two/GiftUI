import GiftUI
import GiftUIExecution
import Testing

@testable import GiftUIObservableState

private let faultLimits = ObservableStateLimits(
    maximumLocations: 1,
    maximumRegistrations: 1,
    maximumStagedAssociations: 1
)!

private let expectedAttachment = _GiftUIObservationAttachment(
    slot: 0,
    generation: 7
)

private let mismatchedAttachment = _GiftUIObservationAttachment(
    slot: 0,
    generation: 8
)

@Test
func everyReservationFaultIsStickyAndDiscardRestoresReusableStorage() {
    let cases: [(UInt16, UInt16, ObservableStateError)] = [
        (1, 0, .locationCapacityExhausted),
        (0, 1, .registrationCapacityExhausted),
    ]

    for (locations, registrations, expected) in cases {
        var lifecycle = ObservableStateCandidateLifecycle(limits: faultLimits)
        #expect(
            lifecycle.beginCandidate(
                phase: .deriving,
                liveLocationCount: locations,
                registrationCount: registrations
            ) == .success(.candidateStarted)
        )
        #expect(
            lifecycle.reserveEncounter(
                requiresNewLocation: true,
                requiresNewRegistration: true,
                changesAssociationSet: true
            ) == expected
        )
        lifecycle.recordFailure(.invariantViolation)
        #expect(lifecycle.failure == expected)
        #expect(
            lifecycle.finishCandidate(.discard, phase: .deriving)
                == .success(.candidateDiscarded)
        )
        #expect(
            lifecycle.beginCandidate(
                phase: .deriving,
                liveLocationCount: 0,
                registrationCount: 0
            ) == .success(.candidateStarted)
        )
    }

    var associationFull = ObservableStateCandidateLifecycle(limits: faultLimits)
    #expect(
        associationFull.beginCandidate(
            phase: .deriving,
            liveLocationCount: 0,
            registrationCount: 0
        ) == .success(.candidateStarted)
    )
    #expect(
        associationFull.reserveEncounter(
            requiresNewLocation: false,
            requiresNewRegistration: false,
            changesAssociationSet: false
        ) == nil
    )
    #expect(
        associationFull.reserveEncounter(
            requiresNewLocation: false,
            requiresNewRegistration: false,
            changesAssociationSet: false
        ) == .associationStagingCapacityExhausted
    )
}

@Test
func nilAndMismatchedAttachmentReturnsInvalidateCandidateRoute() {
    for returned in [nil, mismatchedAttachment] {
        var registration = ObservableStateRegistrationLifecycle()
        #expect(registration.beginAttachment(expectedAttachment) == nil)
        #expect(
            registration.acceptAttachmentReturn(returned)
                == .staleAttachment
        )
        #expect(!registration.isActive)
        #expect(
            registration.acceptReport(expectedAttachment)
                == .staleAttachment
        )
    }
}

@Test
func reportDuringAttachPoisonsLaterMatchingReturnAndRoute() {
    var registration = ObservableStateRegistrationLifecycle()
    #expect(registration.beginAttachment(expectedAttachment) == nil)
    #expect(
        registration.acceptReport(expectedAttachment) == .staleAttachment
    )
    #expect(
        registration.acceptAttachmentReturn(expectedAttachment)
            == .staleAttachment
    )
    #expect(!registration.isActive)
    #expect(
        registration.acceptReport(expectedAttachment) == .staleAttachment
    )
}

@Test
func mismatchedDetachDoesNotRetireTheInstalledRegistration() {
    var registration = ObservableStateRegistrationLifecycle()
    #expect(registration.beginAttachment(expectedAttachment) == nil)
    #expect(registration.acceptAttachmentReturn(expectedAttachment) == nil)
    #expect(registration.isActive)

    #expect(
        registration.retire(attachment: mismatchedAttachment)
            == .invariantViolation
    )
    #expect(registration.isActive)
    #expect(registration.acceptReport(expectedAttachment) == nil)

    #expect(registration.retire(attachment: expectedAttachment) == nil)
    #expect(!registration.isActive)
    #expect(
        registration.acceptReport(expectedAttachment) == .staleAttachment
    )
}

@Test
func shutdownInvalidatesBeforeOneRequiredDetach() {
    var registration = ObservableStateRegistrationLifecycle()
    #expect(registration.beginAttachment(expectedAttachment) == nil)
    #expect(registration.acceptAttachmentReturn(expectedAttachment) == nil)
    let firstShutdown = registration.shutdown()
    let repeatedShutdown = registration.shutdown()
    #expect(firstShutdown)
    #expect(!repeatedShutdown)
    #expect(registration.isShutdown)
    #expect(
        registration.acceptReport(expectedAttachment) == .staleAttachment
    )
    #expect(
        registration.beginAttachment(mismatchedAttachment)
            == .invalidPhaseSafetyNotProven
    )
}

@Test
func finishInvariantFailureClearsCandidateAndPreservesFirstFailure() {
    var lifecycle = ObservableStateCandidateLifecycle(limits: faultLimits)
    #expect(
        lifecycle.beginCandidate(
            phase: .deriving,
            liveLocationCount: 0,
            registrationCount: 0
        ) == .success(.candidateStarted)
    )
    lifecycle.recordFailure(.duplicateOwner)
    lifecycle.recordFailure(.incompatibleAssociation)
    #expect(lifecycle.failure == .duplicateOwner)
    #expect(
        lifecycle.finishCandidate(
            .publish,
            phase: .publishing,
            publicationInvariantSatisfied: false
        ) == .failure(.invariantViolation)
    )
    #expect(!lifecycle.isActive)
    #expect(lifecycle.failure == nil)
}
