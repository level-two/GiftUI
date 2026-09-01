@testable import GiftUITextResources
import GiftUI
import XCTest

final class CommonCatalogueValidationTests: XCTestCase {
    func testCompleteCatalogueValidatesForEachRequiredRealization() {
        let fixture = makeCommonCatalogue(availability: [true, true])
        XCTAssertEqual(validate(fixture, requiring: 0), .valid)
        XCTAssertEqual(validate(fixture, requiring: 1), .valid)
    }

    func testBitmapOnlyAndOutlineOnlyPreserveCatalogueAndIdentity() {
        let complete = makeCommonCatalogue(availability: [true, true])
        let bitmapOnly = makeCommonCatalogue(availability: [true, false])
        let outlineOnly = makeCommonCatalogue(availability: [false, true])

        XCTAssertEqual(
            complete.metrics.descriptor,
            bitmapOnly.metrics.descriptor
        )
        XCTAssertEqual(
            complete.metrics.descriptor,
            outlineOnly.metrics.descriptor
        )
        XCTAssertEqual(
            complete.raster.realizationValues,
            bitmapOnly.raster.realizationValues
        )
        XCTAssertEqual(
            complete.raster.realizationValues,
            outlineOnly.raster.realizationValues
        )
        XCTAssertEqual(complete.raster.recordValues, bitmapOnly.raster.recordValues)
        XCTAssertEqual(complete.raster.recordValues, outlineOnly.raster.recordValues)

        XCTAssertEqual(validate(bitmapOnly, requiring: 0), .valid)
        XCTAssertEqual(validate(outlineOnly, requiring: 1), .valid)
        XCTAssertEqual(
            validate(bitmapOnly, requiring: 1),
            .invalid(.incompatibleViews)
        )
        XCTAssertEqual(
            validate(outlineOnly, requiring: 0),
            .invalid(.incompatibleViews)
        )
    }

    func testAvailabilityClaimWithoutCompleteBorrowIsIncompatible() {
        let fixture = makeCommonCatalogue(
            availability: [true, true],
            refusedBorrowRealization: 1
        )
        XCTAssertEqual(
            validate(fixture, requiring: 0),
            .invalid(.incompatibleViews)
        )
    }

    func testOmittedUnselectedRecordMetadataStillValidates() {
        let base = makeCommonCatalogue(availability: [true, false])
        var records = base.raster.recordValues
        records[1] = GlyphRasterRecord(
            glyph: records[1].glyph,
            offset: records[1].offset,
            byteCount: records[1].byteCount,
            rowByteCount: 1,
            pixelWidth: records[1].pixelWidth,
            pixelHeight: records[1].pixelHeight
        )
        let fixture = TextResourcePackage(
            metrics: base.metrics,
            raster: CommonCatalogueRaster(
                descriptor: base.raster.descriptor,
                realizationValues: base.raster.realizationValues,
                recordValues: records,
                payloadValues: base.raster.payloadValues,
                availability: base.raster.availability,
                refusedBorrowRealization: nil
            )
        )
        XCTAssertEqual(
            validate(fixture, requiring: 0),
            .invalid(.malformedRasterRecord)
        )
    }

    func testEveryAvailableUnselectedPayloadMustPassIntegrity() {
        let base = makeCommonCatalogue(availability: [true, true])
        var payloads = base.raster.payloadValues
        var changedOutline = payloads[1]!
        changedOutline[9] ^= 1
        payloads[1] = changedOutline
        let fixture = TextResourcePackage(
            metrics: base.metrics,
            raster: CommonCatalogueRaster(
                descriptor: base.raster.descriptor,
                realizationValues: base.raster.realizationValues,
                recordValues: base.raster.recordValues,
                payloadValues: payloads,
                availability: base.raster.availability,
                refusedBorrowRealization: nil
            )
        )
        XCTAssertEqual(
            validate(fixture, requiring: 0),
            .invalid(.integrityMismatch)
        )
    }
}

private struct CommonCatalogueMetrics: CanonicalTextMetricsView {
    let descriptor: TextResourceDescriptor
    let instanceValue: FontInstanceDescriptor
    let mappingValue: ScalarGlyphMappingRecord
    let metricsValue: GlyphMetrics

    func instance(at index: UInt16) -> FontInstanceDescriptor? {
        index == 0 ? instanceValue : nil
    }

    func mapping(
        at index: UInt16,
        in instance: FontInstanceID
    ) -> ScalarGlyphMappingRecord? {
        index == 0 && instance == instanceValue.id ? mappingValue : nil
    }

    func metrics(
        for glyph: GiftUITextResources.GlyphID,
        in instance: FontInstanceID
    ) -> GlyphMetrics? {
        glyph.rawValue == 0 && instance == instanceValue.id ? metricsValue : nil
    }
}

private struct CommonCatalogueRaster: TextRasterResourceView {
    let descriptor: TextResourceDescriptor
    let realizationValues: [RasterRealizationDescriptor]
    let recordValues: [GlyphRasterRecord]
    let payloadValues: [[UInt8]?]
    let availability: [Bool]
    let refusedBorrowRealization: UInt16?

