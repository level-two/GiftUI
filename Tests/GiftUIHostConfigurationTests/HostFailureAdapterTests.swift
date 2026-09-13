import GiftUICapabilities
import GiftUIFailureCore
import GiftUIRuntimeCore
import GiftUITextResources
import Testing

@testable import GiftUIHostConfiguration

@Test func hostOwnedConfigurationErrorsMapToExactFacts() {
    let invalidValueErrors: [HostConfigurationError] = [
        .duplicateRole(.runtimeProfile),
        .missingRole(.runtimeProfile),
        .invalidGraph,
        .profileMismatch,
        .invalidWorkload,
        .invalidActionDomain,
        .invalidModelTarget,
        .invalidInputIntegration,
        .invalidWakeIntegration,
        .invalidPacingPolicy,
    ]
    for error in invalidValueErrors {
        #expect(
            HostFailureAdapter.fact(for: error)
                == hostFailureFact(condition: .invalidValue)
        )
    }
    #expect(
        HostFailureAdapter.fact(for: .insufficientWorkloadCapacity)
            == hostFailureFact(condition: .capacityExhausted)
    )
    #expect(
        HostFailureAdapter.fact(for: .arithmeticOverflow)
            == hostFailureFact(condition: .arithmeticOverflow)
    )
    for error in [
        HostConfigurationError.invalidEndpointDescriptor,
        .incompleteFailurePolicy,
        .invariantViolation,
    ] {
        #expect(
            HostFailureAdapter.fact(for: error)
                == hostFailureFact(
                    condition: .invariantViolation,
                    containment: .safetyNotProven
                )
        )
    }
}

@Test func runtimeProfileErrorsPreserveTheirExactMapping() {
    let cases: [(RuntimeProfileValidationError, GiftUIFailureFact)] = [
        (.invalidLimits, hostFailureFact(condition: .invalidValue)),
        (.incompatibleLimits, hostFailureFact(condition: .invalidValue)),
        (.missingStorage, hostFailureFact(condition: .capacityExhausted)),
        (.insufficientStorage, hostFailureFact(condition: .capacityExhausted)),
        (
            .arithmeticOverflow,
            GiftUIFailureFact(
                condition: .arithmeticOverflow,
                origin: .foundation,
                affectedScope: .runtime,
                containment: .contained
            )
        ),
        (
            .staticCanvasTableInvalid,
            hostFailureFact(
                condition: .invariantViolation,
                containment: .safetyNotProven
            )
        ),
        (
            .invariantViolation,
            hostFailureFact(
                condition: .invariantViolation,
                containment: .safetyNotProven
            )
        ),
    ]
    for (error, expected) in cases {
        #expect(
            HostFailureAdapter.fact(for: .invalidRuntimeProfile(error))
                == expected
        )
    }
}

@Test func textResourceErrorsPreserveTheirExactThreeWayMapping() {
    let invalidValue: [TextResourceValidationError] = [
        .unsupportedSchema, .invalidCount, .malformedMetrics,
        .malformedMapping, .malformedRasterRecord,
    ]
    let invalidIdentity: [TextResourceValidationError] = [
        .invalidIdentity, .incompatibleViews, .integrityMismatch,
    ]
    for error in invalidValue {
        #expect(
            HostFailureAdapter.fact(for: .invalidTextResources(error))
                == hostFailureFact(condition: .invalidValue)
        )
    }
    for error in invalidIdentity {
        #expect(
            HostFailureAdapter.fact(for: .invalidTextResources(error))
                == hostFailureFact(condition: .invalidIdentity)
        )
    }
    #expect(
        HostFailureAdapter.fact(
            for: .invalidTextResources(.capacityExceeded)
        ) == hostFailureFact(condition: .capacityExhausted)
    )
}

