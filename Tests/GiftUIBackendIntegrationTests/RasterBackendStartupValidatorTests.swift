import GiftUI
import GiftUIRasterCore
import GiftUISurfaceCore
import GiftUITextResources
import Testing

@testable import GiftUIBackendIntegration
@testable import GiftUICapabilities

private let expectedOperations: RasterOperationSet = [
    .opaqueRectangles,
    .positionedText,
    .straightLineStrokes,
    .clipping,
    .damage,
]
private let expectedExtent = CapabilityExtent(width: 4, height: 3)!
private let expectedRegion = CapabilityExtent(width: 4, height: 3)!
private let expectedBytes = CapabilityByteCount(rawValue: 48)

func effective(
    operations: RasterOperationSet = expectedOperations,
    extent: CapabilityExtent = expectedExtent,
    regionExtent: CapabilityExtent = expectedRegion,
    rowBytes: UInt32 = 16,
    operationStream: OperationStreamLifetime = .synchronousBorrowedOneShot,
    encoding: CanonicalPixelEncoding = .rgba8888,
    submissionLifetime: SubmissionLifetime = .synchronousBorrow,
    handoff: SubmissionHandoff = .synchronous,
    realization: RasterRealizationKind = .fullSurface,
    requiredRasterBytes: UInt32 = 48,
    requiredPayloadBytes: UInt32 = 48,
    inFlightCount: UInt8 = 1,
    requiredInFlightBytes: UInt32 = 48
) -> EffectiveRasterPresentation {
    EffectiveRasterPresentation(
        operations: operations,
        extent: extent,
        regionExtent: regionExtent,
        rowBytes: CapabilityByteCount(rawValue: rowBytes),
        operationStream: operationStream,
        encoding: encoding,
        submissionLifetime: submissionLifetime,
        handoff: handoff,
        realization: realization,
        requiredRasterBytes: CapabilityByteCount(rawValue: requiredRasterBytes),
        requiredPayloadBytes: CapabilityByteCount(rawValue: requiredPayloadBytes),
        inFlightCount: inFlightCount,
        requiredInFlightBytes: CapabilityByteCount(rawValue: requiredInFlightBytes)
    )
}

func descriptor(
    encoding: CanonicalPixelEncoding = .rgba8888,
    realization: RasterRealizationKind = .fullSurface
) -> RasterSurfaceDescriptor {
    RasterSurfaceDescriptor(
        bounds: Rect(
            origin: Point(x: 0, y: 0),
            size: Size(width: 4, height: 3)!
        )!,
        encoding: encoding,
        bytesPerRow: encoding == .rgba8888 ? 16 : 8,
        realization: realization,
        regionWidth: 4,
        regionHeight: realization == .fullSurface ? 3 : 1
    )!
}

func limits(
    raster: UInt32 = 48,
    payload: UInt32 = 48,
    inFlightCount: UInt8 = 1,
    glyph: UInt32 = 12,
    stroke: UInt32 = 20,
    tileVisits: UInt32 = 8,
    regionSubmissions: UInt32 = 12
) -> RasterPayloadLimits {
    RasterPayloadLimits(
        maximumRasterBytes: raster,
        maximumPayloadBytes: payload,
        maximumRegionsPerPayload: 4,
        maximumRegionSubmissionsPerFrame: regionSubmissions,
        maximumTileVisitsPerFrame: tileVisits,
        maximumInFlightPayloads: inFlightCount,
        maximumGlyphRasterBytes: glyph,
        maximumStrokeWorkspaceBytes: stroke
    )!
}

private func validate(
    descriptor: RasterSurfaceDescriptor? = descriptor(),
    effectivePresentation: EffectiveRasterPresentation = effective(),
    resourceValidation: TextResourceValidationResult = .valid,
    payloadLimits: RasterPayloadLimits = limits(),
    surfaceBytes: UInt32 = 48,
    displayLifetime: SubmissionLifetime = .synchronousBorrow,
    displayHandoff: SubmissionHandoff = .synchronous,
    displayInFlightCount: UInt8 = 1,
    displayInFlightBytes: UInt32 = 48,
    glyphBytes: UInt32 = 12,
    strokeBytes: UInt32 = 20,
    tileVisits: UInt32 = 8,
    regionSubmissions: UInt32 = 12
) -> RasterBackendError? {
    RasterBackendStartupValidator.validate(
        descriptor: descriptor,
        effectivePresentation: effectivePresentation,
        resourceValidation: resourceValidation,
        payloadLimits: payloadLimits,
        surfaceWritableCapacityBytes: surfaceBytes,
        displaySubmissionLifetime: displayLifetime,
        displayHandoff: displayHandoff,
        displayMaximumInFlightPayloads: displayInFlightCount,
        displayMaximumInFlightBytes: displayInFlightBytes,
        requiredGlyphRasterBytes: glyphBytes,
        requiredStrokeWorkspaceBytes: strokeBytes,
        requiredTileVisitsPerFrame: tileVisits,
        requiredRegionSubmissionsPerFrame: regionSubmissions
    )
}

