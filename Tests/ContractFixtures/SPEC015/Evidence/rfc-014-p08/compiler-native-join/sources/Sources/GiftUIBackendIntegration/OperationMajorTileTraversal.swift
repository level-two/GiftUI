import GiftUI
import GiftUIRasterCore
import GiftUISurfaceCore

package enum OperationMajorTileTraversalResult: Equatable, Sendable {
    case completed(tileVisits: UInt32)
    case invalidGeometry
    case workspaceFailure
    case rasterFailure
    case consumeFailure
    case arithmeticOverflow
}

package enum OperationMajorTileTraversal {
    package static func visit<Storage>(
        operationClip: Rect,
        damageBounds: Rect,
        workspace: inout RGB565TileWorkspace<Storage>,
        _ rasterize: (Rect, (Point, CanonicalEncodedPixel) -> Bool) -> Bool,
        _ consume: (inout RGB565TileWorkspace<Storage>) -> Bool
    ) -> OperationMajorTileTraversalResult where Storage: RGB565TileStorage {
        let descriptor = workspace.descriptor
        guard contains(descriptor.bounds, damageBounds) else {
            return .invalidGeometry
        }
        guard
            let covered = RasterFillCoverage.intersection(
                operationClip,
                damageBounds,
                descriptor.bounds,
                descriptor.bounds
            )
        else { return .arithmeticOverflow }
        guard covered.size.width > 0, covered.size.height > 0 else {
            return .completed(tileVisits: 0)
        }

        let tileHeight = Int32(descriptor.regionHeight)
        var tileY = (covered.minY / tileHeight) * tileHeight
        var visits: UInt32 = 0
        while tileY < covered.maxY {
            let remaining = descriptor.bounds.maxY - tileY
            let height = min(tileHeight, remaining)
            guard
                let tile = Rect(
                    origin: Point(x: descriptor.bounds.minX, y: tileY),
                    size: Size(width: descriptor.bounds.size.width, height: height)!
                )
            else { return .arithmeticOverflow }
            let tileDamageMinY = max(tile.minY, damageBounds.minY)
            let tileDamageMaxY = min(tile.maxY, damageBounds.maxY)
            guard
                let tileDamage = Rect(
                    origin: Point(x: damageBounds.minX, y: tileDamageMinY),
                    size: Size(
                        width: damageBounds.size.width,
                        height: tileDamageMaxY - tileDamageMinY
                    )!
                )
            else { return .arithmeticOverflow }
            guard workspace.beginTile(tile) else { return .workspaceFailure }
            let rasterized = rasterize(tileDamage) { point, pixel in
                workspace.replacePixel(at: point, with: pixel)
            }
            guard rasterized else {
                _ = workspace.finishTile()
                return .rasterFailure
            }
            guard consume(&workspace) else {
                _ = workspace.finishTile()
                return .consumeFailure
            }
            guard workspace.finishTile() else { return .workspaceFailure }
            let nextVisits = visits.addingReportingOverflow(1)
            guard !nextVisits.overflow else { return .arithmeticOverflow }
            visits = nextVisits.partialValue
            tileY += tileHeight
        }
        return .completed(tileVisits: visits)
    }

    private static func contains(_ outer: Rect, _ inner: Rect) -> Bool {
        inner.minX >= outer.minX && inner.minY >= outer.minY
            && inner.maxX <= outer.maxX && inner.maxY <= outer.maxY
    }
}
