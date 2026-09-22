import GiftUI
import GiftUIRenderCore
import Testing

@testable import SignalAnalyzerTargetHost

@Test func staticNRFDrawingPlanRecordsRoundTripAtEveryLastSlot() {
    let codec = StaticSignalAnalyzerNRFDrawingPlanRecords.self
    #expect(codec.regionByteCount == 13_536)
    #expect(codec.usedEnd == 7_248)
    var bytes = [UInt8](repeating: 0, count: codec.regionByteCount)
    bytes.withUnsafeMutableBytes { region in
        let canvas = StaticSignalAnalyzerNRFPlanCanvasRecord(
            identity: 0xAF12, firstStroke: 4, strokeCount: 1
        )
        #expect(codec.stageCanvas(canvas, at: 4, in: region))
        #expect(codec.canvas(at: 4, in: region) == canvas)
        #expect(!codec.stageCanvas(canvas, at: 4, in: region))
        #expect(!codec.stageCanvas(canvas, at: 5, in: region))

        let clip = Rect(
            origin: Point(x: -20, y: 5), size: Size(width: 400, height: 280)!
        )!
        let header = StraightLineStrokeHeader(
            color: Color(red: 12, green: 34, blue: 56),
            lineWidth: 1, lineCap: .round, lineJoin: .round,
            surfaceOrigin: Point(x: 30, y: -7), inheritedClip: clip,
            pointCount: 2, subpathCount: 1
        )
        let stroke = StaticSignalAnalyzerNRFPlanStrokeRecord(
            canvas: canvas.identity, firstPoint: 830, firstSubpath: 15,
            header: header
        )
        #expect(codec.stageStroke(stroke, at: 4, in: region))
        #expect(codec.stroke(at: 4, in: region) == stroke)
        #expect(!codec.stageStroke(stroke, at: 4, in: region))
        #expect(!codec.stageStroke(stroke, at: 5, in: region))

        let origin = Point(x: 0, y: 0)
        let end = Point(x: Int32.max, y: Int32.min)
        #expect(codec.stagePoint(origin, at: 830, in: region))
        #expect(codec.stagePoint(end, at: 831, in: region))
        #expect(codec.point(at: 830, in: region) == origin)
        #expect(codec.point(at: 831, in: region) == end)
        #expect(!codec.stagePoint(origin, at: 830, in: region))
        #expect(!codec.stagePoint(end, at: 832, in: region))
        #expect(codec.point(at: 829, in: region) == nil)

        let subpath = SubpathRange(firstPoint: 0, pointCount: 2)!
        #expect(codec.stageSubpath(subpath, at: 15, in: region))
        #expect(codec.subpath(at: 15, in: region) == subpath)
        #expect(!codec.stageSubpath(subpath, at: 15, in: region))
        #expect(!codec.stageSubpath(subpath, at: 16, in: region))
        #expect(region[codec.usedEnd ..< codec.regionByteCount].allSatisfy { $0 == 0 })
    }
}

@Test func staticNRFDrawingPlanRecordsRejectWrongRegionAndCorruptStroke() {
    let codec = StaticSignalAnalyzerNRFDrawingPlanRecords.self
    var short = [UInt8](repeating: 0, count: codec.regionByteCount - 1)
    short.withUnsafeMutableBytes { region in
        #expect(!codec.stagePoint(Point(x: 1, y: 2), at: 0, in: region))
        #expect(codec.point(at: 0, in: region) == nil)
    }
    var bytes = [UInt8](repeating: 0, count: codec.regionByteCount)
    bytes.withUnsafeMutableBytes { region in
        let header = StraightLineStrokeHeader(
            color: Color(red: 1, green: 2, blue: 3),
            lineWidth: 1, lineCap: .butt, lineJoin: .miter,
            surfaceOrigin: Point(x: 0, y: 0),
            inheritedClip: Rect(
                origin: Point(x: 0, y: 0),
                size: Size(width: 480, height: 320)!
            )!,
            pointCount: 0, subpathCount: 0
        )
        let stroke = StaticSignalAnalyzerNRFPlanStrokeRecord(
            canvas: 1, firstPoint: 0, firstSubpath: 0, header: header
        )
        #expect(codec.stageStroke(stroke, at: 0, in: region))
        region[codec.strokeOffset + 9] = 255
        #expect(codec.stroke(at: 0, in: region) == nil)
        region[codec.strokeOffset + 9] = LineCap.butt.rawValue
        region[codec.strokeOffset + 44] = 1
        #expect(codec.stroke(at: 0, in: region) == nil)
    }
}
