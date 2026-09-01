@testable import GiftUITextResources
import GiftUI
import XCTest

final class ValidationPredicateTests: XCTestCase {
    func testSchemaCapacityAndCountPredicatesAreIsolated() {
        let base = makePredicateFixture()
        assertResult(
            replacingMetricsDescriptor(
                base,
                descriptor(base.metrics.descriptor, schemaVersion: 2)
            ),
            .unsupportedSchema
        )
        for fixture in [
            replacingMetricsDescriptor(
                base,
                descriptor(base.metrics.descriptor, instanceCount: 2)
            ),
            replacingInstance(
                base,
                instance(base.metrics.instanceValue!, glyphCount: 257)
            ),
            replacingInstance(
                base,
                instance(base.metrics.instanceValue!, mappingCount: 257)
            ),
            replacingMetricsDescriptor(
                base,
                descriptor(base.metrics.descriptor, realizationCount: 3)
            ),
            replacingMetricsDescriptor(
                base,
                descriptor(
                    base.metrics.descriptor,
                    canonicalManifestByteCount: 16_385
                )
            ),
            replacingRealization(
                base,
                realization(
                    base.raster.realizationValues[0]!,
                    payloadByteCount: 65_537
                )
            ),
        ] {
            assertResult(fixture, .capacityExceeded)
        }

        for fixture in [
            replacingMetricsDescriptor(
                base,
                descriptor(base.metrics.descriptor, instanceCount: 0)
            ),
            replacingInstance(
                base,
                instance(base.metrics.instanceValue!, glyphCount: 0)
            ),
            replacingInstance(
                base,
                instance(base.metrics.instanceValue!, mappingCount: 0)
            ),
            replacingMetricsDescriptor(
                base,
                descriptor(base.metrics.descriptor, realizationCount: 0)
            ),
            replacingMetricsDescriptor(
                base,
                descriptor(
                    base.metrics.descriptor,
                    canonicalManifestByteCount: 0
                )
            ),
            replacingMetricsWithMissingInstance(base),
            replacingMetrics(base, mappings: []),
            replacingMetrics(base, glyphMetrics: []),
            replacingRaster(base, realizationValues: []),
            replacingRaster(base, records: []),
            replacingMetrics(base, returnsExtraInstance: true),
            replacingMetrics(base, returnsExtraMapping: true),
            replacingMetrics(base, returnsExtraMetric: true),
            replacingRaster(base, returnsExtraRealization: true),
            replacingRaster(base, returnsExtraRecord: true),
        ] {
            assertResult(fixture, .invalidCount)
        }
    }

    func testIdentityAndCompatibilityPredicatesAreIsolated() {
        let base = makePredicateFixture()
        let otherResource = FontResourceID(rawValue: digestFilled(with: 7))
        let baseInstance = base.metrics.instanceValue!
        let baseRealization = base.raster.realizationValues[0]!
        let baseRecord = base.raster.records[0]
        for fixture in [
            replacingInstance(
                base,
                instance(
                    baseInstance,
                    id: FontInstanceID(
                        resource: baseInstance.id.resource,
                        instanceIndex: 1
                    )
                )
            ),
            replacingInstance(
                base,
                instance(
                    baseInstance,
                    id: FontInstanceID(
                        resource: otherResource,
                        instanceIndex: 0
                    )
                )
            ),
            replacingInstance(
                base,
                instance(
                    baseInstance,
                    replacementGlyph: GiftUITextResources.GlyphID(rawValue: 1)
                )
            ),
            replacingRealization(
                base,
                realization(
                    baseRealization,
                    id: RasterRealizationID(rawValue: 1)
                )
            ),
            replacingRealization(
                base,
                realization(
                    baseRealization,
                    instance: FontInstanceID(
                        resource: otherResource,
                        instanceIndex: 0
                    )
                )
            ),
            replacingRecord(
                base,
                changedRecord(
                    baseRecord,
                    glyph: GiftUITextResources.GlyphID(rawValue: 1)
                )
            ),
            replacingRaster(base, claimsInvalidAvailability: true),
        ] {
            assertResult(fixture, .invalidIdentity)
        }

        let mismatchedRasterDescriptor = replacingRasterDescriptor(
            base,
            descriptor(base.raster.descriptor, resource: otherResource)
        )
        assertResult(
            replacingRealization(
                mismatchedRasterDescriptor,
                realization(
                    baseRealization,
                    instance: FontInstanceID(
                        resource: otherResource,
                        instanceIndex: 0
                    )
                )
            ),
            .incompatibleViews
        )
        assertResult(base, .incompatibleViews, requiring: 1)
        assertResult(
            replacingRaster(base, availability: [false]),
            .incompatibleViews
        )
        let twoGlyphMetrics = replacingMetrics(
            replacingInstance(
                base,
                instance(base.metrics.instanceValue!, glyphCount: 2)
            ),
            glyphMetrics: [
                base.metrics.glyphMetrics[0],
                base.metrics.glyphMetrics[0],
            ]
        )
        assertResult(
            twoGlyphMetrics,
            .incompatibleViews
        )
        assertResult(
            replacingRaster(base, refusesBorrow: true),
            .incompatibleViews
        )
    }

