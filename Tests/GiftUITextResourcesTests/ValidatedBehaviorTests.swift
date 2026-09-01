@testable import GiftUITextResources
@testable import GiftUI
import XCTest

final class ValidatedBehaviorTests: XCTestCase {
    func testGoldenBaselineMetricsAndExplicitPoints() {
        let fixture = makeGoldenBehaviorFixture()
        XCTAssertEqual(
            TextResourceValidator.validate(
                fixture,
                requiring: RasterRealizationID(rawValue: 0)
            ),
            .valid
        )

        let line = fixture.metrics.instanceDescriptor.lineMetrics
        XCTAssertEqual(line.ascent, 12)
        XCTAssertEqual(line.descent, 3)
        XCTAssertEqual(line.lineGap, 2)
        let lineBoxHeight = GeometryArithmetic.add(line.ascent, line.descent)
        XCTAssertEqual(lineBoxHeight, 15)
        let baselineStep = lineBoxHeight.flatMap {
            GeometryArithmetic.add($0, line.lineGap)
        }
        XCTAssertEqual(baselineStep, 17)

        let baseline = Point(x: 20, y: 30)
        let glyph = fixture.metrics.glyphMetrics
        XCTAssertEqual(
            glyph.checkedInkRectangle(at: baseline),
            Rect(
                origin: Point(x: 18, y: 21),
                size: Size(width: 7, height: 9)!
            )
        )
        XCTAssertEqual(
            glyph.checkedAdvancedOrigin(from: baseline),
            Point(x: 31, y: 30)
        )
        XCTAssertEqual(
            baselineStep.flatMap { step in
                GeometryArithmetic.add(baseline.y, step)
            },
            47
        )
    }

    func testGoldenMappingsAndExplicitLineBreaks() {
        let fixture = makeGoldenBehaviorFixture()
        let instance = fixture.metrics.instanceDescriptor.id
        XCTAssertEqual(
            classifyValidatedScalar(0x41, metrics: fixture.metrics, instance: instance),
            .glyph(.exact(GlyphID(rawValue: 0)))
        )
        XCTAssertEqual(
            classifyValidatedScalar(0x2603, metrics: fixture.metrics, instance: instance),
            .glyph(.replacement(GlyphID(rawValue: 0)))
        )
        XCTAssertEqual(
            classifyValidatedScalar(0x0a, metrics: fixture.metrics, instance: instance),
            .explicitLineBreak
        )
        XCTAssertEqual(
            classifyValidatedScalar(0x0d, metrics: fixture.metrics, instance: instance),
            .explicitLineBreak
        )
        XCTAssertEqual(
            classifyValidatedScalar(0xd800, metrics: fixture.metrics, instance: instance),
            .invalidPrevalidatedInput
        )
    }

    func testExpectedNilAndUnexpectedPostValidationNilStayDistinct() {
        let fixture = makeGoldenBehaviorFixture()
        let instance = fixture.metrics.instanceDescriptor.id
        let gate = PostValidationLookupGate()
        let guarded = GatedGoldenMetrics(base: fixture.metrics, gate: gate)
        let guardedPackage = TextResourcePackage(
            metrics: guarded,
            raster: fixture.raster
        )
        XCTAssertEqual(
            TextResourceValidator.validate(
                guardedPackage,
                requiring: RasterRealizationID(rawValue: 0)
            ),
            .valid
        )

        XCTAssertEqual(
            classifyValidatedScalar(0x0a, metrics: guarded, instance: instance),
            .explicitLineBreak
        )
        XCTAssertEqual(
            classifyValidatedScalar(0x11_0000, metrics: guarded, instance: instance),
            .invalidPrevalidatedInput
        )
        gate.refuseMappingLookup = true
        XCTAssertEqual(
            classifyValidatedScalar(0x41, metrics: guarded, instance: instance),
            .unexpectedPostValidationLookupFailure
        )
    }

    func testEveryConsumerGeometryOverflowSiteReturnsNil() {
        XCTAssertNil(GeometryArithmetic.add(Int32.max, 1))
        XCTAssertNil(GeometryArithmetic.add(Int32.max - 1, 2))
        XCTAssertNil(GeometryArithmetic.add(Int32.max, 17))

        let offsetXOverflow = GlyphMetrics(
            advanceX: 0, offsetX: 1, offsetY: 0,
            inkSize: Size(width: 0, height: 0)!
        )
        XCTAssertNil(
            offsetXOverflow.checkedInkRectangle(at: Point(x: .max, y: 0))
        )

        let offsetYOverflow = GlyphMetrics(
            advanceX: 0, offsetX: 0, offsetY: 1,
            inkSize: Size(width: 0, height: 0)!
        )
        XCTAssertNil(
            offsetYOverflow.checkedInkRectangle(at: Point(x: 0, y: .max))
        )

        let rightEdgeOverflow = GlyphMetrics(
            advanceX: 0, offsetX: 0, offsetY: 0,
            inkSize: Size(width: 1, height: 0)!
        )
        XCTAssertNil(
            rightEdgeOverflow.checkedInkRectangle(at: Point(x: .max, y: 0))
        )

        let bottomEdgeOverflow = GlyphMetrics(
            advanceX: 0, offsetX: 0, offsetY: 0,
            inkSize: Size(width: 0, height: 1)!
        )
        XCTAssertNil(
            bottomEdgeOverflow.checkedInkRectangle(at: Point(x: 0, y: .max))
        )

        let advanceOverflow = GlyphMetrics(
            advanceX: 1, offsetX: 0, offsetY: 0,
            inkSize: Size(width: 0, height: 0)!
        )
        XCTAssertNil(
            advanceOverflow.checkedAdvancedOrigin(from: Point(x: .max, y: 0))
        )
    }
}

