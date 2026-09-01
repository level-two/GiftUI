@testable import GiftUITextResources
import GiftUI
import XCTest

final class GiftUITextResourcesTests: XCTestCase {
    func testExactIdentityDeclarationsPreserveEveryRawWord() {
        let digest = makeDigest()
        XCTAssertEqual(digest.word0, 0x0011_2233)
        XCTAssertEqual(digest.word1, 0x4455_6677)
        XCTAssertEqual(digest.word2, 0x8899_aabb)
        XCTAssertEqual(digest.word3, 0xccdd_eeff)
        XCTAssertEqual(digest.word4, .min)
        XCTAssertEqual(digest.word5, .max)
        XCTAssertEqual(digest.word6, 0x0123_4567)
        XCTAssertEqual(digest.word7, 0x89ab_cdef)

        let resource = FontResourceID(rawValue: digest)
        let instance = FontInstanceID(resource: resource, instanceIndex: .max)
        let glyph = GlyphID(rawValue: .max)
        let realization = RasterRealizationID(rawValue: .max)
        let glyphRaw: UInt16 = glyph.rawValue
        let realizationRaw: UInt16 = realization.rawValue

        XCTAssertEqual(resource.rawValue, digest)
        XCTAssertEqual(instance.resource, resource)
        XCTAssertEqual(instance.instanceIndex, .max)
        XCTAssertEqual(glyphRaw, .max)
        XCTAssertEqual(realizationRaw, .max)
        XCTAssertEqual(Set([resource, resource]).count, 1)
        XCTAssertEqual(Set([instance, instance]).count, 1)
        XCTAssertEqual(Set([glyph, glyph]).count, 1)
        XCTAssertEqual(Set([realization, realization]).count, 1)
        requireSendable(digest)
        requireSendable(resource)
        requireSendable(instance)
        requireSendable(glyph)
        requireSendable(realization)
    }

    func testZeroRawValuesRemainPresentIdentities() {
        let zeroDigest = TextResourceDigest(
            word0: 0, word1: 0, word2: 0, word3: 0,
            word4: 0, word5: 0, word6: 0, word7: 0
        )
        XCTAssertEqual(FontResourceID(rawValue: zeroDigest).rawValue, zeroDigest)
        XCTAssertEqual(GlyphID(rawValue: 0).rawValue, 0)
        XCTAssertEqual(RasterRealizationID(rawValue: 0).rawValue, 0)
    }

    func testRasterKindsAndValidationErrorsHaveExactRawValues() {
        let bitmapRaw: UInt8 = TextRasterKind.monochromeBitmap1.rawValue
        let outlineRaw: UInt8 = TextRasterKind.packagedOutline.rawValue
        XCTAssertEqual(bitmapRaw, 0)
        XCTAssertEqual(outlineRaw, 1)

        let errors: [TextResourceValidationError] = [
            .unsupportedSchema,
            .capacityExceeded,
            .invalidCount,
            .invalidIdentity,
            .incompatibleViews,
            .malformedMetrics,
            .malformedMapping,
            .malformedRasterRecord,
            .integrityMismatch,
        ]
        XCTAssertEqual(errors.map(\.rawValue), Array(0 ... 8))
        XCTAssertEqual(TextResourceValidationResult.valid, .valid)
        XCTAssertEqual(
            TextResourceValidationResult.invalid(.invalidIdentity),
            .invalid(.invalidIdentity)
        )
        requireSendable(errors[0])
        requireSendable(TextResourceValidationResult.valid)
    }

    func testDescriptorsAndMetricsPreserveExactFields() throws {
        let resource = FontResourceID(rawValue: makeDigest())
        let instanceID = FontInstanceID(resource: resource, instanceIndex: 0)
        let glyph = GlyphID(rawValue: 7)
        let lineMetrics = FontLineMetrics(ascent: 12, descent: 3, lineGap: 2)
        let glyphMetrics = GlyphMetrics(
            advanceX: 11,
            offsetX: -2,
            offsetY: -12,
            inkSize: try XCTUnwrap(Size(width: 9, height: 12))
        )
        let instance = FontInstanceDescriptor(
            id: instanceID,
            lineMetrics: lineMetrics,
            replacementGlyph: glyph,
            glyphCount: 102,
            mappingCount: 96
        )
        let realization = RasterRealizationDescriptor(
            id: RasterRealizationID(rawValue: 1),
            instance: instanceID,
            kind: .packagedOutline,
            glyphCount: 102,
            payloadByteCount: 13_195,
            payloadDigest: makeDigest()
        )
        let descriptor = TextResourceDescriptor(
            schemaVersion: 1,
            resource: resource,
            instanceCount: 1,
            realizationCount: 2,
            canonicalManifestByteCount: 6_218
        )

        XCTAssertEqual(lineMetrics.ascent, 12)
        XCTAssertEqual(lineMetrics.descent, 3)
        XCTAssertEqual(lineMetrics.lineGap, 2)
        XCTAssertEqual(glyphMetrics.advanceX, 11)
        XCTAssertEqual(glyphMetrics.offsetX, -2)
        XCTAssertEqual(glyphMetrics.offsetY, -12)
        XCTAssertEqual(glyphMetrics.inkSize, Size(width: 9, height: 12))
        XCTAssertEqual(instance.id, instanceID)
        XCTAssertEqual(instance.lineMetrics, lineMetrics)
        XCTAssertEqual(instance.replacementGlyph, glyph)
        XCTAssertEqual(instance.glyphCount, 102)
        XCTAssertEqual(instance.mappingCount, 96)
        XCTAssertEqual(realization.id.rawValue, 1)
        XCTAssertEqual(realization.instance, instanceID)
        XCTAssertEqual(realization.kind, .packagedOutline)
        XCTAssertEqual(realization.glyphCount, 102)
        XCTAssertEqual(realization.payloadByteCount, 13_195)
        XCTAssertEqual(realization.payloadDigest, makeDigest())
        XCTAssertEqual(descriptor.schemaVersion, 1)
        XCTAssertEqual(descriptor.resource, resource)
        XCTAssertEqual(descriptor.instanceCount, 1)
        XCTAssertEqual(descriptor.realizationCount, 2)
        XCTAssertEqual(descriptor.canonicalManifestByteCount, 6_218)
        requireSendable(lineMetrics)
        requireSendable(glyphMetrics)
        requireSendable(instance)
        requireSendable(realization)
        requireSendable(descriptor)
    }