    func testMetricAndMappingPredicatesAreIsolated() {
        let base = makePredicateFixture()
        let baseInstance = base.metrics.instanceValue!
        let baseMetrics = base.metrics.glyphMetrics[0]
        for line in [
            FontLineMetrics(ascent: 0, descent: 0, lineGap: 0),
            FontLineMetrics(ascent: 1, descent: -1, lineGap: 0),
            FontLineMetrics(ascent: 1, descent: 0, lineGap: -1),
            FontLineMetrics(ascent: .max, descent: 1, lineGap: 0),
        ] {
            assertResult(
                replacingInstance(
                    base,
                    instance(baseInstance, lineMetrics: line)
                ),
                .malformedMetrics
            )
        }
        for metrics in [
            GlyphMetrics(
                advanceX: -1, offsetX: 0, offsetY: 0,
                inkSize: Size(width: 1, height: 1)!
            ),
            GlyphMetrics(
                advanceX: 1, offsetX: .max, offsetY: 0,
                inkSize: Size(width: 1, height: 1)!
            ),
            GlyphMetrics(
                advanceX: 1, offsetX: 0, offsetY: .max,
                inkSize: Size(width: 1, height: 1)!
            ),
        ] {
            assertResult(
                replacingMetrics(base, glyphMetrics: [metrics]),
                .malformedMetrics
            )
        }
        XCTAssertEqual(baseMetrics.advanceX, 1)

        for scalar in [UInt32(0x11_0000), 0xd800, 0x0a, 0x0d] {
            assertResult(
                replacingMetrics(
                    base,
                    mappings: [ScalarGlyphMappingRecord(
                        scalarValue: scalar,
                        glyph: GiftUITextResources.GlyphID(rawValue: 0)
                    )]
                ),
                .malformedMapping
            )
        }
        assertResult(
            replacingMetrics(
                base,
                mappings: [ScalarGlyphMappingRecord(
                    scalarValue: 0x41,
                    glyph: GiftUITextResources.GlyphID(rawValue: 1)
                )]
            ),
            .malformedMapping
        )
        let twoMappingInstance = instance(baseInstance, mappingCount: 2)
        for mappings in [
            [mapping(0x42), mapping(0x41)],
            [mapping(0x41), mapping(0x41)],
        ] {
            assertResult(
                replacingMetrics(
                    replacingInstance(base, twoMappingInstance),
                    mappings: mappings
                ),
                .malformedMapping
            )
        }
    }

