import GiftUI
import GiftUICapabilities
import GiftUIRasterCore
import GiftUIRenderCore
import GiftUISurfaceCore
import Testing

@testable import GiftUIBackendIntegration

private let admissionBounds = Rect(
    origin: Point(x: 0, y: 0),
    size: Size(width: 8, height: 6)!
)!
private let admissionDescriptor = RasterSurfaceDescriptor(
    bounds: admissionBounds,
    encoding: .rgb565BigEndian,
    bytesPerRow: 16,
    realization: .tiled,
    regionWidth: 8,
    regionHeight: 4
)!
private let admissionCapacity = RenderSinkCapacity(
    maximumOperations: 3,
    maximumPositionedGlyphs: 2
)

private func admissionLimits(
    tileVisits: UInt32 = 6,
    regionSubmissions: UInt32 = 144
) -> RasterPayloadLimits {
    RasterPayloadLimits(
        maximumRasterBytes: 64,
        maximumPayloadBytes: 64,
        maximumRegionsPerPayload: 8,
        maximumRegionSubmissionsPerFrame: regionSubmissions,
        maximumTileVisitsPerFrame: tileVisits,
        maximumInFlightPayloads: 1,
        maximumGlyphRasterBytes: 1,
        maximumStrokeWorkspaceBytes: 1
    )!
}

@Test
func constructionWorkMapsOverflowAndCapacityWithoutCallingAnEndpoint() {
    let overflowDescriptor = RasterSurfaceDescriptor(
        bounds: Rect(
            origin: Point(x: 0, y: 0),
            size: Size(width: 65_535, height: 32_769)!
        )!,
        encoding: .rgb565BigEndian,
        bytesPerRow: 131_070,
        realization: .tiled,
        regionWidth: 65_535,
        regionHeight: 1
    )!
    let overflowCapacity = RenderSinkCapacity(
        maximumOperations: 2,
        maximumPositionedGlyphs: 1
    )

    #expect(
        RasterFrameWorkAdmission.constructionFailure(
            descriptor: admissionDescriptor,
            sinkCapacity: admissionCapacity,
            limits: admissionLimits()
        ) == nil
    )
    #expect(
        RasterFrameWorkAdmission.constructionFailure(
            descriptor: admissionDescriptor,
            sinkCapacity: admissionCapacity,
            limits: admissionLimits(tileVisits: 5)
        ) == .capacityExhausted
    )
    #expect(
        RasterFrameWorkAdmission.constructionFailure(
            descriptor: overflowDescriptor,
            sinkCapacity: overflowCapacity,
            limits: admissionLimits(
                tileVisits: .max,
                regionSubmissions: .max
            )
        ) == .arithmeticOverflow
    )
}

@Test
func perHeaderWorkMapsEveryContradictionToContractViolation() {
    let outside = Rect(
        origin: Point(x: 7, y: 5),
        size: Size(width: 2, height: 1)!
    )!
    let header = RenderPlanHeader(
        surfaceBounds: admissionBounds,
        damageBounds: outside,
        operationCount: 3,
        positionedGlyphCount: 2,
        maximumObservedClipDepth: 1
    )

    #expect(
        RasterFrameWorkAdmission.headerFailure(
            header,
            descriptor: admissionDescriptor,
            sinkCapacity: admissionCapacity,
            limits: admissionLimits()
        ) == .contractViolation
    )
    #expect(
        RasterFrameWorkAdmission.headerFailure(
            RenderPlanHeader(
                surfaceBounds: admissionBounds,
                damageBounds: admissionBounds,
                operationCount: 3,
                positionedGlyphCount: 2,
                maximumObservedClipDepth: 1
            ),
            descriptor: admissionDescriptor,
            sinkCapacity: admissionCapacity,
            limits: admissionLimits(regionSubmissions: 143)
        ) == .contractViolation
    )
}
