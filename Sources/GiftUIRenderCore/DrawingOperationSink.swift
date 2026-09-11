import GiftUI

package struct SubpathRange: Equatable, Sendable {
    package let firstPoint: UInt16
    package let pointCount: UInt16

    package init?(firstPoint: UInt16, pointCount: UInt16) {
        guard pointCount > 0 else { return nil }
        guard !firstPoint.addingReportingOverflow(pointCount).overflow else { return nil }

        self.firstPoint = firstPoint
        self.pointCount = pointCount
    }
}

package struct StraightLineStrokeHeader: Equatable, Sendable {
    package let color: Color
    package let lineWidth: GeometryScalar
    package let lineCap: LineCap
    package let lineJoin: LineJoin
    package let surfaceOrigin: Point
    package let inheritedClip: Rect
    package let pointCount: UInt16
    package let subpathCount: UInt16
}

package protocol StraightLineStrokeView {
    var header: StraightLineStrokeHeader { get }
    func point(at index: UInt16) -> Point?
    func subpath(at index: UInt16) -> SubpathRange?
}

package protocol DrawingOperationSink: RenderOperationSink {
    mutating func straightLineStroke<Stroke: StraightLineStrokeView>(
        _ stroke: borrowing Stroke
    ) -> Bool
}
