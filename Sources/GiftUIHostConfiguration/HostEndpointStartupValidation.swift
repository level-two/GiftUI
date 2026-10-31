import GiftUICapabilities
import GiftUIRasterCore
import GiftUISurfaceCore
import GiftUITextResources

package enum HostEndpointStartupValidation {
    #if GIFTUI_STARTUP_QUALIFICATION
        @_noAllocation
    #endif
    package static func validateInert(
        _ endpoint: HostEndpointConfiguration,
        effectivePresentation: EffectiveRasterPresentation,
        selectedTextRasterRealization: RasterRealizationID
    ) -> HostConfigurationError? {
        let descriptor = endpoint.descriptor
        let payload = endpoint.payloadLimits
        guard
            RasterPresentationEqualityProjection.matches(
                endpoint.effectivePresentation, effectivePresentation),
            RasterPresentationEqualityProjection.matches(
                descriptor.capabilityExtent, effectivePresentation.extent),
            descriptor.encoding.rawValue == effectivePresentation.encoding.rawValue,
            descriptor.bytesPerRow == effectivePresentation.rowBytes.rawValue,
            descriptor.realization.rawValue == effectivePresentation.realization.rawValue,
            descriptor.regionWidth == effectivePresentation.regionExtent.width,
            descriptor.regionHeight == effectivePresentation.regionExtent.height,
            endpoint.surfaceWritableCapacityBytes
                == effectivePresentation.requiredRasterBytes.rawValue,
            payload.maximumRasterBytes
                == effectivePresentation.requiredRasterBytes.rawValue,
            payload.maximumPayloadBytes
                == effectivePresentation.requiredPayloadBytes.rawValue,
            payload.maximumInFlightPayloads == effectivePresentation.inFlightCount,
            payload.maximumInFlightBytes
                == effectivePresentation.requiredInFlightBytes.rawValue,
            endpoint.displaySubmissionLifetime.rawValue
                == effectivePresentation.submissionLifetime.rawValue,
            endpoint.displayHandoff.rawValue == effectivePresentation.handoff.rawValue,
            endpoint.displayMaximumInFlightPayloads
                == effectivePresentation.inFlightCount,
            endpoint.displayMaximumInFlightBytes
                == effectivePresentation.requiredInFlightBytes.rawValue,
            endpoint.textRasterRealization.rawValue == selectedTextRasterRealization.rawValue,
            endpoint.healthOwnerCount == 1,
            endpoint.endpointAndDisplayShareHealthOwner
        else { return .invalidEndpointDescriptor }
        return nil
    }

    package static func validateConstructedProjection(
        _ constructed: HostEndpointConfiguration,
        equals validated: HostEndpointConfiguration
    ) -> HostConfigurationError? {
        constructed == validated ? nil : .invalidEndpointDescriptor
    }
}
