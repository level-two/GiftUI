import GiftUI
import XCTest

@testable import GiftUITextResources

final class CanonicalSerializationTests: XCTestCase {
    func testSHA256OfficialVectors() {
        assertSHA256(
            [],
            equals: digest(
                0xe3b0_c442, 0x98fc_1c14, 0x9afb_f4c8, 0x996f_b924,
                0x27ae_41e4, 0x649b_934c, 0xa495_991b, 0x7852_b855
            )
        )
        assertSHA256(
            Array("abc".utf8),
            equals: digest(
                0xba78_16bf, 0x8f01_cfea, 0x4141_40de, 0x5dae_2223,
                0xb003_61a3, 0x9617_7a9c, 0xb410_ff61, 0xf200_15ad
            )
        )
        assertSHA256(
            Array(
                "abcdbcdecdefdefgefghfghighijhijkijkljklmklmnlmnomnopnopq".utf8
            ),
            equals: digest(
                0x248d_6a61, 0xd206_38b8, 0xe5c0_2693, 0x0c3e_6039,
                0xa33c_e459, 0x64ff_2167, 0xf6ec_edd4, 0x19db_06c1
            )
        )
    }

    func testSchemaVersionOneManifestMatchesExactByteVectorAndDigest() {
        let resourcePackage = makeManifestPackage()
        var actualBytes: [UInt8] = []
        let byteCount = TextResourceValidator.forEachCanonicalManifestByte(
            in: resourcePackage,
            { actualBytes.append($0) }
        )
        let expectedBytes = bytes(
            fromHex: """
                476966745549546578745265736f75726365732f76310001000100000000000c
                fffffffd0000000200000001000100000041000000000000000bfffffffeffff
                fff4000000090000000c00010000000000000100000003000102030405060708
                090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f0000000000000000
                0003000100010003
                """)

        XCTAssertEqual(byteCount, 135)
        XCTAssertEqual(actualBytes, expectedBytes)
        let result = TextResourceValidator.canonicalManifestDigest(
            of: resourcePackage
        )
        XCTAssertEqual(result?.byteCount, 135)
        XCTAssertEqual(
            result?.digest,
            digest(
                0x4f0d_c73a, 0x27f7_6ffb, 0x2c38_ea43, 0x348a_c24f,
                0xca3f_ceec, 0x87e9_694f, 0x6f4c_ef78, 0x453a_2ebe
            )
        )
    }

    func testNoncanonicalMetadataAndRawPayloadDoNotEnterManifest() {
        let first = makeManifestPackage(
            metadata: .init(
                filename: "first.bitmap",
                timestamp: 1,
                locale: "pl_PL",
                tableAddress: 0x1000,
                displayName: "First"
            ),
            rawPayload: [0x00, 0x01, 0x02]
        )
        let second = makeManifestPackage(
            metadata: .init(
                filename: "renamed.bin",
                timestamp: .max,
                locale: "tr_TR",
                tableAddress: .max,
                displayName: "Unrelated Name"
            ),
            rawPayload: [0xff, 0xfe, 0xfd]
        )

        XCTAssertEqual(
            TextResourceValidator.canonicalManifestDigest(of: first)?.digest,
            TextResourceValidator.canonicalManifestDigest(of: second)?.digest
        )
    }

    func testEverySerializedRegionAndPayloadDigestAffectIdentity() {
        let original = canonicalBytes(of: makeManifestPackage())
        XCTAssertEqual(original.count, 135)

        // One byte from every field or repeated-field region in schema v1.
        let representativeOffsets = [
            22, 24, // schema and instance count
            26, 29, 33, 37, 40, 42, 44, // instance fields
            48, 51, // mapping fields
            53, 57, 61, 65, 69, 73, // glyph and geometry fields
            75, 77, 79, 80, 82, 86, // realization fields
            90, 118, // first and last payload-digest bytes
            119, 123, 127, 129, 131, 133, // raster record fields
        ]
        let originalDigest = sha256(original)
        for offset in representativeOffsets {
            var changed = original
            changed[offset] ^= 1
            XCTAssertNotEqual(
                sha256(changed),
                originalDigest,
                "canonical byte at offset \(offset) did not affect identity"
            )
        }

        let changedPayloadDigest = makeManifestPackage(
            payloadDigest: digest(
                0x0101_0203, 0x0405_0607, 0x0809_0a0b, 0x0c0d_0e0f,
                0x1011_1213, 0x1415_1617, 0x1819_1a1b, 0x1c1d_1e1f
            )
        )
        XCTAssertNotEqual(
            TextResourceValidator.canonicalManifestDigest(
                of: changedPayloadDigest
            )?.digest,
            originalDigest
        )
    }

