import GiftUI
import GiftUIDrawing
import GiftUIRuntimeCore
import GiftUIRuntimeDynamic
import GiftUIRuntimeStatic
import Testing

#if GIFTUI_DYNAMIC_PROFILE
    private struct CanvasStorageTranscript: Equatable {
        let semanticOccurrences: UInt16
        let invocationCount: UInt16
        let pathPoints: UInt16
        let pathSubpaths: UInt16
        let planStrokes: UInt16
        let combinedRenderOperations: UInt16
        let failure: DrawingError?
        let releaseCount: UInt16
        let laterInvocationRejected: Bool
    }

    private struct CanvasTrace {
        var invocationCount = UInt16(0)
        var pathPoints = UInt16(0)
        var pathSubpaths = UInt16(0)
        var planStrokes = UInt16(0)
    }

    private let canvasTraceOperations = _GiftUIDrawingOperations(
        beginPath: { storage, _, pathGeneration in
            pathGeneration.pointee = 1
            let trace = storage.assumingMemoryBound(to: CanvasTrace.self)
            trace.pointee.invocationCount += 1
            trace.pointee.pathSubpaths += 1
            return _GiftUIDrawingStatus.success.rawValue
        },
        endPath: { _, _, _ in _GiftUIDrawingStatus.success.rawValue },
        movePath: { storage, _, _, _, _ in
            storage.assumingMemoryBound(to: CanvasTrace.self).pointee.pathPoints += 1
            return _GiftUIDrawingStatus.success.rawValue
        },
        addLineToPath: { storage, _, _, _, _ in
            storage.assumingMemoryBound(to: CanvasTrace.self).pointee.pathPoints += 1
            return _GiftUIDrawingStatus.success.rawValue
        },
        strokePath: { storage, _, _, _, _, _, _, _, _ in
            storage.assumingMemoryBound(to: CanvasTrace.self).pointee.planStrokes += 1
            return _GiftUIDrawingStatus.success.rawValue
        }
    )

    private enum FixtureCanvasIdentity: UInt8, Equatable, Sendable {
        case waveform = 1
    }

    private struct StaticCanvasCapture: Equatable, Sendable {
        let shouldFail: Bool
    }

    private struct StaticCanvasTable: StaticCanvasCallableTable {
        typealias CaptureStorage = StaticCanvasCapture

        let callableCaseCount = UInt16(1)

        func captureByteCount(for id: UInt16) -> UInt16? {
            id == 1 ? UInt16(MemoryLayout<StaticCanvasCapture>.size) : nil
        }

        mutating func invoke(
            id: UInt16,
            captures: borrowing StaticCanvasCapture,
            context: inout GraphicsContext,
            size: Size
        ) throws(DrawingError) {
            guard id == 1 else { throw .invariantViolation }
            try drawFixture(
                context: &context,
                size: size,
                shouldFail: captures.shouldFail
            )
        }
    }

    @Test(arguments: [false, true])
    func dynamicAndStaticCanvasStorageProduceEqualLifetimeTranscripts(
        shouldFail: Bool
    ) {
        let dynamic = dynamicCanvasTranscript(shouldFail: shouldFail)
        let `static` = staticCanvasTranscript(shouldFail: shouldFail)

        #expect(dynamic == `static`)
        #expect(dynamic.semanticOccurrences == 1)
        #expect(dynamic.invocationCount == 1)
        #expect(dynamic.pathPoints == 2)
        #expect(dynamic.pathSubpaths == 1)
        #expect(dynamic.planStrokes == 1)
        #expect(dynamic.combinedRenderOperations == 3)
        #expect(dynamic.failure == (shouldFail ? .invalidValue : nil))
        #expect(dynamic.releaseCount == 1)
        #expect(dynamic.laterInvocationRejected)
    }

    private func dynamicCanvasTranscript(shouldFail: Bool) -> CanvasStorageTranscript {
        let identity = DynamicStructuralIdentity(rawValue: 1)!
        var storage = DynamicCanvasCallableStorage<DynamicStructuralIdentity>(capacity: 1)
        let staged = storage.stage(
            identity: identity,
            canvas: Canvas { context, size throws(DrawingError) in
                try drawFixture(
                    context: &context,
                    size: size,
                    shouldFail: shouldFail
                )
            }
        )
        #expect(staged)
        var trace = CanvasTrace()
        let failure = invokeDynamic(
            storage: &storage,
            identity: identity,
            trace: &trace
        )
        storage.releaseCanvas(at: identity)
        let laterInvocationRejected =
            invokeDynamic(
                storage: &storage,
                identity: identity,
                trace: &trace
            ) == .invariantViolation
        let transcript = makeTranscript(
            trace: trace,
            failure: failure,
            releaseCount: storage.releaseCount,
            laterInvocationRejected: laterInvocationRejected
        )
        storage.discard()
        return transcript
    }

    private func staticCanvasTranscript(shouldFail: Bool) -> CanvasStorageTranscript {
        let capture = StaticCanvasCapture(shouldFail: shouldFail)
        var occurrence = StaticCanvasOccurrence(
            identity: FixtureCanvasIdentity.waveform,
            callableID: 1,
            declaredCaptureByteCount: UInt16(MemoryLayout<StaticCanvasCapture>.size),
            capture: capture,
            metadata: StaticCanvasMetadata()
        )!
        var table = StaticCanvasTable()
        var trace = CanvasTrace()
        let failure = invokeStatic(
            occurrence: &occurrence,
            table: &table,
            trace: &trace
        )
        let laterInvocationRejected =
            invokeStatic(
                occurrence: &occurrence,
                table: &table,
                trace: &trace
            ) == .invariantViolation
        return makeTranscript(
            trace: trace,
            failure: failure,
            releaseCount: UInt16(occurrence.releaseCount),
            laterInvocationRejected: laterInvocationRejected
        )
    }

    private struct StaticCanvasMetadata: RuntimeStaticCanvasAuditMetadata {
        let callableCaseCount = UInt16(1)
        let declaredEntryCount = UInt16(1)
        let maximumDeclaredID = UInt16(1)

        func coverageMultiplicity(for id: UInt16) -> UInt8 { id == 1 ? 1 : 0 }

        func captureByteCount(for id: UInt16) -> UInt16? {
            id == 1 ? UInt16(MemoryLayout<StaticCanvasCapture>.size) : nil
        }
    }

    private func invokeDynamic(
        storage: inout DynamicCanvasCallableStorage<DynamicStructuralIdentity>,
        identity: DynamicStructuralIdentity,
        trace: inout CanvasTrace
    ) -> DrawingError? {
        withCanvasContext(trace: &trace) { context -> DrawingError? in
            do {
                try storage.invokeCanvas(
                    at: identity,
                    context: &context,
                    size: Size(width: 8, height: 4)!
                )
                return nil
            } catch {
                return error as? DrawingError ?? .invariantViolation
            }
        }
    }

    private func invokeStatic(
        occurrence: inout StaticCanvasOccurrence<FixtureCanvasIdentity, StaticCanvasCapture>,
        table: inout StaticCanvasTable,
        trace: inout CanvasTrace
    ) -> DrawingError? {
        withCanvasContext(trace: &trace) { context -> DrawingError? in
            do {
                try occurrence.invoke(
                    table: &table,
                    context: &context,
                    size: Size(width: 8, height: 4)!
                )
                return nil
            } catch {
                return error as? DrawingError ?? .invariantViolation
            }
        }
    }

    private func withCanvasContext<Result>(
        trace: inout CanvasTrace,
        body: (inout GraphicsContext) -> Result
    ) -> Result {
        withUnsafeMutablePointer(to: &trace) { pointer in
            var context = GraphicsContext(
                storage: UnsafeMutableRawPointer(pointer),
                generation: 1,
                operations: canvasTraceOperations
            )
            return body(&context)
        }
    }

    private func drawFixture(
        context: inout GraphicsContext,
        size: Size,
        shouldFail: Bool
    ) throws(DrawingError) {
        try context.withPath { context, path throws(DrawingError) in
            try path.move(to: Point(x: 0, y: 0))
            try path.addLine(to: Point(x: size.width, y: size.height))
            try context.stroke(path, with: .color(.white), lineWidth: 1)
        }
        if shouldFail { throw .invalidValue }
    }

    private func makeTranscript(
        trace: CanvasTrace,
        failure: DrawingError?,
        releaseCount: UInt16,
        laterInvocationRejected: Bool
    ) -> CanvasStorageTranscript {
        CanvasStorageTranscript(
            semanticOccurrences: 1,
            invocationCount: trace.invocationCount,
            pathPoints: trace.pathPoints,
            pathSubpaths: trace.pathSubpaths,
            planStrokes: trace.planStrokes,
            combinedRenderOperations: 2 + trace.planStrokes,
            failure: failure,
            releaseCount: releaseCount,
            laterInvocationRejected: laterInvocationRejected
        )
    }
#endif
