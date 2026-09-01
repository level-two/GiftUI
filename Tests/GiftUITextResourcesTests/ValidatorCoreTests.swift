@testable import GiftUITextResources
import GiftUI
import XCTest

final class ValidatorCoreTests: XCTestCase {
    func testCompleteSyntheticPackageValidates() {
        let fixture = makeValidValidationFixture()
        XCTAssertEqual(
            TextResourceValidator.validate(
                fixture,
                requiring: RasterRealizationID(rawValue: 0)
            ),
            .valid
        )
    }

    func testRawValuePrecedenceWinsOverTraversalOrder() {
        let fixture = makeValidValidationFixture(
            schemaVersion: 2,
            instanceCount: 0,
            realizationCount: 0,
            canonicalManifestByteCount: 0
        )
        XCTAssertEqual(
            TextResourceValidator.validate(
                fixture,
                requiring: RasterRealizationID(rawValue: 1)
            ),
            .invalid(.unsupportedSchema)
        )
    }

    func testEarlierPredicateDoesNotShortCircuitCompleteTraversal() {
        let base = makeValidValidationFixture(schemaVersion: 2)
        let metrics = CountingValidationMetrics(base: base.metrics)
        let raster = CountingValidationRaster(base: base.raster)
        let fixture = TextResourcePackage(metrics: metrics, raster: raster)
        XCTAssertEqual(
            TextResourceValidator.validate(
                fixture,
                requiring: RasterRealizationID(rawValue: 0)
            ),
            .invalid(.unsupportedSchema)
        )
        XCTAssertEqual(metrics.instanceVisits, 3)
        XCTAssertEqual(metrics.mappingVisits, 3)
        XCTAssertEqual(metrics.metricVisits, 4)
        XCTAssertEqual(raster.realizationVisits, 3)
        XCTAssertEqual(raster.recordVisits, 3)
        XCTAssertEqual(raster.payloadVisits, 1)
        XCTAssertEqual(raster.payloadByteVisits, 1)
    }
}

private final class CountingValidationMetrics: CanonicalTextMetricsView {
    let base: ValidationMetrics
    private(set) var instanceVisits = 0
    private(set) var mappingVisits = 0
    private(set) var metricVisits = 0

    init(base: ValidationMetrics) { self.base = base }

    var descriptor: TextResourceDescriptor { base.descriptor }

    func instance(at index: UInt16) -> FontInstanceDescriptor? {
        instanceVisits += 1
        return base.instance(at: index)
    }

    func mapping(
        at index: UInt16,
        in instance: FontInstanceID
    ) -> ScalarGlyphMappingRecord? {
        mappingVisits += 1
        return base.mapping(at: index, in: instance)
    }

    func metrics(
        for glyph: GiftUITextResources.GlyphID,
        in instance: FontInstanceID
    ) -> GlyphMetrics? {
        metricVisits += 1
        return base.metrics(for: glyph, in: instance)
    }
}

private final class CountingValidationRaster: TextRasterResourceView {
    let base: ValidationRaster
    private(set) var realizationVisits = 0
    private(set) var recordVisits = 0
    private(set) var payloadVisits = 0
    private(set) var payloadByteVisits = 0

    init(base: ValidationRaster) { self.base = base }

    var descriptor: TextResourceDescriptor { base.descriptor }

    func realization(at index: UInt16) -> RasterRealizationDescriptor? {
        realizationVisits += 1
        return base.realization(at: index)
    }

    func record(
        for glyph: GiftUITextResources.GlyphID,
        realization: RasterRealizationID
    ) -> GlyphRasterRecord? {
        recordVisits += 1
        return base.record(for: glyph, realization: realization)
    }

    func isPayloadAvailable(for realization: RasterRealizationID) -> Bool {
        base.isPayloadAvailable(for: realization)
    }

    func withPayload<Result>(
        for record: GlyphRasterRecord,
        realization: RasterRealizationID,
        _ body: (UnsafeRawBufferPointer) throws -> Result
    ) rethrows -> Result? {
        payloadVisits += 1
        return try base.withPayload(for: record, realization: realization) {
            payloadByteVisits += $0.count
            return try body($0)
        }
    }
}

private struct ValidationMetrics: CanonicalTextMetricsView {
    let descriptor: TextResourceDescriptor
    let instanceDescriptor: FontInstanceDescriptor
    let mappingRecord: ScalarGlyphMappingRecord
    let glyphMetrics: GlyphMetrics

    func instance(at index: UInt16) -> FontInstanceDescriptor? {
        index == 0 && descriptor.instanceCount > 0 ? instanceDescriptor : nil
    }

    func mapping(
        at index: UInt16,
        in instance: FontInstanceID
    ) -> ScalarGlyphMappingRecord? {
        index == 0 && instance == instanceDescriptor.id
            && instanceDescriptor.mappingCount > 0 ? mappingRecord : nil
    }

    func metrics(
        for glyph: GiftUITextResources.GlyphID,
        in instance: FontInstanceID
    ) -> GlyphMetrics? {
        glyph.rawValue == 0 && instance == instanceDescriptor.id
            && instanceDescriptor.glyphCount > 0 ? glyphMetrics : nil
    }
}