    func realization(at index: UInt16) -> RasterRealizationDescriptor? {
        Int(index) < realizationValues.count
            ? realizationValues[Int(index)] : nil
    }

    func record(
        for glyph: GiftUITextResources.GlyphID,
        realization: RasterRealizationID
    ) -> GlyphRasterRecord? {
        guard glyph.rawValue == 0,
              Int(realization.rawValue) < recordValues.count else { return nil }
        return recordValues[Int(realization.rawValue)]
    }

    func isPayloadAvailable(for realization: RasterRealizationID) -> Bool {
        Int(realization.rawValue) < availability.count
            && availability[Int(realization.rawValue)]
    }

    func withPayload<Result>(
        for record: GlyphRasterRecord,
        realization: RasterRealizationID,
        _ body: (UnsafeRawBufferPointer) throws -> Result
    ) rethrows -> Result? {
        guard isPayloadAvailable(for: realization),
              refusedBorrowRealization != realization.rawValue,
              let payload = payloadValues[Int(realization.rawValue)] else {
            return nil
        }
        return try payload.withUnsafeBytes { bytes in
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
                isAvailable: true,
                payload: bytes,
                body
            )
        }
    }
}

private typealias CommonCataloguePackage = TextResourcePackage<
    CommonCatalogueMetrics,
    CommonCatalogueRaster
>

private func makeCommonCatalogue(
    availability: [Bool],
    refusedBorrowRealization: UInt16? = nil
) -> CommonCataloguePackage {
    let bitmap: [UInt8] = [0x80]
    let outline: [UInt8] = [
        1, 0x08, 0x00, 0x00, 0x10,
        1, 1, 0x00, 0x00, 0x00, 0x00,
        5,
    ]
    let bitmapDigest = bitmap.withUnsafeBytes {
        TextResourceValidator.sha256(of: $0)
    }
    let outlineDigest = outline.withUnsafeBytes {
        TextResourceValidator.sha256(of: $0)
    }

    func build(resource: FontResourceID) -> CommonCataloguePackage {
        let descriptor = TextResourceDescriptor(
            schemaVersion: 1,
            resource: resource,
            instanceCount: 1,
            realizationCount: 2,
            canonicalManifestByteCount: 194
        )
        let instanceID = FontInstanceID(resource: resource, instanceIndex: 0)
        let metrics = CommonCatalogueMetrics(
            descriptor: descriptor,
            instanceValue: FontInstanceDescriptor(
                id: instanceID,
                lineMetrics: FontLineMetrics(ascent: 1, descent: 0, lineGap: 0),
                replacementGlyph: GiftUITextResources.GlyphID(rawValue: 0),
                glyphCount: 1,
                mappingCount: 1
            ),
            mappingValue: ScalarGlyphMappingRecord(
                scalarValue: 0x41,
                glyph: GiftUITextResources.GlyphID(rawValue: 0)
            ),
            metricsValue: GlyphMetrics(
                advanceX: 1,
                offsetX: 0,
                offsetY: 0,
                inkSize: Size(width: 1, height: 1)!
            )
        )
        let realizations = [
            RasterRealizationDescriptor(
                id: RasterRealizationID(rawValue: 0),
                instance: instanceID,
                kind: .monochromeBitmap1,
                glyphCount: 1,
                payloadByteCount: UInt32(bitmap.count),
                payloadDigest: bitmapDigest
            ),
            RasterRealizationDescriptor(
                id: RasterRealizationID(rawValue: 1),
                instance: instanceID,
                kind: .packagedOutline,
                glyphCount: 1,
                payloadByteCount: UInt32(outline.count),
                payloadDigest: outlineDigest
            ),
        ]
        let records = [
            GlyphRasterRecord(
                glyph: GiftUITextResources.GlyphID(rawValue: 0),
                offset: 0,
                byteCount: UInt32(bitmap.count),
                rowByteCount: 1,
                pixelWidth: 1,
                pixelHeight: 1
            ),
            GlyphRasterRecord(
                glyph: GiftUITextResources.GlyphID(rawValue: 0),
                offset: 0,
                byteCount: UInt32(outline.count),
                rowByteCount: 0,
                pixelWidth: 1,
                pixelHeight: 1
            ),
        ]
        let payloads: [[UInt8]?] = [
            availability[0] ? bitmap : nil,
            availability[1] ? outline : nil,
        ]
        return CommonCataloguePackage(
            metrics: metrics,
            raster: CommonCatalogueRaster(
                descriptor: descriptor,
                realizationValues: realizations,
                recordValues: records,
                payloadValues: payloads,
                availability: availability,
                refusedBorrowRealization: refusedBorrowRealization
            )
        )
    }

    let zeroResource = FontResourceID(rawValue: zeroValidationDigest())
    let provisional = build(resource: zeroResource)
    let identity = TextResourceValidator.canonicalManifestDigest(
        of: provisional
    )!.digest
    return build(resource: FontResourceID(rawValue: identity))
}

private func validate(
    _ fixture: CommonCataloguePackage,
    requiring realization: UInt16
) -> TextResourceValidationResult {
    TextResourceValidator.validate(
        fixture,
        requiring: RasterRealizationID(rawValue: realization)
    )
}
