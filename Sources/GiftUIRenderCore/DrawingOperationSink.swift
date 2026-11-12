import GiftUI

@usableFromInline
package struct SubpathRange: Equatable, Sendable {
    @usableFromInline
    package let firstPoint: UInt16
    @usableFromInline
    package let pointCount: UInt16

    package init?(firstPoint: UInt16, pointCount: UInt16) {
        guard pointCount > 0 else { return nil }
        guard !firstPoint.addingReportingOverflow(pointCount).overflow else { return nil }

        self.firstPoint = firstPoint
        self.pointCount = pointCount
    }
}

@usableFromInline
package struct StraightLineStrokeHeader: Equatable, Sendable {
    @usableFromInline
    package let color: Color
    @usableFromInline
    package let lineWidth: GeometryScalar
    @usableFromInline
    package let lineCap: LineCap
    @usableFromInline
    package let lineJoin: LineJoin
    @usableFromInline
    package let surfaceOrigin: Point
    @usableFromInline
    package let inheritedClip: Rect
    @usableFromInline
    package let pointCount: UInt16
    @usableFromInline
    package let subpathCount: UInt16

    package init(
        color: Color,
        lineWidth: GeometryScalar,
        lineCap: LineCap,
        lineJoin: LineJoin,
        surfaceOrigin: Point,
        inheritedClip: Rect,
        pointCount: UInt16,
        subpathCount: UInt16
    ) {
        self.color = color
        self.lineWidth = lineWidth
        self.lineCap = lineCap
        self.lineJoin = lineJoin
        self.surfaceOrigin = surfaceOrigin
        self.inheritedClip = inheritedClip
        self.pointCount = pointCount
        self.subpathCount = subpathCount
    }
}

@usableFromInline
package protocol StraightLineStrokeView {
    var header: StraightLineStrokeHeader { get }
    func point(at index: UInt16) -> Point?
    func subpath(at index: UInt16) -> SubpathRange?
}

@usableFromInline
package protocol DrawingOperationSink: RenderOperationSink {
    mutating func straightLineStroke<Stroke: StraightLineStrokeView>(
        _ stroke: borrowing Stroke
    ) -> Bool
}