    func testRasterAndIntegrityPredicatesAreIsolated() {
        let base = makePredicateFixture()
        let baseRecord = base.raster.records[0]
        for changed in [
            changedRecord(baseRecord, rowByteCount: 2),
            changedRecord(baseRecord, pixelWidth: 2),
            changedRecord(baseRecord, pixelHeight: 2),
        ] {
            assertResult(replacingRecord(base, changed), .malformedRasterRecord)
        }
        assertResult(
            replacingPayloadEnvelope(
                base,
                record: changedRecord(baseRecord, offset: 1),
                payload: [0x00, 0x80]
            ),
            .malformedRasterRecord
        )
        assertResult(
            replacingPayloadEnvelope(
                base,
                record: changedRecord(baseRecord, byteCount: 2),
                payload: [0x80, 0x00]
            ),
            .malformedRasterRecord
        )
        assertResult(
            replacingRaster(base, payloads: [[0x81]]),
            .malformedRasterRecord
        )

        let outlineRealization = realization(
            base.raster.realizationValues[0]!,
            kind: .packagedOutline,
            payloadByteCount: 6,
            payloadDigest: digest(of: [1, 8, 0, 0, 16, 7])
        )
        let outlineRecord = changedRecord(
            baseRecord,
            byteCount: 6,
            rowByteCount: 0
        )
        assertResult(
            replacingRaster(
                replacingRealization(base, outlineRealization),
                records: [outlineRecord],
                payloads: [[1, 8, 0, 0, 16, 7]]
            ),
            .malformedRasterRecord
        )

        assertResult(
            replacingRealization(
                base,
                realization(
                    base.raster.realizationValues[0]!,
                    payloadDigest: digestFilled(with: 9)
                )
            ),
            .integrityMismatch
        )
        assertResult(
            replacingBothDescriptors(
                base,
                descriptor(
                    base.metrics.descriptor,
                    canonicalManifestByteCount: 134
                )
            ),
            .integrityMismatch
        )
        let wrongResource = FontResourceID(rawValue: digestFilled(with: 11))
        let wrongDescriptor = descriptor(
            base.metrics.descriptor,
            resource: wrongResource
        )
        let wrongInstanceID = FontInstanceID(
            resource: wrongResource,
            instanceIndex: 0
        )
        let wrongIdentityFixture = replacingBothDescriptors(
            replacingRealization(
                replacingInstance(
                    base,
                    instance(base.metrics.instanceValue!, id: wrongInstanceID)
                ),
                realization(
                    base.raster.realizationValues[0]!,
                    instance: wrongInstanceID
                )
            ),
            wrongDescriptor
        )
        assertResult(wrongIdentityFixture, .integrityMismatch)
    }

    func testZeroBytePayloadAndEmptyRecordPartitionValidate() {
        assertResult(makeCertifiedZeroPayloadFixture(), nil)
    }

    func testRejectionDoesNotRepairOrSubstituteInput() {
        let invalidMapping = ScalarGlyphMappingRecord(
            scalarValue: 0x0a,
            glyph: GiftUITextResources.GlyphID(rawValue: 0)
        )
        let fixture = replacingMetrics(
            makePredicateFixture(),
            mappings: [invalidMapping]
        )
        let descriptorBefore = fixture.metrics.descriptor
        let instanceBefore = fixture.metrics.instanceValue
        let recordBefore = fixture.raster.records[0]
        let payloadBefore = fixture.raster.payloads[0]
        assertResult(fixture, .malformedMapping)
        XCTAssertEqual(fixture.metrics.descriptor, descriptorBefore)
        XCTAssertEqual(fixture.metrics.instanceValue, instanceBefore)
        XCTAssertEqual(fixture.metrics.mappings, [invalidMapping])
        XCTAssertEqual(fixture.raster.records[0], recordBefore)
        XCTAssertEqual(fixture.raster.payloads[0], payloadBefore)
    }
}

private struct PredicateMetrics: CanonicalTextMetricsView {
    let descriptor: TextResourceDescriptor
    let instanceValue: FontInstanceDescriptor?
    let mappings: [ScalarGlyphMappingRecord]
    let glyphMetrics: [GlyphMetrics]
    let returnsExtraInstance: Bool
    let returnsExtraMapping: Bool
    let returnsExtraMetric: Bool

