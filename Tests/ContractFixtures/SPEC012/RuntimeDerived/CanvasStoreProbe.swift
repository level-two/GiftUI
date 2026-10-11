import GiftUI
import GiftUIDrawing
import GiftUIExecution
import GiftUILayout
import GiftUIRenderCore
import GiftUIObservableState
import GiftUIRuntimeCore
import GiftUIRuntimeStatic
#if !hasFeature(Embedded)
import GiftUIRuntimeDynamic
#endif
import CounterSchema
import CounterCanvas
import CounterCanvasTable

package struct CanvasTrace {
    var reads: InlineArray<4, UInt8> = .init(repeating: 0)
    var endpoints: InlineArray<4, Point> = .init(repeating: Point(x: 0, y: 0))
    var readCount = 0
    var contexts = 0
    var releases = 0
    var strokes = 0
    var destroys = 0
    var current: UInt16 = 0
    var failure: UInt8 = 0
}
package struct CanvasModel: ~Copyable {
    let value: UInt8
    let trace: UnsafeMutablePointer<CanvasTrace>
    deinit { trace.pointee.destroys += 1 }
}
package enum CanvasDomain: CounterReadDomain {
    package typealias Slot = ObservableModelReadSlot<CanvasModel>
    package static func bind(_ key: _GiftUIModelKey<CounterModelSchema>, slots: Span<Slot>) throws(_GiftUIAccessFailure) -> Int {
        try slots[0].ownership.pointee.bind(key, schema: 1)
    }
    package static func CounterRead_value(at index: Int, slots: Span<Slot>) -> UInt8 {
        switch slots[index].model.pointee {
        case .some(let model):
            let trace = model.trace
            trace.pointee.reads[trace.pointee.readCount] = model.value
            trace.pointee.readCount += 1
            return model.value
        case .none: preconditionFailure("binding admitted absent model")
        }
    }
}
package typealias CanvasTable = CounterSchemaCanvasTable<CanvasDomain>

private struct CanvasLayout: ResolvedRenderLayoutView {
    var malformed = false
    var zeroSize = false
    var rootIdentity: UInt16 { 1 }
    var layoutScopeCount: UInt16 { 3 }
    var renderSnapshotVersion: UInt32 { 1 }
    var rootBounds: Rect { Rect(origin: Point(x: 0, y: 0), size: Size(width: 100, height: 100)!)! }
    func layoutIdentity(at ordinal: UInt16) -> UInt16? { ordinal < 3 ? ordinal + 1 : nil }
    func layoutOrdinal(of identity: UInt16) -> UInt16? { malformed ? 2 : identity - 1 }
    func bounds(of identity: UInt16) -> Rect? {
        Rect(origin: Point(x: GeometryScalar(identity * 10), y: 20),
             size: Size(width: zeroSize ? 0 : GeometryScalar(identity * 5), height: zeroSize ? 0 : GeometryScalar(identity * 7))!)
    }
    func clip(of identity: UInt16) -> Rect? { rootBounds }
    func textLineCount(of identity: UInt16) -> UInt16? { 0 }
    func textLine(of identity: UInt16, at index: UInt16) -> ResolvedRenderTextLine? { nil }
    func glyph(of identity: UInt16, at index: UInt16) -> ResolvedRenderGlyph? { nil }
}
private let canvasLimits = DrawingLimits(maximumLineWidth: 4, maximumCanvasOccurrences: 3,
    maximumLivePathPoints: 4, maximumLivePathSubpaths: 2, maximumPlanStrokes: 3,
    maximumPlanPoints: 12, maximumPlanSubpaths: 6, maximumNormalizedStrokeOperations: 3)!
