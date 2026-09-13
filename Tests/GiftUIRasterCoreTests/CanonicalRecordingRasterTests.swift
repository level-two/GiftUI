import GiftUI
import GiftUICapabilities
import GiftUIRenderCore
import GiftUISurfaceCore
import GiftUITextResources
import Testing

@testable import GiftUIRasterCore

private struct CanonicalRecordingSurface: RasterSurface {
    let descriptor: RasterSurfaceDescriptor
    let writableCapacityBytes: UInt32
    private(set) var presentationResponsibilityAccepted = false
    private(set) var bytes: [UInt8]
    private(set) var affected: [Bool]

    private var header: RenderPlanHeader?

    init(descriptor: RasterSurfaceDescriptor) {
        self.descriptor = descriptor
        writableCapacityBytes =
            descriptor.bytesPerRow
            * UInt32(descriptor.regionHeight)
        bytes = [UInt8](repeating: 0, count: Int(writableCapacityBytes))
        affected = [Bool](
            repeating: false,
            count: Int(descriptor.bounds.size.width * descriptor.bounds.size.height)
        )
    }

    mutating func beginFrame(_ header: RenderPlanHeader) -> Bool {
        guard self.header == nil,
            header.surfaceBounds == descriptor.bounds,
            contains(descriptor.bounds, header.damageBounds)
        else { return false }
        self.header = header
        bytes = [UInt8](repeating: 0, count: bytes.count)
        affected = [Bool](repeating: false, count: affected.count)
        return true
    }

    mutating func replacePixel(
        at point: Point,
        with pixel: CanonicalEncodedPixel
    ) -> Bool {
        guard let header,
            header.damageBounds.contains(point),
            descriptor.bounds.contains(point),
            pixel.encoding == descriptor.encoding
        else { return false }
        let logicalIndex = Int(
            point.y * descriptor.bounds.size.width + point.x
        )
        let byteOffset =
            Int(UInt32(point.y) * descriptor.bytesPerRow)
            + Int(point.x) * Int(pixel.byteCount)
        affected[logicalIndex] = true
        bytes[byteOffset] = pixel.byte0
        bytes[byteOffset + 1] = pixel.byte1
        if pixel.byteCount == 4 {
            bytes[byteOffset + 2] = pixel.byte2
            bytes[byteOffset + 3] = pixel.byte3
        }
        return true
    }

    mutating func finishFrame() -> Bool {
        guard header != nil else { return false }
        header = nil
        return true
    }

    mutating func discardFrame() {
        header = nil
        bytes = [UInt8](repeating: 0, count: bytes.count)
        affected = [Bool](repeating: false, count: affected.count)
    }

    func mask() -> [String] {
        let width = Int(descriptor.bounds.size.width)
        let height = Int(descriptor.bounds.size.height)
        return (0 ..< height).map { row in
            String(
                (0 ..< width).map { column in
                    affected[(row * width) + column] ? "#" : "."
                })
        }
    }

    private func contains(_ outer: Rect, _ inner: Rect) -> Bool {
        inner.minX >= outer.minX && inner.minY >= outer.minY
            && inner.maxX <= outer.maxX && inner.maxY <= outer.maxY
    }
}

private struct CanonicalRecordingEndpoint: RasterFrameSink {
    let capacity: RenderSinkCapacity
    let descriptor: RasterSurfaceDescriptor
    let payloadLimits: RasterPayloadLimits
    let metrics: GlyphMetricsFixture
    let raster: GlyphRasterFixture
    let realization: RasterRealizationDescriptor

    private(set) var failure: RasterBackendError?
    private(set) var surface: CanonicalRecordingSurface
    private var header: RenderPlanHeader?
    private var glyphOperation: PositionedGlyphOperationHeader?
    private var operationCount: UInt16 = 0
    private var glyphCount: UInt16 = 0

