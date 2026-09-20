import GiftUI
import GiftUIDrawing
import GiftUIRuntimeStatic
import SignalAnalyzerDomain
import SignalAnalyzerPresentation
import SignalAnalyzerTargetHost
import Testing

@Test func staticNRFCanvasTableHasExactGeneratedLayout() {
    let table = StaticSignalAnalyzerNRFCanvasCallableTable()

    #expect(MemoryLayout<StaticSignalAnalyzerNRFGridCanvasCapture>.size == 0)
    #expect(MemoryLayout<StaticSignalAnalyzerNRFTraceCanvasCapture>.size == 32)
    #expect(MemoryLayout<StaticSignalAnalyzerNRFCanvasCaptureStorage>.size == 32)
    #expect(table.callableCaseCount == 2)
    #expect(table.captureByteCount(for: 0) == nil)
    #expect(table.captureByteCount(for: 1) == 0)
    #expect(table.captureByteCount(for: 2) == 32)
    #expect(table.captureByteCount(for: 3) == nil)
}

@Test func staticNRFCanvasTableInvokesGridAndTraceCases() throws {
    var table = StaticSignalAnalyzerNRFCanvasCallableTable()
    var probe = StaticNRFCanvasProbe()

    try withStaticNRFCanvasContext(probe: &probe) { context throws(DrawingError) in
        let captures = StaticSignalAnalyzerNRFCanvasCaptureStorage(
            StaticSignalAnalyzerNRFGridCanvasCapture()
        )
        try table.invoke(
            id: 1,
            captures: captures,
            context: &context,
            size: Size(width: 100, height: 40)!
        )
    }
    #expect(probe.moveCount == 12)
    #expect(probe.points.count == 24)
    #expect(probe.strokeCount == 1)

    var model = staticNRFCanvasModel()
    try withUnsafePointer(to: &model) { location in
        let handle = StaticCanvasObservableModelHandle(hostOwnedLocation: location)
        let trace = StaticSignalAnalyzerNRFTraceCanvasCapture(
            model: handle,
            channelID: SignalChannelID(rawValue: 1),
            visibleRange: .zero ..< .seconds(2)
        )!
        let captures = StaticSignalAnalyzerNRFCanvasCaptureStorage(trace)
        try withStaticNRFCanvasContext(probe: &probe) { context throws(DrawingError) in
            try table.invoke(
                id: 2,
                captures: captures,
                context: &context,
                size: Size(width: 100, height: 8)!
            )
        }
    }
    #expect(probe.moveCount == 13)
    #expect(probe.points.count == 26)
    #expect(probe.strokeCount == 2)
}

@Test func staticNRFCanvasTableRejectsInvalidCaseAndCaptureInputs() throws {
    var table = StaticSignalAnalyzerNRFCanvasCallableTable()
    var probe = StaticNRFCanvasProbe()
    let grid = StaticSignalAnalyzerNRFCanvasCaptureStorage(
        StaticSignalAnalyzerNRFGridCanvasCapture()
    )

    try withStaticNRFCanvasContext(probe: &probe) { context in
        #expect(throws: DrawingError.invariantViolation) {
            try table.invoke(
                id: 3,
                captures: grid,
                context: &context,
                size: Size(width: 100, height: 8)!
            )
        }
    }

    var model = staticNRFCanvasModel()
    withUnsafePointer(to: &model) { location in
        let handle = StaticCanvasObservableModelHandle(hostOwnedLocation: location)
        #expect(
            StaticSignalAnalyzerNRFTraceCanvasCapture(
                model: handle,
                channelID: SignalChannelID(rawValue: 0),
                visibleRange: .zero ..< .seconds(2)
            ) == nil
        )
        #expect(
            StaticSignalAnalyzerNRFTraceCanvasCapture(
                model: handle,
                channelID: SignalChannelID(rawValue: 1),
                visibleRange: .zero ..< .nanoseconds(1)
            ) == nil
        )
    }
}

private final class StaticNRFCanvasRepository: SignalAcquisitionRepository {
    func startObservingCapture(sink: some SignalCaptureSink) {}
    func stopObservingCapture() {}
    func startObservingAcquisitionState(sink: some AcquisitionStateSink) {}
    func stopObservingAcquisitionState() {}
    func start() throws {}
    func stop() {}
    func clear() {}
}