private struct CanvasWorkspace: DrawingPlanConstructionWorkspace {
    let trace: UnsafeMutablePointer<CanvasTrace>
    let capacity = canvasLimits
    var isActive = false
    var refuseAcquire = false
    var failSeal = false
    var discardCount = 0
    var resetCount = 0
    var summary = DrawingPlanSummary(canvasOccurrenceCount: 0, strokeCount: 0, pointCount: 0, subpathCount: 0, normalizedStrokeOperationCount: 0)
    mutating func acquire() -> Bool { if refuseAcquire { return false }; isActive = true; return true }
    mutating func discard() { discardCount += 1 }
    mutating func reset() { resetCount += 1; isActive = false }
    mutating func seal(canvasOccurrenceCount: UInt16) -> DrawingPlanResult {
        if failSeal { return .failure(.capacityExhausted) }
        summary = DrawingPlanSummary(canvasOccurrenceCount: canvasOccurrenceCount, strokeCount: UInt16(trace.pointee.strokes), pointCount: UInt16(trace.pointee.strokes * 2), subpathCount: UInt16(trace.pointee.strokes), normalizedStrokeOperationCount: UInt16(trace.pointee.strokes))
        isActive = false
        return .success(summary)
    }
    func strokeCount(of canvas: UInt16) -> UInt16? { nil }
    func strokeHeader(of canvas: UInt16, at index: UInt16) -> StraightLineStrokeHeader? { nil }
    func point(of canvas: UInt16, stroke: UInt16, at index: UInt16) -> Point? { nil }
    func subpath(of canvas: UInt16, stroke: UInt16, at index: UInt16) -> SubpathRange? { nil }
    mutating func withCanvasContext<Result>(identity: UInt16, surfaceOrigin: Point, inheritedClip: Rect,
        _ body: (inout GraphicsContext) throws(DrawingError) -> Result) throws(DrawingError) -> Result {
        precondition(surfaceOrigin == Point(x: GeometryScalar(identity * 10), y: 20))
        precondition(inheritedClip == Rect(origin: Point(x: 0, y: 0), size: Size(width: 100, height: 100)!)!)
        trace.pointee.current = identity
        trace.pointee.contexts += 1
        let operations = _GiftUIDrawingOperations(
            beginPath: { pointer, _, generation in
                let t = pointer.assumingMemoryBound(to: CanvasTrace.self)
                if t.pointee.failure == 2 && t.pointee.current == 2 { return _GiftUIDrawingStatus.invalidValue.rawValue }
                generation.pointee = 1; return 0
            }, endPath: { _, _, _ in 0 }, movePath: { _, _, _, _, _ in 0 },
            addLineToPath: { pointer, _, _, x, y in
                let t = pointer.assumingMemoryBound(to: CanvasTrace.self)
                t.pointee.endpoints[Int(t.pointee.current - 1)] = Point(x: x, y: y); return 0
            }, strokePath: { pointer, _, _, _, _, _, _, _, _ in
                let t = pointer.assumingMemoryBound(to: CanvasTrace.self)
                if t.pointee.failure == 3 && t.pointee.current == 2 { return _GiftUIDrawingStatus.capacityExhausted.rawValue }
                t.pointee.strokes += 1; return 0
            })
        var context = GraphicsContext(storage: UnsafeMutableRawPointer(trace), generation: 1, operations: operations)
        defer { context.invalidate() }
        return try body(&context)
    }
}