    init(
        descriptor: RasterSurfaceDescriptor,
        metrics: GlyphMetricsFixture = GlyphMetricsFixture(),
        raster: GlyphRasterFixture = GlyphRasterFixture()
    ) {
        capacity = RenderSinkCapacity(
            maximumOperations: 16,
            maximumPositionedGlyphs: 16
        )
        self.descriptor = descriptor
        payloadLimits = RasterPayloadLimits(
            maximumRasterBytes: 4096,
            maximumPayloadBytes: 4096,
            maximumRegionsPerPayload: 64,
            maximumRegionSubmissionsPerFrame: 4096,
            maximumTileVisitsPerFrame: 4096,
            maximumInFlightPayloads: 1,
            maximumGlyphRasterBytes: 4096,
            maximumStrokeWorkspaceBytes: 4096
        )!
        self.metrics = metrics
        self.raster = raster
        realization = glyphRealization
        surface = CanonicalRecordingSurface(descriptor: descriptor)
    }

    mutating func begin(_ header: RenderPlanHeader) -> Bool {
        guard self.header == nil,
            header.operationCount <= capacity.maximumOperations,
            header.positionedGlyphCount <= capacity.maximumPositionedGlyphs,
            surface.beginFrame(header)
        else { return record(.malformedStream) }
        self.header = header
        operationCount = 0
        glyphCount = 0
        failure = nil
        return true
    }

    mutating func fillRect(_ operation: FillRectOperation) -> Bool {
        guard let header, glyphOperation == nil else {
            return record(.malformedStream)
        }
        let result = RasterFillCoverage.rasterize(
            operation,
            descriptor: descriptor,
            damageBounds: header.damageBounds
        ) { point, pixel in
            surface.replacePixel(at: point, with: pixel)
        }
        guard accept(result) else { return false }
        return incrementOperation()
    }

    mutating func beginPositionedGlyphs(
        _ operation: PositionedGlyphOperationHeader
    ) -> Bool {
        guard header != nil, glyphOperation == nil else {
            return record(.malformedStream)
        }
        glyphOperation = operation
        glyphCount = 0
        return true
    }

    mutating func positionedGlyph(_ glyph: PositionedGlyph) -> Bool {
        guard let header, let glyphOperation else {
            return record(.malformedStream)
        }
        let result = RasterGlyphCoverage.rasterize(
            glyph,
            operation: glyphOperation,
            metrics: metrics,
            raster: raster,
            realization: realization,
            descriptor: descriptor,
            damageBounds: header.damageBounds
        ) { point, pixel in
            surface.replacePixel(at: point, with: pixel)
        }
        guard accept(result) else { return false }
        let next = glyphCount.addingReportingOverflow(1)
        guard !next.overflow else { return record(.arithmeticOverflow) }
        glyphCount = next.partialValue
        return true
    }

    mutating func endPositionedGlyphs() -> Bool {
        guard let glyphOperation, glyphCount == glyphOperation.glyphCount else {
            return record(.malformedStream)
        }
        self.glyphOperation = nil
        return incrementOperation()
    }

    mutating func straightLineStroke<Stroke: StraightLineStrokeView>(
        _ stroke: borrowing Stroke
    ) -> Bool {
        guard let header, glyphOperation == nil else {
            return record(.malformedStream)
        }
        let result = RasterStrokeCoverage.rasterize(
            stroke,
            descriptor: descriptor,
            damageBounds: header.damageBounds
        ) { point, pixel in
            surface.replacePixel(at: point, with: pixel)
        }
        guard accept(result) else { return false }
        return incrementOperation()
    }

    mutating func finish() -> Bool {
        guard let header, glyphOperation == nil,
            operationCount == header.operationCount,
            surface.finishFrame()
        else { return record(.malformedStream) }
        self.header = nil
        return true
    }

    mutating func discard() {
        surface.discardFrame()
        header = nil
        glyphOperation = nil
    }

    private mutating func incrementOperation() -> Bool {
        let next = operationCount.addingReportingOverflow(1)
        guard !next.overflow else { return record(.arithmeticOverflow) }
        operationCount = next.partialValue
        return true
    }

    private mutating func accept(_ result: RasterFillResult) -> Bool {
        switch result {
        case .completed:
            return true
        case .invalidGeometry:
            return record(.invalidGeometry)
        case .arithmeticOverflow:
            return record(.arithmeticOverflow)
        case .replacementRefused:
            return record(.rasterizationFailure)
        }
    }

