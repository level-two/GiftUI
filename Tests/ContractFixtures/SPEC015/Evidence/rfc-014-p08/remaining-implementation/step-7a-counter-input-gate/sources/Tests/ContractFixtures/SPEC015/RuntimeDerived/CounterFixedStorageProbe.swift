import GiftUI
import GiftUIRenderCore

package func p08CounterFixedStorage() -> Int {
    var checks = 0
    var pathBytes: InlineArray<20, UInt8> = .init(repeating: 0)
    checks += withUnsafeMutableBytes(of: &pathBytes) { bytes in
        var path = StaticCounterLivePathStorage(region: bytes)!
        precondition(path.startFirstSubpath(at: Point(x: 4, y: 8)))
        precondition(path.appendLine(to: Point(x: 40, y: 8)))
        precondition(!path.appendLine(to: Point(x: 44, y: 8)))
        precondition(!path.startNextSubpath(at: Point(x: 0, y: 0)))
        precondition(path.pointCount == 2 && path.subpathCount == 1)
        precondition(path.point(at: 0) == Point(x: 4, y: 8) && path.point(at: 1) == Point(x: 40, y: 8))
        precondition(path.subpath(at: 0) == SubpathRange(firstPoint: 0, pointCount: 2))
        path.reset()
        precondition(path.pointCount == 0 && path.subpathCount == 0)
        return 8
    }
    var planBytes: InlineArray<112, UInt8> = .init(repeating: 0)
    checks += withUnsafeMutableBytes(of: &planBytes) { bytes in
        precondition(!StaticCounterDrawingPlanRecords.stagePoint(Point(x: 1, y: 1), at: 2, in: bytes))
        precondition(!StaticCounterDrawingPlanRecords.stageSubpath(SubpathRange(firstPoint: 0, pointCount: 2)!, at: 1, in: bytes))
        precondition(StaticCounterDrawingPlanStorage(region: bytes, capacity: counterDrawingLimits) != nil)
        precondition(bytes.allSatisfy { $0 == 0 })
        return 4
    }
    return checks
}
