@testable import GiftUITextResources
import GiftUI
import XCTest

final class AccessorBehaviorTests: XCTestCase {
    func testUnicodeScalarClassificationCoversEveryBoundary() {
        XCTAssertTrue(TextResourceValidator.isValidUnicodeScalar(0))
        XCTAssertTrue(TextResourceValidator.isValidUnicodeScalar(0xd7ff))
        XCTAssertFalse(TextResourceValidator.isValidUnicodeScalar(0xd800))
        XCTAssertFalse(TextResourceValidator.isValidUnicodeScalar(0xdfff))
        XCTAssertTrue(TextResourceValidator.isValidUnicodeScalar(0xe000))
        XCTAssertTrue(TextResourceValidator.isValidUnicodeScalar(0x10_ffff))
        XCTAssertFalse(TextResourceValidator.isValidUnicodeScalar(0x11_0000))
        XCTAssertFalse(TextResourceValidator.isValidUnicodeScalar(.max))
    }

    func testDefaultMappingIsExactForReferenceCoverageAndOtherwiseReplaces() {
        let fixture = makeAccessorFixture()
        let instance = fixture.metrics.instanceDescriptor.id
        var expectedGlyph: UInt16 = 1
        for scalar in UInt32(0x20) ... UInt32(0x7e) {
            XCTAssertEqual(
                fixture.metrics.mapScalar(scalar, in: instance),
                .exact(GlyphID(rawValue: expectedGlyph))
            )
            expectedGlyph += 1
        }
        XCTAssertEqual(
            fixture.metrics.mapScalar(0x00b0, in: instance),
            .exact(GlyphID(rawValue: 96))
        )
        XCTAssertEqual(
            fixture.metrics.mapScalar(0x2603, in: instance),
            .replacement(GlyphID(rawValue: 0))
        )
        XCTAssertEqual(
            fixture.metrics.mapScalar(0x41, in: instance),
            .exact(GlyphID(rawValue: 34))
        )
        XCTAssertEqual(
            fixture.metrics.mapScalar(0x61, in: instance),
            .exact(GlyphID(rawValue: 66))
        )
    }

    func testMappingRejectsLineBreakInvalidAndMismatchedIdentityInputs() {
        let fixture = makeAccessorFixture()
        let instance = fixture.metrics.instanceDescriptor.id
        XCTAssertNil(fixture.metrics.mapScalar(0x0a, in: instance))
        XCTAssertNil(fixture.metrics.mapScalar(0x0d, in: instance))
        XCTAssertNil(fixture.metrics.mapScalar(0xd800, in: instance))
        XCTAssertNil(fixture.metrics.mapScalar(0x11_0000, in: instance))

        let otherResource = FontResourceID(rawValue: digest(1))
        XCTAssertNil(
            fixture.metrics.mapScalar(
                0x41,
                in: FontInstanceID(resource: otherResource, instanceIndex: 0)
            )
        )
        XCTAssertNil(
            fixture.metrics.mapScalar(
                0x41,
                in: FontInstanceID(
                    resource: instance.resource,
                    instanceIndex: 1
                )
            )
        )
    }

    func testExplicitCRLFAndIsolatedBreakClassificationPrecedesLookup() {
        let fixture = makeAccessorFixture()
        let scalars: [UInt32] = [0x41, 0x0d, 0x0a, 0x42, 0x0d, 0x43, 0x0a]
        let result = classifySequence(
            scalars,
            metrics: fixture.metrics,
            instance: fixture.metrics.instanceDescriptor.id
        )
        XCTAssertEqual(result.lineBreaks, 3)
        XCTAssertEqual(result.glyphs.count, 3)
        XCTAssertEqual(result.glyphs[0], .exact(GlyphID(rawValue: 34)))
        XCTAssertEqual(result.glyphs[1], .exact(GlyphID(rawValue: 35)))
        XCTAssertEqual(result.glyphs[2], .exact(GlyphID(rawValue: 36)))
    }