    func instance(at index: UInt16) -> FontInstanceDescriptor? {
        if index == 0 { return instanceValue }
        return returnsExtraInstance ? instanceValue : nil
    }

    func mapping(
        at index: UInt16,
        in instance: FontInstanceID
    ) -> ScalarGlyphMappingRecord? {
        guard instance == instanceValue?.id else { return nil }
        if Int(index) < mappings.count { return mappings[Int(index)] }
        return returnsExtraMapping ? mappings.last : nil
    }

    func metrics(
        for glyph: GiftUITextResources.GlyphID,
        in instance: FontInstanceID
    ) -> GlyphMetrics? {
        guard instance == instanceValue?.id else { return nil }
        if Int(glyph.rawValue) < glyphMetrics.count {
            return glyphMetrics[Int(glyph.rawValue)]
        }
        return returnsExtraMetric ? glyphMetrics.last : nil
    }
}

private struct PredicateRaster: TextRasterResourceView {
    let descriptor: TextResourceDescriptor
    let realizationValues: [RasterRealizationDescriptor?]
    let records: [GlyphRasterRecord]
    let payloads: [[UInt8]]
    let availability: [Bool]
    let returnsExtraRealization: Bool
    let returnsExtraRecord: Bool
    let claimsInvalidAvailability: Bool
    let refusesBorrow: Bool

    func realization(at index: UInt16) -> RasterRealizationDescriptor? {
        if Int(index) < realizationValues.count {
            return realizationValues[Int(index)]
        }
        return returnsExtraRealization ? realizationValues.last ?? nil : nil
    }

    func record(
        for glyph: GiftUITextResources.GlyphID,
        realization: RasterRealizationID
    ) -> GlyphRasterRecord? {
        guard realizationValues.contains(where: { $0?.id == realization }) else {
            return nil
        }
        if Int(glyph.rawValue) < records.count { return records[Int(glyph.rawValue)] }
        return returnsExtraRecord ? records.last : nil
    }

    func isPayloadAvailable(for realization: RasterRealizationID) -> Bool {
        if Int(realization.rawValue) < availability.count {
            return availability[Int(realization.rawValue)]
        }
        return claimsInvalidAvailability
    }

    func withPayload<Result>(
        for record: GlyphRasterRecord,
        realization: RasterRealizationID,
        _ body: (UnsafeRawBufferPointer) throws -> Result
    ) rethrows -> Result? {
        guard !refusesBorrow,
              Int(realization.rawValue) < payloads.count,
              isPayloadAvailable(for: realization) else { return nil }
        return try payloads[Int(realization.rawValue)].withUnsafeBytes { bytes in
            let start = Int(record.offset)
            let end = start + Int(record.byteCount)
            guard start <= end, end <= bytes.count else { return nil }
            return try body(UnsafeRawBufferPointer(rebasing: bytes[start ..< end]))
        }
    }
}

private typealias PredicatePackage = TextResourcePackage<PredicateMetrics, PredicateRaster>

private func makePredicateFixture() -> PredicatePackage {
    let base = makeValidValidationFixture()
    return PredicatePackage(
        metrics: PredicateMetrics(
            descriptor: base.metrics.descriptor,
            instanceValue: base.metrics.instanceDescriptor,
            mappings: [base.metrics.mappingRecord],
            glyphMetrics: [base.metrics.glyphMetrics],
            returnsExtraInstance: false,
            returnsExtraMapping: false,
            returnsExtraMetric: false
        ),
        raster: PredicateRaster(
            descriptor: base.raster.descriptor,
            realizationValues: [base.raster.realizationDescriptor],
            records: [base.raster.recordValue],
            payloads: [base.raster.payload],
            availability: [true],
            returnsExtraRealization: false,
            returnsExtraRecord: false,
            claimsInvalidAvailability: false,
            refusesBorrow: false
        )
    )
}

