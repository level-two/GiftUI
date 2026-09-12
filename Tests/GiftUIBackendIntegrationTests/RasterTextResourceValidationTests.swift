import GiftUI
import GiftUIRasterCore
import GiftUITextResources
import Testing

@testable import GiftUIBackendIntegration

private let resourceDigest = TextResourceDigest(
    word0: 1,
    word1: 2,
    word2: 3,
    word3: 4,
    word4: 5,
    word5: 6,
    word6: 7,
    word7: 8
)
private let resourceID = FontResourceID(rawValue: resourceDigest)
private let resourceDescriptor = TextResourceDescriptor(
    schemaVersion: 1,
    resource: resourceID,
    instanceCount: 1,
    realizationCount: 1,
    canonicalManifestByteCount: 64
)
private let resourceRealization = RasterRealizationDescriptor(
    id: RasterRealizationID(rawValue: 0),
    instance: FontInstanceID(resource: resourceID, instanceIndex: 0),
    kind: .monochromeBitmap1,
    glyphCount: 3,
    payloadByteCount: 9,
    payloadDigest: resourceDigest
)
private let resourceRecords = [
    GlyphRasterRecord(
        glyph: GlyphID(rawValue: 0),
        offset: 0,
        byteCount: 2,
        rowByteCount: 1,
        pixelWidth: 8,
        pixelHeight: 2
    ),
    GlyphRasterRecord(
        glyph: GlyphID(rawValue: 1),
        offset: 2,
        byteCount: 5,
        rowByteCount: 1,
        pixelWidth: 8,
        pixelHeight: 5
    ),
    GlyphRasterRecord(
        glyph: GlyphID(rawValue: 2),
        offset: 7,
        byteCount: 2,
        rowByteCount: 1,
        pixelWidth: 8,
        pixelHeight: 2
    ),
]

private func resourceLimits(
    glyphBytes: UInt32 = 5,
    strokeBytes: UInt32 = 7
) -> RasterPayloadLimits {
    RasterPayloadLimits(
        maximumRasterBytes: 16,
        maximumPayloadBytes: 16,
        maximumRegionsPerPayload: 1,
        maximumRegionSubmissionsPerFrame: 1,
        maximumTileVisitsPerFrame: 1,
        maximumInFlightPayloads: 1,
        maximumGlyphRasterBytes: glyphBytes,
        maximumStrokeWorkspaceBytes: strokeBytes
    )!
}

@Test
func textResourceValidationPreservesExactIdentityAndGreatestRecord() {
    let raster = RecordingTextRaster()
    let result = RasterTextResourceValidator.validate(
        raster,
        prevalidation: .valid,
        expectedDescriptor: resourceDescriptor,
        selectedRealization: resourceRealization,
        payloadLimits: resourceLimits(),
        requiredStrokeWorkspaceBytes: 7
    )

    #expect(
        result
            == .compatible(
                RasterTextResourceFacts(
                    descriptor: resourceDescriptor,
                    realization: resourceRealization,
                    greatestGlyphRasterBytes: 5,
                    requiredStrokeWorkspaceBytes: 7
                )
            )
    )
    #expect(raster.realizationRequests == [0])
    #expect(raster.availabilityRequests == [RasterRealizationID(rawValue: 0)])
    #expect(raster.recordRequests.map(\.0) == [0, 1, 2])
    #expect(raster.recordRequests.allSatisfy { $0.1 == RasterRealizationID(rawValue: 0) })
}

@Test
func textResourceValidationRejectsPrevalidationBeforeViewAccess() {
    let raster = RecordingTextRaster()

    #expect(
        RasterTextResourceValidator.validate(
            raster,
            prevalidation: .invalid(.malformedRasterRecord),
            expectedDescriptor: resourceDescriptor,
            selectedRealization: resourceRealization,
            payloadLimits: resourceLimits(),
            requiredStrokeWorkspaceBytes: 7
        ) == .failure(.incompatibleResource)
    )
    #expect(raster.descriptorReadCount == 0)
    #expect(raster.recordRequests.isEmpty)
}

@Test
func textResourceValidationRejectsDescriptorRealizationAndAvailabilityMismatch() {
    let mismatchedDescriptor = TextResourceDescriptor(
        schemaVersion: 1,
        resource: FontResourceID(
            rawValue: TextResourceDigest(
                word0: 9,
                word1: 2,
                word2: 3,
                word3: 4,
                word4: 5,
                word5: 6,
                word6: 7,
                word7: 8
            )
        ),
        instanceCount: 1,
        realizationCount: 1,
        canonicalManifestByteCount: 64
    )
    let wrongRealization = RasterRealizationDescriptor(
        id: RasterRealizationID(rawValue: 1),
        instance: resourceRealization.instance,
        kind: resourceRealization.kind,
        glyphCount: resourceRealization.glyphCount,
        payloadByteCount: resourceRealization.payloadByteCount,
        payloadDigest: resourceRealization.payloadDigest
    )

    #expect(
        validateRaster(RecordingTextRaster(), descriptor: mismatchedDescriptor)
            == .failure(.incompatibleResource))
    #expect(
        validateRaster(RecordingTextRaster(), realization: wrongRealization)
            == .failure(.incompatibleResource))
    #expect(
        validateRaster(RecordingTextRaster(isAvailable: false)) == .failure(.incompatibleResource))
}