    func testMetricAndRasterAccessorsAreTotalAndIdentityExact() {
        let fixture = makeAccessorFixture()
        let instance = fixture.metrics.instanceDescriptor.id
        XCTAssertEqual(fixture.metrics.instance(at: 0), fixture.metrics.instanceDescriptor)
        XCTAssertNil(fixture.metrics.instance(at: 1))
        XCTAssertNotNil(
            fixture.metrics.metrics(for: GlyphID(rawValue: 96), in: instance)
        )
        XCTAssertNil(
            fixture.metrics.metrics(for: GlyphID(rawValue: 97), in: instance)
        )
        XCTAssertNil(
            fixture.metrics.metrics(
                for: GlyphID(rawValue: 0),
                in: FontInstanceID(resource: digestResource(2), instanceIndex: 0)
            )
        )

        let realization = RasterRealizationID(rawValue: 0)
        XCTAssertNotNil(fixture.raster.realization(at: 0))
        XCTAssertNil(fixture.raster.realization(at: 1))
        XCTAssertNotNil(
            fixture.raster.record(for: GlyphID(rawValue: 0), realization: realization)
        )
        XCTAssertNil(
            fixture.raster.record(for: GlyphID(rawValue: 97), realization: realization)
        )
        XCTAssertNil(
            fixture.raster.record(
                for: GlyphID(rawValue: 0),
                realization: RasterRealizationID(rawValue: 1)
            )
        )
        XCTAssertTrue(fixture.raster.isPayloadAvailable(for: realization))
        XCTAssertFalse(
            fixture.raster.isPayloadAvailable(
                for: RasterRealizationID(rawValue: 1)
            )
        )
    }

    func testCheckedInkAndAdvanceGeometryRejectEveryOverflowBoundary() {
        let metrics = GlyphMetrics(
            advanceX: 7,
            offsetX: -2,
            offsetY: 3,
            inkSize: Size(width: 9, height: 4)!
        )
        XCTAssertEqual(
            metrics.checkedInkRectangle(at: Point(x: 10, y: 20)),
            Rect(origin: Point(x: 8, y: 23), size: Size(width: 9, height: 4)!)
        )
        XCTAssertEqual(
            metrics.checkedAdvancedOrigin(from: Point(x: 10, y: 20)),
            Point(x: 17, y: 20)
        )
        XCTAssertNil(
            metrics.checkedAdvancedOrigin(from: Point(x: .max, y: 0))
        )
        XCTAssertNil(metrics.checkedInkRectangle(at: Point(x: .min, y: 0)))

        let edgeOverflow = GlyphMetrics(
            advanceX: 0,
            offsetX: 0,
            offsetY: 0,
            inkSize: Size(width: 1, height: 1)!
        )
        XCTAssertNil(
            edgeOverflow.checkedInkRectangle(at: Point(x: .max, y: 0))
        )
        XCTAssertNil(
            edgeOverflow.checkedInkRectangle(at: Point(x: 0, y: .max))
        )
    }

    func testMonochromeBitmapUsesMSBFirstRowsAndZeroPadding() {
        let record = GlyphRasterRecord(
            glyph: GlyphID(rawValue: 0),
            offset: 0,
            byteCount: 4,
            rowByteCount: 2,
            pixelWidth: 9,
            pixelHeight: 2
        )
        let metrics = GlyphMetrics(
            advanceX: 9,
            offsetX: 0,
            offsetY: 0,
            inkSize: Size(width: 9, height: 2)!
        )
        let bytes: [UInt8] = [0x80, 0x80, 0x40, 0x00]
        bytes.withUnsafeBytes { buffer in
            XCTAssertTrue(
                TextResourceValidator.isStructurallyValidMonochromeBitmap(
                    record: record,
                    metrics: metrics,
                    bytes: buffer
                )
            )
            XCTAssertEqual(
                TextResourceValidator.monochromeBitmapCoverage(
                    x: 0, y: 0, record: record, bytes: buffer
                ),
                true
            )
            XCTAssertEqual(
                TextResourceValidator.monochromeBitmapCoverage(
                    x: 1, y: 0, record: record, bytes: buffer
                ),
                false
            )
            XCTAssertEqual(
                TextResourceValidator.monochromeBitmapCoverage(
                    x: 8, y: 0, record: record, bytes: buffer
                ),
                true
            )
            XCTAssertEqual(
                TextResourceValidator.monochromeBitmapCoverage(
                    x: 1, y: 1, record: record, bytes: buffer
                ),
                true
            )
            XCTAssertNil(
                TextResourceValidator.monochromeBitmapCoverage(
                    x: 9, y: 0, record: record, bytes: buffer
                )
            )
        }
    }

