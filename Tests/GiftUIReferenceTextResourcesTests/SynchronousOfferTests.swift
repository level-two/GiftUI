import GiftUI
@testable import GiftUIReferenceTextResources
@testable import GiftUITextResources
import Testing

private struct ContractLocalGlyphRequest {
    let instance: FontInstanceID
    let glyph: GlyphID
    let point: Point
}

private enum ContractLocalSynchronousOffer {
    static func withResources<M, R, Result>(
        for request: borrowing ContractLocalGlyphRequest,
        in resourcePackage: borrowing TextResourcePackage<M, R>,
        realization: RasterRealizationID,
        _ body: (
            FontInstanceID,
            GlyphID,
            Point,
            GlyphMetrics,
            UnsafeRawBufferPointer
        ) throws -> Result
    ) rethrows -> Result?
    where M: CanonicalTextMetricsView, R: TextRasterResourceView {
        guard let metrics = resourcePackage.metrics.metrics(
            for: request.glyph,
            in: request.instance
        ),
        let record = resourcePackage.raster.record(
            for: request.glyph,
            realization: realization
        ) else {
            return nil
        }
        let offeredInstance = request.instance
        let offeredGlyph = request.glyph
        let offeredPoint = request.point
        return try resourcePackage.raster.withPayload(
            for: record,
            realization: realization
        ) { bytes in
            try body(
                offeredInstance,
                offeredGlyph,
                offeredPoint,
                metrics,
                bytes
            )
        }
    }
}

@Test
func synchronousOfferPerformsNestedReferenceLookupExactlyOnce() {
    let resourcePackage = GiftUIReferenceTextResources.completePackage
    let instance = resourcePackage.metrics.instance(at: 0)!.id
    let request = ContractLocalGlyphRequest(
        instance: instance,
        glyph: GlyphID(rawValue: 0),
        point: Point(x: 17, y: 23)
    )
    var invocationCount = 0
    let result = ContractLocalSynchronousOffer.withResources(
        for: request,
        in: resourcePackage,
        realization: RasterRealizationID(rawValue: 0)
    ) { offeredInstance, offeredGlyph, point, _, bytes in
        invocationCount += 1
        #expect(offeredInstance == request.instance)
        #expect(offeredGlyph == request.glyph)
        #expect(point == request.point)
        #expect(bytes.count > 0)
        return UInt8(41)
    }
    #expect(result == 41)
    #expect(invocationCount == 1)
}

@Test
func synchronousOfferInvokesOnceForAnEmptyPayload() {
    let fixture = EmptyOfferFixture(available: true)
    let request = fixture.request
    var invocationCount = 0
    let result = ContractLocalSynchronousOffer.withResources(
        for: request,
        in: fixture.resourcePackage,
        realization: RasterRealizationID(rawValue: 0)
    ) { _, _, _, _, bytes in
        invocationCount += 1
        #expect(bytes.count == 0)
        return true
    }
    #expect(result == true)
    #expect(invocationCount == 1)
    #expect(fixture.state.payloadInvocationCount == 1)
    #expect(fixture.state.borrowIsActive == false)
}

@Test
func invalidAndUnavailableOffersNeverInvokeTheBody() {
    let unavailable = EmptyOfferFixture(available: false)
    var invocationCount = 0
    let unavailableResult = ContractLocalSynchronousOffer.withResources(
        for: unavailable.request,
        in: unavailable.resourcePackage,
        realization: RasterRealizationID(rawValue: 0)
    ) { _, _, _, _, _ in
        invocationCount += 1
        return true
    }
    #expect(unavailableResult == nil)

    let valid = EmptyOfferFixture(available: true)
    let invalidRequest = ContractLocalGlyphRequest(
        instance: valid.request.instance,
        glyph: GlyphID(rawValue: 1),
        point: valid.request.point
    )
    let invalidResult = ContractLocalSynchronousOffer.withResources(
        for: invalidRequest,
        in: valid.resourcePackage,
        realization: RasterRealizationID(rawValue: 0)
    ) { _, _, _, _, _ in
        invocationCount += 1
        return true
    }
    #expect(invalidResult == nil)
    #expect(invocationCount == 0)
    #expect(unavailable.state.payloadInvocationCount == 0)
    #expect(valid.state.payloadInvocationCount == 0)
}

