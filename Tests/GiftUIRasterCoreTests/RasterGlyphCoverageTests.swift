import GiftUI
import GiftUICapabilities
import GiftUIRenderCore
import GiftUISurfaceCore
import GiftUITextResources
import Testing

@testable import GiftUIRasterCore

private let glyphDigest = TextResourceDigest(
    word0: 1,
    word1: 2,
    word2: 3,
    word3: 4,
    word4: 5,
    word5: 6,
    word6: 7,
    word7: 8
)
private let glyphResource = FontResourceID(rawValue: glyphDigest)
private let glyphInstance = FontInstanceID(
    resource: glyphResource,
    instanceIndex: 0
)
private let glyphResourceDescriptor = TextResourceDescriptor(
    schemaVersion: 1,
    resource: glyphResource,
    instanceCount: 1,
    realizationCount: 1,
    canonicalManifestByteCount: 1
)
private let glyphRealization = RasterRealizationDescriptor(
    id: RasterRealizationID(rawValue: 0),
    instance: glyphInstance,
    kind: .monochromeBitmap1,
    glyphCount: 1,
    payloadByteCount: 2,
    payloadDigest: glyphDigest
)
private let glyphRecord = GlyphRasterRecord(
    glyph: GlyphID(rawValue: 0),
    offset: 0,
    byteCount: 2,
    rowByteCount: 1,
    pixelWidth: 3,
    pixelHeight: 2
)
private let glyphMetrics = GlyphMetrics(
    advanceX: 4,
    offsetX: -1,
    offsetY: -2,
    inkSize: Size(width: 3, height: 2)!
)
private let glyphBounds = Rect(
    origin: Point(x: 0, y: 0),
    size: Size(width: 5, height: 4)!
)!
private let glyphDescriptor = RasterSurfaceDescriptor(
    bounds: glyphBounds,
    encoding: .rgb565BigEndian,
    bytesPerRow: 10,
    realization: .fullSurface,
    regionWidth: 5,
    regionHeight: 4
)!
private let glyphOperation = PositionedGlyphOperationHeader(
    instance: glyphInstance,
    clip: glyphBounds,
    color: .green,
    glyphCount: 1
)

@Test
func glyphCoverageUsesExactMetricsRecordPayloadBaselineAndClip() {
    let metrics = GlyphMetricsFixture()
    let raster = GlyphRasterFixture()
    var pixels: [(Point, CanonicalEncodedPixel)] = []

    let result = RasterGlyphCoverage.rasterize(
        PositionedGlyph(glyph: GlyphID(rawValue: 0), baseline: Point(x: 2, y: 2)),
        operation: glyphOperation,
        metrics: metrics,
        raster: raster,
        realization: glyphRealization,
        descriptor: glyphDescriptor,
        damageBounds: glyphBounds
    ) { point, pixel in
        pixels.append((point, pixel))
        return true
    }

    #expect(result == .completed(pixelCount: 4, payloadBytes: 2))
    #expect(metrics.requests.count == 1)
    #expect(metrics.requests[0].0 == GlyphID(rawValue: 0))
    #expect(metrics.requests[0].1 == glyphInstance)
    #expect(raster.recordRequests.count == 1)
    #expect(raster.recordRequests[0].0 == GlyphID(rawValue: 0))
    #expect(raster.recordRequests[0].1 == glyphRealization.id)
    #expect(raster.payloadRequests.count == 1)
    #expect(raster.payloadRequests[0].0 == glyphRecord)
    #expect(raster.payloadRequests[0].1 == glyphRealization.id)
    #expect(
        pixels.map(\.0) == [
            Point(x: 1, y: 0),
            Point(x: 3, y: 0),
            Point(x: 2, y: 1),
            Point(x: 3, y: 1),
        ])
    #expect(pixels.allSatisfy { ($0.1.byte0, $0.1.byte1) == (0x07, 0xE0) })
    #expect(raster.payload == [0, 0])
}

@Test
func glyphCoverageClipsBeforeBorrowAndSkipsEmptyPayloadAccess() {
    let emptyClip = Rect(
        origin: Point(x: 4, y: 3),
        size: Size(width: 1, height: 1)!
    )!
    let operation = PositionedGlyphOperationHeader(
        instance: glyphInstance,
        clip: emptyClip,
        color: .red,
        glyphCount: 1
    )
    let raster = GlyphRasterFixture()

    let result = RasterGlyphCoverage.rasterize(
        PositionedGlyph(glyph: GlyphID(rawValue: 0), baseline: Point(x: 2, y: 2)),
        operation: operation,
        metrics: GlyphMetricsFixture(),
        raster: raster,
        realization: glyphRealization,
        descriptor: glyphDescriptor,
        damageBounds: glyphBounds
    ) { _, _ in false }

    #expect(result == .completed(pixelCount: 0, payloadBytes: 0))
    #expect(raster.recordRequests.count == 1)
    #expect(raster.payloadRequests.isEmpty)
}

@Test
func glyphCoverageRejectsMissingExactResourceWithoutFallback() {
    let missingMetrics = GlyphMetricsFixture(storedMetrics: nil)
    let unusedRaster = GlyphRasterFixture()
    #expect(
        rasterizeGlyph(metrics: missingMetrics, raster: unusedRaster)
            == .incompatibleResource
    )
    #expect(missingMetrics.requests.count == 1)
    #expect(unusedRaster.recordRequests.isEmpty)

    let missingRecord = GlyphRasterFixture(storedRecord: nil)
    #expect(
        rasterizeGlyph(metrics: GlyphMetricsFixture(), raster: missingRecord)
            == .incompatibleResource
    )
    #expect(missingRecord.recordRequests.count == 1)
    #expect(missingRecord.payloadRequests.isEmpty)

    let missingPayload = GlyphRasterFixture(payloadAvailable: false)
    #expect(
        rasterizeGlyph(metrics: GlyphMetricsFixture(), raster: missingPayload)
            == .incompatibleResource
    )
    #expect(missingPayload.payloadRequests.count == 1)
}