private enum ValidatedScalarResult: Equatable {
    case explicitLineBreak
    case invalidPrevalidatedInput
    case glyph(GlyphMapping)
    case unexpectedPostValidationLookupFailure
}

private func classifyValidatedScalar<M: CanonicalTextMetricsView>(
    _ scalar: UInt32,
    metrics: M,
    instance: FontInstanceID
) -> ValidatedScalarResult {
    if scalar == 0x0a || scalar == 0x0d {
        return .explicitLineBreak
    }
    guard TextResourceValidator.isValidUnicodeScalar(scalar) else {
        return .invalidPrevalidatedInput
    }
    guard let mapping = metrics.mapScalar(scalar, in: instance) else {
        return .unexpectedPostValidationLookupFailure
    }
    return .glyph(mapping)
}

private final class PostValidationLookupGate {
    var refuseMappingLookup = false
}

private struct GatedGoldenMetrics: CanonicalTextMetricsView {
    let base: ValidationMetrics
    let gate: PostValidationLookupGate

    var descriptor: TextResourceDescriptor { base.descriptor }

    func instance(at index: UInt16) -> FontInstanceDescriptor? {
        base.instance(at: index)
    }

    func mapping(
        at index: UInt16,
        in instance: FontInstanceID
    ) -> ScalarGlyphMappingRecord? {
        gate.refuseMappingLookup ? nil : base.mapping(at: index, in: instance)
    }

    func metrics(
        for glyph: GiftUITextResources.GlyphID,
        in instance: FontInstanceID
    ) -> GlyphMetrics? {
        base.metrics(for: glyph, in: instance)
    }
}

private func makeGoldenBehaviorFixture()
    -> TextResourcePackage<ValidationMetrics, ValidationRaster> {
    let payload: [UInt8] = Array(repeating: 0x80, count: 9)
    let payloadDigest = payload.withUnsafeBytes {
        TextResourceValidator.sha256(of: $0)
    }
    let provisional = makeGoldenBehaviorFixture(
        resource: FontResourceID(rawValue: zeroValidationDigest()),
        payload: payload,
        payloadDigest: payloadDigest
    )
    let resource = FontResourceID(
        rawValue: TextResourceValidator.canonicalManifestDigest(
            of: provisional
        )!.digest
    )
    return makeGoldenBehaviorFixture(
        resource: resource,
        payload: payload,
        payloadDigest: payloadDigest
    )
}

private func makeGoldenBehaviorFixture(
    resource: FontResourceID,
    payload: [UInt8],
    payloadDigest: TextResourceDigest
) -> TextResourcePackage<ValidationMetrics, ValidationRaster> {
    let descriptor = TextResourceDescriptor(
        schemaVersion: 1,
        resource: resource,
        instanceCount: 1,
        realizationCount: 1,
        canonicalManifestByteCount: 135
    )
    let instanceID = FontInstanceID(resource: resource, instanceIndex: 0)
    let metrics = ValidationMetrics(
        descriptor: descriptor,
        instanceDescriptor: FontInstanceDescriptor(
            id: instanceID,
            lineMetrics: FontLineMetrics(ascent: 12, descent: 3, lineGap: 2),
            replacementGlyph: GlyphID(rawValue: 0),
            glyphCount: 1,
            mappingCount: 1
        ),
        mappingRecord: ScalarGlyphMappingRecord(
            scalarValue: 0x41,
            glyph: GlyphID(rawValue: 0)
        ),
        glyphMetrics: GlyphMetrics(
            advanceX: 11,
            offsetX: -2,
            offsetY: -9,
            inkSize: Size(width: 7, height: 9)!
        )
    )
    let realization = RasterRealizationDescriptor(
        id: RasterRealizationID(rawValue: 0),
        instance: instanceID,
        kind: .monochromeBitmap1,
        glyphCount: 1,
        payloadByteCount: 9,
        payloadDigest: payloadDigest
    )
    let raster = ValidationRaster(
        descriptor: descriptor,
        realizationDescriptor: realization,
        recordValue: GlyphRasterRecord(
            glyph: GlyphID(rawValue: 0),
            offset: 0,
            byteCount: 9,
            rowByteCount: 1,
            pixelWidth: 7,
            pixelHeight: 9
        ),
        payload: payload
    )
    return TextResourcePackage(metrics: metrics, raster: raster)
}
