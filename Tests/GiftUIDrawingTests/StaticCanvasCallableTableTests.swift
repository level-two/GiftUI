import GiftUI
import Testing

@testable import GiftUIDrawing

@Test
func generatedStaticCanvasTableHasCompleteDenseCasesAndGreatestUnionSize() {
    let table = GeneratedStaticCanvasCallableTable()
    #expect(table.callableCaseCount == 3)
    #expect(table.captureByteCount(for: 0) == nil)
    #expect(table.captureByteCount(for: 1) == 8)
    #expect(table.captureByteCount(for: 2) == 12)
    #expect(table.captureByteCount(for: 3) == 0)
    #expect(table.captureByteCount(for: 4) == nil)

    #expect(MemoryLayout<GeneratedStaticCanvasCapture1>.size == 8)
    #expect(MemoryLayout<GeneratedStaticCanvasCapture2>.size == 12)
    #expect(MemoryLayout<GeneratedStaticCanvasCapture3>.size == 0)
    #expect(MemoryLayout<GeneratedStaticCanvasCaptureStorage>.size == 12)
    #expect(
        MemoryLayout<GeneratedStaticCanvasCaptureStorage>.size
            == max(
                MemoryLayout<GeneratedStaticCanvasCapture1>.size,
                MemoryLayout<GeneratedStaticCanvasCapture2>.size,
                MemoryLayout<GeneratedStaticCanvasCapture3>.size
            )
    )
}

@Test
func generatedStaticCanvasDispatchPreservesCaseOrderValuesAndDistinctOccurrences() {
    var table = GeneratedStaticCanvasCallableTable()
    var probe = GeneratedCanvasDrawingProbe()
    var grid = GeneratedStaticCanvasOccurrence(
        id: 1,
        captures: GeneratedStaticCanvasCaptureStorage(
            GeneratedStaticCanvasCapture1(color: .gray, lineWidth: 1)
        )
    )
    var blueTrace = GeneratedStaticCanvasOccurrence(
        id: 2,
        captures: GeneratedStaticCanvasCaptureStorage(
            GeneratedStaticCanvasCapture2(
                color: .blue,
                verticalOffset: 8,
                highLevel: 2
            )
        )
    )
    var greenTrace = GeneratedStaticCanvasOccurrence(
        id: 2,
        captures: GeneratedStaticCanvasCaptureStorage(
            GeneratedStaticCanvasCapture2(
                color: .green,
                verticalOffset: 16,
                highLevel: 10
            )
        )
    )
    var marker = GeneratedStaticCanvasOccurrence(
        id: 3,
        captures: GeneratedStaticCanvasCaptureStorage(
            GeneratedStaticCanvasCapture3()
        )
    )

    let error = captureGeneratedDrawingError { () throws(DrawingError) in
        try withGeneratedCanvasContext(probe: &probe) {
            (context: inout GraphicsContext) throws(DrawingError) in
            let size = Size(width: 40, height: 24)!
            try grid.invoke(table: &table, context: &context, size: size)
            try blueTrace.invoke(table: &table, context: &context, size: size)
            try greenTrace.invoke(table: &table, context: &context, size: size)
            try marker.invoke(table: &table, context: &context, size: size)
        }
    }

    #expect(error == nil)
    #expect(
        probe.strokes == [
            GeneratedCanvasStroke(
                color: .gray,
                lineWidth: 1,
                points: [Point(x: 0, y: 0), Point(x: 40, y: 0)]
            ),
            GeneratedCanvasStroke(
                color: .blue,
                lineWidth: 1,
                points: [Point(x: 0, y: 8), Point(x: 40, y: 2)]
            ),
            GeneratedCanvasStroke(
                color: .green,
                lineWidth: 1,
                points: [Point(x: 0, y: 16), Point(x: 40, y: 10)]
            ),
            GeneratedCanvasStroke(
                color: .white,
                lineWidth: 1,
                points: [Point(x: 40, y: 0), Point(x: 40, y: 24)]
            ),
        ]
    )
    for occurrence in [grid, blueTrace, greenTrace, marker] {
        #expect(occurrence.releaseCount == 1)
        #expect(!occurrence.hasCaptures)
    }
}

@Test
func generatedStaticCanvasThrowDestroysCaptureAndCannotBeInvokedAgain() {
    var table = GeneratedStaticCanvasCallableTable()
    var probe = GeneratedCanvasDrawingProbe()
    var occurrence = GeneratedStaticCanvasOccurrence(
        id: 1,
        captures: GeneratedStaticCanvasCaptureStorage(
            GeneratedStaticCanvasCapture1(color: .red, lineWidth: 0)
        )
    )

    let firstError = captureGeneratedDrawingError { () throws(DrawingError) in
        try withGeneratedCanvasContext(probe: &probe) {
            (context: inout GraphicsContext) throws(DrawingError) in
            try occurrence.invoke(
                table: &table,
                context: &context,
                size: Size(width: 10, height: 10)!
            )
        }
    }
    #expect(firstError == .invalidValue)
    #expect(occurrence.releaseCount == 1)
    #expect(!occurrence.hasCaptures)
    #expect(probe.endPathCount == 1)
    #expect(probe.strokes.isEmpty)

    let secondError = captureGeneratedDrawingError { () throws(DrawingError) in
        try withGeneratedCanvasContext(probe: &probe) {
            (context: inout GraphicsContext) throws(DrawingError) in
            try occurrence.invoke(
                table: &table,
                context: &context,
                size: Size(width: 10, height: 10)!
            )
        }
    }
    #expect(secondError == .invalidScope)
    #expect(occurrence.releaseCount == 1)
}

