import GiftUI
import GiftUICapabilities
import GiftUIDisplayCore
import GiftUIRasterCore
import GiftUISurfaceCore
import GiftUITextResources
import Testing

@testable import GiftUIHostConfiguration

@Test func exactInertEndpointProjectionPassesWithoutConstructingAnOwner() {
    let endpoint = makeHostEndpointFixture()
    var validator = makeValidHostValidator(endpoint: endpoint)

    guard case .valid(let report) = validator.validate() else {
        Issue.record("exact inert endpoint must validate")
        return
    }
    #expect(report.effectivePresentation == endpoint.effectivePresentation)
}

@Test func everyEndpointProjectionFamilyMustMatchTheEffectiveValue() {
    let valid = makeHostEndpointFixture()
    let mismatchedDescriptor = RasterSurfaceDescriptor(
        bounds: Rect(
            origin: Point(x: 0, y: 0),
            size: Size(width: 480, height: 320)!
        )!,
        encoding: .rgb565BigEndian,
        bytesPerRow: 960,
        realization: .tiled,
        regionWidth: 480,
        regionHeight: 3
    )!
    let rasterMismatch = payloadLimits(maximumRasterBytes: 3_839)
    let payloadMismatch = payloadLimits(maximumPayloadBytes: 3_839)
    let inFlightMismatch = payloadLimits(maximumInFlightPayloads: 2)
    let variants = [
        endpoint(valid, descriptor: mismatchedDescriptor),
        endpoint(valid, surfaceWritableCapacityBytes: 3_839),
        endpoint(valid, payloadLimits: rasterMismatch),
        endpoint(valid, payloadLimits: payloadMismatch),
        endpoint(valid, payloadLimits: inFlightMismatch),
        endpoint(valid, displaySubmissionLifetime: .synchronousCopy),
        endpoint(valid, displayHandoff: .queued),
        endpoint(valid, displayMaximumInFlightPayloads: 2),
        endpoint(valid, displayMaximumInFlightBytes: 3_839),
        endpoint(valid, healthOwnerCount: 2),
        endpoint(valid, endpointAndDisplayShareHealthOwner: false),
    ]

    for variant in variants {
        #expect(
            HostEndpointStartupValidation.validateInert(
                variant,
                effectivePresentation: valid.effectivePresentation,
                selectedTextRasterRealization: RasterRealizationID(rawValue: 1)
            ) == .invalidEndpointDescriptor
        )
    }
    #expect(
        HostEndpointStartupValidation.validateInert(
            valid,
            effectivePresentation: valid.effectivePresentation,
            selectedTextRasterRealization: RasterRealizationID(rawValue: 2)
        ) == .invalidEndpointDescriptor
    )
}

@Test func validatorReportsInertEndpointMismatchAtTheEndpointStage() {
    let mismatch = makeHostEndpointFixture(
        displayMaximumInFlightBytes: 3_839
    )
    var validator = makeValidHostValidator(endpoint: mismatch)
    #expect(
        validator.validate()
            == .invalid(
                stage: .endpoint,
                error: .invalidEndpointDescriptor
            )
    )
}

@Test func constructedEndpointProjectionMustEqualTheValidatedProjection() {
    let validated = makeHostEndpointFixture()
    #expect(
        HostEndpointStartupValidation.validateConstructedProjection(
            validated,
            equals: validated
        ) == nil
    )
    #expect(
        HostEndpointStartupValidation.validateConstructedProjection(
            endpoint(validated, displayHandoff: .queued),
            equals: validated
        ) == .invalidEndpointDescriptor
    )
}

private func payloadLimits(
    maximumRasterBytes: UInt32 = 3_840,
    maximumPayloadBytes: UInt32 = 3_840,
    maximumInFlightPayloads: UInt8 = 1
) -> RasterPayloadLimits {
    RasterPayloadLimits(
        maximumRasterBytes: maximumRasterBytes,
        maximumPayloadBytes: maximumPayloadBytes,
        maximumRegionsPerPayload: 1,
        maximumRegionSubmissionsPerFrame: 80,
        maximumTileVisitsPerFrame: 80,
        maximumInFlightPayloads: maximumInFlightPayloads,
        maximumGlyphRasterBytes: 3_840,
        maximumStrokeWorkspaceBytes: 3_840
    )!
}

private func endpoint(
    _ source: HostEndpointConfiguration,
    descriptor: RasterSurfaceDescriptor? = nil,
    payloadLimits: RasterPayloadLimits? = nil,
    surfaceWritableCapacityBytes: UInt32? = nil,
    displaySubmissionLifetime: SubmissionLifetime? = nil,
    displayHandoff: SubmissionHandoff? = nil,
    displayMaximumInFlightPayloads: UInt8? = nil,
    displayMaximumInFlightBytes: UInt32? = nil,
    healthOwnerCount: UInt8? = nil,
    endpointAndDisplayShareHealthOwner: Bool? = nil
) -> HostEndpointConfiguration {
    HostEndpointConfiguration(
        effectivePresentation: source.effectivePresentation,
        descriptor: descriptor ?? source.descriptor,
        payloadLimits: payloadLimits ?? source.payloadLimits,
        surfaceWritableCapacityBytes:
            surfaceWritableCapacityBytes ?? source.surfaceWritableCapacityBytes,
        displaySubmissionLifetime:
            displaySubmissionLifetime ?? source.displaySubmissionLifetime,
        displayHandoff: displayHandoff ?? source.displayHandoff,
        displayMaximumInFlightPayloads:
            displayMaximumInFlightPayloads
            ?? source.displayMaximumInFlightPayloads,
        displayMaximumInFlightBytes:
            displayMaximumInFlightBytes ?? source.displayMaximumInFlightBytes,
        textRasterRealization: source.textRasterRealization,
        healthOwnerCount: healthOwnerCount ?? source.healthOwnerCount,
        endpointAndDisplayShareHealthOwner:
            endpointAndDisplayShareHealthOwner
            ?? source.endpointAndDisplayShareHealthOwner
    )
}
