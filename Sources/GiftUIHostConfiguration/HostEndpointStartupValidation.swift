import GiftUICapabilities
import GiftUITextResources

package enum HostEndpointStartupValidation {
    package static func validateInert(
        _ endpoint: HostEndpointConfiguration,
        effectivePresentation: EffectiveRasterPresentation,
        selectedTextRasterRealization: RasterRealizationID
    ) -> HostConfigurationError? {
        let descriptor = endpoint.descriptor
        let payload = endpoint.payloadLimits
        guard endpoint.effectivePresentation == effectivePresentation,
            descriptor.capabilityExtent == effectivePresentation.extent,
            descriptor.encoding == effectivePresentation.encoding,
            descriptor.bytesPerRow == effectivePresentation.rowBytes.rawValue,
            descriptor.realization == effectivePresentation.realization,
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
            endpoint.displaySubmissionLifetime
                == effectivePresentation.submissionLifetime,
            endpoint.displayHandoff == effectivePresentation.handoff,
            endpoint.displayMaximumInFlightPayloads
                == effectivePresentation.inFlightCount,
            endpoint.displayMaximumInFlightBytes
                == effectivePresentation.requiredInFlightBytes.rawValue,
            endpoint.textRasterRealization == selectedTextRasterRealization,
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
