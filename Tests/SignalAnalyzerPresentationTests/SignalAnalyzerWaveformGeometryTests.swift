import GiftUI
import SignalAnalyzerDomain
import SignalAnalyzerPresentation
import Testing

@Suite("Signal Analyzer waveform geometry")
struct SignalAnalyzerWaveformGeometryTests {
    @Test("ruler formats lower midpoint and upper bounds with two fractional digits")
    func rulerLabels() {
        let labels = SignalAnalyzerRulerLabels(
            visibleRange: Duration.milliseconds(15_300) ..< .milliseconds(17_300)
        )

        #expect(waveformText(labels.lowerBound) == "15.30 s")
        #expect(waveformText(labels.midpoint) == "16.30 s")
        #expect(waveformText(labels.upperBound) == "17.30 s")
    }

    @Test("trace includes lower-bound state and upper-bound transition exactly")
    func traceBoundaries() {
        let channel = SignalChannelID(rawValue: 1)
        let capture = SignalCapture(
            transitions: [
                SignalTransition(channelID: channel, timestamp: .milliseconds(100), level: .high),
                SignalTransition(channelID: channel, timestamp: .milliseconds(150), level: .low),
                SignalTransition(channelID: channel, timestamp: .milliseconds(200), level: .high),
                SignalTransition(channelID: channel, timestamp: .milliseconds(250), level: .low),
            ],
            duration: .milliseconds(250)
        )!
        let range = Duration.milliseconds(100) ..< .milliseconds(200)

        #expect(
            SignalAnalyzerWaveformGeometry.startingLevel(
                capture: capture,
                channelID: channel,
                visibleLowerBound: range.lowerBound
            ) == .high
        )
        #expect(
            SignalAnalyzerWaveformGeometry.tracePointCount(
                capture: capture,
                channelID: channel,
                visibleRange: range
            ) == 6
        )
        #expect(
            SignalAnalyzerWaveformGeometry.x(
                for: .milliseconds(150),
                visibleRange: range,
                width: 100
            ) == 50
        )
        #expect(
            SignalAnalyzerWaveformGeometry.x(
                for: .milliseconds(200),
                visibleRange: range,
                width: 100
            ) == 100
        )
        #expect(capture.currentLevel(for: channel) == .low)
    }

    @Test("grid and trace workload matches the approved preset inputs")
    func workload() {
        #expect(SignalAnalyzerWaveformGeometry.canvasOccurrenceCount == 5)
        #expect(SignalAnalyzerWaveformGeometry.strokeCount == 5)
        #expect(SignalAnalyzerWaveformGeometry.gridSubpathCount == 12)
        #expect(SignalAnalyzerWaveformGeometry.gridPointCount == 24)
        #expect(SignalAnalyzerWaveformGeometry.maximumLiveTracePointCount == 202)
        #expect(SignalAnalyzerWaveformGeometry.snapshotPointCount == 832)
        #expect(SignalAnalyzerWaveformGeometry.snapshotSubpathCount == 16)
    }

    @Test("grid emits twelve two-point subpaths in one stroke")
    func gridOperations() throws {
        var probe = WaveformDrawingProbe()
        try invoke(size: Size(width: 100, height: 40)!, probe: &probe) {
            (context, size) throws(DrawingError) in
            try drawSignalAnalyzerGrid(context: &context, size: size)
        }

        #expect(probe.moveCount == 12)
        #expect(probe.points.count == 24)
        #expect(probe.strokeCount == 1)
        #expect(probe.points.first == Point(x: 0, y: 0))
        #expect(probe.points.last == Point(x: 100, y: 20))
    }

    @Test("trace streams exact boundary points and one stroke")
    func traceOperations() throws {
        let channel = SignalChannelID(rawValue: 1)
        let capture = SignalCapture(
            transitions: [
                SignalTransition(channelID: channel, timestamp: .milliseconds(100), level: .high),
                SignalTransition(channelID: channel, timestamp: .milliseconds(150), level: .low),
                SignalTransition(channelID: channel, timestamp: .milliseconds(200), level: .high),
            ],
            duration: .milliseconds(200)
        )!
        var probe = WaveformDrawingProbe()
        try invoke(size: Size(width: 100, height: 8)!, probe: &probe) {
            (context, size) throws(DrawingError) in
            try drawSignalAnalyzerTrace(
                context: &context,
                size: size,
                channelID: channel,
                capture: capture,
                visibleRange: Duration.milliseconds(100) ..< .milliseconds(200)
            )
        }

        #expect(
            probe.points == [
                Point(x: 0, y: 2),
                Point(x: 50, y: 2),
                Point(x: 50, y: 6),
                Point(x: 100, y: 6),
                Point(x: 100, y: 2),
                Point(x: 100, y: 2),
            ])
        #expect(probe.moveCount == 1)
        #expect(probe.strokeCount == 1)
    }

    @Test("empty trimmed and accepted-maximum traces stay within exact bounds")
    func boundedTraceCases() throws {
        let channel = SignalChannelID(rawValue: 1)
        var emptyProbe = WaveformDrawingProbe()
        try invoke(size: Size(width: 100, height: 8)!, probe: &emptyProbe) {
            (context, size) throws(DrawingError) in
            try drawSignalAnalyzerTrace(
                context: &context,
                size: size,
                channelID: channel,
                capture: .empty(),
                visibleRange: .zero ..< .seconds(2)
            )
        }
        #expect(emptyProbe.points == [Point(x: 0, y: 6), Point(x: 100, y: 6)])

        let trimmed = SignalCapture(
            transitions: [
                SignalTransition(channelID: channel, timestamp: .seconds(11), level: .low)
            ],
            duration: .seconds(11),
            retainedLowerBound: .seconds(10),
            baselineLevels: SignalChannelLevels(
                ch1: .high,
                ch2: .low,
                ch3: .low,
                ch4: .low
            )
        )!
        #expect(
            SignalAnalyzerWaveformGeometry.startingLevel(
                capture: trimmed,
                channelID: channel,
                visibleLowerBound: .seconds(10)
            ) == .high
        )

        let transitions = (1 ... 100).map { index in
            SignalTransition(
                channelID: channel,
                timestamp: .milliseconds(index * 50),
                level: index.isMultiple(of: 2) ? .low : .high
            )
        }
        let maximum = SignalCapture(transitions: transitions, duration: .seconds(5))!
        var maximumProbe = WaveformDrawingProbe()
        try invoke(size: Size(width: 100, height: 8)!, probe: &maximumProbe) {
            (context, size) throws(DrawingError) in
            try drawSignalAnalyzerTrace(
                context: &context,
                size: size,
                channelID: channel,
                capture: maximum,
                visibleRange: .zero ..< .seconds(5)
            )
        }
        #expect(maximumProbe.points.count == 202)
        #expect(maximumProbe.strokeCount == 1)
    }
}

