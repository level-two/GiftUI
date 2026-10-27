import GiftUIInteraction
import P08CounterTable
import GiftUI
import GiftUIDrawing
import GiftUIExecution
import GiftUILayout
import GiftUIObservableState
import GiftUIRenderCore
import GiftUIRenderLowering
import GiftUIRuntimeCore
import GiftUIRuntimeStatic
import GiftUISemanticCore
#if !hasFeature(Embedded)
import GiftUIRuntimeDynamic
#endif
import P08CounterSchema

let counterRenderLimits = RenderLimits(maximumOperations: 25, maximumPositionedGlyphs: 64, maximumClipDepth: 4)!
let counterRenderCapacity = RenderWorkspaceCapacity(maximumSemanticScopes: 32, maximumLayoutScopes: 32, maximumTraversalDepth: 12, maximumTextLines: 16)!

struct CounterRenderSink: DrawingOperationSink {
    let capacity = RenderSinkCapacity(maximumOperations: 25, maximumPositionedGlyphs: 64)
    var header: RenderPlanHeader?
    var operations: UInt16 = 0
    var glyphs: UInt16 = 0
    var strokes: UInt16 = 0
    var finishes = 0
    var discards = 0
    var firstPoint: Point?
    var secondPoint: Point?
    var strokeHeader: StraightLineStrokeHeader?
    var glyphRecords: InlineArray<64, PositionedGlyph?> = .init(repeating: nil)
    mutating func begin(_ header: RenderPlanHeader) -> Bool { self.header = header; return true }
    mutating func fillRect(_ operation: FillRectOperation) -> Bool { operations += 1; return true }
    mutating func beginPositionedGlyphs(_ operation: PositionedGlyphOperationHeader) -> Bool { operations += 1; return true }
    mutating func positionedGlyph(_ glyph: PositionedGlyph) -> Bool {
        guard glyphs < 64 else { return false }
        glyphRecords[Int(glyphs)] = glyph; glyphs += 1; return true
    }
    mutating func endPositionedGlyphs() -> Bool { true }
    mutating func finish() -> Bool { finishes += 1; return true }
    mutating func discard() { discards += 1 }
    mutating func straightLineStroke<S: StraightLineStrokeView>(_ stroke: borrowing S) -> Bool {
        let header = stroke.header
        strokeHeader = header; firstPoint = stroke.point(at: 0); secondPoint = stroke.point(at: 1)
        let subpath = stroke.subpath(at: 0)
        counterRenderExpect(header.pointCount == 2 && header.subpathCount == 1)
        counterRenderExpect(header.color == .white && header.lineWidth == 1)
        counterRenderExpect(header.lineCap == .round && header.lineJoin == .round)
        counterRenderExpect(subpath == SubpathRange(firstPoint: 0, pointCount: 2))
        operations += 1; strokes += 1
        return true
    }
}

// Actual algorithm join; no expected geometry is supplied to the runtime.
private func renderCounter<G: CounterGeometry>(geometry: inout G,
    semantic: borrowing SemanticRecordStore,
    models: borrowing ObservableModelScope<CounterOwnedModel, CounterModelSchema>,
    values: borrowing CanvasStagedValues<SemanticRecordReference, CounterValueTable>,
    value: UInt8, limits: RuntimeProfileLimits) -> Int {
    var checks = 0
    let canvas = values.identity(at: 0)!
    var source = CounterSource(models: models.borrowedScope(), values: values.borrowedValues(), table: CounterValueTable())
    do throws(SemanticExpansionError) {
        try semantic.withCandidateView { bank in
            let result = geometry.layout(bank, limits: limits)
            guard case .success = result else {
            #if !hasFeature(Embedded)
            print("counter layout failed", result)
            #endif
            preconditionFailure("counter layout") }
        }
        let context = ExecutionContext(cycle: RunCycleID(rawValue: 1), semanticRevision: nil, candidateFrame: nil, phase: .deriving)
        let draw = geometry.draw(source: &source, context: context, limits: limits)
        guard case .success(let summary) = draw else {
        #if !hasFeature(Embedded)
        print("counter draw failed", draw)
        #endif
        preconditionFailure("counter drawing") }
        counterRenderExpect(summary.canvasOccurrenceCount == 1 && summary.strokeCount == (value == 0 ? 0 : 1)); checks += 1
        checks += geometry.verifyPlan(canvas: canvas, value: value)
        // Invocation releases the owned capture while retaining identity metadata
        // until mandatory attempt discard; discard must not release it twice.
        counterRenderExpect(values.count == 1 && values.releaseCount == 1); checks += 1
        var sink = CounterRenderSink()
        try semantic.withCandidateView { bank in
            let result = geometry.preflight(bank, limits: limits)
            guard case .success(let header) = result else {
            #if !hasFeature(Embedded)
            print("counter render preflight failed", result)
            #endif
            preconditionFailure("counter render preflight") }
            let produced = geometry.produce(bank, header: header, sink: &sink, limits: limits)
            counterRenderExpect(produced == .success(header)); checks += 1
            counterRenderExpect(sink.operations == header.operationCount && sink.glyphs == header.positionedGlyphCount); checks += 1
        }
        counterRenderExpect(sink.glyphs == 22 && sink.strokes == (value == 0 ? 0 : 1)); checks += 1
        counterRenderExpect(sink.finishes == 1 && sink.discards == 0); checks += 1
        counterRenderExpect(geometry.bounds(canvas)?.size == Size(width: 48, height: 16)); checks += 1
        geometry.reset()
    } catch { preconditionFailure("counter borrowed render") }
    return checks
}

