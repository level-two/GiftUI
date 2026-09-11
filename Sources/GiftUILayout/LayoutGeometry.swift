import GiftUI

package enum LayoutGeometry {
    package static let zeroSize = Size(width: 0, height: 0)!

    package static func cap(
        ideal: Size,
        to proposal: ProposedSize
    ) -> LayoutMeasurement {
        LayoutMeasurement(
            idealSize: ideal,
            resolvedSize: Size(
                width: proposal.width.map { min(ideal.width, $0) } ?? ideal.width,
                height: proposal.height.map { min(ideal.height, $0) } ?? ideal.height
            )!
        )
    }

    package static func adding(
        width: GeometryScalar,
        height: GeometryScalar,
        to size: Size
    ) -> Size? {
        guard let resolvedWidth = GeometryArithmetic.add(size.width, width),
            let resolvedHeight = GeometryArithmetic.add(size.height, height)
        else { return nil }
        return Size(width: resolvedWidth, height: resolvedHeight)
    }

    package static func insetProposal(
        _ proposal: ProposedSize,
        horizontal: GeometryScalar,
        vertical: GeometryScalar
    ) -> ProposedSize? {
        let width: GeometryScalar?
        if let proposedWidth = proposal.width {
            guard
                let difference = GeometryArithmetic.subtract(
                    proposedWidth,
                    horizontal
                )
            else { return nil }
            width = max(0, difference)
        } else {
            width = nil
        }

        let height: GeometryScalar?
        if let proposedHeight = proposal.height {
            guard
                let difference = GeometryArithmetic.subtract(
                    proposedHeight,
                    vertical
                )
            else { return nil }
            height = max(0, difference)
        } else {
            height = nil
        }
        return ProposedSize(width: width, height: height)
    }

    package static func translated(
        _ point: Point,
        x: GeometryScalar,
        y: GeometryScalar
    ) -> Point? {
        guard let translatedX = GeometryArithmetic.add(point.x, x),
            let translatedY = GeometryArithmetic.add(point.y, y)
        else { return nil }
        return Point(x: translatedX, y: translatedY)
    }

    package static func offset(
        container: GeometryScalar,
        child: GeometryScalar,
        alignment: HorizontalAlignment
    ) -> GeometryScalar? {
        switch alignment {
        case .leading:
            return 0
        case .center:
            guard let difference = GeometryArithmetic.subtract(container, child)
            else { return nil }
            return difference / 2
        }
    }

    package static func offset(
        container: GeometryScalar,
        child: GeometryScalar,
        alignment: VerticalAlignment
    ) -> GeometryScalar? {
        guard let difference = GeometryArithmetic.subtract(container, child) else {
            return nil
        }
        switch alignment {
        case .top:
            return 0
        case .center:
            return difference / 2
        case .bottom:
            return difference
        }
    }

    package static func spacingTotal(
        spacing: GeometryScalar,
        childCount: UInt16
    ) -> GeometryScalar? {
        guard childCount > 1 else { return 0 }
        return GeometryArithmetic.multiply(
            spacing,
            GeometryScalar(childCount - 1)
        )
    }

    package static func intersection(_ lhs: Rect, _ rhs: Rect) -> Rect? {
        let minimumX = max(lhs.minX, rhs.minX)
        let minimumY = max(lhs.minY, rhs.minY)
        let maximumX = min(lhs.maxX, rhs.maxX)
        let maximumY = min(lhs.maxY, rhs.maxY)
        let width: GeometryScalar
        let height: GeometryScalar
        if maximumX < minimumX {
            width = 0
        } else {
            guard let difference = GeometryArithmetic.subtract(maximumX, minimumX)
            else { return nil }
            width = difference
        }
        if maximumY < minimumY {
            height = 0
        } else {
            guard let difference = GeometryArithmetic.subtract(maximumY, minimumY)
            else { return nil }
            height = difference
        }
        guard let size = Size(width: width, height: height) else { return nil }
        return Rect(origin: Point(x: minimumX, y: minimumY), size: size)
    }

    package static func clamped(
        _ value: GeometryScalar,
        minimum: GeometryScalar,
        maximum: FrameLimit?
    ) -> GeometryScalar {
        let raised = max(value, minimum)
        guard case .points(let finiteMaximum) = maximum else { return raised }
        return min(raised, finiteMaximum)
    }
}