@Test
func textResourceValidationRejectsMissingMalformedAndOversizedRecords() {
    var missing = resourceRecords
    missing.removeLast()
    var malformed = resourceRecords
    malformed[1] = GlyphRasterRecord(
        glyph: GlyphID(rawValue: 2),
        offset: 2,
        byteCount: 5,
        rowByteCount: 1,
        pixelWidth: 8,
        pixelHeight: 5
    )
    var overflowing = resourceRecords
    overflowing[1] = GlyphRasterRecord(
        glyph: GlyphID(rawValue: 1),
        offset: .max,
        byteCount: 5,
        rowByteCount: 1,
        pixelWidth: 8,
        pixelHeight: 5
    )

    #expect(
        validateRaster(RecordingTextRaster(records: missing)) == .failure(.incompatibleResource))
    #expect(
        validateRaster(RecordingTextRaster(records: malformed)) == .failure(.incompatibleResource))
    #expect(
        validateRaster(RecordingTextRaster(records: overflowing)) == .failure(.incompatibleResource)
    )
    #expect(
        validateRaster(RecordingTextRaster(), limits: resourceLimits(glyphBytes: 4))
            == .failure(.capacityExhausted))
    #expect(
        validateRaster(RecordingTextRaster(), limits: resourceLimits(strokeBytes: 6))
            == .failure(.capacityExhausted))
}

@Test
func postStartupLookupUsesOnlyExactSelectedIdentityWithoutFallback() {
    let raster = RecordingTextRaster()

    #expect(
        RasterTextResourceValidator.record(
            for: GlyphID(rawValue: 1),
            in: raster,
            selectedRealization: resourceRealization
        ) == .available(resourceRecords[1])
    )
    #expect(
        RasterTextResourceValidator.record(
            for: GlyphID(rawValue: 3),
            in: raster,
            selectedRealization: resourceRealization
        ) == .incompatibleResource
    )
    #expect(raster.recordRequests.map(\.0) == [1])
}

private func validateRaster(
    _ raster: RecordingTextRaster,
    descriptor: TextResourceDescriptor = resourceDescriptor,
    realization: RasterRealizationDescriptor = resourceRealization,
    limits: RasterPayloadLimits = resourceLimits()
) -> RasterTextResourceValidationResult {
    RasterTextResourceValidator.validate(
        raster,
        prevalidation: .valid,
        expectedDescriptor: descriptor,
        selectedRealization: realization,
        payloadLimits: limits,
        requiredStrokeWorkspaceBytes: 7
    )
}

private final class RecordingTextRaster: TextRasterResourceView {
    private let storedDescriptor: TextResourceDescriptor
    private let storedRealization: RasterRealizationDescriptor?
    private let records: [GlyphRasterRecord]
    private let isAvailable: Bool

    private(set) var descriptorReadCount = 0
    private(set) var realizationRequests: [UInt16] = []
    private(set) var availabilityRequests: [RasterRealizationID] = []
    private(set) var recordRequests: [(UInt16, RasterRealizationID)] = []

    init(
        descriptor: TextResourceDescriptor = resourceDescriptor,
        realization: RasterRealizationDescriptor? = resourceRealization,
        records: [GlyphRasterRecord] = resourceRecords,
        isAvailable: Bool = true
    ) {
        storedDescriptor = descriptor
        storedRealization = realization
        self.records = records
        self.isAvailable = isAvailable
    }

    var descriptor: TextResourceDescriptor {
        descriptorReadCount += 1
        return storedDescriptor
    }

    func realization(at index: UInt16) -> RasterRealizationDescriptor? {
        realizationRequests.append(index)
        guard index == storedRealization?.id.rawValue else { return nil }
        return storedRealization
    }

    func record(
        for glyph: GlyphID,
        realization: RasterRealizationID
    ) -> GlyphRasterRecord? {
        recordRequests.append((glyph.rawValue, realization))
        guard realization == storedRealization?.id,
            Int(glyph.rawValue) < records.count
        else {
            return nil
        }
        return records[Int(glyph.rawValue)]
    }

    func isPayloadAvailable(for realization: RasterRealizationID) -> Bool {
        availabilityRequests.append(realization)
        return isAvailable && realization == storedRealization?.id
    }

    func withPayload<Result>(
        for record: GlyphRasterRecord,
        realization: RasterRealizationID,
        _ body: (UnsafeRawBufferPointer) throws -> Result
    ) rethrows -> Result? {
        _ = record
        _ = realization
        _ = body
        return nil
    }
}
