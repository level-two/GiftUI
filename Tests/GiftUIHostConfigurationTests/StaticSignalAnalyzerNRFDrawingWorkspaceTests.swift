import GiftUI
import GiftUIDrawing
import GiftUIHostConfiguration
import Testing

@testable import SignalAnalyzerTargetHost

@Test func staticNRFDrawingWorkspaceInvokesFiveScopedCanvasContexts() throws {
    let limits = GeneratedSignalAnalyzerPresets.nrf52840Static().runtimeLimits.drawing
    var pathBytes = [UInt8](repeating: 0, count: 3_280)
    var planBytes = [UInt8](repeating: 0, count: 13_536)
    try pathBytes.withUnsafeMutableBytes { path in
        try planBytes.withUnsafeMutableBytes { plan in
            path[0] = 0xA5
            plan[0] = 0x5A
            var workspace = StaticSignalAnalyzerNRFDrawingWorkspace(
                pathRegion: path, planRegion: plan, capacity: limits
            )!
            #expect(path[0] == 0xA5)
            #expect(plan[0] == 0x5A)
            #expect({ workspace.acquire() }())
            #expect(plan[0] == 0)
            let clip = Rect(
                origin: Point(x: 0, y: 0), size: Size(width: 480, height: 320)!
            )!
            for index in 0 ..< 5 {
                let identity = UInt16(index + 1)
                let origin = Point(x: Int32(index * 10), y: 5)
                try workspace.withCanvasContext(
                    identity: identity, surfaceOrigin: origin,
                    inheritedClip: clip
                ) { (context: inout GraphicsContext) throws(DrawingError) in
                    try context.withPath {
                        (context: inout GraphicsContext, path: inout Path) throws(DrawingError) in
                        try path.move(to: Point(x: 0, y: 0))
                        try path.addLine(to: Point(x: 7, y: 9))
                        try context.stroke(
                            path,
                            with: .color(Color(red: UInt8(index), green: 20, blue: 30)),
                            lineWidth: 1
                        )
                    }
                }
            }
            let expected = DrawingPlanSummary(
                canvasOccurrenceCount: 5, strokeCount: 5,
                pointCount: 10, subpathCount: 5,
                normalizedStrokeOperationCount: 5
            )
            #expect({ workspace.seal(canvasOccurrenceCount: 5) }() == .success(expected))
            #expect(workspace.summary == expected)
            #expect(workspace.point(of: 5, stroke: 0, at: 0) == Point(x: 40, y: 5))
            #expect(workspace.point(of: 5, stroke: 0, at: 1) == Point(x: 47, y: 14))
            #expect(workspace.strokeCount(of: 5) == 1)
            #expect(path.allSatisfy { $0 == 0 })
            workspace.reset()
            #expect(plan.allSatisfy { $0 == 0 })
        }
    }
}

@Test func staticNRFDrawingWorkspaceRejectsInvalidPathAndDiscardsPartialPlan() throws {
    let limits = GeneratedSignalAnalyzerPresets.nrf52840Static().runtimeLimits.drawing
    var pathBytes = [UInt8](repeating: 0, count: 3_280)
    var planBytes = [UInt8](repeating: 0, count: 13_536)
    try pathBytes.withUnsafeMutableBytes { path in
        try planBytes.withUnsafeMutableBytes { plan in
            var workspace = StaticSignalAnalyzerNRFDrawingWorkspace(
                pathRegion: path, planRegion: plan, capacity: limits
            )!
            #expect({ workspace.acquire() }())
            let clip = Rect(
                origin: Point(x: 0, y: 0), size: Size(width: 480, height: 320)!
            )!
            #expect(throws: DrawingError.invalidPathState) {
                try workspace.withCanvasContext(
                    identity: 1, surfaceOrigin: Point(x: 0, y: 0),
                    inheritedClip: clip
                ) { (context: inout GraphicsContext) throws(DrawingError) in
                    try context.withPath {
                        (_: inout GraphicsContext, path: inout Path) throws(DrawingError) in
                        try path.addLine(to: Point(x: 1, y: 1))
                    }
                }
            }
            #expect(
                { workspace.seal(canvasOccurrenceCount: 1) }()
                    == .failure(.invariantViolation))
            workspace.discard()
            #expect(path.allSatisfy { $0 == 0 })
            #expect(plan.allSatisfy { $0 == 0 })
        }
    }
}