private struct ValidationRaster: TextRasterResourceView {
    let descriptor: TextResourceDescriptor
    let realizationDescriptor: RasterRealizationDescriptor
    let recordValue: GlyphRasterRecord
    let payload: [UInt8]

    func realization(at index: UInt16) -> RasterRealizationDescriptor? {
        index == 0 && descriptor.realizationCount > 0
            ? realizationDescriptor : nil
    }

    func record(
        for glyph: GiftUITextResources.GlyphID,
        realization: RasterRealizationID
    ) -> GlyphRasterRecord? {
        glyph.rawValue == 0 && realization == realizationDescriptor.id
            && realizationDescriptor.glyphCount > 0 ? recordValue : nil
    }

    func isPayloadAvailable(for realization: RasterRealizationID) -> Bool {
        realization == realizationDescriptor.id
            && descriptor.realizationCount > 0
    }

    func withPayload<Result>(
        for record: GlyphRasterRecord,
        realization: RasterRealizationID,
        _ body: (UnsafeRawBufferPointer) throws -> Result
    ) rethrows -> Result? {
        try payload.withUnsafeBytes { bytes in
            try TextResourceValidator.withPayloadSlice(
                for: record,
                cataloguedRecord: self.record(
                    for: record.glyph,
                    realization: realization
                ),
                realization: realization,
                cataloguedRealization: self.realization(
                    at: realization.rawValue
                ),
                isAvailable: isPayloadAvailable(for: realization),
                payload: bytes,
                body
            )
        }
    }
}

private func makeValidValidationFixture(
    schemaVersion: UInt16 = 1,
    instanceCount: UInt16 = 1,
    realizationCount: UInt16 = 1,
    canonicalManifestByteCount: UInt32 = 135
) -> TextResourcePackage<ValidationMetrics, ValidationRaster> {
    let payload: [UInt8] = [0x80]
    let payloadDigest = payload.withUnsafeBytes {
        TextResourceValidator.sha256(of: $0)
    }
    let zeroResource = FontResourceID(rawValue: zeroValidationDigest())
    let provisional = makeValidationFixture(
        resource: zeroResource,
        payloadDigest: payloadDigest,
        payload: payload,
        schemaVersion: schemaVersion,
        instanceCount: instanceCount,
        realizationCount: realizationCount,
        canonicalManifestByteCount: canonicalManifestByteCount
    )
    let identity = TextResourceValidator.canonicalManifestDigest(
        of: provisional
    )?.digest ?? zeroValidationDigest()
    return makeValidationFixture(
        resource: FontResourceID(rawValue: identity),
        payloadDigest: payloadDigest,
        payload: payload,
        schemaVersion: schemaVersion,
        instanceCount: instanceCount,
        realizationCount: realizationCount,
        canonicalManifestByteCount: canonicalManifestByteCount
    )
}

private func makeValidationFixture(
    resource: FontResourceID,
    payloadDigest: TextResourceDigest,
    payload: [UInt8],
    schemaVersion: UInt16,
    instanceCount: UInt16,
    realizationCount: UInt16,
    canonicalManifestByteCount: UInt32
) -> TextResourcePackage<ValidationMetrics, ValidationRaster> {
    let descriptor = TextResourceDescriptor(
        schemaVersion: schemaVersion,
        resource: resource,
        instanceCount: instanceCount,
        realizationCount: realizationCount,
        canonicalManifestByteCount: canonicalManifestByteCount
    )
    let instanceID = FontInstanceID(resource: resource, instanceIndex: 0)
    let instance = FontInstanceDescriptor(
        id: instanceID,
        lineMetrics: FontLineMetrics(ascent: 1, descent: 0, lineGap: 0),
        replacementGlyph: GiftUITextResources.GlyphID(rawValue: 0),
        glyphCount: 1,
        mappingCount: 1
    )
    let metrics = ValidationMetrics(
        descriptor: descriptor,
        instanceDescriptor: instance,
        mappingRecord: ScalarGlyphMappingRecord(
            scalarValue: 0x41,
            glyph: GiftUITextResources.GlyphID(rawValue: 0)
        ),
        glyphMetrics: GlyphMetrics(
            advanceX: 1,
            offsetX: 0,
            offsetY: 0,
            inkSize: Size(width: 1, height: 1)!
        )
    )
    let realization = RasterRealizationDescriptor(
        id: RasterRealizationID(rawValue: 0),
        instance: instanceID,
        kind: .monochromeBitmap1,
        glyphCount: 1,
        payloadByteCount: 1,
        payloadDigest: payloadDigest
    )
    let raster = ValidationRaster(
        descriptor: descriptor,
        realizationDescriptor: realization,
        recordValue: GlyphRasterRecord(
            glyph: GiftUITextResources.GlyphID(rawValue: 0),
            offset: 0,
            byteCount: 1,
            rowByteCount: 1,
            pixelWidth: 1,
            pixelHeight: 1
        ),
        payload: payload
    )
    return TextResourcePackage(metrics: metrics, raster: raster)
}

private func zeroValidationDigest() -> TextResourceDigest {
    TextResourceDigest(
        word0: 0, word1: 0, word2: 0, word3: 0,
        word4: 0, word5: 0, word6: 0, word7: 0
    )
}
