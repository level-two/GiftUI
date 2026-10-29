import GiftUI
import GiftUIDrawing
import GiftUILayout
import GiftUIRenderLowering

// Runtime arguments keep each imported constructor checked beyond literal folding.
@_noAllocation @inline(never)
private func layout(_ a: UInt16, _ b: UInt16, _ c: UInt16, _ d: UInt16, _ e: UInt16) -> LayoutLimits? {
    LayoutLimits(maximumScopes: a, maximumDepth: b, maximumTextScalars: c, maximumTextLines: d, maximumPositionedGlyphs: e)
}
@_noAllocation @inline(never)
private func drawing(_ width: Int32, _ a: UInt16, _ b: UInt16, _ c: UInt16, _ d: UInt16, _ e: UInt16, _ f: UInt16, _ g: UInt16) -> DrawingLimits? {
    DrawingLimits(maximumLineWidth: width, maximumCanvasOccurrences: a, maximumLivePathPoints: b, maximumLivePathSubpaths: c, maximumPlanStrokes: d, maximumPlanPoints: e, maximumPlanSubpaths: f, maximumNormalizedStrokeOperations: g)
}
@_noAllocation @inline(never)
private func render(_ a: UInt16, _ b: UInt16, _ c: UInt16) -> RenderLimits? {
    RenderLimits(maximumOperations: a, maximumPositionedGlyphs: b, maximumClipDepth: c)
}
@_noAllocation @inline(never)
private func workspace(_ a: UInt16, _ b: UInt16, _ c: UInt16, _ d: UInt16) -> RenderWorkspaceCapacity? {
    RenderWorkspaceCapacity(maximumSemanticScopes: a, maximumLayoutScopes: b, maximumTraversalDepth: c, maximumTextLines: d)
}
@_noAllocation @inline(never)
private func point(_ x: Int32, _ y: Int32) -> Point { Point(x: x, y: y) }
@_noAllocation @inline(never)
private func size(_ w: Int32, _ h: Int32) -> Size? { Size(width: w, height: h) }
@_noAllocation @inline(never)
private func rectangle(_ p: Point, _ s: Size) -> Rect? { Rect(origin: p, size: s) }
@_noAllocation @inline(never)
private func add(_ a: Int32, _ b: Int32) -> Int32? { GeometryArithmetic.add(a, b) }

@main
private struct GeometryQualification {
    static func check(_ condition: Bool, _ count: inout Int) {
        precondition(condition)
        count += 1
    }
    static func main() {
        var checks = 0
        for v: [UInt16] in [[1, 1, 1, 1, 1], [32, 12, 64, 16, 64], [.max, .max, .max, .max, .max]] {
            let x = layout(v[0], v[1], v[2], v[3], v[4])!
            check([x.maximumScopes, x.maximumDepth, x.maximumTextScalars, x.maximumTextLines, x.maximumPositionedGlyphs] == v, &checks)
        }
        for i in 0..<5 {
            var v: [UInt16] = [1, 1, 1, 1, 1]; v[i] = 0
            check(layout(v[0], v[1], v[2], v[3], v[4]) == nil, &checks)
        }
        for (w, v): (Int32, [UInt16]) in [(1, [1, 1, 1, 1, 1, 1, 1]), (1, [1, 2, 1, 1, 2, 1, 1]), (.max, [.max, .max, .max, .max, .max, .max, .max])] {
            let x = drawing(w, v[0], v[1], v[2], v[3], v[4], v[5], v[6])!
            check(x.maximumLineWidth == w, &checks)
            check([x.maximumCanvasOccurrences, x.maximumLivePathPoints, x.maximumLivePathSubpaths, x.maximumPlanStrokes, x.maximumPlanPoints, x.maximumPlanSubpaths, x.maximumNormalizedStrokeOperations] == v, &checks)
        }
        for w: Int32 in [0, -1, .min] { check(drawing(w, 1, 1, 1, 1, 1, 1, 1) == nil, &checks) }
        for i in 0..<7 {
            var v: [UInt16] = [1, 1, 1, 1, 1, 1, 1]; v[i] = 0
            check(drawing(1, v[0], v[1], v[2], v[3], v[4], v[5], v[6]) == nil, &checks)
        }
        check(drawing(1, 1, 1, 1, 2, 1, 1, 1) == nil, &checks)
        check(drawing(1, 1, 1, 1, 2, 1, 1, 2) != nil, &checks)
        for v: [UInt16] in [[1, 1, 1], [25, 64, 4], [.max, .max, .max]] {
            let x = render(v[0], v[1], v[2])!
            check([x.maximumOperations, x.maximumPositionedGlyphs, x.maximumClipDepth] == v, &checks)
        }
        for i in 0..<3 {
            var v: [UInt16] = [1, 1, 1]; v[i] = 0
            check(render(v[0], v[1], v[2]) == nil, &checks)
        }
        for v: [UInt16] in [[1, 1, 1, 1], [32, 32, 12, 16], [.max, .max, .max, .max]] {
            let x = workspace(v[0], v[1], v[2], v[3])!
            check([x.maximumSemanticScopes, x.maximumLayoutScopes, x.maximumTraversalDepth, x.maximumTextLines] == v, &checks)
        }
        for i in 0..<4 {
            var v: [UInt16] = [1, 1, 1, 1]; v[i] = 0
            check(workspace(v[0], v[1], v[2], v[3]) == nil, &checks)
        }
        let p = point(.min, .max)
        check(p.x == .min && p.y == .max, &checks)
        for (w, h): (Int32, Int32) in [(0, 0), (100, 120), (.max, .max)] {
            let x = size(w, h)!
            check(x.width == w && x.height == h, &checks)
        }
        for (w, h): (Int32, Int32) in [(-1, 0), (0, -1), (.min, .max), (.max, .min)] {
            check(size(w, h) == nil, &checks)
        }
        for (x, y, w, h): (Int32, Int32, Int32, Int32) in [(0, 0, 100, 120), (-100, -120, 100, 120), (.min, .min, .max, .max), (.max, .max, 0, 0)] {
            let r = rectangle(point(x, y), size(w, h)!)!
            check(r.origin.x == x && r.origin.y == y && r.size.width == w && r.size.height == h, &checks)
        }
        check(rectangle(point(.max, 0), size(1, 0)!) == nil, &checks)
        check(rectangle(point(0, .max), size(0, 1)!) == nil, &checks)
        check(add(.max, 1) == nil, &checks)
        check(add(.min, -1) == nil, &checks)
        check(add(.max, 0) == .max, &checks)
        check(add(.min, 0) == .min, &checks)
        check(add(-100, 100) == 0, &checks)
        check(add(-1, -1) == -2, &checks)
        check(MemoryLayout<Point>.size == 8 && MemoryLayout<Size>.size == 8 && MemoryLayout<Rect>.size == 16, &checks)
        check(MemoryLayout<LayoutLimits>.size == 10 && MemoryLayout<DrawingLimits>.size == 18 && MemoryLayout<RenderLimits>.size == 6 && MemoryLayout<RenderWorkspaceCapacity>.size == 8, &checks)
        print("GEOMETRY_QUALIFICATION checks=\(checks) actual-inputs=5 scalar-guards=all signed-overflow=both zero-size=accepted fields-and-layout=preserved")
    }
}
