import GiftUI
import Testing

@testable import GiftUIRenderCore

private struct TestStroke: StraightLineStrokeView {
    let header: StraightLineStrokeHeader
    let points: [Point]
    let subpaths: [SubpathRange]

    func point(at index: UInt16) -> Point? {
        guard Int(index) < points.count else { return nil }
        return points[Int(index)]
    }

    func subpath(at index: UInt16) -> SubpathRange? {
        guard Int(index) < subpaths.count else { return nil }
        return subpaths[Int(index)]
    }
}

private struct TestDrawingSink: DrawingOperationSink {
    let capacity = RenderSinkCapacity(maximumOperations: 1, maximumPositionedGlyphs: 0)
    private(set) var strokeHeader: StraightLineStrokeHeader?
    private(set) var firstPoint: Point?
    private(set) var firstSubpath: SubpathRange?
    var acceptsStroke = true

    mutating func straightLineStroke<Stroke: StraightLineStrokeView>(
        _ stroke: borrowing Stroke
    ) -> Bool {
        strokeHeader = stroke.header
        firstPoint = stroke.point(at: 0)
        firstSubpath = stroke.subpath(at: 0)
        return acceptsStroke
    }

    mutating func begin(_: RenderPlanHeader) -> Bool { true }
    mutating func fillRect(_: FillRectOperation) -> Bool { true }
    mutating func beginPositionedGlyphs(_: PositionedGlyphOperationHeader) -> Bool { true }
    mutating func positionedGlyph(_: PositionedGlyph) -> Bool { true }
    mutating func endPositionedGlyphs() -> Bool { true }
    mutating func finish() -> Bool { true }
    mutating func discard() {}
}

@Test(arguments: [true, false])
func drawingOperationSinkRetainsOnlyDerivedValuesAfterBorrowReturns(
    acceptsStroke: Bool
) {
    let point = Point(x: 47, y: 53)
    let subpath = SubpathRange(firstPoint: 0, pointCount: 1)!
    let header = StraightLineStrokeHeader(
        color: .blue,
        lineWidth: 3,
        lineCap: .butt,
        lineJoin: .round,
        surfaceOrigin: Point(x: 0, y: 0),
        inheritedClip: Rect(
            origin: Point(x: 0, y: 0),
            size: Size(width: 59, height: 61)!
        )!,
        pointCount: 1,
        subpathCount: 1
    )
    var sink = TestDrawingSink(acceptsStroke: acceptsStroke)

    do {
        let stroke = TestStroke(header: header, points: [point], subpaths: [subpath])
        #expect(sink.straightLineStroke(stroke) == acceptsStroke)
    }

    #expect(sink.strokeHeader == header)
    #expect(sink.firstPoint == point)
    #expect(sink.firstSubpath == subpath)
}

@Test
func drawingOperationSinkConsumesTheBorrowedStrokeView() {
    let point = Point(x: 3, y: 5)
    let subpath = SubpathRange(firstPoint: 0, pointCount: 1)!
    let rect = Rect(origin: Point(x: 0, y: 0), size: Size(width: 8, height: 13)!)!
    let header = StraightLineStrokeHeader(
        color: .red,
        lineWidth: 2,
        lineCap: .round,
        lineJoin: .miter,
        surfaceOrigin: Point(x: 1, y: 2),
        inheritedClip: rect,
        pointCount: 1,
        subpathCount: 1
    )
    let stroke = TestStroke(header: header, points: [point], subpaths: [subpath])
    var sink = TestDrawingSink()

    let accepted = sink.straightLineStroke(stroke)
    #expect(accepted)
    #expect(sink.strokeHeader == header)
    #expect(sink.firstPoint == point)
    #expect(sink.firstSubpath == subpath)
}
