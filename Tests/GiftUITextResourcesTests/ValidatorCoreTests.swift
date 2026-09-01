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

    func testEachValidationClassHasAnIsolatedFixture() {
        for fault in ValidationPairFault.allCases {
            XCTAssertEqual(
                validate(makePairwiseValidationFixture([fault])),
                .invalid(fault.expectedError),
                "isolated fault \(fault)"
            )
        }
    }

    func testEveryPairUsesRawValuePrecedenceInBothFaultOrders() {
        let faults = ValidationPairFault.allCases
        var pairCount = 0
        for firstIndex in faults.indices {
            for secondIndex in faults.indices where secondIndex > firstIndex {
                let first = faults[firstIndex]
                let second = faults[secondIndex]
                let expected = first.expectedError.rawValue
                    < second.expectedError.rawValue
                    ? first.expectedError : second.expectedError
                XCTAssertEqual(
                    validate(makePairwiseValidationFixture([first, second])),
                    .invalid(expected),
                    "pair \(first), \(second)"
                )
                XCTAssertEqual(
                    validate(makePairwiseValidationFixture([second, first])),
                    .invalid(expected),
                    "reversed pair \(second), \(first)"
                )
                pairCount += 1
            }
        }
        XCTAssertEqual(pairCount, 36)
    }
}

private enum ValidationPairFault: CaseIterable, Hashable {
    case unsupportedSchema
    case capacityExceeded
    case invalidCount
    case invalidIdentity
    case incompatibleViews
    case malformedMetrics
    case malformedMapping
    case malformedRasterRecord
    case integrityMismatch

    var expectedError: TextResourceValidationError {
        switch self {
        case .unsupportedSchema: .unsupportedSchema
        case .capacityExceeded: .capacityExceeded
        case .invalidCount: .invalidCount
        case .invalidIdentity: .invalidIdentity
        case .incompatibleViews: .incompatibleViews
        case .malformedMetrics: .malformedMetrics
        case .malformedMapping: .malformedMapping
        case .malformedRasterRecord: .malformedRasterRecord
        case .integrityMismatch: .integrityMismatch
        }
    }
}

private func validate(
    _ fixture: TextResourcePackage<ValidationMetrics, ValidationRaster>
) -> TextResourceValidationResult {
    TextResourceValidator.validate(
        fixture,
        requiring: RasterRealizationID(rawValue: 0)
    )
}

private func makePairwiseValidationFixture(
    _ orderedFaults: [ValidationPairFault]
) -> TextResourcePackage<ValidationMetrics, ValidationRaster> {
    let faults = Set(orderedFaults)
    let schemaVersion: UInt16 = faults.contains(.unsupportedSchema) ? 2 : 1
    let instanceCount: UInt16 = faults.contains(.capacityExceeded) ? 2 : 1
    let manifestByteCount: UInt32 = faults.contains(.invalidCount) ? 0 : 135
    let instanceIndex: UInt16 = faults.contains(.invalidIdentity) ? 1 : 0
    let lineAscent: Int32 = faults.contains(.malformedMetrics) ? 0 : 1
    let mappingScalar: UInt32 = faults.contains(.malformedMapping) ? 0x0a : 0x41
    let payload: [UInt8] = [
        faults.contains(.malformedRasterRecord) ? 0x81 : 0x80,
    ]
    let payloadDigest = payload.withUnsafeBytes {
        TextResourceValidator.sha256(of: $0)
    }
    let zero = zeroValidationDigest()
    let zeroResource = FontResourceID(rawValue: zero)
    let provisional = makePairwiseValidationFixture(
        metricsResource: zeroResource,
        rasterResource: zeroResource,
        payloadDigest: payloadDigest,
        payload: payload,
        schemaVersion: schemaVersion,
        instanceCount: instanceCount,
        manifestByteCount: manifestByteCount,
        instanceIndex: instanceIndex,
        lineAscent: lineAscent,
        mappingScalar: mappingScalar
    )
    let computedIdentity = TextResourceValidator.canonicalManifestDigest(
        of: provisional
    )?.digest ?? zero
    let metricsIdentity = faults.contains(.integrityMismatch)
        ? zero : computedIdentity
    let metricsResource = FontResourceID(rawValue: metricsIdentity)
    let rasterResource = faults.contains(.incompatibleViews)
        ? FontResourceID(rawValue: TextResourceDigest(
            word0: 1, word1: 1, word2: 1, word3: 1,
            word4: 1, word5: 1, word6: 1, word7: 1
        ))
        : metricsResource
    return makePairwiseValidationFixture(
        metricsResource: metricsResource,
        rasterResource: rasterResource,
        payloadDigest: payloadDigest,
        payload: payload,
        schemaVersion: schemaVersion,
        instanceCount: instanceCount,
        manifestByteCount: manifestByteCount,
        instanceIndex: instanceIndex,
        lineAscent: lineAscent,
        mappingScalar: mappingScalar
    )
}

private func makePairwiseValidationFixture(
    metricsResource: FontResourceID,
    rasterResource: FontResourceID,
    payloadDigest: TextResourceDigest,
    payload: [UInt8],
    schemaVersion: UInt16,
    instanceCount: UInt16,
    manifestByteCount: UInt32,
    instanceIndex: UInt16,
    lineAscent: Int32,
    mappingScalar: UInt32
) -> TextResourcePackage<ValidationMetrics, ValidationRaster> {
    let metricsDescriptor = TextResourceDescriptor(
        schemaVersion: schemaVersion,
        resource: metricsResource,
        instanceCount: instanceCount,
        realizationCount: 1,
        canonicalManifestByteCount: manifestByteCount
    )
    let rasterDescriptor = TextResourceDescriptor(
        schemaVersion: schemaVersion,
        resource: rasterResource,
        instanceCount: instanceCount,
        realizationCount: 1,
        canonicalManifestByteCount: manifestByteCount
    )
    let metricsInstanceID = FontInstanceID(
        resource: metricsResource,
        instanceIndex: instanceIndex
    )
    let rasterInstanceID = FontInstanceID(
        resource: rasterResource,
        instanceIndex: instanceIndex
    )
    let metrics = ValidationMetrics(
        descriptor: metricsDescriptor,
        instanceDescriptor: FontInstanceDescriptor(
            id: metricsInstanceID,
            lineMetrics: FontLineMetrics(
                ascent: lineAscent,
                descent: 0,
                lineGap: 0
            ),
            replacementGlyph: GiftUITextResources.GlyphID(rawValue: 0),
            glyphCount: 1,
            mappingCount: 1
        ),
        mappingRecord: ScalarGlyphMappingRecord(
            scalarValue: mappingScalar,
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
        instance: rasterInstanceID,
        kind: .monochromeBitmap1,
        glyphCount: 1,
        payloadByteCount: 1,
        payloadDigest: payloadDigest
    )
    let raster = ValidationRaster(
        descriptor: rasterDescriptor,
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

struct ValidationMetrics: CanonicalTextMetricsView {
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

struct ValidationRaster: TextRasterResourceView {
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

func makeValidValidationFixture(
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

func makeValidationFixture(
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

func zeroValidationDigest() -> TextResourceDigest {
    TextResourceDigest(
        word0: 0, word1: 0, word2: 0, word3: 0,
        word4: 0, word5: 0, word6: 0, word7: 0
    )
}
