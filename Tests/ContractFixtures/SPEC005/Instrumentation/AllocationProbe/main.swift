import GiftUI
import GiftUITextResources

@_silgen_name("giftui_allocation_probe_reset")
private func resetAllocationCount()

@_silgen_name("giftui_allocation_probe_read")
private func readAllocationCount() -> UInt64

private struct StaticMetricsView: CanonicalTextMetricsView {
    let descriptor: TextResourceDescriptor
    let instanceDescriptor: FontInstanceDescriptor

    func instance(at index: UInt16) -> FontInstanceDescriptor? {
        index == 0 ? instanceDescriptor : nil
    }

    func mapping(
        at index: UInt16,
        in instance: FontInstanceID
    ) -> ScalarGlyphMappingRecord? {
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

private struct StaticRasterView: TextRasterResourceView {
    let descriptor: TextResourceDescriptor
    let realizationDescriptor: RasterRealizationDescriptor

    func realization(at index: UInt16) -> RasterRealizationDescriptor? {
        index == 0 ? realizationDescriptor : nil
    }

    func record(
        for glyph: GiftUITextResources.GlyphID,
        realization: RasterRealizationID
    ) -> GlyphRasterRecord? {
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
        let emptyPayload: () = ()
        return try withUnsafeBytes(of: emptyPayload) { bytes in
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

@inline(never)
private func exercise(seed: UInt32) -> UInt32 {
    let digest = TextResourceDigest(
        word0: seed, word1: seed, word2: seed, word3: seed,
        word4: seed, word5: seed, word6: seed, word7: seed
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
    let realization = RasterRealizationDescriptor(
        id: RasterRealizationID(rawValue: 0),
        instance: instanceID,
        kind: .monochromeBitmap1,
        glyphCount: 256,
        payloadByteCount: 0,
        payloadDigest: digest
    )
    let metrics = StaticMetricsView(
        descriptor: descriptor,
        instanceDescriptor: instance
    )
    let raster = StaticRasterView(
        descriptor: descriptor,
        realizationDescriptor: realization
    )
    let resourcePackage = TextResourcePackage(metrics: metrics, raster: raster)
    var checksum = seed
    if case let .exact(glyph) = metrics.mapScalar(0x20ff, in: instanceID) {
        checksum &+= UInt32(glyph.rawValue)
    }
    checksum &+= UInt32(
        metrics.metrics(
            for: GiftUITextResources.GlyphID(rawValue: 255),
            in: instanceID
        )?.advanceX ?? 0
    )
    let record = raster.record(
        for: GiftUITextResources.GlyphID(rawValue: 255),
        realization: realization.id
    )!
    checksum &+= UInt32(
        raster.withPayload(for: record, realization: realization.id) {
            $0.count
        } ?? 1
    )
    if let count = TextResourceValidator.forEachCanonicalManifestByte(
        in: resourcePackage,
        { checksum &+= UInt32($0) }
    ) {
        checksum &+= count
    }
    if let manifest = TextResourceValidator.canonicalManifestDigest(
        of: resourcePackage
    ) {
        checksum &+= manifest.byteCount
        checksum &+= manifest.digest.word0
    }

    let payload = (UInt8(0x10), UInt8(0x20), UInt8(0x30), UInt8(0x40))
    let payloadRecord = GlyphRasterRecord(
        glyph: GiftUITextResources.GlyphID(rawValue: 0),
        offset: 0,
        byteCount: 4,
        rowByteCount: 1,
        pixelWidth: 1,
        pixelHeight: 4
    )
    let payloadRealization = RasterRealizationDescriptor(
        id: RasterRealizationID(rawValue: 0),
        instance: instanceID,
        kind: .monochromeBitmap1,
        glyphCount: 1,
        payloadByteCount: 4,
        payloadDigest: digest
    )
    withUnsafeBytes(of: payload) { bytes in
        checksum &+= UInt32(
            TextResourceValidator.withPayloadSlice(
                for: payloadRecord,
                cataloguedRecord: payloadRecord,
                realization: payloadRealization.id,
                cataloguedRealization: payloadRealization,
                isAvailable: true,
                payload: bytes
            ) { slice in
                UInt32(slice[0]) &+ UInt32(slice[3])
            } ?? 0
        )
    }
    return checksum
}

var warmup: UInt32 = 0
for index in UInt32(0) ..< 10 {
    warmup &+= exercise(seed: index)
}

resetAllocationCount()
var checksum = warmup
for iteration in UInt32(0) ..< 100 {
    checksum &+= exercise(seed: iteration)
}
let allocationCount = readAllocationCount()

print("allocation_count=\(allocationCount)")
print("checksum=\(checksum)")
if allocationCount != 0 {
    fatalError("SPEC-005 hot-path allocation probe failed")
}