    func testDigestWordsEncodeAndSerializeBigEndian() {
        let resourcePackage = makeManifestPackage()
        let bytes = canonicalBytes(of: resourcePackage)
        XCTAssertEqual(
            Array(bytes[87 ..< 119]),
            Array(0 ... 31)
        )

        let hash = sha256([0x00, 0x01, 0x02, 0x03])
        XCTAssertEqual(
            hash,
            digest(
                0x054e_dec1, 0xd021_1f62, 0x4fed_0cbc, 0xa9d4_f940,
                0x0b0e_491c, 0x4374_2af2, 0xc5b0_abeb, 0xf0c9_90d8
            )
        )
    }

    func testUnavailableDeclaredEntryCannotProduceCertifiedDigest() {
        let complete = makeManifestPackage()
        let incomplete = TextResourcePackage(
            metrics: ManifestMetrics(
                descriptor: complete.metrics.descriptor,
                instanceValue: nil
            ),
            raster: complete.raster
        )
        var visits = 0
        XCTAssertNil(
            TextResourceValidator.forEachCanonicalManifestByte(
                in: incomplete,
                { _ in visits += 1 }
            )
        )
        XCTAssertEqual(visits, 26)
        XCTAssertNil(TextResourceValidator.canonicalManifestDigest(of: incomplete))
    }
}

private struct FixtureMetadata {
    let filename: String
    let timestamp: UInt64
    let locale: String
    let tableAddress: UInt64
    let displayName: String

    static let baseline = FixtureMetadata(
        filename: "resource.bitmap1",
        timestamp: 0,
        locale: "en_US_POSIX",
        tableAddress: 0,
        displayName: "GiftUI Test"
    )
}

private struct ManifestMetrics: CanonicalTextMetricsView {
    let descriptor: TextResourceDescriptor
    let instanceValue: FontInstanceDescriptor?

    func instance(at index: UInt16) -> FontInstanceDescriptor? {
        index == 0 ? instanceValue : nil
    }

    func mapping(
        at index: UInt16,
        in instance: FontInstanceID
    ) -> ScalarGlyphMappingRecord? {
        guard index == 0, instance == instanceValue?.id else { return nil }
        return ScalarGlyphMappingRecord(
            scalarValue: 0x41,
            glyph: GlyphID(rawValue: 0)
        )
    }

    func mapScalar(
        _ scalarValue: UInt32,
        in instance: FontInstanceID
    ) -> GlyphMapping? {
        guard scalarValue == 0x41, instance == instanceValue?.id else { return nil }
        return .exact(GlyphID(rawValue: 0))
    }

    func metrics(
        for glyph: GiftUITextResources.GlyphID,
        in instance: FontInstanceID
    ) -> GlyphMetrics? {
        guard glyph.rawValue == 0, instance == instanceValue?.id else { return nil }
        return GlyphMetrics(
            advanceX: 11,
            offsetX: -2,
            offsetY: -12,
            inkSize: Size(width: 9, height: 12)!
        )
    }
}

private struct ManifestRaster: TextRasterResourceView {
    let descriptor: TextResourceDescriptor
    let realizationValue: RasterRealizationDescriptor
    let metadata: FixtureMetadata
    let rawPayload: [UInt8]

    func realization(at index: UInt16) -> RasterRealizationDescriptor? {
        index == 0 ? realizationValue : nil
    }

    func record(
        for glyph: GiftUITextResources.GlyphID,
        realization: RasterRealizationID
    ) -> GlyphRasterRecord? {
        guard glyph.rawValue == 0, realization == realizationValue.id else {
            return nil
        }
        return GlyphRasterRecord(
            glyph: glyph,
            offset: 0,
            byteCount: 3,
            rowByteCount: 1,
            pixelWidth: 1,
            pixelHeight: 3
        )
    }

