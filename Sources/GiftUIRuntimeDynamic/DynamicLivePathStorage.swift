import GiftUI
import GiftUIDrawing
import GiftUIRenderCore

package struct DynamicLivePathStorage: LivePathStorage {
    package let maximumPointCount: UInt16
    package let maximumSubpathCount: UInt16

    private var points: [Point] = []
    private var subpaths: [SubpathRange] = []

    package init(maximumPointCount: UInt16, maximumSubpathCount: UInt16) {
        precondition(maximumPointCount > 0)
        precondition(maximumSubpathCount > 0)
        self.maximumPointCount = maximumPointCount
        self.maximumSubpathCount = maximumSubpathCount
        points.reserveCapacity(Int(maximumPointCount))
        subpaths.reserveCapacity(Int(maximumSubpathCount))
    }

    package var pointCount: UInt16 { UInt16(points.count) }
    package var subpathCount: UInt16 { UInt16(subpaths.count) }

    package func point(at index: UInt16) -> Point? {
        guard Int(index) < points.count else { return nil }
        return points[Int(index)]
    }

    package func subpath(at index: UInt16) -> SubpathRange? {
        guard Int(index) < subpaths.count else { return nil }
        return subpaths[Int(index)]
    }

    package mutating func startFirstSubpath(at point: Point) -> Bool {
        guard points.isEmpty, subpaths.isEmpty,
            maximumPointCount > 0, maximumSubpathCount > 0
        else { return false }
        points.append(point)
        subpaths.append(SubpathRange(firstPoint: 0, pointCount: 1)!)
        return true
    }

    package mutating func replaceCurrentSubpathStart(
        with point: Point
    ) -> Bool {
        guard subpaths.last?.pointCount == 1, !points.isEmpty else {
            return false
        }
        points[points.count - 1] = point
        return true
    }

    package mutating func startNextSubpath(at point: Point) -> Bool {
        guard pointCount < maximumPointCount,
            subpathCount < maximumSubpathCount
        else { return false }
        let firstPoint = pointCount
        points.append(point)
        subpaths.append(SubpathRange(firstPoint: firstPoint, pointCount: 1)!)
        return true
    }

    package mutating func appendLine(to point: Point) -> Bool {
        guard pointCount < maximumPointCount,
            let current = subpaths.last
        else { return false }
        let nextCount = current.pointCount.addingReportingOverflow(1)
        guard !nextCount.overflow,
            let nextRange = SubpathRange(
                firstPoint: current.firstPoint,
                pointCount: nextCount.partialValue
            )
        else { return false }
        points.append(point)
        subpaths[subpaths.count - 1] = nextRange
        return true
    }

    package mutating func reset() {
        points.removeAll(keepingCapacity: true)
        subpaths.removeAll(keepingCapacity: true)
    }
}
