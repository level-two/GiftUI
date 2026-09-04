import GiftUICapabilities
import GiftUIFailureCore

enum CapabilityFailureAdapter {
    static func condition(
        for unavailable: RasterPresentationUnavailable
    ) -> GiftUIConditionID {
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
    }

    static func requiredFamilyFailure(
        _ unavailable: RasterPresentationUnavailable
    ) -> GiftUIOutcome<CapabilitySnapshot> {
        .failure(
            GiftUIFailureFact(
                condition: condition(for: unavailable),
                origin: .capability,
                affectedScope: .runtime,
                containment: .contained
            ))
    }
}
