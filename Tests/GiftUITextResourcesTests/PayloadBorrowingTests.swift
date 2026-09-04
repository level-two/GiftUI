import XCTest

@testable import GiftUITextResources

final class PayloadBorrowingTests: XCTestCase {
    func testValidRecordInvokesBodyExactlyOnceWithExactSlice() {
        let raster = makeBorrowingRaster()
        var invocations = 0
        let result = raster.withPayload(
            for: raster.cataloguedRecord,
            realization: raster.realizationDescriptor.id
        ) { bytes -> UInt32 in
            invocations += 1
            XCTAssertEqual(bytes.count, 3)
            XCTAssertEqual(Array(bytes), [0x20, 0x30, 0x40])
            return 0x1234_5678
        }
        XCTAssertEqual(result, 0x1234_5678)
        XCTAssertEqual(invocations, 1)
    }

    func testValidZeroByteRecordStillInvokesBodyExactlyOnce() {
        let raster = makeBorrowingRaster(
            payload: [],
            record: GlyphRasterRecord(
                glyph: GlyphID(rawValue: 0), offset: 0, byteCount: 0,
                rowByteCount: 0, pixelWidth: 0, pixelHeight: 0
            )
        )
        var invocations = 0
        let result = raster.withPayload(
            for: raster.cataloguedRecord,
            realization: raster.realizationDescriptor.id
        ) { bytes in
            invocations += 1
            XCTAssertEqual(bytes.count, 0)
            return 7
        }
        XCTAssertEqual(result, 7)
        XCTAssertEqual(invocations, 1)
    }

    func testInvalidOrUnavailableInputNeverInvokesBody() {
        let base = makeBorrowingRaster()
        let wrongRecord = GlyphRasterRecord(
            glyph: base.cataloguedRecord.glyph,
            offset: base.cataloguedRecord.offset,
            byteCount: base.cataloguedRecord.byteCount - 1,
            rowByteCount: base.cataloguedRecord.rowByteCount,
            pixelWidth: base.cataloguedRecord.pixelWidth,
            pixelHeight: base.cataloguedRecord.pixelHeight
        )
        let invalidGlyph = GlyphRasterRecord(
            glyph: GlyphID(rawValue: 1),
            offset: 0, byteCount: 1, rowByteCount: 1,
            pixelWidth: 1, pixelHeight: 1
        )
        let cases: [(BorrowingRaster, GlyphRasterRecord, RasterRealizationID)] = [
            (base, wrongRecord, base.realizationDescriptor.id),
            (base, invalidGlyph, base.realizationDescriptor.id),
            (base, base.cataloguedRecord, RasterRealizationID(rawValue: 1)),
            (
                makeBorrowingRaster(isAvailable: false),
                base.cataloguedRecord,
                base.realizationDescriptor.id
            ),
            (
                makeBorrowingRaster(
                    payload: [0x10, 0x20, 0x30, 0x40],
                    declaredPayloadByteCount: 5
                ),
                base.cataloguedRecord,
                base.realizationDescriptor.id
            ),
        ]

        for (raster, record, realization) in cases {
            var invocations = 0
            let result: Int? = raster.withPayload(
                for: record,
                realization: realization
            ) { _ in
                invocations += 1
                return 1
            }
            XCTAssertNil(result)
            XCTAssertEqual(invocations, 0)
        }
    }

    func testBodyThrownSentinelPropagatesUnchangedAfterOneInvocation() {
        let raster = makeBorrowingRaster()
        var invocations = 0
        XCTAssertThrowsError(
            try raster.withPayload(
                for: raster.cataloguedRecord,
                realization: raster.realizationDescriptor.id
            ) { _ -> Never in
                invocations += 1
                throw BodySentinel.expected
            }
        ) { error in
            XCTAssertEqual(error as? BodySentinel, .expected)
        }
        XCTAssertEqual(invocations, 1)
    }

    func testValidationAndAvailabilityPathsCannotProduceBodyError() {
        let raster = makeBorrowingRaster(isAvailable: false)
        var invocations = 0
        let result = nonthrowingBorrow(
            raster,
            record: raster.cataloguedRecord,
            realization: raster.realizationDescriptor.id,
            invocations: &invocations
        )
        XCTAssertNil(result)
        XCTAssertEqual(invocations, 0)
    }

    func testBorrowStorageIsPoisonedImmediatelyAfterReturn() {
        let raster = PoisoningRaster()
        let observation = raster.withPayload(
            for: raster.cataloguedRecord,
            realization: raster.realizationDescriptor.id
        ) { bytes in
            BorrowObservation(
                address: UInt(bitPattern: bytes.baseAddress),
                count: bytes.count,
                firstByte: bytes[0],
                sourceWasActive: raster.isBorrowActive
            )
        }

        XCTAssertEqual(observation?.count, 3)
        XCTAssertEqual(observation?.firstByte, 0x20)
        XCTAssertEqual(observation?.sourceWasActive, true)
        XCTAssertNotEqual(observation?.address, 0)
        XCTAssertFalse(raster.isBorrowActive)
        XCTAssertFalse(
            raster.isPayloadAvailable(for: raster.realizationDescriptor.id)
        )
        XCTAssertEqual(raster.poisonedBytes, [0xdd, 0xdd, 0xdd, 0xdd, 0xdd])

        var reinvocations = 0
        let second: Int? = raster.withPayload(
            for: raster.cataloguedRecord,
            realization: raster.realizationDescriptor.id
        ) { _ in
            reinvocations += 1
            return 1
        }
        XCTAssertNil(second)
        XCTAssertEqual(reinvocations, 0)
    }
}