private func assertResult(
    _ fixture: PredicatePackage,
    _ error: TextResourceValidationError?,
    requiring realization: UInt16 = 0,
    file: StaticString = #filePath,
    line: UInt = #line
) {
    let expected: TextResourceValidationResult = error.map { .invalid($0) } ?? .valid
    XCTAssertEqual(
        TextResourceValidator.validate(
            fixture,
            requiring: RasterRealizationID(rawValue: realization)
        ),
        expected,
        file: file,
        line: line
    )
}

private func replacingMetricsDescriptor(
    _ fixture: PredicatePackage,
    _ value: TextResourceDescriptor
) -> PredicatePackage {
    PredicatePackage(
        metrics: PredicateMetrics(
            descriptor: value,
            instanceValue: fixture.metrics.instanceValue,
            mappings: fixture.metrics.mappings,
            glyphMetrics: fixture.metrics.glyphMetrics,
            returnsExtraInstance: fixture.metrics.returnsExtraInstance,
            returnsExtraMapping: fixture.metrics.returnsExtraMapping,
            returnsExtraMetric: fixture.metrics.returnsExtraMetric
        ),
        raster: fixture.raster
    )
}

private func replacingRasterDescriptor(
    _ fixture: PredicatePackage,
    _ value: TextResourceDescriptor
) -> PredicatePackage {
    PredicatePackage(
        metrics: fixture.metrics,
        raster: PredicateRaster(
            descriptor: value,
            realizationValues: fixture.raster.realizationValues,
            records: fixture.raster.records,
            payloads: fixture.raster.payloads,
            availability: fixture.raster.availability,
            returnsExtraRealization: fixture.raster.returnsExtraRealization,
            returnsExtraRecord: fixture.raster.returnsExtraRecord,
            claimsInvalidAvailability: fixture.raster.claimsInvalidAvailability,
            refusesBorrow: fixture.raster.refusesBorrow
        )
    )
}

private func replacingBothDescriptors(
    _ fixture: PredicatePackage,
    _ value: TextResourceDescriptor
) -> PredicatePackage {
    replacingRasterDescriptor(replacingMetricsDescriptor(fixture, value), value)
}

private func replacingInstance(
    _ fixture: PredicatePackage,
    _ value: FontInstanceDescriptor
) -> PredicatePackage {
    replacingMetrics(fixture, instanceValue: value)
}

private func replacingMetricsWithMissingInstance(
    _ fixture: PredicatePackage
) -> PredicatePackage {
    PredicatePackage(
        metrics: PredicateMetrics(
            descriptor: fixture.metrics.descriptor,
            instanceValue: nil,
            mappings: fixture.metrics.mappings,
            glyphMetrics: fixture.metrics.glyphMetrics,
            returnsExtraInstance: fixture.metrics.returnsExtraInstance,
            returnsExtraMapping: fixture.metrics.returnsExtraMapping,
            returnsExtraMetric: fixture.metrics.returnsExtraMetric
        ),
        raster: fixture.raster
    )
}

private func replacingMetrics(
    _ fixture: PredicatePackage,
    instanceValue: FontInstanceDescriptor? = nil,
    mappings: [ScalarGlyphMappingRecord]? = nil,
    glyphMetrics: [GlyphMetrics]? = nil,
    returnsExtraInstance: Bool? = nil,
    returnsExtraMapping: Bool? = nil,
    returnsExtraMetric: Bool? = nil
) -> PredicatePackage {
    PredicatePackage(
        metrics: PredicateMetrics(
            descriptor: fixture.metrics.descriptor,
            instanceValue: instanceValue ?? fixture.metrics.instanceValue,
            mappings: mappings ?? fixture.metrics.mappings,
            glyphMetrics: glyphMetrics ?? fixture.metrics.glyphMetrics,
            returnsExtraInstance: returnsExtraInstance
                ?? fixture.metrics.returnsExtraInstance,
            returnsExtraMapping: returnsExtraMapping
                ?? fixture.metrics.returnsExtraMapping,
            returnsExtraMetric: returnsExtraMetric
                ?? fixture.metrics.returnsExtraMetric
        ),
        raster: fixture.raster
    )
}

