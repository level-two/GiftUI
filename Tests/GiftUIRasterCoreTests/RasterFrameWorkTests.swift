import GiftUI
import GiftUICapabilities
import GiftUIRenderCore
import GiftUISurfaceCore
import Testing

@testable import GiftUIRasterCore

private let workBounds = Rect(
    origin: Point(x: 0, y: 0),
    size: Size(width: 8, height: 6)!
)!
private let workDescriptor = RasterSurfaceDescriptor(
    bounds: workBounds,
    encoding: .rgb565BigEndian,
    bytesPerRow: 16,
    realization: .tiled,
    regionWidth: 8,
    regionHeight: 4
)!
private let workCapacity = RenderSinkCapacity(
    maximumOperations: 3,
    maximumPositionedGlyphs: 2
)

private func workLimits(
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

private func header(
    surface: Rect = workBounds,
    damage: Rect = workBounds,
    operations: UInt16 = 3,
    glyphs: UInt16 = 2
) -> RenderPlanHeader {
    RenderPlanHeader(
        surfaceBounds: surface,
        damageBounds: damage,
        operationCount: operations,
        positionedGlyphCount: glyphs,
        maximumObservedClipDepth: 1
    )
}

@Test
func frameWorkCalculatesExactConstructionAndPartialTileCeilings() {
    let construction = RasterFrameWorkCalculator.constructionBounds(
        descriptor: workDescriptor,
        sinkCapacity: workCapacity,
        limits: workLimits()
    )
    let partialDamage = Rect(
        origin: Point(x: 1, y: 1),
        size: Size(width: 5, height: 5)!
    )!
    let frame = RasterFrameWorkCalculator.headerBounds(
        header(damage: partialDamage, operations: 2, glyphs: 1),
        descriptor: workDescriptor,
        sinkCapacity: workCapacity,
        limits: workLimits()
    )

    #expect(
        construction
            == .admitted(
                RasterFrameWorkBounds(
                    damagedRows: 6,
                    damagedPixels: 48,
                    tileRows: 2,
                    tileVisits: 6,
                    regionSubmissions: 144
                )
            )
    )
    #expect(
        frame
            == .admitted(
                RasterFrameWorkBounds(
                    damagedRows: 5,
                    damagedPixels: 25,
                    tileRows: 2,
                    tileVisits: 4,
                    regionSubmissions: 50
                )
            )
    )
}

@Test
func frameWorkMapsEveryEmptyDamageShapeToAllZeroBounds() {
    let zeroWidth = Rect(
        origin: Point(x: 0, y: 0),
        size: Size(width: 0, height: 6)!
    )!
    let zeroHeight = Rect(
        origin: Point(x: 0, y: 0),
        size: Size(width: 8, height: 0)!
    )!
    let expected = RasterFrameWorkCalculation.admitted(
        RasterFrameWorkBounds(
            damagedRows: 0,
            damagedPixels: 0,
            tileRows: 0,
            tileVisits: 0,
            regionSubmissions: 0
        )
    )

    #expect(
        RasterFrameWorkCalculator.headerBounds(
            header(damage: zeroWidth),
            descriptor: workDescriptor,
            sinkCapacity: workCapacity,
            limits: workLimits()
        ) == expected
    )
    #expect(
        RasterFrameWorkCalculator.headerBounds(
            header(damage: zeroHeight),
            descriptor: workDescriptor,
            sinkCapacity: workCapacity,
            limits: workLimits()
        ) == expected
    )
}

@Test
func frameWorkAdmitsExactLimitsAndRejectsFirstExcess() {
    #expect(
        RasterFrameWorkCalculator.constructionBounds(
            descriptor: workDescriptor,
            sinkCapacity: workCapacity,
            limits: workLimits()
        ).isAdmitted
    )
    #expect(
        RasterFrameWorkCalculator.constructionBounds(
            descriptor: workDescriptor,
            sinkCapacity: workCapacity,
            limits: workLimits(tileVisits: 5)
        ) == .capacityExceeded
    )
    #expect(
        RasterFrameWorkCalculator.constructionBounds(
            descriptor: workDescriptor,
            sinkCapacity: workCapacity,
            limits: workLimits(regionSubmissions: 143)
        ) == .capacityExceeded
    )
}

@Test
func frameWorkRejectsEveryCheckedArithmeticOverflow() {
    let limits = workLimits(tileVisits: .max, regionSubmissions: .max)

    #expect(
        RasterFrameWorkCalculator.calculate(
            damageWidth: .max,
            damageHeight: 2,
            operationCount: 1,
            regionHeight: 1,
            limits: limits
        ) == .arithmeticOverflow
    )
    #expect(
        RasterFrameWorkCalculator.calculate(
            damageWidth: 1,
            damageHeight: .max,
            operationCount: 1,
            regionHeight: 2,
            limits: limits
        ) == .arithmeticOverflow
    )
    #expect(
        RasterFrameWorkCalculator.calculate(
            damageWidth: 1,
            damageHeight: .max,
            operationCount: 2,
            regionHeight: 1,
            limits: limits
        ) == .arithmeticOverflow
    )
    #expect(
        RasterFrameWorkCalculator.calculate(
            damageWidth: .max,
            damageHeight: 1,
            operationCount: 2,
            regionHeight: .max,
            limits: limits
        ) == .arithmeticOverflow
    )
}

@Test
func frameWorkRejectsHeadersThatContradictConstruction() {
    let shiftedSurface = Rect(
        origin: Point(x: 1, y: 0),
        size: Size(width: 8, height: 6)!
    )!
    let outsideDamage = Rect(
        origin: Point(x: 7, y: 5),
        size: Size(width: 2, height: 1)!
    )!

    #expect(
        RasterFrameWorkCalculator.headerBounds(
            header(surface: shiftedSurface),
            descriptor: workDescriptor,
            sinkCapacity: workCapacity,
            limits: workLimits()
        ) == .invalidHeader
    )
    #expect(
        RasterFrameWorkCalculator.headerBounds(
            header(damage: outsideDamage),
            descriptor: workDescriptor,
            sinkCapacity: workCapacity,
            limits: workLimits()
        ) == .invalidHeader
    )
    #expect(
        RasterFrameWorkCalculator.headerBounds(
            header(operations: 4),
            descriptor: workDescriptor,
            sinkCapacity: workCapacity,
            limits: workLimits()
        ) == .invalidHeader
    )
    #expect(
        RasterFrameWorkCalculator.headerBounds(
            header(glyphs: 3),
            descriptor: workDescriptor,
            sinkCapacity: workCapacity,
            limits: workLimits()
        ) == .invalidHeader
    )
}

private extension RasterFrameWorkCalculation {
    var isAdmitted: Bool {
        if case .admitted = self { return true }
        return false
    }
}
