import GiftUI
import XCTest

@testable import GiftUITextResources

final class WorkBoundTests: XCTestCase {
    func testMaximumLinearMappingLookupUsesExactly256Comparisons() {
        let fixture = CountingFixture()
        let instance = fixture.metrics.instanceDescriptor.id
        XCTAssertEqual(
            fixture.metrics.mapScalar(0x20ff, in: instance),
            .exact(GiftUITextResources.GlyphID(rawValue: 255))
        )
        XCTAssertEqual(fixture.metrics.mappingVisits, 256)

        fixture.metrics.resetVisits()
        XCTAssertEqual(
            fixture.metrics.mapScalar(0x30ff, in: instance),
            .replacement(GiftUITextResources.GlyphID(rawValue: 0))
        )
        XCTAssertEqual(fixture.metrics.mappingVisits, 256)

        fixture.metrics.resetVisits()
        XCTAssertNil(fixture.metrics.mapScalar(0xd800, in: instance))
        XCTAssertEqual(fixture.metrics.mappingVisits, 0)
    }

    func testMetricRecordAndPayloadLookupsUseOneBoundedVisit() {
        let fixture = CountingFixture()
        let instance = fixture.metrics.instanceDescriptor.id
        let glyph = GiftUITextResources.GlyphID(rawValue: 255)
        let realization = fixture.raster.realizationDescriptor.id
        XCTAssertNotNil(fixture.metrics.metrics(for: glyph, in: instance))
        XCTAssertNotNil(fixture.raster.record(for: glyph, realization: realization))
        let record = fixture.raster.record(for: glyph, realization: realization)!
        let result = fixture.raster.withPayload(
            for: record,
            realization: realization
        ) { $0.count }
        XCTAssertEqual(result, 0)
        XCTAssertEqual(fixture.metrics.metricVisits, 1)
        XCTAssertEqual(fixture.raster.recordVisits, 2)
        XCTAssertEqual(fixture.raster.payloadVisits, 1)
    }

    func testCanonicalPathVisitsEveryTableEntryExactlyOnce() {
        let fixture = CountingFixture()
        var canonicalByteVisits: UInt32 = 0
        let byteCount = TextResourceValidator.forEachCanonicalManifestByte(
            in: fixture.resourcePackage,
            { _ in canonicalByteVisits += 1 }
        )
        XCTAssertEqual(byteCount, canonicalByteVisits)
        XCTAssertEqual(fixture.metrics.instanceVisits, 1)
        XCTAssertEqual(fixture.metrics.mappingVisits, 256)
        XCTAssertEqual(fixture.metrics.metricVisits, 256)
        XCTAssertEqual(fixture.raster.realizationVisits, 1)
        XCTAssertEqual(fixture.raster.recordVisits, 256)
        XCTAssertEqual(fixture.raster.payloadVisits, 0)
    }
}

private final class CountingFixture {
    let metrics: CountingMetrics
    let raster: CountingRaster

    init() {
        let digest = TextResourceDigest(
            word0: 0, word1: 0, word2: 0, word3: 0,
            word4: 0, word5: 0, word6: 0, word7: 0
        )
        let resource = FontResourceID(rawValue: digest)
        let descriptor = TextResourceDescriptor(
            schemaVersion: 1,
            resource: resource,
            instanceCount: 1,
            realizationCount: 1,
            canonicalManifestByteCount: 11_589
        )
        let instanceID = FontInstanceID(resource: resource, instanceIndex: 0)
        let instance = FontInstanceDescriptor(
            id: instanceID,
            lineMetrics: FontLineMetrics(ascent: 12, descent: 3, lineGap: 2),
            replacementGlyph: GiftUITextResources.GlyphID(rawValue: 0),
            glyphCount: 256,
            mappingCount: 256
        )
        metrics = CountingMetrics(
            descriptor: descriptor,
            instanceDescriptor: instance
        )
        raster = CountingRaster(
            descriptor: descriptor,
            realizationDescriptor: RasterRealizationDescriptor(
                id: RasterRealizationID(rawValue: 0),
                instance: instanceID,
                kind: .monochromeBitmap1,
                glyphCount: 256,
                payloadByteCount: 0,
                payloadDigest: digest
            )
        )
    }

