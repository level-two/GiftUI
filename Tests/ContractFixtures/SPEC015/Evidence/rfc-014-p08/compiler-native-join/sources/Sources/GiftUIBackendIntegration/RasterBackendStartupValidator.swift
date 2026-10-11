import GiftUICapabilities
import GiftUIRasterCore
import GiftUISurfaceCore
import GiftUITextResources

package enum RasterBackendStartupValidator {
    package static func validate(
        descriptor: RasterSurfaceDescriptor?,
        effectivePresentation: EffectiveRasterPresentation,
        resourceValidation: TextResourceValidationResult,
        payloadLimits: RasterPayloadLimits,
        surfaceWritableCapacityBytes: UInt32,
        displaySubmissionLifetime: SubmissionLifetime,
        displayHandoff: SubmissionHandoff,
        displayMaximumInFlightPayloads: UInt8,
        displayMaximumInFlightBytes: UInt32,
        requiredGlyphRasterBytes: UInt32,
        requiredStrokeWorkspaceBytes: UInt32,
        requiredTileVisitsPerFrame: UInt32,
        requiredRegionSubmissionsPerFrame: UInt32
    ) -> RasterBackendError? {
        guard let descriptor else { return .invalidGeometry }

        guard
            matchesEffectivePresentation(
                descriptor: descriptor,
                effectivePresentation: effectivePresentation,
                displaySubmissionLifetime: displaySubmissionLifetime,
                displayHandoff: displayHandoff
            )
        else {
            return .invariantViolation
        }

        guard resourceValidation == .valid else {
            return .incompatibleResource
        }

        guard
            effectivePresentation.operations
                == RasterBackendContributionAdapter.requiredOperations
        else {
            return .unsupportedOperation
        }

        guard
            surfaceWritableCapacityBytes
                == effectivePresentation.requiredRasterBytes.rawValue,
            payloadLimits.admitsRasterBytes(
                effectivePresentation.requiredRasterBytes.rawValue
            ),
            payloadLimits.admitsPayloadBytes(
                effectivePresentation.requiredPayloadBytes.rawValue
            ),
            payloadLimits.admitsInFlight(
                payloads: effectivePresentation.inFlightCount,
                bytes: effectivePresentation.requiredInFlightBytes.rawValue
            ),
            effectivePresentation.inFlightCount <= displayMaximumInFlightPayloads,
            effectivePresentation.requiredInFlightBytes.rawValue
                <= displayMaximumInFlightBytes
        else {
            return .capacityExhausted
        }

        guard payloadLimits.admitsGlyphRasterBytes(requiredGlyphRasterBytes),
            payloadLimits.admitsStrokeWorkspaceBytes(requiredStrokeWorkspaceBytes)
        else {
            return .capacityExhausted
        }

        guard payloadLimits.admitsTileVisits(requiredTileVisitsPerFrame),
            payloadLimits.admitsRegionSubmissions(requiredRegionSubmissionsPerFrame)
        else {
            return .capacityExhausted
        }

        return nil
    }

    private static func matchesEffectivePresentation(
        descriptor: RasterSurfaceDescriptor,
        effectivePresentation: EffectiveRasterPresentation,
        displaySubmissionLifetime: SubmissionLifetime,
        displayHandoff: SubmissionHandoff
    ) -> Bool {
        let regionBytes = descriptor.bytesPerRow * UInt32(descriptor.regionHeight)
        return descriptor.capabilityExtent == effectivePresentation.extent
            && descriptor.regionWidth == effectivePresentation.regionExtent.width
            && descriptor.regionHeight == effectivePresentation.regionExtent.height
            && descriptor.bytesPerRow == effectivePresentation.rowBytes.rawValue
            && effectivePresentation.operationStream == .synchronousBorrowedOneShot
            && descriptor.encoding == effectivePresentation.encoding
            && displaySubmissionLifetime == effectivePresentation.submissionLifetime
            && displayHandoff == effectivePresentation.handoff
            && descriptor.realization == effectivePresentation.realization
            && regionBytes == effectivePresentation.requiredRasterBytes.rawValue
            && regionBytes == effectivePresentation.requiredPayloadBytes.rawValue
            && effectivePresentation.inFlightCount == 1
            && effectivePresentation.requiredInFlightBytes
                == effectivePresentation.requiredPayloadBytes
    }
}
