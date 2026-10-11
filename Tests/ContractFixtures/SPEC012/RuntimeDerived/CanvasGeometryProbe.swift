import GiftUI
import GiftUIDrawing
import GiftUIRenderCore
import P06DrawingWorkspace

// Expectations are the immutable/subpath scenario in StrokeSnapshotTests and
// SPEC012's local-to-surface translation and discard/reset access rules.
public func giftuiP06Geometry() -> UInt32 {
    var checks: UInt32 = 0
    func expect(_ value: Bool) { checks += 1; precondition(value) }
    var pathBytes: InlineArray<3280, UInt8> = .init(repeating: 0)
    var planBytes: InlineArray<13536, UInt8> = .init(repeating: 0)
    withUnsafeMutableBytes(of: &pathBytes) { path in
        withUnsafeMutableBytes(of: &planBytes) { plan in
            let limits = DrawingLimits(maximumLineWidth: 4, maximumCanvasOccurrences: 5, maximumLivePathPoints: 202, maximumLivePathSubpaths: 12, maximumPlanStrokes: 5, maximumPlanPoints: 832, maximumPlanSubpaths: 16, maximumNormalizedStrokeOperations: 5)!
            var workspace = StaticSignalAnalyzerNRFDrawingWorkspace(pathRegion: path, planRegion: plan, capacity: limits)!
            let clip = Rect(origin: Point(x: 0, y: 0), size: Size(width: 100, height: 100)!)!
            expect(workspace.acquire())
            do throws(DrawingError) {
                try workspace.withCanvasContext(identity: 1, surfaceOrigin: Point(x: 11, y: 13), inheritedClip: clip) { (context) throws(DrawingError) in
                    try context.withPath { (context, path) throws(DrawingError) in
                        do throws(DrawingError) { try path.addLine(to: Point(x: 1, y: 2)); preconditionFailure("line before move") }
                        catch { expect(error == .invalidPathState) }
                        try path.move(to: Point(x: 0, y: 0))
                        try path.move(to: Point(x: 1, y: 2))
                        try path.addLine(to: Point(x: 3, y: 4))
                        do throws(DrawingError) { try context.stroke(path, with: .color(.red), lineWidth: 0); preconditionFailure("zero width") }
                        catch { expect(error == .invalidValue) }
                        try context.stroke(path, with: .color(Color(red: 5, green: 6, blue: 7)), style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .miter))
                        try path.move(to: Point(x: 17, y: 19))
                        try path.addLine(to: Point(x: 23, y: 29))
                        try context.stroke(path, with: .color(.red), style: StrokeStyle(lineWidth: 3, lineCap: .butt, lineJoin: .round))
                    }
                    try context.withPath { (context, path) throws(DrawingError) in
                        try context.stroke(path, with: .color(.white), lineWidth: 1)
                    }
                }
                // The retained analyzer workspace admits its exact five/five
                // profile. Empty records fill that profile without changing
                // the independent first two snapshot expectations.
                for identity: UInt16 in 2...5 {
                    try workspace.withCanvasContext(identity: identity, surfaceOrigin: Point(x: 0, y: 0), inheritedClip: clip) { (context) throws(DrawingError) in
                        if identity < 4 {
                            try context.withPath { (context, path) throws(DrawingError) in
                                try context.stroke(path, with: .color(.white), lineWidth: 1)
                            }
                        }
                    }
                }
            } catch { preconditionFailure("geometry construction") }
            let result = workspace.seal(canvasOccurrenceCount: 5)
            guard case .success(let summary) = result else { preconditionFailure("geometry seal") }
            expect(summary.canvasOccurrenceCount == 5 && summary.strokeCount == 5 && summary.pointCount == 6 && summary.subpathCount == 3)
            expect(workspace.strokeCount(of: 1) == 3)
            expect(workspace.point(of: 1, stroke: 0, at: 0) == Point(x: 12, y: 15))
            expect(workspace.point(of: 1, stroke: 0, at: 1) == Point(x: 14, y: 17))
            expect(workspace.point(of: 1, stroke: 0, at: 2) == nil)
            expect(workspace.point(of: 1, stroke: 1, at: 2) == Point(x: 28, y: 32))
            expect(workspace.point(of: 1, stroke: 1, at: 3) == Point(x: 34, y: 42))
            expect(workspace.subpath(of: 1, stroke: 0, at: 0) == SubpathRange(firstPoint: 0, pointCount: 2)!)
            expect(workspace.subpath(of: 1, stroke: 1, at: 1) == SubpathRange(firstPoint: 2, pointCount: 2)!)
            expect(workspace.strokeHeader(of: 1, at: 0)?.color == Color(red: 5, green: 6, blue: 7))
            expect(workspace.strokeHeader(of: 1, at: 0)?.surfaceOrigin == Point(x: 11, y: 13))
            expect(workspace.strokeHeader(of: 1, at: 2)?.pointCount == 0)
            workspace.discard()
            expect(workspace.strokeCount(of: 1) == nil && workspace.point(of: 1, stroke: 0, at: 0) == nil)
            workspace.reset()
            expect(workspace.acquire())
            workspace.discard(); workspace.reset()
        }
    }
    return checks
}