    func testMappingAndRasterRecordsPreserveExactFields() {
        let glyph = GlyphID(rawValue: 42)
        let mapping = ScalarGlyphMappingRecord(scalarValue: 0x00b0, glyph: glyph)
        let raster = GlyphRasterRecord(
            glyph: glyph,
            offset: 123,
            byteCount: 45,
            rowByteCount: 3,
            pixelWidth: 17,
            pixelHeight: 15
        )

        XCTAssertEqual(GlyphMapping.exact(glyph), .exact(glyph))
        XCTAssertEqual(GlyphMapping.replacement(glyph), .replacement(glyph))
        XCTAssertNotEqual(GlyphMapping.exact(glyph), .replacement(glyph))
        XCTAssertEqual(mapping.scalarValue, 0x00b0)
        XCTAssertEqual(mapping.glyph, glyph)
        XCTAssertEqual(raster.glyph, glyph)
        XCTAssertEqual(raster.offset, 123)
        XCTAssertEqual(raster.byteCount, 45)
        XCTAssertEqual(raster.rowByteCount, 3)
        XCTAssertEqual(raster.pixelWidth, 17)
        XCTAssertEqual(raster.pixelHeight, 15)
        requireSendable(GlyphMapping.exact(glyph))
        requireSendable(mapping)
        requireSendable(raster)
    }

    func testGenericPackageAndValidatorSeamRejectsIncompletePackage() {
        let descriptor = TextResourceDescriptor(
            schemaVersion: 1,
            resource: FontResourceID(rawValue: makeDigest()),
            instanceCount: 1,
            realizationCount: 1,
            canonicalManifestByteCount: 1
        )
        let metrics = EmptyMetricsView(descriptor: descriptor)
        let raster = EmptyRasterView(descriptor: descriptor)
        let resourcePackage = TextResourcePackage(metrics: metrics, raster: raster)

        XCTAssertEqual(resourcePackage.metrics.descriptor, descriptor)
        XCTAssertEqual(resourcePackage.raster.descriptor, descriptor)
        XCTAssertEqual(
            TextResourceValidator.validate(
                resourcePackage,
                requiring: RasterRealizationID(rawValue: 0)
            ),
            .invalid(.invalidCount)
        )
    }
}

private struct EmptyMetricsView: CanonicalTextMetricsView {
    let descriptor: TextResourceDescriptor

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
        for glyph: GiftUITextResources.GlyphID,
        in instance: FontInstanceID
    ) -> GlyphMetrics? { nil }
}

private struct EmptyRasterView: TextRasterResourceView {
    let descriptor: TextResourceDescriptor

    func realization(at index: UInt16) -> RasterRealizationDescriptor? { nil }

    func record(
        for glyph: GiftUITextResources.GlyphID,
        realization: RasterRealizationID
    ) -> GlyphRasterRecord? { nil }

    func isPayloadAvailable(for realization: RasterRealizationID) -> Bool { false }

    func withPayload<Result>(
        for record: GlyphRasterRecord,
        realization: RasterRealizationID,
        _ body: (UnsafeRawBufferPointer) throws -> Result
    ) rethrows -> Result? { nil }
}

private func makeDigest() -> TextResourceDigest {
    TextResourceDigest(
        word0: 0x0011_2233,
        word1: 0x4455_6677,
        word2: 0x8899_aabb,
        word3: 0xccdd_eeff,
        word4: .min,
        word5: .max,
        word6: 0x0123_4567,
        word7: 0x89ab_cdef
    )
}

private func requireSendable<T: Sendable>(_ value: T) {}