    var resourcePackage: TextResourcePackage<CountingMetrics, CountingRaster> {
        TextResourcePackage(metrics: metrics, raster: raster)
    }
}

private final class CountingMetrics: CanonicalTextMetricsView {
    let descriptor: TextResourceDescriptor
    let instanceDescriptor: FontInstanceDescriptor
    private(set) var instanceVisits = 0
    private(set) var mappingVisits = 0
    private(set) var metricVisits = 0

    init(
        descriptor: TextResourceDescriptor,
        instanceDescriptor: FontInstanceDescriptor
    ) {
        self.descriptor = descriptor
        self.instanceDescriptor = instanceDescriptor
    }

    func resetVisits() {
        instanceVisits = 0
        mappingVisits = 0
        metricVisits = 0
    }

    func instance(at index: UInt16) -> FontInstanceDescriptor? {
        instanceVisits += 1
        return index == 0 ? instanceDescriptor : nil
    }

    func mapping(
        at index: UInt16,
        in instance: FontInstanceID
    ) -> ScalarGlyphMappingRecord? {
        mappingVisits += 1
        guard instance == instanceDescriptor.id, index < 256 else { return nil }
        return ScalarGlyphMappingRecord(
            scalarValue: 0x2000 + UInt32(index),
            glyph: GiftUITextResources.GlyphID(rawValue: index)
        )
    }

    func metrics(
        for glyph: GiftUITextResources.GlyphID,
        in instance: FontInstanceID
    ) -> GlyphMetrics? {
        metricVisits += 1
        guard instance == instanceDescriptor.id, glyph.rawValue < 256 else {
            return nil
        }
        return GlyphMetrics(
            advanceX: 1,
            offsetX: 0,
            offsetY: 0,
            inkSize: Size(width: 0, height: 0)!
        )
    }
}

private final class CountingRaster: TextRasterResourceView {
    let descriptor: TextResourceDescriptor
    let realizationDescriptor: RasterRealizationDescriptor
    private(set) var realizationVisits = 0
    private(set) var recordVisits = 0
    private(set) var payloadVisits = 0

    init(
        descriptor: TextResourceDescriptor,
        realizationDescriptor: RasterRealizationDescriptor
    ) {
        self.descriptor = descriptor
        self.realizationDescriptor = realizationDescriptor
    }

    func realization(at index: UInt16) -> RasterRealizationDescriptor? {
        realizationVisits += 1
        return index == 0 ? realizationDescriptor : nil
    }

    func record(
        for glyph: GiftUITextResources.GlyphID,
        realization: RasterRealizationID
    ) -> GlyphRasterRecord? {
        recordVisits += 1
        guard realization == realizationDescriptor.id, glyph.rawValue < 256 else {
            return nil
        }
        return GlyphRasterRecord(
            glyph: glyph,
            offset: 0,
            byteCount: 0,
            rowByteCount: 0,
            pixelWidth: 0,
            pixelHeight: 0
        )
    }

    func isPayloadAvailable(for realization: RasterRealizationID) -> Bool {
        realization == realizationDescriptor.id
    }

    func withPayload<Result>(
        for record: GlyphRasterRecord,
        realization: RasterRealizationID,
        _ body: (UnsafeRawBufferPointer) throws -> Result
    ) rethrows -> Result? {
        guard realization == realizationDescriptor.id,
            record.glyph.rawValue < 256,
            record.byteCount == 0
        else { return nil }
        payloadVisits += 1
        return try body(UnsafeRawBufferPointer(start: nil, count: 0))
    }
}