    private mutating func accept(_ result: RasterGlyphResult) -> Bool {
        switch result {
        case .completed:
            return true
        case .incompatibleResource:
            return record(.incompatibleResource)
        case .invalidGeometry:
            return record(.invalidGeometry)
        case .arithmeticOverflow:
            return record(.arithmeticOverflow)
        case .replacementRefused:
            return record(.rasterizationFailure)
        }
    }

    private mutating func accept(_ result: RasterStrokeResult) -> Bool {
        switch result {
        case .completed:
            return true
        case .invalidGeometry:
            return record(.invalidGeometry)
        case .invalidStroke:
            return record(.malformedStream)
        case .arithmeticOverflow:
            return record(.arithmeticOverflow)
        case .replacementRefused:
            return record(.rasterizationFailure)
        }
    }

    private mutating func record(_ error: RasterBackendError) -> Bool {
        if failure == nil { failure = error }
        return false
    }
}

@Test
func canonicalRecordingEndpointPreservesOrderDamageStrideAndExactBytes() {
    let bounds = recordingRect(0, 0, 5, 4)
    let descriptor = RasterSurfaceDescriptor(
        bounds: bounds,
        encoding: .rgb565BigEndian,
        bytesPerRow: 13,
        realization: .fullSurface,
        regionWidth: 5,
        regionHeight: 4
    )!
    var endpoint = CanonicalRecordingEndpoint(descriptor: descriptor)
    let header = RenderPlanHeader(
        surfaceBounds: bounds,
        damageBounds: recordingRect(1, 0, 4, 3),
        operationCount: 3,
        positionedGlyphCount: 1,
        maximumObservedClipDepth: 1
    )
    let began = endpoint.begin(header)
    #expect(began)
    let filled = endpoint.fillRect(
        FillRectOperation(
            bounds: recordingRect(-2, -1, 8, 5),
            clip: recordingRect(0, 0, 5, 4),
            color: .red
        )
    )
    #expect(filled)
    let beganGlyphs = endpoint.beginPositionedGlyphs(glyphOperation)
    #expect(beganGlyphs)
    let emittedGlyph = endpoint.positionedGlyph(
        PositionedGlyph(
            glyph: GlyphID(rawValue: 0),
            baseline: Point(x: 2, y: 2)
        )
    )
    #expect(emittedGlyph)
    let endedGlyphs = endpoint.endPositionedGlyphs()
    #expect(endedGlyphs)

    let stroke = RecordingStroke(
        header: StraightLineStrokeHeader(
            color: .blue,
            lineWidth: 1,
            lineCap: .butt,
            lineJoin: .miter,
            surfaceOrigin: Point(x: 0, y: 0),
            inheritedClip: recordingRect(0, 0, 5, 4),
            pointCount: 2,
            subpathCount: 1
        ),
        points: [Point(x: 1, y: 1), Point(x: 5, y: 1)],
        subpath: SubpathRange(firstPoint: 0, pointCount: 2)!
    )
    let stroked = endpoint.straightLineStroke(stroke)
    #expect(stroked)
    let finished = endpoint.finish()
    #expect(finished)

    #expect(endpoint.surface.mask() == [".####", ".####", ".####", "....."])
    #expect(Array(endpoint.surface.bytes[10 ..< 13]) == [0, 0, 0])
    #expect(Array(endpoint.surface.bytes[23 ..< 26]) == [0, 0, 0])
    #expect(endpoint.surface.bytes[2] == 0x00)
    #expect(endpoint.surface.bytes[3] == 0x1F)
    #expect(endpoint.surface.bytes[28] == 0xF8)
    #expect(endpoint.surface.bytes[29] == 0x00)
    #expect(endpoint.failure == nil)
}

private struct RecordingStroke: StraightLineStrokeView {
    let header: StraightLineStrokeHeader
    let points: [Point]
    let subpath: SubpathRange

    func point(at index: UInt16) -> Point? {
        index < points.count ? points[Int(index)] : nil
    }

    func subpath(at index: UInt16) -> SubpathRange? {
        index == 0 ? subpath : nil
    }
}

private func recordingRect(
    _ x: Int32,
    _ y: Int32,
    _ width: Int32,
    _ height: Int32
) -> Rect {
    Rect(
        origin: Point(x: x, y: y),
        size: Size(width: width, height: height)!
    )!
}
