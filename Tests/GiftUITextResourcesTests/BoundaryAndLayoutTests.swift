@testable import GiftUITextResources
import XCTest

final class BoundaryAndLayoutTests: XCTestCase {
    func testEveryNormativeValueHasBoundedSizeStrideAndAlignment() {
        assertLayout(TextResourceDigest.self, size: 32, maximum: 32)
        assertLayout(FontResourceID.self, size: 32, maximum: 32)
        assertLayout(FontInstanceID.self, size: 34, maximum: 36)
        assertLayout(GiftUITextResources.GlyphID.self, size: 2, maximum: 2)
        assertLayout(RasterRealizationID.self, size: 2, maximum: 2)
        assertLayout(TextRasterKind.self, size: 1, maximum: 1)
        assertLayout(FontLineMetrics.self, size: 12, maximum: 12)
        assertLayout(GlyphMetrics.self, size: 20, maximum: 24)
        assertLayout(FontInstanceDescriptor.self, size: 54, maximum: 80)
        assertLayout(RasterRealizationDescriptor.self, size: 80, maximum: 80)
        assertLayout(TextResourceDescriptor.self, size: 44, maximum: 80)
        assertLayout(GlyphMapping.self, size: 3, maximum: 4)
        assertLayout(ScalarGlyphMappingRecord.self, size: 6, maximum: 8)
        assertLayout(GlyphRasterRecord.self, size: 18, maximum: 80)
        assertLayout(TextResourceValidationError.self, size: 1, maximum: 1)
        assertLayout(TextResourceValidationResult.self, size: 1, maximum: 2)
    }

    func testInstanceCountZeroOneAndMaximumPlusOneIndependently() {
        XCTAssertTrue(withinCapacity(instanceCount: 0))
        XCTAssertTrue(withinCapacity(instanceCount: 1))
        XCTAssertFalse(withinCapacity(instanceCount: 2))
    }

    func testGlyphCountZeroOneMaximumAndMaximumPlusOneIndependently() {
        XCTAssertTrue(withinCapacity(glyphCount: 0))
        XCTAssertTrue(withinCapacity(glyphCount: 1))
        XCTAssertTrue(withinCapacity(glyphCount: 256))
        XCTAssertFalse(withinCapacity(glyphCount: 257))
    }

    func testMappingCountZeroOneMaximumAndMaximumPlusOneIndependently() {
        XCTAssertTrue(withinCapacity(mappingCount: 0))
        XCTAssertTrue(withinCapacity(mappingCount: 1))
        XCTAssertTrue(withinCapacity(mappingCount: 256))
        XCTAssertFalse(withinCapacity(mappingCount: 257))
    }

    func testRealizationCountZeroOneMaximumAndMaximumPlusOneIndependently() {
        XCTAssertTrue(withinCapacity(realizationCount: 0))
        XCTAssertTrue(withinCapacity(realizationCount: 1))
        XCTAssertTrue(withinCapacity(realizationCount: 2))
        XCTAssertFalse(withinCapacity(realizationCount: 3))
    }

    func testManifestBytesZeroOneMaximumAndMaximumPlusOneIndependently() {
        XCTAssertTrue(withinCapacity(canonicalManifestByteCount: 0))
        XCTAssertTrue(withinCapacity(canonicalManifestByteCount: 1))
        XCTAssertTrue(withinCapacity(canonicalManifestByteCount: 16_384))
        XCTAssertFalse(withinCapacity(canonicalManifestByteCount: 16_385))
    }

    func testPayloadBytesZeroOneMaximumAndMaximumPlusOneIndependently() {
        XCTAssertTrue(withinCapacity(payloadByteCount: 0))
        XCTAssertTrue(withinCapacity(payloadByteCount: 1))
        XCTAssertTrue(withinCapacity(payloadByteCount: 65_536))
        XCTAssertFalse(withinCapacity(payloadByteCount: 65_537))
    }