private struct GeneratedStaticCanvasOccurrence {
    let id: UInt16
    private var captures: GeneratedStaticCanvasCaptureStorage?
    private(set) var releaseCount: UInt16 = 0

    init(id: UInt16, captures: GeneratedStaticCanvasCaptureStorage) {
        self.id = id
        self.captures = captures
    }

    var hasCaptures: Bool { captures != nil }

    mutating func invoke(
        table: inout GeneratedStaticCanvasCallableTable,
        context: inout GraphicsContext,
        size: Size
    ) throws(DrawingError) {
        guard let captures else { throw DrawingError.invalidScope }
        defer {
            self.captures = nil
            releaseCount += 1
        }
        try table.invoke(
            id: id,
            captures: captures,
            context: &context,
            size: size
        )
    }
}

private struct GeneratedCanvasStroke: Equatable {
    let color: Color
    let lineWidth: GeometryScalar
    let points: [Point]
}

private struct GeneratedCanvasDrawingProbe {
    var activePath = false
    var points: [Point] = []
    var strokes: [GeneratedCanvasStroke] = []
    var endPathCount: UInt16 = 0
}

private func withGeneratedCanvasContext<Result>(
    probe: inout GeneratedCanvasDrawingProbe,
    _ body: (inout GraphicsContext) throws(DrawingError) -> Result
) throws(DrawingError) -> Result {
    do {
        return try withUnsafeMutablePointer(to: &probe) { probePointer in
            var context = GraphicsContext(
                storage: UnsafeMutableRawPointer(probePointer),
                generation: 1,
                operations: generatedCanvasDrawingOperations
            )
            defer { context.invalidate() }
            return try body(&context)
        }
    } catch let error as DrawingError {
        throw error
    } catch {
        throw DrawingError.invariantViolation
    }
}

private let generatedCanvasDrawingOperations = _GiftUIDrawingOperations(
    beginPath: { storage, contextGeneration, pathGeneration in
        guard contextGeneration == 1 else {
            return _GiftUIDrawingStatus.invalidScope.rawValue
        }
        let probe = storage.assumingMemoryBound(
            to: GeneratedCanvasDrawingProbe.self
        )
        guard !probe.pointee.activePath else {
            return _GiftUIDrawingStatus.reentrancyViolation.rawValue
        }
        probe.pointee.activePath = true
        probe.pointee.points.removeAll(keepingCapacity: true)
        pathGeneration.pointee = 1
        return _GiftUIDrawingStatus.success.rawValue
    },
    endPath: { storage, contextGeneration, pathGeneration in
        let probe = storage.assumingMemoryBound(
            to: GeneratedCanvasDrawingProbe.self
        )
        guard contextGeneration == 1, pathGeneration == 1,
            probe.pointee.activePath
        else { return _GiftUIDrawingStatus.invalidScope.rawValue }
        probe.pointee.activePath = false
        probe.pointee.endPathCount += 1
        return _GiftUIDrawingStatus.success.rawValue
    },
    movePath: { storage, contextGeneration, pathGeneration, x, y in
        generatedCanvasAppendPoint(
            storage: storage,
            contextGeneration: contextGeneration,
            pathGeneration: pathGeneration,
            point: Point(x: x, y: y),
            replaces: true
        )
    },
    addLineToPath: { storage, contextGeneration, pathGeneration, x, y in
        generatedCanvasAppendPoint(
            storage: storage,
            contextGeneration: contextGeneration,
            pathGeneration: pathGeneration,
            point: Point(x: x, y: y),
            replaces: false
        )
    },
    strokePath: {
        storage,
        contextGeneration,
        pathGeneration,
        red,
        green,
        blue,
        lineWidth,
        _,
        _ in
        let probe = storage.assumingMemoryBound(
            to: GeneratedCanvasDrawingProbe.self
        )
        guard contextGeneration == 1, pathGeneration == 1,
            probe.pointee.activePath
        else { return _GiftUIDrawingStatus.invalidScope.rawValue }
        probe.pointee.strokes.append(
            GeneratedCanvasStroke(
                color: Color(red: red, green: green, blue: blue),
                lineWidth: lineWidth,
                points: probe.pointee.points
            )
        )
        return _GiftUIDrawingStatus.success.rawValue
    }
)

private func generatedCanvasAppendPoint(
    storage: UnsafeMutableRawPointer,
    contextGeneration: UInt32,
    pathGeneration: UInt32,
    point: Point,
    replaces: Bool
) -> UInt8 {
    let probe = storage.assumingMemoryBound(to: GeneratedCanvasDrawingProbe.self)
    guard contextGeneration == 1, pathGeneration == 1,
        probe.pointee.activePath
    else { return _GiftUIDrawingStatus.invalidScope.rawValue }
    if replaces {
        probe.pointee.points = [point]
    } else {
        probe.pointee.points.append(point)
    }
    return _GiftUIDrawingStatus.success.rawValue
}

private func captureGeneratedDrawingError(
    _ body: () throws(DrawingError) -> Void
) -> DrawingError? {
    do {
        try body()
        return nil
    } catch {
        return error
    }
}
