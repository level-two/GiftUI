import GiftUICapabilities
import GiftUIFailureCore
import GiftUIRuntimeCore
import GiftUITextResources

package struct FixedMVPHostResidualPolicyTable: MVPHostResidualPolicyTable {
    package let fatalHookIsAvailable: Bool

    package init(fatalHookIsAvailable: Bool) {
        self.fatalHookIsAvailable = fatalHookIsAvailable
    }

    package func allowed(
        for context: HostResidualPolicyContext
    ) -> GiftUIAllowedDispositions {
        HostResidualPolicyTableValidation.expectedRow(for: context).allowed
    }

    package func selection(
        for context: HostResidualPolicyContext
    ) -> GiftUIResidualDisposition {
        HostResidualPolicyTableValidation.expectedRow(for: context).selection
    }
}

package struct FixedMVPHostResidualPolicy: MVPHostResidualPolicy {
    private let table: FixedMVPHostResidualPolicyTable

    package init(table: FixedMVPHostResidualPolicyTable) {
        self.table = table
    }

    package mutating func disposition(
        for input: GiftUIResidualPolicyInput<HostResidualPolicyContext>
    ) -> GiftUIResidualDisposition {
        table.selection(for: input.context)
    }
}

package enum HostFailureAdapter {
    package static func fact(
        for error: HostConfigurationError
    ) -> GiftUIFailureFact {
        switch error {
        case .invalidRuntimeProfile(let runtimeError):
            return runtimeProfileFact(for: runtimeError)
        case .invalidTextResources(let textError):
            return textResourceFact(for: textError)
        case .capabilityUnavailable(let unavailable):
            return capabilityFact(for: unavailable)
        case .insufficientWorkloadCapacity:
            return hostFact(condition: .capacityExhausted)
        case .arithmeticOverflow:
            return hostFact(condition: .arithmeticOverflow)
        case .invalidEndpointDescriptor, .incompleteFailurePolicy,
            .invariantViolation:
            return hostFact(
                condition: .invariantViolation,
                containment: .safetyNotProven
            )
        case .duplicateRole, .missingRole, .invalidGraph, .profileMismatch,
            .invalidWorkload, .invalidActionDomain, .invalidModelTarget,
            .invalidInputIntegration, .invalidWakeIntegration,
            .invalidPacingPolicy:
            return hostFact(condition: .invalidValue)
        }
    }

    package static func startupPolicyInput(
        for result: HostValidationResult,
        projectionsWereDiscarded: Bool
    ) -> GiftUIResidualPolicyInput<HostResidualPolicyContext>? {
        guard projectionsWereDiscarded,
            case .invalid(let stage, let error) = result,
            !(stage == .policy && error == .incompleteFailurePolicy)
        else { return nil }
        return GiftUIResidualPolicyInput(
            outcome: .failure(fact(for: error)),
            context: .startupValidation,
            allowed: .quiesceAffectedScope,
            attemptOrdinal: 0,
            attemptLimit: 1
        )
    }

    private static func runtimeProfileFact(
        for error: RuntimeProfileValidationError
    ) -> GiftUIFailureFact {
        switch error {
        case .invalidLimits, .incompatibleLimits:
            return hostFact(condition: .invalidValue)
        case .missingStorage, .insufficientStorage:
            return hostFact(condition: .capacityExhausted)
        case .arithmeticOverflow:
            return GiftUIFailureFact(
                condition: .arithmeticOverflow,
                origin: .foundation,
                affectedScope: .runtime,
                containment: .contained
            )
        case .staticCanvasTableInvalid, .invariantViolation:
            return hostFact(
                condition: .invariantViolation,
                containment: .safetyNotProven
            )
        }
    }

    private static func textResourceFact(
        for error: TextResourceValidationError
    ) -> GiftUIFailureFact {
        let condition: GiftUIConditionID =
            switch error {
            case .unsupportedSchema, .invalidCount, .malformedMetrics,
                .malformedMapping, .malformedRasterRecord:
                .invalidValue
            case .invalidIdentity, .incompatibleViews, .integrityMismatch:
                .invalidIdentity
            case .capacityExceeded:
                .capacityExhausted
            }
        return hostFact(condition: condition)
    }

    private static func capabilityFact(
        for unavailable: RasterPresentationUnavailable
    ) -> GiftUIFailureFact {
        let condition: GiftUIConditionID =
            switch unavailable {
            case .malformedRequirement:
                .rasterMalformedRequirement
            case .duplicateContributor:
                .rasterDuplicateContributor
            case .missingContributor:
                .rasterMissingContributor
            case .malformedContribution:
                .rasterMalformedContribution
            case .insufficientCapacity:
                .rasterInsufficientCapacity
            case .operationSetMismatch:
                .rasterOperationSetMismatch
            case .operationStreamMismatch:
                .rasterOperationStreamMismatch
            case .logicalExtentOverflow:
                .rasterLogicalExtentOverflow
            case .unsupportedLogicalExtent:
                .rasterUnsupportedLogicalExtent
            case .noCommonCanonicalPixelEncoding:
                .rasterNoCommonCanonicalPixelEncoding
            case .incompatibleSubmissionLifetime:
                .rasterIncompatibleSubmissionLifetime
            case .incompatibleSubmissionHandoff:
                .rasterIncompatibleSubmissionHandoff
            case .policyHasNoConformingRealization:
                .rasterPolicyHasNoConformingRealization
            case .byteCountOverflow:
                .rasterByteCountOverflow
            }
        return GiftUIFailureFact(
            condition: condition,
            origin: .capability,
            affectedScope: .runtime,
            containment: .contained
        )
    }

    private static func hostFact(
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
}