    func testMonochromeBitmapRejectsRowCountDimensionsBytesAndPadding() {
        let metrics = GlyphMetrics(
            advanceX: 9,
            offsetX: 0,
            offsetY: 0,
            inkSize: Size(width: 9, height: 1)!
        )
        let base = GlyphRasterRecord(
            glyph: GlyphID(rawValue: 0), offset: 0, byteCount: 2,
            rowByteCount: 2, pixelWidth: 9, pixelHeight: 1
        )
        assertInvalidBitmap(base, metrics, [0x80, 0x01])
        assertInvalidBitmap(
            GlyphRasterRecord(
                glyph: base.glyph, offset: 0, byteCount: 1,
                rowByteCount: 1, pixelWidth: 9, pixelHeight: 1
            ),
            metrics,
            [0x80]
        )
        assertInvalidBitmap(base, metrics, [0x80])
        assertInvalidBitmap(
            base,
            GlyphMetrics(
                advanceX: 9, offsetX: 0, offsetY: 0,
                inkSize: Size(width: 8, height: 1)!
            ),
            [0x80, 0x00]
        )
    }

    func testRasterRecordsMustBeAnExactGapFreePartition() {
        let fixture = makePartitionFixture(offsets: [0, 2], counts: [2, 1])
        XCTAssertTrue(
            TextResourceValidator.recordsFormGapFreePartition(
                for: fixture.raster.realizations[0],
                in: fixture.raster
            )
        )
        for malformed in [
            makePartitionFixture(offsets: [0, 3], counts: [2, 0]),
            makePartitionFixture(offsets: [0, 1], counts: [2, 1]),
            makePartitionFixture(offsets: [1, 2], counts: [1, 1]),
            makePartitionFixture(offsets: [0, 2], counts: [2, 2]),
        ] {
            XCTAssertFalse(
                TextResourceValidator.recordsFormGapFreePartition(
                    for: malformed.raster.realizations[0],
                    in: malformed.raster
                )
            )
        }
    }

    func testPackagedOutlineAcceptsExactGrammarAndBigEndianHeader() {
        let bytes = validOutlineBytes()
        let record = outlineRecord(byteCount: UInt32(bytes.count))
        bytes.withUnsafeBytes { buffer in
            XCTAssertTrue(
                TextResourceValidator.isStructurallyValidPackagedOutline(
                    record: record,
                    metrics: outlineMetrics(),
                    bytes: buffer
                )
            )
        }
        var openContour = bytes
        openContour[openContour.count - 1] = 6
        openContour.withUnsafeBytes { buffer in
            XCTAssertTrue(
                TextResourceValidator.isStructurallyValidPackagedOutline(
                    record: outlineRecord(byteCount: UInt32(openContour.count)),
                    metrics: outlineMetrics(),
                    bytes: buffer
                )
            )
        }
    }

    func testPackagedOutlineRejectsVersionHeaderAritySentinelAndTrailingErrors() {
        let valid = validOutlineBytes()
        var cases: [[UInt8]] = [
            [],
            [1, 0x08, 0x00, 0x00, 0x10],
            [2] + Array(valid.dropFirst()),
            [1, 0, 0, 0, 16, 1, 1, 0, 0, 0, 0, 5],
            [1, 8, 0, 0, 0, 1, 1, 0, 0, 0, 0, 5],
            [1, 8, 0, 0, 16, 1, 2, 0, 0, 0, 0, 5],
            [1, 8, 0, 0, 16, 2, 1, 0, 0, 0, 0, 5],
            [1, 8, 0, 0, 16, 1, 1, 0, 0, 0, 0, 2, 2, 0, 0, 0, 0, 0, 0, 0, 0, 5],
            [1, 8, 0, 0, 16, 1, 1, 0, 0, 0, 0, 3, 0, 5],
            [1, 8, 0, 0, 16, 1, 1, 0, 0, 0, 0, 4, 2, 0, 0, 0, 0, 0, 0, 0, 0, 5],
            [1, 8, 0, 0, 16, 1, 1, 0, 0, 0, 0, 2, 1, 0x7f, 0xff, 0x7f, 0xff, 5],
            [1, 8, 0, 0, 16, 1, 1, 0, 0, 0, 0, 7],
            [1, 8, 0, 0, 16, 1, 1, 0, 0, 0, 0],
            [1, 8, 0, 0, 16, 5],
        ]
        var truncated = valid
        truncated.removeLast(3)
        cases.append(truncated)
        cases.append(valid + [0])

        for bytes in cases {
            bytes.withUnsafeBytes { buffer in
                XCTAssertFalse(
                    TextResourceValidator.isStructurallyValidPackagedOutline(
                        record: outlineRecord(byteCount: UInt32(bytes.count)),
                        metrics: outlineMetrics(),
                        bytes: buffer
                    ),
                    "unexpectedly accepted \(bytes)"
                )
            }
        }

        valid.withUnsafeBytes { buffer in
            XCTAssertFalse(
                TextResourceValidator.isStructurallyValidPackagedOutline(
                    record: GlyphRasterRecord(
                        glyph: GlyphID(rawValue: 0), offset: 0,
                        byteCount: UInt32(valid.count), rowByteCount: 1,
                        pixelWidth: 9, pixelHeight: 12
                    ),
                    metrics: outlineMetrics(),
                    bytes: buffer
                )
            )
        }
    }
}