private func waveformText(_ text: BoundedText) -> String {
    text.withUTF8 { String(decoding: $0, as: UTF8.self) }
}

private struct WaveformDrawingProbe {
    var points: [Point] = []
    var moveCount = 0
    var strokeCount = 0
}

private let waveformDrawingOperations = _GiftUIDrawingOperations(
    beginPath: waveformBeginPath,
    endPath: waveformEndPath,
    movePath: waveformMovePath,
    addLineToPath: waveformAddLine,
    strokePath: waveformStrokePath
)

private func invoke(
    size: Size,
    probe: inout WaveformDrawingProbe,
    body: (inout GraphicsContext, Size) throws(DrawingError) -> Void
) throws {
    try withUnsafeMutablePointer(to: &probe) { pointer in
        var context = GraphicsContext(
            storage: UnsafeMutableRawPointer(pointer),
            generation: 1,
            operations: waveformDrawingOperations
        )
        try body(&context, size)
    }
}

private func waveformProbe(
    _ storage: UnsafeMutableRawPointer
) -> UnsafeMutablePointer<WaveformDrawingProbe> {
    storage.assumingMemoryBound(to: WaveformDrawingProbe.self)
}

private func waveformBeginPath(
    _ storage: UnsafeMutableRawPointer,
    _ contextGeneration: UInt32,
    _ pathGeneration: UnsafeMutablePointer<UInt32>
) -> UInt8 {
    _ = storage
    guard contextGeneration == 1 else { return _GiftUIDrawingStatus.invalidScope.rawValue }
    pathGeneration.pointee = 1
    return _GiftUIDrawingStatus.success.rawValue
}

private func waveformEndPath(
    _ storage: UnsafeMutableRawPointer,
    _ contextGeneration: UInt32,
    _ pathGeneration: UInt32
) -> UInt8 {
    _ = storage
    guard contextGeneration == 1, pathGeneration == 1 else {
        return _GiftUIDrawingStatus.invalidScope.rawValue
    }
    return _GiftUIDrawingStatus.success.rawValue
}

private func waveformMovePath(
    _ storage: UnsafeMutableRawPointer,
    _ contextGeneration: UInt32,
    _ pathGeneration: UInt32,
    _ x: GeometryScalar,
    _ y: GeometryScalar
) -> UInt8 {
    guard contextGeneration == 1, pathGeneration == 1 else {
        return _GiftUIDrawingStatus.invalidScope.rawValue
    }
    waveformProbe(storage).pointee.moveCount += 1
    waveformProbe(storage).pointee.points.append(Point(x: x, y: y))
    return _GiftUIDrawingStatus.success.rawValue
}

private func waveformAddLine(
    _ storage: UnsafeMutableRawPointer,
    _ contextGeneration: UInt32,
    _ pathGeneration: UInt32,
    _ x: GeometryScalar,
    _ y: GeometryScalar
) -> UInt8 {
    guard contextGeneration == 1, pathGeneration == 1 else {
        return _GiftUIDrawingStatus.invalidScope.rawValue
    }
    waveformProbe(storage).pointee.points.append(Point(x: x, y: y))
    return _GiftUIDrawingStatus.success.rawValue
}

private func waveformStrokePath(
    _ storage: UnsafeMutableRawPointer,
    _ contextGeneration: UInt32,
    _ pathGeneration: UInt32,
    _ red: UInt8,
    _ green: UInt8,
    _ blue: UInt8,
    _ lineWidth: GeometryScalar,
    _ lineCap: UInt8,
    _ lineJoin: UInt8
) -> UInt8 {
    _ = red
    _ = green
    _ = blue
    _ = lineWidth
    _ = lineCap
    _ = lineJoin
    guard contextGeneration == 1, pathGeneration == 1 else {
        return _GiftUIDrawingStatus.invalidScope.rawValue
    }
    waveformProbe(storage).pointee.strokeCount += 1
    return _GiftUIDrawingStatus.success.rawValue
}
