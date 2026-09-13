import GiftUIDisplayCore
import GiftUIFailureCore
import GiftUIRasterCore
import Testing

@testable import GiftUIBackendIntegration

@Test
func constructionFailuresMapWithExactOwnerAndContainment() {
    assertRasterMapping(
        .arithmeticOverflow,
        at: .construction,
        condition: .arithmeticOverflow,
        origin: .foundation,
        scope: .runtime,
        containment: .contained
    )
    assertRasterMapping(
        .capacityExhausted,
        at: .construction,
        condition: .capacityExhausted,
        origin: .hostComposition,
        scope: .runtime,
        containment: .contained
    )
    assertRasterMapping(
        .invariantViolation,
        at: .construction,
        condition: .invariantViolation,
        origin: .hostComposition,
        scope: .runtime,
        containment: .safetyNotProven
    )
}

@Test
func prebodyAndRuntimeRasterFailuresFollowExactTable() {
    for error in [RasterBackendError.invalidEnvelope, .invalidGeometry] {
        assertRasterMapping(
            error,
            at: .preBody,
            condition: .invalidValue,
            origin: .backend,
            scope: .candidateFrame,
            containment: .contained
        )
    }
    assertRasterMapping(
        .reentrancyViolation,
        at: .postBegin,
        condition: .reentrancyViolation,
        origin: .backend,
        scope: .runtime,
        containment: .safetyNotProven
    )
    let invariantRuntime: [RasterBackendError] = [
        .unsupportedOperation,
        .incompatibleResource,
        .invalidGeometry,
        .arithmeticOverflow,
        .capacityExhausted,
        .malformedStream,
        .rasterizationFailure,
        .invariantViolation,
    ]
    for error in invariantRuntime {
        assertRasterMapping(
            error,
            at: .postBegin,
            condition: .invariantViolation,
            origin: .backend,
            scope: .runtime,
            containment: .safetyNotProven
        )
    }
}

@Test
func displayMappingsPreserveExactLocalErrorAndAcceptanceBoundary() {
    for error in [
        DisplayTargetError.invalidDescriptor,
        .invalidReservation,
        .capacityExhausted,
        .arithmeticOverflow,
        .transportUnavailable,
        .invariantViolation,
    ] {
        let mapping = RasterBackendOwnerFailureAdapter.map(
            error,
            at: .postBegin
        )
        #expect(mapping.rasterError == nil)
        #expect(mapping.displayError == error)
        #expect(mapping.fact.condition == .invariantViolation)
        #expect(mapping.fact.origin == .backend)
        #expect(mapping.fact.affectedScope == .runtime)
        #expect(mapping.fact.containment == .safetyNotProven)
    }
    let transport = RasterBackendOwnerFailureAdapter.map(
        DisplayTargetError.transportUnavailable,
        at: .postAcceptance
    )
    #expect(transport.displayError == .transportUnavailable)
    #expect(transport.fact.condition == .requiredFacilityUnavailable)
    #expect(transport.fact.origin == .presentationIntegration)
    #expect(transport.fact.affectedScope == .component)
    #expect(transport.fact.containment == .contained)

    let reentrant = RasterBackendOwnerFailureAdapter.map(
        DisplayTargetError.reentrancyViolation,
        at: .postAcceptance
    )
    #expect(reentrant.displayError == .reentrancyViolation)
    #expect(reentrant.fact.condition == .reentrancyViolation)
    #expect(reentrant.fact.origin == .backend)
    #expect(reentrant.fact.affectedScope == .runtime)
    #expect(reentrant.fact.containment == .safetyNotProven)
}

@Test
func acceptedRasterDisplayFailureMapsToFacilityUnavailability() {
    assertRasterMapping(
        .displayFailure,
        at: .postAcceptance,
        condition: .requiredFacilityUnavailable,
        origin: .presentationIntegration,
        scope: .component,
        containment: .contained
    )
}

private func assertRasterMapping(
    _ error: RasterBackendError,
    at point: RasterFailureDetectionPoint,
    condition: GiftUIConditionID,
    origin: GiftUIFailureOrigin,
    scope: GiftUIAffectedScope,
    containment: GiftUIContainment
) {
    let mapping = RasterBackendOwnerFailureAdapter.map(error, at: point)
    #expect(mapping.rasterError == error)
    #expect(mapping.displayError == nil)
    #expect(mapping.fact.condition == condition)
    #expect(mapping.fact.origin == origin)
    #expect(mapping.fact.affectedScope == scope)
    #expect(mapping.fact.containment == containment)
}