    func isPayloadAvailable(for realization: RasterRealizationID) -> Bool {
        realization == realizationValue.id
    }

    func withPayload<Result>(
        for record: GlyphRasterRecord,
        realization: RasterRealizationID,
        _ body: (UnsafeRawBufferPointer) throws -> Result
    ) rethrows -> Result? {
        guard realization == realizationValue.id else { return nil }
        return try rawPayload.withUnsafeBytes { try body($0) }
    }
}

private func makeManifestPackage(
    metadata: FixtureMetadata = .baseline,
    rawPayload: [UInt8] = [0xaa, 0xbb, 0xcc],
    payloadDigest: TextResourceDigest = digest(
        0x0001_0203, 0x0405_0607, 0x0809_0a0b, 0x0c0d_0e0f,
        0x1011_1213, 0x1415_1617, 0x1819_1a1b, 0x1c1d_1e1f
    )
) -> TextResourcePackage<ManifestMetrics, ManifestRaster> {
    let zeroDigest = digest(0, 0, 0, 0, 0, 0, 0, 0)
    let resource = FontResourceID(rawValue: zeroDigest)
    let descriptor = TextResourceDescriptor(
        schemaVersion: 1,
        resource: resource,
        instanceCount: 1,
        realizationCount: 1,
        canonicalManifestByteCount: 135
    )
    let instanceID = FontInstanceID(resource: resource, instanceIndex: 0)
    let instance = FontInstanceDescriptor(
        id: instanceID,
        lineMetrics: FontLineMetrics(ascent: 12, descent: -3, lineGap: 2),
        replacementGlyph: GlyphID(rawValue: 0),
        glyphCount: 1,
        mappingCount: 1
    )
    let realization = RasterRealizationDescriptor(
        id: RasterRealizationID(rawValue: 0),
        instance: instanceID,
        kind: .monochromeBitmap1,
        glyphCount: 1,
        payloadByteCount: 3,
        payloadDigest: payloadDigest
    )
    return TextResourcePackage(
        metrics: ManifestMetrics(
            descriptor: descriptor,
            instanceValue: instance
        ),
        raster: ManifestRaster(
            descriptor: descriptor,
            realizationValue: realization,
            metadata: metadata,
            rawPayload: rawPayload
        )
    )
}

private func canonicalBytes<M, R>(
    of resourcePackage: borrowing TextResourcePackage<M, R>
) -> [UInt8]
where M: CanonicalTextMetricsView, R: TextRasterResourceView {
    var result: [UInt8] = []
    let byteCount = TextResourceValidator.forEachCanonicalManifestByte(
        in: resourcePackage,
        { result.append($0) }
    )
    XCTAssertNotNil(byteCount)
    return result
}

private func assertSHA256(
    _ bytes: [UInt8],
    equals expected: TextResourceDigest,
    file: StaticString = #filePath,
    line: UInt = #line
) {
    XCTAssertEqual(sha256(bytes), expected, file: file, line: line)
}

private func sha256(_ bytes: [UInt8]) -> TextResourceDigest {
    bytes.withUnsafeBytes { TextResourceValidator.sha256(of: $0) }
}

private func digest(
    _ word0: UInt32,
    _ word1: UInt32,
    _ word2: UInt32,
    _ word3: UInt32,
    _ word4: UInt32,
    _ word5: UInt32,
    _ word6: UInt32,
    _ word7: UInt32
) -> TextResourceDigest {
    TextResourceDigest(
        word0: word0, word1: word1, word2: word2, word3: word3,
        word4: word4, word5: word5, word6: word6, word7: word7
    )
}

private func bytes(fromHex source: String) -> [UInt8] {
    let digits = source.utf8.filter { byte in
        (byte >= 48 && byte <= 57) || (byte >= 97 && byte <= 102)
    }
    precondition(digits.count.isMultiple(of: 2))
    var result: [UInt8] = []
    var index = 0
    while index < digits.count {
        result.append((hexValue(digits[index]) << 4) | hexValue(digits[index + 1]))
        index += 2
    }
    return result
}

private func hexValue(_ byte: UInt8) -> UInt8 {
    byte <= 57 ? byte - 48 : byte - 87
}