@Test func capabilityErrorsPreserveProducerSpecificConditions() {
    let required = CapabilityByteCount(rawValue: 2)
    let available = CapabilityByteCount(rawValue: 1)
    let cases: [(RasterPresentationUnavailable, GiftUIConditionID)] = [
        (.malformedRequirement(field: .extent), .rasterMalformedRequirement),
        (.duplicateContributor(role: .renderProducer), .rasterDuplicateContributor),
        (.missingContributor(role: .rasterBackend), .rasterMissingContributor),
        (
            .malformedContribution(role: .surfaceDisplay, field: .rowByteAlignment),
            .rasterMalformedContribution
        ),
        (
            .insufficientCapacity(
                domain: .payload,
                required: required,
                available: available
            ),
            .rasterInsufficientCapacity
        ),
        (.operationSetMismatch, .rasterOperationSetMismatch),
        (.operationStreamMismatch, .rasterOperationStreamMismatch),
        (.logicalExtentOverflow, .rasterLogicalExtentOverflow),
        (.unsupportedLogicalExtent, .rasterUnsupportedLogicalExtent),
        (.noCommonCanonicalPixelEncoding, .rasterNoCommonCanonicalPixelEncoding),
        (.incompatibleSubmissionLifetime, .rasterIncompatibleSubmissionLifetime),
        (.incompatibleSubmissionHandoff, .rasterIncompatibleSubmissionHandoff),
        (.policyHasNoConformingRealization, .rasterPolicyHasNoConformingRealization),
        (.byteCountOverflow(domain: .raster), .rasterByteCountOverflow),
    ]
    for (unavailable, condition) in cases {
        #expect(
            HostFailureAdapter.fact(for: .capabilityUnavailable(unavailable))
                == GiftUIFailureFact(
                    condition: condition,
                    origin: .capability,
                    affectedScope: .runtime,
                    containment: .contained
                )
        )
    }
}

@Test func startupPolicyInputExistsOnlyAfterDiscardForOrdinaryFailure() {
    let failure = HostValidationResult.invalid(
        stage: .workload,
        error: .insufficientWorkloadCapacity
    )
    #expect(
        HostFailureAdapter.startupPolicyInput(
            for: failure,
            projectionsWereDiscarded: false
        ) == nil
    )
    guard
        let input = HostFailureAdapter.startupPolicyInput(
            for: failure,
            projectionsWereDiscarded: true
        )
    else {
        Issue.record("discarded ordinary failure must create one policy input")
        return
    }
    #expect(input.context == .startupValidation)
    #expect(input.allowed == .quiesceAffectedScope)
    #expect(input.attemptOrdinal == 0)
    #expect(input.attemptLimit == 1)
    guard case .failure(let fact) = input.outcome else {
        Issue.record("startup policy input must retain the mapped failure")
        return
    }
    #expect(fact == hostFailureFact(condition: .capacityExhausted))
}

@Test func successAndPolicyDefectNeverCreateAStartupPolicyInput() {
    var validator = makeValidHostValidator()
    let valid = validator.validate()
    #expect(
        HostFailureAdapter.startupPolicyInput(
            for: valid,
            projectionsWereDiscarded: true
        ) == nil
    )
    let defect = HostValidationResult.invalid(
        stage: .policy,
        error: .incompleteFailurePolicy
    )
    #expect(
        HostFailureAdapter.startupPolicyInput(
            for: defect,
            projectionsWereDiscarded: true
        ) == nil
    )
}

@Test func fixedPolicyTableAndPolicyAreTotalOverAllNineContexts() {
    let table = FixedMVPHostResidualPolicyTable(fatalHookIsAvailable: true)
    #expect(HostResidualPolicyTableValidation.validate(table))
    var policy = FixedMVPHostResidualPolicy(table: table)

    for rawValue in UInt8(0) ... 8 {
        let context = HostResidualPolicyContext(rawValue: rawValue)!
        let allowed = table.allowed(for: context)
        let outcome: GiftUIOutcome<Void>
        if allowed.contains(.requestPacedRetry) {
            outcome = .operational(
                GiftUIOperationalFact(
                    kind: .retryableRefusal,
                    origin: .backend,
                    affectedScope: .runtime
                )
            )
        } else {
            outcome = .failure(
                hostFailureFact(
                    condition: .invariantViolation,
                    containment: context == .safetyNotProven
                        ? .safetyNotProven : .contained
                )
            )
        }
        guard
            let input = GiftUIResidualPolicyInput(
                outcome: outcome,
                context: context,
                allowed: allowed,
                attemptOrdinal: 0,
                attemptLimit: allowed.contains(.requestPacedRetry) ? 3 : 1
            )
        else {
            Issue.record("exact policy row must construct")
            continue
        }
        #expect(
            policy.disposition(for: input).rawValue
                == table.selection(for: context).rawValue
        )
    }
}

private func hostFailureFact(
    condition: GiftUIConditionID,
    containment: GiftUIContainment = .contained
) -> GiftUIFailureFact {
    GiftUIFailureFact(
        condition: condition,
        origin: .hostComposition,
        affectedScope: .runtime,
        containment: containment
    )
}