@Test
func startupValidatorAcceptsExactImmutableConfigurationAtEveryLimit() {
    let selected = effective()

    #expect(validate(effectivePresentation: selected) == nil)
    #expect(selected == effective())
    #expect(selected.requiredRasterBytes == expectedBytes)
    #expect(
        validate(
            effectivePresentation: effective(
                submissionLifetime: .synchronousCopy,
                handoff: .queued
            ),
            displayLifetime: .synchronousCopy,
            displayHandoff: .queued
        ) == nil
    )
}

@Test
func startupValidatorChecksDescriptorBeforeEveryLaterStage() {
    #expect(
        validate(
            descriptor: nil,
            effectivePresentation: effective(operations: [.opaqueRectangles]),
            resourceValidation: .invalid(.integrityMismatch),
            payloadLimits: limits(raster: 1),
            surfaceBytes: 1
        ) == .invalidGeometry
    )
}

@Test
func startupValidatorRejectsEveryEffectiveGeometryAndSelectionMismatch() {
    #expect(
        validate(effectivePresentation: effective(extent: .init(width: 5, height: 3)!))
            == .invariantViolation
    )
    #expect(
        validate(
            effectivePresentation: effective(
                regionExtent: .init(width: 4, height: 2)!
            )
        ) == .invariantViolation
    )
    #expect(validate(effectivePresentation: effective(rowBytes: 20)) == .invariantViolation)
    #expect(
        validate(
            effectivePresentation: effective(
                operationStream: .incompatibleWithSynchronousBorrowedOneShot
            )
        ) == .invariantViolation
    )
    #expect(
        validate(effectivePresentation: effective(encoding: .rgb565BigEndian))
            == .invariantViolation
    )
    #expect(
        validate(effectivePresentation: effective(submissionLifetime: .synchronousCopy))
            == .invariantViolation
    )
    #expect(
        validate(effectivePresentation: effective(handoff: .queued))
            == .invariantViolation
    )
    #expect(
        validate(effectivePresentation: effective(realization: .tiled))
            == .invariantViolation
    )
}

@Test
func startupValidatorRejectsEveryEffectiveUsageMismatch() {
    #expect(
        validate(effectivePresentation: effective(requiredRasterBytes: 47))
            == .invariantViolation
    )
    #expect(
        validate(effectivePresentation: effective(requiredPayloadBytes: 47))
            == .invariantViolation
    )
    #expect(
        validate(effectivePresentation: effective(inFlightCount: 2))
            == .invariantViolation
    )
    #expect(
        validate(effectivePresentation: effective(requiredInFlightBytes: 47))
            == .invariantViolation
    )
}

@Test
func startupValidatorPreservesResourceThenOperationDetectionOrder() {
    let incompleteOperations = effective(operations: [.opaqueRectangles])

    #expect(
        validate(
            effectivePresentation: incompleteOperations,
            resourceValidation: .invalid(.integrityMismatch)
        ) == .incompatibleResource
    )
    #expect(
        validate(effectivePresentation: incompleteOperations)
            == .unsupportedOperation
    )
    #expect(
        validate(
            effectivePresentation: effective(
                operations: RasterOperationSet(rawValue: 0x3f)
            )
        ) == .unsupportedOperation
    )
}

@Test
func startupValidatorRejectsEachRasterPayloadAndInFlightStore() {
    #expect(validate(payloadLimits: limits(raster: 47)) == .capacityExhausted)
    #expect(validate(surfaceBytes: 47) == .capacityExhausted)
    #expect(validate(surfaceBytes: 49) == .capacityExhausted)
    #expect(validate(payloadLimits: limits(payload: 47)) == .capacityExhausted)
    #expect(
        validate(payloadLimits: limits(inFlightCount: 1), displayInFlightCount: 0)
            == .capacityExhausted)
    #expect(validate(displayInFlightBytes: 47) == .capacityExhausted)
}

@Test
func startupValidatorRejectsWorkspaceBeforePerFrameCeilings() {
    #expect(
        validate(
            glyphBytes: 13,
            tileVisits: 9,
            regionSubmissions: 13
        ) == .capacityExhausted
    )
    #expect(validate(strokeBytes: 21, tileVisits: 9) == .capacityExhausted)
    #expect(validate(tileVisits: 9) == .capacityExhausted)
    #expect(validate(regionSubmissions: 13) == .capacityExhausted)
}

@Test
func startupValidatorNeverRecomputesOrClampsSelectedDisplayFacts() {
    #expect(
        validate(
            effectivePresentation: effective(submissionLifetime: .synchronousCopy),
            displayLifetime: .synchronousBorrow
        ) == .invariantViolation
    )
    #expect(
        validate(
            effectivePresentation: effective(handoff: .queued),
            displayHandoff: .synchronous
        ) == .invariantViolation
    )
}