private enum BodySentinel: Error, Equatable {
    case expected
}

private struct BorrowObservation: Equatable {
    let address: UInt
    let count: Int
    let firstByte: UInt8
    let sourceWasActive: Bool
}

private struct BorrowingRaster: TextRasterResourceView {
    let descriptor: TextResourceDescriptor
    let realizationDescriptor: RasterRealizationDescriptor
    let cataloguedRecord: GlyphRasterRecord
    let payload: [UInt8]
    let available: Bool

    func realization(at index: UInt16) -> RasterRealizationDescriptor? {
        index == realizationDescriptor.id.rawValue
            ? realizationDescriptor : nil
    }

    func record(
        for glyph: GiftUITextResources.GlyphID,
        realization: RasterRealizationID
    ) -> GlyphRasterRecord? {
        glyph == cataloguedRecord.glyph
            && realization == realizationDescriptor.id ? cataloguedRecord : nil
    }

    func isPayloadAvailable(for realization: RasterRealizationID) -> Bool {
        available && realization == realizationDescriptor.id
    }

    func withPayload<Result>(
        for record: GlyphRasterRecord,
        realization: RasterRealizationID,
        _ body: (UnsafeRawBufferPointer) throws -> Result
    ) rethrows -> Result? {
        try payload.withUnsafeBytes { payloadBytes in
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
                payload: payloadBytes,
                body
            )
        }
    }
}

private final class PoisoningRaster: TextRasterResourceView {
    let descriptor: TextResourceDescriptor
    let realizationDescriptor: RasterRealizationDescriptor
    let cataloguedRecord: GlyphRasterRecord
    private let storage: UnsafeMutableRawPointer
    private(set) var isBorrowActive = false
    private var available = true

    init() {
        let fixture = makeBorrowingRaster()
        descriptor = fixture.descriptor
        realizationDescriptor = fixture.realizationDescriptor
        cataloguedRecord = fixture.cataloguedRecord
        storage = .allocate(byteCount: 5, alignment: 1)
        let initial: [UInt8] = [0x10, 0x20, 0x30, 0x40, 0x50]
        initial.withUnsafeBytes { source in
            storage.copyMemory(from: source.baseAddress!, byteCount: source.count)
        }
    }

    deinit {
        storage.deallocate()
    }

    var poisonedBytes: [UInt8] {
        Array(UnsafeRawBufferPointer(start: storage, count: 5))
    }

    func realization(at index: UInt16) -> RasterRealizationDescriptor? {
        index == realizationDescriptor.id.rawValue
            ? realizationDescriptor : nil
    }

    func record(
        for glyph: GiftUITextResources.GlyphID,
        realization: RasterRealizationID
    ) -> GlyphRasterRecord? {
        glyph == cataloguedRecord.glyph
            && realization == realizationDescriptor.id ? cataloguedRecord : nil
    }

    func isPayloadAvailable(for realization: RasterRealizationID) -> Bool {
        available && realization == realizationDescriptor.id
    }

    func withPayload<Result>(
        for record: GlyphRasterRecord,
        realization: RasterRealizationID,
        _ body: (UnsafeRawBufferPointer) throws -> Result
    ) rethrows -> Result? {
        guard available else { return nil }
        isBorrowActive = true
        defer {
            storage.initializeMemory(as: UInt8.self, repeating: 0xdd, count: 5)
            isBorrowActive = false
            available = false
        }
        return try TextResourceValidator.withPayloadSlice(
            for: record,
            cataloguedRecord: self.record(
                for: record.glyph,
                realization: realization
            ),
            realization: realization,
            cataloguedRealization: self.realization(at: realization.rawValue),
            isAvailable: isPayloadAvailable(for: realization),
            payload: UnsafeRawBufferPointer(start: storage, count: 5),
            body
        )
    }
}

private func makeBorrowingRaster(
    payload: [UInt8] = [0x10, 0x20, 0x30, 0x40, 0x50],
    record: GlyphRasterRecord = GlyphRasterRecord(
        glyph: GlyphID(rawValue: 0), offset: 1, byteCount: 3,
        rowByteCount: 1, pixelWidth: 1, pixelHeight: 3
    ),
    isAvailable: Bool = true,
    declaredPayloadByteCount: UInt32? = nil
) -> BorrowingRaster {
    let resource = FontResourceID(
        rawValue: TextResourceDigest(
            word0: 0, word1: 0, word2: 0, word3: 0,
            word4: 0, word5: 0, word6: 0, word7: 0
        ))
    let instance = FontInstanceID(resource: resource, instanceIndex: 0)
    let descriptor = TextResourceDescriptor(
        schemaVersion: 1,
        resource: resource,
        instanceCount: 1,
        realizationCount: 1,
        canonicalManifestByteCount: 1
    )
    let realization = RasterRealizationDescriptor(
        id: RasterRealizationID(rawValue: 0),
        instance: instance,
        kind: .monochromeBitmap1,
        glyphCount: 1,
        payloadByteCount: declaredPayloadByteCount ?? UInt32(payload.count),
        payloadDigest: resource.rawValue
    )
    return BorrowingRaster(
        descriptor: descriptor,
        realizationDescriptor: realization,
        cataloguedRecord: record,
        payload: payload,
        available: isAvailable
    )
}

private func nonthrowingBorrow(
    _ raster: BorrowingRaster,
    record: GlyphRasterRecord,
    realization: RasterRealizationID,
    invocations: inout Int
) -> Int? {
    raster.withPayload(for: record, realization: realization) { bytes in
        invocations += 1
        return bytes.count
    }
}
