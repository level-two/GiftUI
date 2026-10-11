import GiftUI
import GiftUIRenderCore
import GiftUISurfaceCore

package enum RasterFillResult: Equatable, Sendable {
    case completed(pixelCount: UInt32)
    case invalidGeometry
    case arithmeticOverflow
    case replacementRefused
}

package enum RasterFillCoverage {
    package static func rasterize(
        _ operation: FillRectOperation,
        descriptor: RasterSurfaceDescriptor,
        damageBounds: Rect,
        _ replace: (Point, CanonicalEncodedPixel) -> Bool
    ) -> RasterFillResult {
        guard contains(descriptor.bounds, damageBounds) else {
            return .invalidGeometry
        }

        guard
            let covered = intersection(
                operation.bounds,
                operation.clip,
                damageBounds,
                descriptor.bounds
            )
        else { return .arithmeticOverflow }
        guard covered.size.width > 0, covered.size.height > 0 else {
            return .completed(pixelCount: 0)
        }

        let pixelCount = UInt32(covered.size.width).multipliedReportingOverflow(
            by: UInt32(covered.size.height)
        )
        guard !pixelCount.overflow else { return .arithmeticOverflow }

        let pixel = CanonicalEncodedPixel(
            color: operation.color,
            encoding: descriptor.encoding
        )
        var y = covered.minY
        while y < covered.maxY {
            var x = covered.minX
            while x < covered.maxX {
                guard replace(Point(x: x, y: y), pixel) else {
                    return .replacementRefused
                }
                x += 1
            }
            y += 1
        }
        return .completed(pixelCount: pixelCount.partialValue)
    }

    package static func intersection(
        _ first: Rect,
        _ second: Rect,
        _ third: Rect,
        _ fourth: Rect
    ) -> Rect? {
        let minimumX = max(first.minX, second.minX, third.minX, fourth.minX)
        let minimumY = max(first.minY, second.minY, third.minY, fourth.minY)
        let maximumX = min(first.maxX, second.maxX, third.maxX, fourth.maxX)
        let maximumY = min(first.maxY, second.maxY, third.maxY, fourth.maxY)
        guard maximumX > minimumX, maximumY > minimumY else {
            return Rect(
                origin: Point(x: minimumX, y: minimumY),
                size: Size(width: 0, height: 0)!
            )
        }
        let width = maximumX.subtractingReportingOverflow(minimumX)
        let height = maximumY.subtractingReportingOverflow(minimumY)
        guard !width.overflow, !height.overflow else { return nil }
        return Rect(
            origin: Point(x: minimumX, y: minimumY),
            size: Size(width: width.partialValue, height: height.partialValue)!
        )
    }

    private static func contains(_ outer: Rect, _ inner: Rect) -> Bool {
        inner.minX >= outer.minX && inner.minY >= outer.minY
            && inner.maxX <= outer.maxX && inner.maxY <= outer.maxY
    }
}
