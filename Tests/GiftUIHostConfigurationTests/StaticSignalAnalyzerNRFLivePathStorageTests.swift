import GiftUI
import GiftUIDrawing
import Testing

@testable import SignalAnalyzerTargetHost

@Test func staticNRFLivePathUsesExactFixedRegionAndScopedBuilderSemantics() throws {
    var bytes = [UInt8](repeating: 0, count: 3_280)
    try bytes.withUnsafeMutableBytes { region in
        let storage = StaticSignalAnalyzerNRFLivePathStorage(region: region)!
        var path = LivePathBuilder(storage: storage)
        try path.move(to: Point(x: -10, y: 20))
        try path.move(to: Point(x: 3, y: 4))
        #expect(path.storage.pointCount == 1)
        #expect(path.storage.point(at: 0) == Point(x: 3, y: 4))
        try path.addLine(to: Point(x: 30, y: 40))
        try path.move(to: Point(x: -5, y: 8))
        try path.addLine(to: Point(x: 9, y: -12))
        #expect(path.storage.pointCount == 4)
        #expect(path.storage.subpathCount == 2)
        #expect(path.storage.subpath(at: 0)?.firstPoint == 0)
        #expect(path.storage.subpath(at: 0)?.pointCount == 2)
        #expect(path.storage.subpath(at: 1)?.firstPoint == 2)
        #expect(path.storage.subpath(at: 1)?.pointCount == 2)
        #expect(path.storage.point(at: 3) == Point(x: 9, y: -12))
        #expect(path.storage.point(at: 4) == nil)
        path.reset()
        #expect(path.storage.pointCount == 0)
        #expect(path.storage.subpathCount == 0)
        #expect(region.allSatisfy { $0 == 0 })
    }
}

@Test func staticNRFLivePathRefusesFirstExcessPointWithoutChangingStoredPrefix() throws {
    var bytes = [UInt8](repeating: 0, count: 3_280)
    try bytes.withUnsafeMutableBytes { region in
        let storage = StaticSignalAnalyzerNRFLivePathStorage(region: region)!
        var path = LivePathBuilder(storage: storage)
        try path.move(to: Point(x: 0, y: 0))
        for index in 1 ..< 202 {
            try path.addLine(to: Point(x: Int32(index), y: -Int32(index)))
        }
        #expect(path.storage.pointCount == 202)
        #expect(path.storage.point(at: 201) == Point(x: 201, y: -201))
        #expect(throws: DrawingError.capacityExhausted) {
            try path.addLine(to: Point(x: 202, y: -202))
        }
        #expect(path.storage.pointCount == 202)
        #expect(path.storage.point(at: 201) == Point(x: 201, y: -201))
    }
}

@Test func staticNRFLivePathRejectsWrongRegionAndMalformedMutation() {
    var short = [UInt8](repeating: 0, count: 3_279)
    short.withUnsafeMutableBytes { region in
        #expect(StaticSignalAnalyzerNRFLivePathStorage(region: region) == nil)
    }
    var bytes = [UInt8](repeating: 0, count: 3_280)
    bytes.withUnsafeMutableBytes { region in
        var storage = StaticSignalAnalyzerNRFLivePathStorage(region: region)!
        #expect({ !storage.appendLine(to: Point(x: 1, y: 1)) }())
        #expect({ !storage.startNextSubpath(at: Point(x: 1, y: 1)) }())
        #expect({ storage.startFirstSubpath(at: Point(x: 2, y: 2)) }())
        #expect({ !storage.startFirstSubpath(at: Point(x: 3, y: 3)) }())
        #expect({ !storage.startNextSubpath(at: Point(x: 4, y: 4)) }())
    }
}