    func testZeroBytePayloadWithZeroByteRecordIsAnExactEmptyPartition() {
        let resource = FontResourceID(rawValue: zeroDigest())
        let descriptor = TextResourceDescriptor(
            schemaVersion: 1,
            resource: resource,
            instanceCount: 1,
            realizationCount: 1,
            canonicalManifestByteCount: 1
        )
        let realization = RasterRealizationDescriptor(
            id: RasterRealizationID(rawValue: 0),
            instance: FontInstanceID(resource: resource, instanceIndex: 0),
            kind: .monochromeBitmap1,
            glyphCount: 1,
            payloadByteCount: 0,
            payloadDigest: zeroDigest()
        )
        let raster = EmptyPartitionRaster(
            descriptor: descriptor,
            realizationDescriptor: realization,
            recordValue: GlyphRasterRecord(
                glyph: GiftUITextResources.GlyphID(rawValue: 0),
                offset: 0,
                byteCount: 0,
                rowByteCount: 0,
                pixelWidth: 0,
                pixelHeight: 0
            )
        )
        XCTAssertTrue(
            TextResourceValidator.recordsFormGapFreePartition(
                for: realization,
                in: raster
            )
        )
    }
}

private struct EmptyPartitionRaster: TextRasterResourceView {
    let descriptor: TextResourceDescriptor
    let realizationDescriptor: RasterRealizationDescriptor
    let recordValue: GlyphRasterRecord

    func realization(at index: UInt16) -> RasterRealizationDescriptor? {
        index == 0 ? realizationDescriptor : nil
    }

    func record(
        for glyph: GiftUITextResources.GlyphID,
        realization: RasterRealizationID
    ) -> GlyphRasterRecord? {
        glyph == recordValue.glyph && realization == realizationDescriptor.id
            ? recordValue : nil
    }

    func isPayloadAvailable(for realization: RasterRealizationID) -> Bool {
        realization == realizationDescriptor.id
    }

    func withPayload<Result>(
        for record: GlyphRasterRecord,
        realization: RasterRealizationID,
        _ body: (UnsafeRawBufferPointer) throws -> Result
    ) rethrows -> Result? {
        guard record == recordValue,
              realization == realizationDescriptor.id else { return nil }
        return try body(UnsafeRawBufferPointer(start: nil, count: 0))
    }
}

private func assertLayout<T>(
    _ type: T.Type,
    size: Int,
    maximum: Int,
    file: StaticString = #filePath,
    line: UInt = #line
) {
    XCTAssertEqual(MemoryLayout<T>.size, size, file: file, line: line)
    XCTAssertLessThanOrEqual(
        MemoryLayout<T>.size,
        maximum,
        file: file,
        line: line
    )
    XCTAssertGreaterThanOrEqual(
        MemoryLayout<T>.stride,
        MemoryLayout<T>.size,
        file: file,
        line: line
    )
    let alignment = MemoryLayout<T>.alignment
    XCTAssertGreaterThan(alignment, 0, file: file, line: line)
    XCTAssertEqual(
        alignment & (alignment - 1),
        0,
        file: file,
        line: line
    )
}

private func withinCapacity(
    instanceCount: UInt16 = 1,
    glyphCount: UInt16 = 1,
    mappingCount: UInt16 = 1,
    realizationCount: UInt16 = 1,
    canonicalManifestByteCount: UInt32 = 1,
    payloadByteCount: UInt32 = 1
) -> Bool {
    TextResourceValidator.isWithinCapacity(
        instanceCount: instanceCount,
        glyphCount: glyphCount,
        mappingCount: mappingCount,
        realizationCount: realizationCount,
        canonicalManifestByteCount: canonicalManifestByteCount,
        payloadByteCount: payloadByteCount
    )
}

private func zeroDigest() -> TextResourceDigest {
    TextResourceDigest(
        word0: 0, word1: 0, word2: 0, word3: 0,
        word4: 0, word5: 0, word6: 0, word7: 0
    )
}