func counterRenderActual(semantic: borrowing SemanticRecordStore, models: borrowing ObservableModelScope<CounterOwnedModel, CounterModelSchema>, values: borrowing CanvasStagedValues<SemanticRecordReference, CounterValueTable>, value: UInt8, dynamic: Bool) -> Int {
    #if !hasFeature(Embedded)
    if dynamic {
        var geometry = DynamicCounterGeometry()
        let limits = counterActualLimits(.dynamic)
        return renderCounter(geometry: &geometry, semantic: semantic, models: models, values: values, value: value, limits: limits)
    }
    #endif
    var scopeBytes: InlineArray<1024, UInt8> = .init(repeating: 0)
    var textBytes: InlineArray<1056, UInt8> = .init(repeating: 0)
    var pathBytes: InlineArray<20, UInt8> = .init(repeating: 0)
    var planBytes: InlineArray<112, UInt8> = .init(repeating: 0)
    return withUnsafeMutableBytes(of: &scopeBytes) { scopes in
        withUnsafeMutableBytes(of: &textBytes) { text in
            withUnsafeMutableBytes(of: &pathBytes) { path in
                withUnsafeMutableBytes(of: &planBytes) { plan in
                    var geometry = StaticCounterGeometry(scopes: scopes, text: text, path: path, plan: plan)
                    return renderCounter(geometry: &geometry, semantic: semantic, models: models, values: values, value: value, limits: counterActualLimits(.static))
                }
            }
        }
    }
}

func counterActualLimits(_ profile: RuntimeProfileKind) -> RuntimeProfileLimits {
    RuntimeProfileLimits(records: .init(maximumPathEntries: 192, maximumPathDepth: 24, maximumPathChildFanout: 5, maximumPayloadBytesPerBank: 4096, maximumIdentityComponentsPerKey: 24, maximumInteractionIdentityComponents: 48), models: .init(maximumModelSlots: 2, maximumOwningTickets: 4, maximumFramePins: 2, maximumModelCaptureBanks: 0), semantic: .init(maximumDepth: 24, maximumSemanticNodes: 24, maximumBodyEvaluations: 8, maximumModifierApplications: 8, maximumActionOccurrences: 2)!, maximumSemanticStructuralOccurrences: 64, layout: counterLayoutLimits, render: counterRenderLimits, renderWorkspace: counterRenderCapacity, renderSink: CounterRenderSink().capacity, maximumOrdinaryRenderOperations: 24, execution: .init(maximumInputEvents: 2, maximumStateChangeFacts: 34, maximumCompletionFacts: 1, maximumSemanticActions: 2, maximumActiveInputSources: 1, maximumCommittedActions: 2)!, observableState: .init(maximumLocations: 1, maximumRegistrations: 1, maximumStagedAssociations: 1)!, interaction: .init(maximumActions: 2, maximumHitRegions: 2)!, drawing: counterDrawingLimits, staticCanvas: profile == .static ? .init(maximumStaticCallableCases: 1, maximumStaticCaptureBytes: UInt16(MemoryLayout<CounterValueTable.CaptureStorage>.stride))! : nil, profile: profile)!
}

func counterVerifyPlan<P: DrawingPlanView>(_ plan: borrowing P, canvas: SemanticRecordReference, bounds: Rect, value: UInt8) -> Int where P.Identity == SemanticRecordReference {
    let summary = plan.summary
    if value == 0 { counterRenderExpect(summary.strokeCount == 0); return 1 }
    let strokeCount = plan.strokeCount(of: canvas)
    let first = plan.point(of: canvas, stroke: 0, at: 0)
    let second = plan.point(of: canvas, stroke: 0, at: 1)
    let subpath = plan.subpath(of: canvas, stroke: 0, at: 0)
    counterRenderExpect(strokeCount == 1)
    let header = plan.strokeHeader(of: canvas, at: 0)!
    counterRenderExpect(header.color == .white && header.lineWidth == 1 && header.lineCap == .round && header.lineJoin == .round)
    counterRenderExpect(header.pointCount == 2 && header.subpathCount == 1)
    counterRenderExpect(first == Point(x: bounds.origin.x + 4, y: bounds.origin.y + 8))
    counterRenderExpect(second == Point(x: bounds.origin.x + 4 + 4 * GeometryScalar(value), y: bounds.origin.y + 8))
    counterRenderExpect(subpath == SubpathRange(firstPoint: 0, pointCount: 2))
    return 6
}

private func counterRenderExpect(_ condition: Bool, file: StaticString = #fileID, line: UInt = #line) {
    if !condition {
    #if !hasFeature(Embedded)
    print("counter render assertion failed", file, line)
    #endif
    preconditionFailure("counter render assertion") }
}
