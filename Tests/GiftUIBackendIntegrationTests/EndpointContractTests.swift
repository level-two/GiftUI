import GiftUI
import GiftUICapabilities
import GiftUIExecution
import GiftUIFailureCore
import GiftUIRasterCore
import GiftUIRenderCore
import GiftUISurfaceCore
import GiftUITextResources
import Testing

@testable import GiftUIBackendIntegration

@Test
func rasterFrameSinkConsumesCanonicalBorrowedStrokeWithoutDrawingModule() {
    var sink = CompileRasterSink()
    let stroke = CompileStrokeView()

    let accepted = sink.straightLineStroke(stroke)

    #expect(accepted)
    #expect(sink.strokeCallCount == 1)
    #expect(sink.failure == nil)
}

@Test
func rasterBackendEndpointPreservesExactAssociatedContracts() {
    var endpoint = CompileRasterEndpoint()
    let result = endpoint.offer(
        provenance: FrameProvenance(
            cycle: RunCycleID(rawValue: 1),
            semanticRevision: SemanticRevision(rawValue: 2),
            candidateFrame: CandidateFrameID(rawValue: 3)
        )
    ) { sink in
        _ = sink
        return .complete
    }

    #expect(result.disposition == .accepted)
    #expect(endpoint.descriptor == endpoint.sink.descriptor)
    #expect(endpoint.payloadLimits == endpoint.sink.payloadLimits)
    #expect(endpoint.textRasterRealization == RasterRealizationID(rawValue: 5))
    #expect(endpoint.health().state == .available)
}

private struct CompileStrokeView: StraightLineStrokeView {
    let header = StraightLineStrokeHeader(
        color: .red,
        lineWidth: 1,
        lineCap: .butt,
        lineJoin: .miter,
        surfaceOrigin: Point(x: 0, y: 0),
        inheritedClip: Rect(
            origin: Point(x: 0, y: 0),
            size: Size(width: 1, height: 1)!
        )!,
        pointCount: 1,
        subpathCount: 1
    )

    func point(at index: UInt16) -> Point? {
        index == 0 ? Point(x: 0, y: 0) : nil
    }

    func subpath(at index: UInt16) -> SubpathRange? {
        index == 0 ? SubpathRange(firstPoint: 0, pointCount: 1) : nil
    }
}

private struct CompileRasterSink: RasterFrameSink {
    let capacity = RenderSinkCapacity(maximumOperations: 1, maximumPositionedGlyphs: 1)
    let descriptor = RasterSurfaceDescriptor(
        bounds: Rect(
            origin: Point(x: 0, y: 0),
            size: Size(width: 1, height: 1)!
        )!,
        encoding: .rgba8888,
        bytesPerRow: 4,
        realization: .fullSurface,
        regionWidth: 1,
        regionHeight: 1
    )!
    let payloadLimits = RasterPayloadLimits(
        maximumRasterBytes: 4,
        maximumPayloadBytes: 4,
        maximumRegionsPerPayload: 1,
        maximumRegionSubmissionsPerFrame: 1,
        maximumTileVisitsPerFrame: 1,
        maximumInFlightPayloads: 1,
        maximumGlyphRasterBytes: 1,
        maximumStrokeWorkspaceBytes: 1
    )!
    var failure: RasterBackendError?
    var strokeCallCount = 0

    mutating func begin(_ header: RenderPlanHeader) -> Bool { true }
    mutating func fillRect(_ operation: FillRectOperation) -> Bool { true }
    mutating func beginPositionedGlyphs(
        _ operation: PositionedGlyphOperationHeader
    ) -> Bool { true }
    mutating func positionedGlyph(_ glyph: PositionedGlyph) -> Bool { true }
    mutating func endPositionedGlyphs() -> Bool { true }
    mutating func finish() -> Bool { true }
    mutating func discard() {}

    mutating func straightLineStroke<Stroke: StraightLineStrokeView>(
        _ stroke: borrowing Stroke
    ) -> Bool {
        _ = stroke.header
        strokeCallCount += 1
        return true
    }
}

private struct CompileTextRaster: TextRasterResourceView {
    var descriptor: TextResourceDescriptor { fatalError("compile-only property") }

    func realization(at index: UInt16) -> RasterRealizationDescriptor? { nil }

    func record(
        for glyph: GlyphID,
        realization: RasterRealizationID
    ) -> GlyphRasterRecord? { nil }

    func isPayloadAvailable(for realization: RasterRealizationID) -> Bool { true }

    func withPayload<Result>(
        for record: GlyphRasterRecord,
        realization: RasterRealizationID,
        _ body: (UnsafeRawBufferPointer) throws -> Result
    ) rethrows -> Result? { nil }
}

private struct CompileRasterEndpoint: RasterBackendEndpoint {
    var sink = CompileRasterSink()
    var effectivePresentation: EffectiveRasterPresentation {
        fatalError("compile-only property")
    }
    var descriptor: RasterSurfaceDescriptor { sink.descriptor }
    var payloadLimits: RasterPayloadLimits { sink.payloadLimits }
    let textRaster = CompileTextRaster()
    let textRasterRealization = RasterRealizationID(rawValue: 5)

    mutating func offer(
        provenance: FrameProvenance,
        body: (inout CompileRasterSink) -> FrameStreamResult
    ) -> FrameOfferResult {
        _ = provenance
        _ = body(&sink)
        return FrameOfferResult(disposition: .accepted, failure: nil)!
    }

    borrowing func health() -> GiftUIOperationalHealth {
        GiftUIOperationalHealth()
    }
}