private struct AccessorMetrics: CanonicalTextMetricsView {
    let descriptor: TextResourceDescriptor
    let instanceDescriptor: FontInstanceDescriptor
    let mappings: [ScalarGlyphMappingRecord]
    let glyphMetrics: [GlyphMetrics]

    func instance(at index: UInt16) -> FontInstanceDescriptor? {
        index == instanceDescriptor.id.instanceIndex
            && index < descriptor.instanceCount ? instanceDescriptor : nil
    }

    func mapping(
        at index: UInt16,
        in instance: FontInstanceID
    ) -> ScalarGlyphMappingRecord? {
        guard instance == instanceDescriptor.id,
              Int(index) < mappings.count else { return nil }
        return mappings[Int(index)]
    }

    func metrics(
        for glyph: GiftUITextResources.GlyphID,
        in instance: FontInstanceID
    ) -> GlyphMetrics? {
        guard instance == instanceDescriptor.id,
              Int(glyph.rawValue) < glyphMetrics.count else { return nil }
        return glyphMetrics[Int(glyph.rawValue)]
    }
}

private struct AccessorRaster: TextRasterResourceView {
    let descriptor: TextResourceDescriptor
    let realizations: [RasterRealizationDescriptor]
    let records: [[GlyphRasterRecord]]
    let available: [Bool]

    func realization(at index: UInt16) -> RasterRealizationDescriptor? {
        Int(index) < realizations.count ? realizations[Int(index)] : nil
    }

    func record(
        for glyph: GiftUITextResources.GlyphID,
        realization: RasterRealizationID
    ) -> GlyphRasterRecord? {
        guard Int(realization.rawValue) < realizations.count,
              realizations[Int(realization.rawValue)].id == realization,
              Int(glyph.rawValue) < records[Int(realization.rawValue)].count else {
            return nil
        }
        return records[Int(realization.rawValue)][Int(glyph.rawValue)]
    }

    func isPayloadAvailable(for realization: RasterRealizationID) -> Bool {
        Int(realization.rawValue) < realizations.count
            && realizations[Int(realization.rawValue)].id == realization
            && available[Int(realization.rawValue)]
    }

    func withPayload<Result>(
        for record: GlyphRasterRecord,
        realization: RasterRealizationID,
        _ body: (UnsafeRawBufferPointer) throws -> Result
    ) rethrows -> Result? { nil }
}

private func makeAccessorFixture()
    -> TextResourcePackage<AccessorMetrics, AccessorRaster> {
    let resource = digestResource(0)
    let instanceID = FontInstanceID(resource: resource, instanceIndex: 0)
    var mappings: [ScalarGlyphMappingRecord] = []
    var glyph: UInt16 = 1
    for scalar in UInt32(0x20) ... UInt32(0x7e) {
        mappings.append(
            ScalarGlyphMappingRecord(
                scalarValue: scalar,
                glyph: GlyphID(rawValue: glyph)
            )
        )
        glyph += 1
    }
    mappings.append(
        ScalarGlyphMappingRecord(
            scalarValue: 0x00b0,
            glyph: GlyphID(rawValue: 96)
        )
    )
    let glyphMetrics = (0 ..< 97).map { index in
        GlyphMetrics(
            advanceX: Int32(index + 1),
            offsetX: 0,
            offsetY: -12,
            inkSize: Size(width: 1, height: 12)!
        )
    }
    let descriptor = TextResourceDescriptor(
        schemaVersion: 1,
        resource: resource,
        instanceCount: 1,
        realizationCount: 1,
        canonicalManifestByteCount: 1
    )
    let instance = FontInstanceDescriptor(
        id: instanceID,
        lineMetrics: FontLineMetrics(ascent: 12, descent: 3, lineGap: 2),
        replacementGlyph: GlyphID(rawValue: 0),
        glyphCount: 97,
        mappingCount: 96
    )
    let realization = RasterRealizationDescriptor(
        id: RasterRealizationID(rawValue: 0),
        instance: instanceID,
        kind: .monochromeBitmap1,
        glyphCount: 97,
        payloadByteCount: 0,
        payloadDigest: digest(0)
    )
    let records = (0 ..< 97).map { index in
        GlyphRasterRecord(
            glyph: GlyphID(rawValue: UInt16(index)), offset: 0,
            byteCount: 0, rowByteCount: 1, pixelWidth: 1, pixelHeight: 12
        )
    }
    return TextResourcePackage(
        metrics: AccessorMetrics(
            descriptor: descriptor,
            instanceDescriptor: instance,
            mappings: mappings,
            glyphMetrics: glyphMetrics
        ),
        raster: AccessorRaster(
            descriptor: descriptor,
            realizations: [realization],
            records: [records],
            available: [true]
        )
    )
}