private func replacingRealization(
    _ fixture: PredicatePackage,
    _ value: RasterRealizationDescriptor
) -> PredicatePackage {
    replacingRaster(fixture, realizationValues: [value])
}

private func replacingRecord(
    _ fixture: PredicatePackage,
    _ value: GlyphRasterRecord
) -> PredicatePackage {
    replacingRaster(fixture, records: [value])
}

private func replacingPayloadEnvelope(
    _ fixture: PredicatePackage,
    record: GlyphRasterRecord,
    payload: [UInt8]
) -> PredicatePackage {
    let changedRealization = realization(
        fixture.raster.realizationValues[0]!,
        payloadByteCount: UInt32(payload.count),
        payloadDigest: digest(of: payload)
    )
    return replacingRaster(
        replacingRealization(fixture, changedRealization),
        records: [record],
        payloads: [payload]
    )
}

private func replacingRaster(
    _ fixture: PredicatePackage,
    realizationValues: [RasterRealizationDescriptor?]? = nil,
    records: [GlyphRasterRecord]? = nil,
    payloads: [[UInt8]]? = nil,
    availability: [Bool]? = nil,
    returnsExtraRealization: Bool? = nil,
    returnsExtraRecord: Bool? = nil,
    claimsInvalidAvailability: Bool? = nil,
    refusesBorrow: Bool? = nil
) -> PredicatePackage {
    PredicatePackage(
        metrics: fixture.metrics,
        raster: PredicateRaster(
            descriptor: fixture.raster.descriptor,
            realizationValues: realizationValues
                ?? fixture.raster.realizationValues,
            records: records ?? fixture.raster.records,
            payloads: payloads ?? fixture.raster.payloads,
            availability: availability ?? fixture.raster.availability,
            returnsExtraRealization: returnsExtraRealization
                ?? fixture.raster.returnsExtraRealization,
            returnsExtraRecord: returnsExtraRecord
                ?? fixture.raster.returnsExtraRecord,
            claimsInvalidAvailability: claimsInvalidAvailability
                ?? fixture.raster.claimsInvalidAvailability,
            refusesBorrow: refusesBorrow ?? fixture.raster.refusesBorrow
        )
    )
}

private func descriptor(
    _ value: TextResourceDescriptor,
    schemaVersion: UInt16? = nil,
    resource: FontResourceID? = nil,
    instanceCount: UInt16? = nil,
    realizationCount: UInt16? = nil,
    canonicalManifestByteCount: UInt32? = nil
) -> TextResourceDescriptor {
    TextResourceDescriptor(
        schemaVersion: schemaVersion ?? value.schemaVersion,
        resource: resource ?? value.resource,
        instanceCount: instanceCount ?? value.instanceCount,
        realizationCount: realizationCount ?? value.realizationCount,
        canonicalManifestByteCount: canonicalManifestByteCount
            ?? value.canonicalManifestByteCount
    )
}

private func instance(
    _ value: FontInstanceDescriptor,
    id: FontInstanceID? = nil,
    lineMetrics: FontLineMetrics? = nil,
    replacementGlyph: GiftUITextResources.GlyphID? = nil,
    glyphCount: UInt16? = nil,
    mappingCount: UInt16? = nil
) -> FontInstanceDescriptor {
    FontInstanceDescriptor(
        id: id ?? value.id,
        lineMetrics: lineMetrics ?? value.lineMetrics,
        replacementGlyph: replacementGlyph ?? value.replacementGlyph,
        glyphCount: glyphCount ?? value.glyphCount,
        mappingCount: mappingCount ?? value.mappingCount
    )
}

private func realization(
    _ value: RasterRealizationDescriptor,
    id: RasterRealizationID? = nil,
    instance: FontInstanceID? = nil,
    kind: TextRasterKind? = nil,
    glyphCount: UInt16? = nil,
    payloadByteCount: UInt32? = nil,
    payloadDigest: TextResourceDigest? = nil
) -> RasterRealizationDescriptor {
    RasterRealizationDescriptor(
        id: id ?? value.id,
        instance: instance ?? value.instance,
        kind: kind ?? value.kind,
        glyphCount: glyphCount ?? value.glyphCount,
        payloadByteCount: payloadByteCount ?? value.payloadByteCount,
        payloadDigest: payloadDigest ?? value.payloadDigest
    )
}