private func staticNRFCanvasModel() -> SignalAnalyzerViewModel {
    let repository = StaticNRFCanvasRepository()
    return SignalAnalyzerViewModel(
        startAcquisition: StartSignalAcquisitionUseCase(repository: repository),
        stopAcquisition: StopSignalAcquisitionUseCase(repository: repository),
        clearCapture: ClearSignalCaptureUseCase(repository: repository)
    )
}

private struct StaticNRFCanvasProbe {
    var points: [Point] = []
    var moveCount = 0
    var strokeCount = 0
}

private let staticNRFCanvasOperations = _GiftUIDrawingOperations(
    beginPath: staticNRFCanvasBeginPath,
    endPath: staticNRFCanvasEndPath,
    movePath: staticNRFCanvasMovePath,
    addLineToPath: staticNRFCanvasAddLine,
    strokePath: staticNRFCanvasStrokePath
)

private func withStaticNRFCanvasContext(
    probe: inout StaticNRFCanvasProbe,
    _ body: (inout GraphicsContext) throws -> Void
) throws {
    try withUnsafeMutablePointer(to: &probe) { pointer in
        var context = GraphicsContext(
            storage: UnsafeMutableRawPointer(pointer),
            generation: 1,
            operations: staticNRFCanvasOperations
        )
        try body(&context)
    }
}

private func staticNRFCanvasProbe(
    _ storage: UnsafeMutableRawPointer
) -> UnsafeMutablePointer<StaticNRFCanvasProbe> {
    storage.assumingMemoryBound(to: StaticNRFCanvasProbe.self)
}

private func staticNRFCanvasBeginPath(
    _: UnsafeMutableRawPointer,
    _ contextGeneration: UInt32,
    _ pathGeneration: UnsafeMutablePointer<UInt32>
) -> UInt8 {
    guard contextGeneration == 1 else { return _GiftUIDrawingStatus.invalidScope.rawValue }
    pathGeneration.pointee = 1
    return _GiftUIDrawingStatus.success.rawValue
}

private func staticNRFCanvasEndPath(
    _: UnsafeMutableRawPointer,
    _ contextGeneration: UInt32,
    _ pathGeneration: UInt32
) -> UInt8 {
    guard contextGeneration == 1, pathGeneration == 1 else {
        return _GiftUIDrawingStatus.invalidScope.rawValue
    }
    return _GiftUIDrawingStatus.success.rawValue
}

private func staticNRFCanvasMovePath(
    _ storage: UnsafeMutableRawPointer,
    _ contextGeneration: UInt32,
    _ pathGeneration: UInt32,
    _ x: GeometryScalar,
    _ y: GeometryScalar
) -> UInt8 {
    guard contextGeneration == 1, pathGeneration == 1 else {
        return _GiftUIDrawingStatus.invalidScope.rawValue
    }
    staticNRFCanvasProbe(storage).pointee.moveCount += 1
    staticNRFCanvasProbe(storage).pointee.points.append(Point(x: x, y: y))
    return _GiftUIDrawingStatus.success.rawValue
}

private func staticNRFCanvasAddLine(
    _ storage: UnsafeMutableRawPointer,
    _ contextGeneration: UInt32,
    _ pathGeneration: UInt32,
    _ x: GeometryScalar,
    _ y: GeometryScalar
) -> UInt8 {
    guard contextGeneration == 1, pathGeneration == 1 else {
        return _GiftUIDrawingStatus.invalidScope.rawValue
    }
    staticNRFCanvasProbe(storage).pointee.points.append(Point(x: x, y: y))
    return _GiftUIDrawingStatus.success.rawValue
}

private func staticNRFCanvasStrokePath(
    _ storage: UnsafeMutableRawPointer,
    _ contextGeneration: UInt32,
    _ pathGeneration: UInt32,
    _: UInt8,
    _: UInt8,
    _: UInt8,
    _: GeometryScalar,
    _: UInt8,
    _: UInt8
) -> UInt8 {
    guard contextGeneration == 1, pathGeneration == 1 else {
        return _GiftUIDrawingStatus.invalidScope.rawValue
    }
    staticNRFCanvasProbe(storage).pointee.strokeCount += 1
    return _GiftUIDrawingStatus.success.rawValue
}
