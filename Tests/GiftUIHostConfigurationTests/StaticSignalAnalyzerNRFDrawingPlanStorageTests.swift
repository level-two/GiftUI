import GiftUI
import GiftUIDrawing
import GiftUIHostConfiguration
import GiftUIRenderCore
import Testing

@testable import SignalAnalyzerTargetHost

@Test func staticNRFDrawingPlanSnapshotsFiveCanvasesIntoOneFixedRegion() throws {
    let limits = GeneratedSignalAnalyzerPresets.nrf52840Static().runtimeLimits.drawing
    var planBytes = [UInt8](repeating: 0, count: 13_536)
    var pathBytes = [UInt8](repeating: 0, count: 3_280)
    try planBytes.withUnsafeMutableBytes { planRegion in
        try pathBytes.withUnsafeMutableBytes { pathRegion in
            var plan = StaticSignalAnalyzerNRFDrawingPlanStorage(
                region: planRegion, capacity: limits
            )!
            #expect({ plan.acquire() }())
            let clip = Rect(
                origin: Point(x: 0, y: 0), size: Size(width: 480, height: 320)!
            )!
            for ordinal in 0 ..< 5 {
                let identity = UInt16(ordinal + 1)
                let origin = Point(x: Int32(ordinal * 10), y: 4)
                #expect({ plan.beginCanvas(identity: identity, origin: origin) }())
                var path = LivePathBuilder(
                    storage: StaticSignalAnalyzerNRFLivePathStorage(region: pathRegion)!
                )
                try path.move(to: Point(x: 0, y: 0))
                try path.addLine(to: Point(x: 5, y: 6))
                try StrokeSnapshotProducer.snapshot(
                    path: path.storage,
                    shading: .color(Color(red: UInt8(ordinal), green: 20, blue: 30)),
                    style: StrokeStyle(lineWidth: 1, lineCap: .round, lineJoin: .round),
                    surfaceOrigin: origin, inheritedClip: clip,
                    plan: &plan
                )
                #expect({ plan.endCanvas() }())
                path.reset()
            }
            let expected = DrawingPlanSummary(
                canvasOccurrenceCount: 5, strokeCount: 5,
                pointCount: 10, subpathCount: 5,
                normalizedStrokeOperationCount: 5
            )
            let secondSubpath = StaticSignalAnalyzerNRFDrawingPlanRecords.subpathOffset + 4
            planRegion[secondSubpath] = 1
            #expect(
                { plan.seal(canvasOccurrenceCount: 5) }()
                    == .failure(.invariantViolation))
            planRegion[secondSubpath] = 0
            #expect({ plan.seal(canvasOccurrenceCount: 5) }() == .success(expected))
            #expect(plan.summary == expected)
            #expect(plan.strokeCount(of: 1) == 1)
            #expect(plan.strokeCount(of: 5) == 1)
            #expect(plan.strokeCount(of: 6) == nil)
            #expect(plan.strokeHeader(of: 5, at: 0)?.surfaceOrigin == Point(x: 40, y: 4))
            #expect(plan.point(of: 5, stroke: 0, at: 0) == Point(x: 40, y: 4))
            #expect(plan.point(of: 5, stroke: 0, at: 1) == Point(x: 45, y: 10))
            #expect(plan.point(of: 5, stroke: 0, at: 2) == nil)
            #expect(
                plan.subpath(of: 5, stroke: 0, at: 0)
                    == SubpathRange(firstPoint: 0, pointCount: 2))
            plan.reset()
            #expect(planRegion.allSatisfy { $0 == 0 })
        }
    }
}

@Test func staticNRFDrawingPlanRejectsIncompleteOrCorruptPublication() {
    let limits = GeneratedSignalAnalyzerPresets.nrf52840Static().runtimeLimits.drawing
    var bytes = [UInt8](repeating: 0, count: 13_536)
    bytes.withUnsafeMutableBytes { region in
        var plan = StaticSignalAnalyzerNRFDrawingPlanStorage(
            region: region, capacity: limits
        )!
        #expect({ plan.acquire() }())
        #expect({ plan.beginCanvas(identity: 1, origin: Point(x: 0, y: 0)) }())
        #expect({ !plan.beginCanvas(identity: 2, origin: Point(x: 0, y: 0)) }())
        #expect({ plan.endCanvas() }())
        #expect({ !plan.beginCanvas(identity: 1, origin: Point(x: 0, y: 0)) }())
        #expect(
            { plan.seal(canvasOccurrenceCount: 1) }()
                == .failure(.invariantViolation))
        #expect(plan.strokeCount(of: 1) == nil)
        plan.discard()
        #expect(region.allSatisfy { $0 == 0 })
    }
}
