import GiftUI
import GiftUIBackendIntegration
import GiftUICapabilities
import GiftUIDisplayCore
import GiftUIExecution
import GiftUIFailureCore
import GiftUIRasterCore
import GiftUIRenderCore
import GiftUISurfaceCore
import GiftUITextResources

private func requireSendable<T: Sendable>(_: T.Type) {}

package func verifyBackendValueSendability() {
    requireSendable(CanonicalEncodedPixel.self)
    requireSendable(RasterSurfaceDescriptor.self)
    requireSendable(RasterPayloadLimits.self)
    requireSendable(DisplayReservationID.self)
    requireSendable(DisplayReservationResult.self)
    requireSendable(DisplayTransferResult.self)
    requireSendable(DisplayTargetError.self)
    requireSendable(RasterBackendError.self)
}

package struct CompileSurfaceRasterSurface: RasterSurface {
    package var descriptor: RasterSurfaceDescriptor { fatalError() }
    package var writableCapacityBytes: UInt32 { 1 }
    package var presentationResponsibilityAccepted: Bool { false }

    package mutating func beginFrame(_ header: RenderPlanHeader) -> Bool {
        _ = header
        return true
    }

    package mutating func replacePixel(
        at point: Point,
        with pixel: CanonicalEncodedPixel
    ) -> Bool {
        _ = point
        _ = pixel
        return true
    }

    package mutating func finishFrame() -> Bool { true }
    package mutating func discardFrame() {}
}

package struct CompileSurfaceRasterFrameSink: RasterFrameSink {
    package var capacity: RenderSinkCapacity {
        RenderSinkCapacity(maximumOperations: 1, maximumPositionedGlyphs: 1)
    }

    package var descriptor: RasterSurfaceDescriptor { fatalError() }
    package var payloadLimits: RasterPayloadLimits { fatalError() }
    package var failure: RasterBackendError? { nil }

    package mutating func begin(_ header: RenderPlanHeader) -> Bool {
        _ = header
        return true
    }

    package mutating func fillRect(_ operation: FillRectOperation) -> Bool {
        _ = operation
        return true
    }

    package mutating func beginPositionedGlyphs(
        _ operation: PositionedGlyphOperationHeader
    ) -> Bool {
        _ = operation
        return true
    }

    package mutating func positionedGlyph(_ glyph: PositionedGlyph) -> Bool {
        _ = glyph
        return true
    }

    package mutating func endPositionedGlyphs() -> Bool { true }
    package mutating func finish() -> Bool { true }
    package mutating func discard() {}

    package mutating func straightLineStroke<Stroke: StraightLineStrokeView>(
        _ stroke: borrowing Stroke
    ) -> Bool {
        _ = stroke.header
        return true
    }
}

package struct CompileSurfaceDisplayWriter: DisplayPayloadWriter {
    package var capacityBytes: UInt32 { 1 }
    package var writtenBytes: UInt32 { 0 }
    package var regionCapacity: UInt16 { 1 }
    package var writtenRegionCount: UInt16 { 0 }

    package mutating func beginRegion(
        origin: Point,
        pixelCount: UInt16,
        encoding: CanonicalPixelEncoding
    ) -> Bool {
        _ = origin
        _ = pixelCount
        _ = encoding
        return true
    }

    package mutating func write(byte: UInt8) -> Bool {
        _ = byte
        return true
    }

    package mutating func endRegion() -> Bool { true }
    package mutating func finish() -> Bool { true }
    package mutating func discard() {}
}

package struct CompileSurfaceDisplayTarget: DisplayTarget {
    package var writer = CompileSurfaceDisplayWriter()
    package var submissionLifetime: SubmissionLifetime { .synchronousBorrow }
    package var handoff: SubmissionHandoff { .synchronous }
    package var maximumInFlightPayloads: UInt8 { 1 }
    package var maximumInFlightBytes: UInt32 { 1 }

    package mutating func reserveFrame(
        descriptor: RasterSurfaceDescriptor,
        payloadCapacityBytes: UInt32,
        regionCapacity: UInt16
    ) -> DisplayReservationResult {
        _ = descriptor
        _ = payloadCapacityBytes
        _ = regionCapacity
        return .backpressured
    }

    package mutating func withWriter<Result>(
        for reservation: DisplayReservationID,
        _ body: (inout CompileSurfaceDisplayWriter) -> Result
    ) -> Result? {
        _ = reservation
        return body(&writer)
    }

    package mutating func submitPayload(
        _ reservation: DisplayReservationID
    ) -> DisplayTransferResult {
        _ = reservation
        return .completed
    }

    package mutating func finishFrame(
        _ reservation: DisplayReservationID
    ) -> DisplayTransferResult {
        _ = reservation
        return .completed
    }

    package mutating func cancelFrame(_ reservation: DisplayReservationID) {
        _ = reservation
    }

    package borrowing func health() -> GiftUIOperationalHealth {
        GiftUIOperationalHealth()
    }
}

package struct CompileSurfaceTextRaster: TextRasterResourceView {
    package var descriptor: TextResourceDescriptor { fatalError() }

    package func realization(at index: UInt16) -> RasterRealizationDescriptor? {
        _ = index
        return nil
    }

    package func record(
        for glyph: GlyphID,
        realization: RasterRealizationID
    ) -> GlyphRasterRecord? {
        _ = glyph
        _ = realization
        return nil
    }

    package func isPayloadAvailable(for realization: RasterRealizationID) -> Bool {
        _ = realization
        return false
    }

    package func withPayload<Result>(
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

package struct CompileSurfaceTextMetrics: CanonicalTextMetricsView {
    package var descriptor: TextResourceDescriptor { fatalError() }

    package func instance(at index: UInt16) -> FontInstanceDescriptor? { nil }

    package func mapping(
        at index: UInt16,
        in instance: FontInstanceID
    ) -> ScalarGlyphMappingRecord? { nil }

    package func mapScalar(
        _ scalarValue: UInt32,
        in instance: FontInstanceID
    ) -> GlyphMapping? { nil }

    package func metrics(
        for glyph: GlyphID,
        in instance: FontInstanceID
    ) -> GlyphMetrics? { nil }
}

package struct CompileSurfaceEndpoint: RasterBackendEndpoint {
    package var sink = CompileSurfaceRasterFrameSink()
    package var effectivePresentation: EffectiveRasterPresentation { fatalError() }
    package var descriptor: RasterSurfaceDescriptor { fatalError() }
    package var payloadLimits: RasterPayloadLimits { fatalError() }
    package var textMetrics = CompileSurfaceTextMetrics()
    package var textRaster = CompileSurfaceTextRaster()
    package var textRasterRealization: RasterRealizationID {
        RasterRealizationID(rawValue: 0)
    }

    package mutating func offer(
        provenance: FrameProvenance,
        body: (inout CompileSurfaceRasterFrameSink) -> FrameStreamResult
    ) -> FrameOfferResult {
        _ = provenance
        _ = body(&sink)
        return FrameOfferResult(disposition: .backpressured, failure: nil)!
    }

    package borrowing func health() -> GiftUIOperationalHealth {
        GiftUIOperationalHealth()
    }
}