@Test
func synchronousOfferEndsEveryBorrowBeforeReturning() {
    let fixture = EmptyOfferFixture(available: true)
    let result = ContractLocalSynchronousOffer.withResources(
        for: fixture.request,
        in: fixture.resourcePackage,
        realization: RasterRealizationID(rawValue: 0)
    ) { _, _, _, _, _ in
        #expect(fixture.state.borrowIsActive)
        return UInt8(7)
    }
    #expect(result == 7)
    #expect(fixture.state.borrowIsActive == false)
    #expect(fixture.state.payloadInvocationCount == 1)
}

private final class EmptyOfferState {
    var payloadInvocationCount = 0
    var borrowIsActive = false
}

private struct EmptyOfferMetrics: CanonicalTextMetricsView {
    let descriptor: TextResourceDescriptor
    let instanceDescriptor: FontInstanceDescriptor

    func instance(at index: UInt16) -> FontInstanceDescriptor? {
        index == 0 ? instanceDescriptor : nil
    }

    func mapping(
        at index: UInt16,
        in instance: FontInstanceID
    ) -> ScalarGlyphMappingRecord? {
        guard index == 0, instance == instanceDescriptor.id else { return nil }
        return ScalarGlyphMappingRecord(
            scalarValue: 0x41,
            glyph: GlyphID(rawValue: 0)
        )
    }

    func metrics(
        for glyph: GlyphID,
        in instance: FontInstanceID
    ) -> GlyphMetrics? {
        guard glyph.rawValue == 0, instance == instanceDescriptor.id else {
            return nil
        }
        return GlyphMetrics(
            advanceX: 0,
            offsetX: 0,
            offsetY: 0,
            inkSize: Size(width: 0, height: 0)!
        )
    }
}

private struct EmptyOfferRaster: TextRasterResourceView {
    let descriptor: TextResourceDescriptor
    let realizationDescriptor: RasterRealizationDescriptor
    let available: Bool
    let state: EmptyOfferState

    func realization(at index: UInt16) -> RasterRealizationDescriptor? {
        index == 0 ? realizationDescriptor : nil
    }

    func record(
        for glyph: GlyphID,
        realization: RasterRealizationID
    ) -> GlyphRasterRecord? {
        guard glyph.rawValue == 0, realization.rawValue == 0 else { return nil }
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
        available && realization.rawValue == 0
    }

    func withPayload<Result>(
        for record: GlyphRasterRecord,
        realization: RasterRealizationID,
        _ body: (UnsafeRawBufferPointer) throws -> Result
    ) rethrows -> Result? {
        guard available,
              record == self.record(for: record.glyph, realization: realization)
        else { return nil }
        state.payloadInvocationCount += 1
        state.borrowIsActive = true
        defer { state.borrowIsActive = false }
        return try withUnsafeBytes(of: ()) { bytes in
            try body(bytes)
        }
    }
}

private struct EmptyOfferFixture {
    let state = EmptyOfferState()
    let request: ContractLocalGlyphRequest
    let resourcePackage: TextResourcePackage<EmptyOfferMetrics, EmptyOfferRaster>

    init(available: Bool) {
        let digest = TextResourceDigest(
            word0: 1, word1: 0, word2: 0, word3: 0,
            word4: 0, word5: 0, word6: 0, word7: 0
        )
        let resource = FontResourceID(rawValue: digest)
        let descriptor = TextResourceDescriptor(
            schemaVersion: 1,
            resource: resource,
            instanceCount: 1,
            realizationCount: 1,
            canonicalManifestByteCount: 1
        )
        let instance = FontInstanceID(resource: resource, instanceIndex: 0)
        let instanceDescriptor = FontInstanceDescriptor(
            id: instance,
            lineMetrics: FontLineMetrics(ascent: 1, descent: 0, lineGap: 0),
            replacementGlyph: GlyphID(rawValue: 0),
            glyphCount: 1,
            mappingCount: 1
        )
        let realization = RasterRealizationDescriptor(
            id: RasterRealizationID(rawValue: 0),
            instance: instance,
            kind: .monochromeBitmap1,
            glyphCount: 1,
            payloadByteCount: 0,
            payloadDigest: TextResourceValidator.sha256(
                of: UnsafeRawBufferPointer(start: nil, count: 0)
            )
        )
        request = ContractLocalGlyphRequest(
            instance: instance,
            glyph: GlyphID(rawValue: 0),
            point: Point(x: 3, y: 5)
        )
        resourcePackage = TextResourcePackage(
            metrics: EmptyOfferMetrics(
                descriptor: descriptor,
                instanceDescriptor: instanceDescriptor
            ),
            raster: EmptyOfferRaster(
                descriptor: descriptor,
                realizationDescriptor: realization,
                available: available,
                state: state
            )
        )
    }
}