@Test
func glyphCoverageRejectsWrongIdentityKindAndCheckedBaselineOverflow() {
    let wrongOperation = PositionedGlyphOperationHeader(
        instance: FontInstanceID(resource: glyphResource, instanceIndex: 1),
        clip: glyphBounds,
        color: .red,
        glyphCount: 1
    )
    let raster = GlyphRasterFixture()
    #expect(
        RasterGlyphCoverage.rasterize(
            PositionedGlyph(glyph: GlyphID(rawValue: 0), baseline: Point(x: 2, y: 2)),
            operation: wrongOperation,
            metrics: GlyphMetricsFixture(),
            raster: raster,
            realization: glyphRealization,
            descriptor: glyphDescriptor,
            damageBounds: glyphBounds
        ) { _, _ in true } == .incompatibleResource
    )
    #expect(raster.recordRequests.isEmpty)

    let outline = RasterRealizationDescriptor(
        id: glyphRealization.id,
        instance: glyphInstance,
        kind: .packagedOutline,
        glyphCount: 1,
        payloadByteCount: 2,
        payloadDigest: glyphDigest
    )
    #expect(
        rasterizeGlyph(
            metrics: GlyphMetricsFixture(),
            raster: GlyphRasterFixture(),
            realization: outline
        ) == .incompatibleResource
    )

    let overflowMetrics = GlyphMetricsFixture(
        storedMetrics: GlyphMetrics(
            advanceX: 0,
            offsetX: 1,
            offsetY: 0,
            inkSize: glyphMetrics.inkSize
        )
    )
    #expect(
        rasterizeGlyph(
            glyph: PositionedGlyph(
                glyph: GlyphID(rawValue: 0),
                baseline: Point(x: .max, y: 0)
            ),
            metrics: overflowMetrics,
            raster: GlyphRasterFixture()
        ) == .invalidGeometry
    )
}

private func rasterizeGlyph(
    glyph: PositionedGlyph = PositionedGlyph(
        glyph: GlyphID(rawValue: 0),
        baseline: Point(x: 2, y: 2)
    ),
    metrics: GlyphMetricsFixture,
    raster: GlyphRasterFixture,
    realization: RasterRealizationDescriptor = glyphRealization
) -> RasterGlyphResult {
    RasterGlyphCoverage.rasterize(
        glyph,
        operation: glyphOperation,
        metrics: metrics,
        raster: raster,
        realization: realization,
        descriptor: glyphDescriptor,
        damageBounds: glyphBounds
    ) { _, _ in true }
}

private final class GlyphMetricsFixture: CanonicalTextMetricsView {
    let descriptor = glyphResourceDescriptor
    let storedMetrics: GlyphMetrics?
    private(set) var requests: [(GlyphID, FontInstanceID)] = []

    init(storedMetrics: GlyphMetrics? = glyphMetrics) {
        self.storedMetrics = storedMetrics
    }

    func instance(at index: UInt16) -> FontInstanceDescriptor? { nil }

    func mapping(
        at index: UInt16,
        in instance: FontInstanceID
    ) -> ScalarGlyphMappingRecord? { nil }

    func mapScalar(
        _ scalarValue: UInt32,
        in instance: FontInstanceID
    ) -> GlyphMapping? { nil }

    func metrics(
        for glyph: GlyphID,
        in instance: FontInstanceID
    ) -> GlyphMetrics? {
        requests.append((glyph, instance))
        guard glyph == glyphRecord.glyph, instance == glyphInstance else {
            return nil
        }
        return storedMetrics
    }
}

private final class GlyphRasterFixture: TextRasterResourceView {
    let descriptor = glyphResourceDescriptor
    let storedRecord: GlyphRasterRecord?
    let payloadAvailable: Bool
    private(set) var payload: [UInt8] = [0xA0, 0x60]
    private(set) var recordRequests: [(GlyphID, RasterRealizationID)] = []
    private(set) var payloadRequests: [(GlyphRasterRecord, RasterRealizationID)] = []

    init(
        storedRecord: GlyphRasterRecord? = glyphRecord,
        payloadAvailable: Bool = true
    ) {
        self.storedRecord = storedRecord
        self.payloadAvailable = payloadAvailable
    }

    func realization(at index: UInt16) -> RasterRealizationDescriptor? {
        index == glyphRealization.id.rawValue ? glyphRealization : nil
    }

    func record(
        for glyph: GlyphID,
        realization: RasterRealizationID
    ) -> GlyphRasterRecord? {
        recordRequests.append((glyph, realization))
        return storedRecord
    }

    func isPayloadAvailable(for realization: RasterRealizationID) -> Bool {
        payloadAvailable && realization == glyphRealization.id
    }

    func withPayload<Result>(
        for record: GlyphRasterRecord,
        realization: RasterRealizationID,
        _ body: (UnsafeRawBufferPointer) throws -> Result
    ) rethrows -> Result? {
        payloadRequests.append((record, realization))
        guard payloadAvailable,
            record == storedRecord,
            realization == glyphRealization.id
        else { return nil }
        let result = try payload.withUnsafeBytes(body)
        payload = [0, 0]
        return result
    }
}