private func exerciseValues(_ values: borrowing CanvasStagedValues<UInt16, CanvasTable>,
                           scope: borrowing ObservableModelScope<CanvasModel, CounterModelSchema>,
                           keys: (_GiftUIModelKey<CounterModelSchema>, _GiftUIModelKey<CounterModelSchema>),
                           trace: UnsafeMutablePointer<CanvasTrace>, mode: UInt8) throws(DrawingError) -> UInt32 {
    var checks: UInt32 = 0
    func expect(_ condition: Bool) { checks += 1; precondition(condition) }
    let table = CanvasTable()
    if mode != 9 {
        for identity: UInt16 in 1 ... 3 {
            var key = identity == 2 ? keys.1 : keys.0
            if mode == 1 && identity == 2 {
                key = .init(ownerInstance: key._giftUIOwnerInstance,
                    allocationGeneration: key._giftUIAllocationGeneration + 99, slot: key._giftUISlot)
            }
            try values.stage(identity: identity,
                value: CanvasTable.payload(CounterTrace<CanvasDomain>(model: key, offset: GeometryScalar(identity)))!, table: table)
        }
    }
    expect(values.releaseCount == 0)
    expect(trace.pointee.readCount == 0)
    var source = ObservableCanvasInvocationSource(models: scope.borrowedScope(), values: values.borrowedValues(), table: table)
    var workspace = CanvasWorkspace(trace: trace)
    workspace.isActive = mode == 6
    workspace.refuseAcquire = mode == 7
    workspace.failSeal = mode == 8
    let context = ExecutionContext(cycle: RunCycleID(rawValue: 1), semanticRevision: nil, candidateFrame: nil, phase: mode == 5 ? .idle : .deriving)
    let result = CanvasPlanProducer.derive(source: &source, layout: CanvasLayout(malformed: mode == 4, zeroSize: mode == 10), executionContext: context, limits: canvasLimits, workspace: &workspace)
    switch mode {
    case 0, 10:
        guard case .success(let summary) = result else { preconditionFailure("success expected") }
        expect(summary.canvasOccurrenceCount == 3 && summary.strokeCount == 3)
        expect(trace.pointee.readCount == 3)
        expect(trace.pointee.reads[0] == 3 && trace.pointee.reads[1] == 7 && trace.pointee.reads[2] == 3)
        expect(trace.pointee.endpoints[0] == Point(x: mode == 10 ? 0 : 5, y: mode == 10 ? 0 : 7))
        expect(trace.pointee.endpoints[2] == Point(x: mode == 10 ? 0 : 15, y: mode == 10 ? 0 : 21))
        expect(values.releaseCount == 3)
    case 1:
        expect(result == .failure(.invalidModelAccess)); expect(trace.pointee.readCount == 1)
        expect(trace.pointee.contexts == 2 && values.releaseCount == 3)
    case 2, 3:
        expect(result == .failure(mode == 2 ? .invalidValue : .capacityExhausted))
        expect(trace.pointee.readCount == 2 && trace.pointee.contexts == 2 && values.releaseCount == 3)
    case 4:
        expect(result == .failure(.invariantViolation)); expect(trace.pointee.readCount == 0 && values.releaseCount == 3)
    case 5, 6, 7:
        expect(result == .failure(mode == 5 ? .invalidPhase : .reentrancyViolation))
        expect(trace.pointee.contexts == 0 && values.releaseCount == 0)
        // The adapter does not acquire on these exits; caller cleanup is explicit.
        values.discard(); expect(values.releaseCount == 3)
    case 8:
        expect(result == .failure(.capacityExhausted)); expect(values.releaseCount == 3)
    case 9:
        guard case .success(let summary) = result else { preconditionFailure("empty success expected") }
        expect(summary.canvasOccurrenceCount == 0 && values.releaseCount == 0 && trace.pointee.contexts == 0)
    default: preconditionFailure("unsupported mode")
    }
    expect(scope.phase == .reading)
    // Entering discovery proves the invocation ended its own active read.
    do throws(ObservableStateError) { try scope.withDiscovery { () throws(ObservableStateError) in () } }
    catch { preconditionFailure("read leaked") }
    values.discard()
    expect(values.count == 0 && values.releaseCount == (mode == 9 ? 0 : 3))
    return checks
}

public func giftuiP06Stores(dynamic: Bool) -> UInt32 {
    var checks: UInt32 = 0
    for mode: UInt8 in 0 ... 10 {
        var trace = CanvasTrace(); trace.failure = mode
        withUnsafeMutablePointer(to: &trace) { trace in
            do throws(ObservableStateError) {
                var namespace = ObservableModelOwnerNamespace()
                var owner = StaticObservableModelStorage<CanvasModel, CounterModelSchema>(identity: try namespace.issue(), schema: 1, needsCapture: false)!
                try owner.withLifetime { (scope) throws(ObservableStateError) in
                    var a = try scope.materialize(CanvasModel(value: 3, trace: trace))
                    var b = try scope.materialize(CanvasModel(value: 7, trace: trace))
                    try scope.withFrame { () throws(ObservableStateError) in
                        try scope.pin(a.key); try scope.pin(b.key)
                        let limits = StaticCanvasLimits(maximumStaticCallableCases: 2, maximumStaticCaptureBytes: 32)!
                        do throws(DrawingError) {
                            #if !hasFeature(Embedded)
                            if dynamic {
                                var storage = DynamicCanvasCallableStorage<UInt16, CanvasTable>(capacity: 3)
                                checks += try storage.withLifetime(table: CanvasTable(), limits: limits) { (values) throws(DrawingError) in
                                    try exerciseValues(values, scope: scope, keys: (a.key, b.key), trace: trace, mode: mode)
                                }
                                return
                            }
                            #endif
                                var storage = StaticCanvasValueStorage()
                                var backing: InlineArray<3, CanvasStagedEntry<UInt16, CanvasTable.CaptureStorage>?> = .init(repeating: nil)
                                var entries = backing.mutableSpan
                                checks += try storage.withLifetime(entries: &entries, table: CanvasTable(), capacity: 3, limits: limits) { (values) throws(DrawingError) in
                                    try exerciseValues(values, scope: scope, keys: (a.key, b.key), trace: trace, mode: mode)
                                }
                        } catch { preconditionFailure("unexpected drawing error") }
                    }
                    try scope.release(&a); try scope.release(&b)
                }
            } catch { preconditionFailure("unexpected owner error") }
        }
        precondition(trace.destroys == 2); checks += 1
    }
    return checks
}