private func makePartitionFixture(offsets: [UInt32], counts: [UInt32])
    -> TextResourcePackage<AccessorMetrics, AccessorRaster> {
    let base = makeAccessorFixture()
    let realization = RasterRealizationDescriptor(
        id: RasterRealizationID(rawValue: 0),
        instance: base.metrics.instanceDescriptor.id,
        kind: .monochromeBitmap1,
        glyphCount: 2,
        payloadByteCount: 3,
        payloadDigest: digest(0)
    )
    let records = (0 ..< 2).map { index in
        GlyphRasterRecord(
            glyph: GlyphID(rawValue: UInt16(index)),
            offset: offsets[index],
            byteCount: counts[index],
            rowByteCount: 1,
            pixelWidth: 1,
            pixelHeight: UInt16(counts[index])
        )
    }
    return TextResourcePackage(
        metrics: base.metrics,
        raster: AccessorRaster(
            descriptor: base.raster.descriptor,
            realizations: [realization],
            records: [records],
            available: [true]
        )
    )
}

private func classifySequence(
    _ scalars: [UInt32],
    metrics: AccessorMetrics,
    instance: FontInstanceID
) -> (lineBreaks: Int, glyphs: [GlyphMapping]) {
    var lineBreaks = 0
    var glyphs: [GlyphMapping] = []
    var index = 0
    while index < scalars.count {
        if scalars[index] == 0x0d {
            lineBreaks += 1
            index += index + 1 < scalars.count && scalars[index + 1] == 0x0a
                ? 2 : 1
            continue
        }
        if scalars[index] == 0x0a {
            lineBreaks += 1
            index += 1
            continue
        }
        if let mapping = metrics.mapScalar(scalars[index], in: instance) {
            glyphs.append(mapping)
        }
        index += 1
    }
    return (lineBreaks, glyphs)
}

private func assertInvalidBitmap(
    _ record: GlyphRasterRecord,
    _ metrics: GlyphMetrics,
    _ bytes: [UInt8],
    file: StaticString = #filePath,
    line: UInt = #line
) {
    bytes.withUnsafeBytes { buffer in
        XCTAssertFalse(
            TextResourceValidator.isStructurallyValidMonochromeBitmap(
                record: record,
                metrics: metrics,
                bytes: buffer
            ),
            file: file,
            line: line
        )
    }
}

private func validOutlineBytes() -> [UInt8] {
    [
        1, 0x08, 0x00, 0x00, 0x10,
        1, 1, 0x00, 0x01, 0xff, 0xfe,
        3, 2, 0x00, 0x02, 0x00, 0x03, 0x7f, 0xff, 0x7f, 0xff,
        4, 3,
        0x00, 0x04, 0x00, 0x05,
        0x00, 0x06, 0x00, 0x07,
        0x00, 0x08, 0x00, 0x09,
        2, 1, 0xff, 0xff, 0x80, 0x00,
        5,
    ]
}

private func outlineRecord(byteCount: UInt32) -> GlyphRasterRecord {
    GlyphRasterRecord(
        glyph: GlyphID(rawValue: 0), offset: 0, byteCount: byteCount,
        rowByteCount: 0, pixelWidth: 9, pixelHeight: 12
    )
}

private func outlineMetrics() -> GlyphMetrics {
    GlyphMetrics(
        advanceX: 10,
        offsetX: 0,
        offsetY: -12,
        inkSize: Size(width: 9, height: 12)!
    )
}

private func digestResource(_ seed: UInt32) -> FontResourceID {
    FontResourceID(rawValue: digest(seed))
}

private func digest(_ seed: UInt32) -> TextResourceDigest {
    TextResourceDigest(
        word0: seed, word1: seed, word2: seed, word3: seed,
        word4: seed, word5: seed, word6: seed, word7: seed
    )
}