private func changedRecord(
    _ value: GlyphRasterRecord,
    glyph: GiftUITextResources.GlyphID? = nil,
    offset: UInt32? = nil,
    byteCount: UInt32? = nil,
    rowByteCount: UInt16? = nil,
    pixelWidth: UInt16? = nil,
    pixelHeight: UInt16? = nil
) -> GlyphRasterRecord {
    GlyphRasterRecord(
        glyph: glyph ?? value.glyph,
        offset: offset ?? value.offset,
        byteCount: byteCount ?? value.byteCount,
        rowByteCount: rowByteCount ?? value.rowByteCount,
        pixelWidth: pixelWidth ?? value.pixelWidth,
        pixelHeight: pixelHeight ?? value.pixelHeight
    )
}

private func mapping(_ scalar: UInt32) -> ScalarGlyphMappingRecord {
    ScalarGlyphMappingRecord(
        scalarValue: scalar,
        glyph: GiftUITextResources.GlyphID(rawValue: 0)
    )
}

private func digestFilled(with value: UInt32) -> TextResourceDigest {
    TextResourceDigest(
        word0: value, word1: value, word2: value, word3: value,
        word4: value, word5: value, word6: value, word7: value
    )
}

private func digest(of bytes: [UInt8]) -> TextResourceDigest {
    bytes.withUnsafeBytes { TextResourceValidator.sha256(of: $0) }
}

private func makeCertifiedZeroPayloadFixture() -> PredicatePackage {
    let zero = zeroValidationDigest()
    let emptyDigest = digest(of: [])
    func build(resource: FontResourceID) -> PredicatePackage {
        let descriptor = TextResourceDescriptor(
            schemaVersion: 1,
            resource: resource,
            instanceCount: 1,
            realizationCount: 1,
            canonicalManifestByteCount: 135
        )
        let instanceID = FontInstanceID(resource: resource, instanceIndex: 0)
        return PredicatePackage(
            metrics: PredicateMetrics(
                descriptor: descriptor,
                instanceValue: FontInstanceDescriptor(
                    id: instanceID,
                    lineMetrics: FontLineMetrics(ascent: 1, descent: 0, lineGap: 0),
                    replacementGlyph: GiftUITextResources.GlyphID(rawValue: 0),
                    glyphCount: 1,
                    mappingCount: 1
                ),
                mappings: [mapping(0x41)],
                glyphMetrics: [GlyphMetrics(
                    advanceX: 0, offsetX: 0, offsetY: 0,
                    inkSize: Size(width: 0, height: 0)!
                )],
                returnsExtraInstance: false,
                returnsExtraMapping: false,
                returnsExtraMetric: false
            ),
            raster: PredicateRaster(
                descriptor: descriptor,
                realizationValues: [RasterRealizationDescriptor(
                    id: RasterRealizationID(rawValue: 0),
                    instance: instanceID,
                    kind: .monochromeBitmap1,
                    glyphCount: 1,
                    payloadByteCount: 0,
                    payloadDigest: emptyDigest
                )],
                records: [GlyphRasterRecord(
                    glyph: GiftUITextResources.GlyphID(rawValue: 0),
                    offset: 0, byteCount: 0, rowByteCount: 0,
                    pixelWidth: 0, pixelHeight: 0
                )],
                payloads: [[]],
                availability: [true],
                returnsExtraRealization: false,
                returnsExtraRecord: false,
                claimsInvalidAvailability: false,
                refusesBorrow: false
            )
        )
    }
    let provisional = build(resource: FontResourceID(rawValue: zero))
    let identity = TextResourceValidator.canonicalManifestDigest(
        of: provisional
    )!.digest
    return build(resource: FontResourceID(rawValue: identity))
}
