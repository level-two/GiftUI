import CycleTable
import GiftUI
import GiftUIDrawing
import GiftUIExecution
import GiftUILayout
import GiftUIRenderCore
import GiftUIRenderLowering
import GiftUIObservableState
import GiftUIReferenceTextResources
import GiftUIRuntimeCore
import GiftUIRuntimeStatic
import GiftUISemanticCore
import CycleSchema
import P07TargetWorkspace

typealias StaticCyclePayload = SemanticRecordPayload
// Only a finite assembly adapter: local IDs refer to the current borrowed bank.
// The existing target workspace still owns all layout records and algorithms.
struct LocalSemantic: ~Escapable, SemanticLayoutView {
    let bank: SemanticRecordView
    let base: SemanticRecordLayoutView
    @_lifetime(borrow bank)
    init(_ bank: borrowing SemanticRecordView) { self.bank = copy bank; base = SemanticRecordLayoutView(bank) }
    var rootIdentity: UInt16 { base.rootIdentity.ordinal + 1 }
    var scopeCount: UInt16 { base.scopeCount }
    func reference(_ id: UInt16) -> SemanticRecordReference? { id == 0 ? nil : bank.reference(at: id - 1) }
    func primitive(at id: UInt16) -> SemanticLayoutPrimitive? { guard let ref = reference(id) else { return nil }; return base.primitive(at: ref) }
    func childCount(of id: UInt16) -> UInt16? { guard let ref = reference(id) else { return nil }; return base.childCount(of: ref) }
    func child(of id: UInt16, at index: UInt16) -> UInt16? { guard let ref = reference(id) else { return nil }; return base.child(of: ref, at: index).map { $0.ordinal + 1 } }
    func modifierCount(of id: UInt16) -> UInt16? { guard let ref = reference(id) else { return nil }; return base.modifierCount(of: ref) }
    func modifierScope(of id: UInt16, at index: UInt16) -> UInt16? { guard let ref = reference(id) else { return nil }; return base.modifierScope(of: ref, at: index).map { $0.ordinal + 1 } }
    func modifier(of id: UInt16, at index: UInt16) -> SemanticLayoutModifier? { guard let ref = reference(id) else { return nil }; return base.modifier(of: ref, at: index) }
    func textScalarCount(of id: UInt16) -> UInt16? { guard let ref = reference(id) else { return nil }; return base.textScalarCount(of: ref) }
    func textScalar(of id: UInt16, at index: UInt16) -> UInt32? { guard let ref = reference(id) else { return nil }; return base.textScalar(of: ref, at: index) }
}
struct QualifiedLayout: ResolvedRenderLayoutView {
    let base: StaticSignalAnalyzerNRFResolvedLayoutView
    let references: InlineArray<126, SemanticRecordReference?>
    var rootIdentity: SemanticRecordReference { references[Int(base.rootIdentity - 1)]! }
    var layoutScopeCount: UInt16 { base.layoutScopeCount }
    var renderSnapshotVersion: UInt32 { base.renderSnapshotVersion }
    var rootBounds: Rect { base.rootBounds }
    func local(_ ref: SemanticRecordReference) -> UInt16? {
        guard ref.ordinal < 126, references[Int(ref.ordinal)] == ref else { return nil }
        return ref.ordinal + 1
    }
    func layoutIdentity(at ordinal: UInt16) -> SemanticRecordReference? { guard let id = base.layoutIdentity(at: ordinal), id > 0, id <= 126 else { return nil }; return references[Int(id - 1)] }
    func layoutOrdinal(of ref: SemanticRecordReference) -> UInt16? { guard let id = local(ref) else { return nil }; return base.layoutOrdinal(of: id) }
    func bounds(of ref: SemanticRecordReference) -> Rect? { guard let id = local(ref) else { return nil }; return base.bounds(of: id) }
    func clip(of ref: SemanticRecordReference) -> Rect? { guard let id = local(ref) else { return nil }; return base.clip(of: id) }
    func textLineCount(of ref: SemanticRecordReference) -> UInt16? { guard let id = local(ref) else { return nil }; return base.textLineCount(of: id) }
    func textLine(of ref: SemanticRecordReference, at index: UInt16) -> ResolvedRenderTextLine? { guard let id = local(ref) else { return nil }; return base.textLine(of: id, at: index) }
    func glyph(of ref: SemanticRecordReference, at index: UInt16) -> ResolvedRenderGlyph? { guard let id = local(ref) else { return nil }; return base.glyph(of: id, at: index) }
}
package func cycleStaticDrawing(
    semantic: borrowing SemanticRecordStore,
    models: borrowing ObservableModelScope<CycleOwnedModel, CycleModelSchema>,
    values: borrowing CanvasStagedValues<SemanticRecordReference, CycleValueTable>, shown: Bool
) -> Int {
    var scopeBytes: InlineArray<3136, UInt8> = .init(repeating: 0)
    var textBytes: InlineArray<4704, UInt8> = .init(repeating: 0)
    var pathBytes: InlineArray<3280, UInt8> = .init(repeating: 0)
    var planBytes: InlineArray<13536, UInt8> = .init(repeating: 0)
    return withUnsafeMutableBytes(of: &scopeBytes) { scopes in
        withUnsafeMutableBytes(of: &textBytes) { text in
            withUnsafeMutableBytes(of: &pathBytes) { path in
                withUnsafeMutableBytes(of: &planBytes) { bytes in
                    let limits = LayoutLimits(maximumScopes: 98, maximumDepth: 19, maximumTextScalars: 224, maximumTextLines: 128, maximumPositionedGlyphs: 224)!
                    var workspace = StaticSignalAnalyzerNRFLayoutWorkspace(scopes: scopes, text: text)!
                    var storage = StaticSignalAnalyzerNRFResolvedLayoutStorage(scopes: scopes, text: text)!
                    var references: InlineArray<126, SemanticRecordReference?> = .init(repeating: nil)
                    do throws(SemanticExpansionError) {
                        try semantic.withCandidateView { bank in
                            for i: UInt16 in 0..<bank.recordCount { references[Int(i)] = bank.reference(at: i) }
                            let result = layout(semantic: LocalSemantic(bank), metrics: GiftUIReferenceTextMetricsView(), proposal: ProposedSize(width: 100, height: 100)!, limits: limits, workspace: &workspace, sink: &storage)
                            guard case .success = result else { preconditionFailure("Static layout") }
                        }
                    } catch { preconditionFailure("Static semantic borrow") }
                    let resolved = QualifiedLayout(base: storage.renderView, references: references)
                    let drawingLimits = DrawingLimits(maximumLineWidth: 4, maximumCanvasOccurrences: 5, maximumLivePathPoints: 202, maximumLivePathSubpaths: 12, maximumPlanStrokes: 5, maximumPlanPoints: 832, maximumPlanSubpaths: 16, maximumNormalizedStrokeOperations: 5)!
                    let base = StaticSignalAnalyzerNRFDrawingWorkspace(pathRegion: path, planRegion: bytes, capacity: drawingLimits)!
                    var plan = StaticRecordDrawingWorkspace(base: base)
                    var source = ObservableCanvasInvocationSource(models: models.borrowedScope(), values: values.borrowedValues(), table: CycleValueTable())
                    let context = ExecutionContext(cycle: RunCycleID(rawValue: 1), semanticRevision: nil, candidateFrame: nil, phase: .deriving)
                    let canvas = values.identity(at: 0)
                    if let canvas {
                        precondition(resolved.layoutOrdinal(of: canvas) != nil, "missing ordinal")
                        precondition(resolved.layoutIdentity(at: resolved.layoutOrdinal(of: canvas)!) == canvas, "identity mismatch")
                        precondition(resolved.bounds(of: canvas) != nil, "missing bounds")
                        precondition(resolved.clip(of: canvas) != nil, "missing clip")
                    }
                    let result = CanvasPlanProducer.derive(source: &source, layout: resolved, executionContext: context, limits: drawingLimits, workspace: &plan)
                    guard case .success(let summary) = result else { preconditionFailure("Static drawing") }
                    precondition(summary.canvasOccurrenceCount == (shown ? 1 : 0))
                    precondition(summary.strokeCount == (shown ? 1 : 0))
                    precondition(values.releaseCount == (shown ? 1 : 0))
                    if let canvas {
                        precondition(plan.strokeCount(of: canvas) == 1)
                        let bounds = resolved.bounds(of: canvas)!
                        precondition(plan.point(of: canvas, stroke: 0, at: 0) == Point(x: bounds.origin.x, y: bounds.origin.y + 3))
                    }
                    var render = QualifiedRender(base: StaticSignalAnalyzerNRFRenderWorkspace(region: text, capacity: cycleRenderLimits, structuralCapacity: cycleRenderCapacity)!)
                    let renderChecks = cycleRender(semantic: semantic, layout: resolved, plan: plan, workspace: &render, shown: shown)
                    plan.discard(); plan.reset()
                    return (shown ? 5 : 3) + renderChecks
                }
            }
        }
    }
}

struct QualifiedRender: RenderProductionWorkspace {
    typealias Identity = SemanticRecordReference
    var base: StaticSignalAnalyzerNRFRenderWorkspace
    var capacity: RenderLimits { base.capacity }
    var structuralCapacity: RenderWorkspaceCapacity { base.structuralCapacity }
    var isActive: Bool { base.isActive }
    var currentForeground: Color? { base.currentForeground }
    mutating func acquire() -> Bool { base.acquire() }
    mutating func visitSemanticScope(at ordinal: UInt16) -> RenderWorkspaceVisit { base.visitSemanticScope(at: ordinal) }
    mutating func visitLayoutScope(at ordinal: UInt16) -> RenderWorkspaceVisit { base.visitLayoutScope(at: ordinal) }
    mutating func pushForeground(_ color: Color) -> Bool { base.pushForeground(color) }
    mutating func popForeground() -> Bool { base.popForeground() }
    mutating func reset() { base.reset() }
}

// Fault injection at storage reads, below StrokeSnapshotProducer's validation.
struct CycleMalformedPath: LivePathStorage {
    let fault: UInt8
    var maximumPointCount: UInt16 { 4 }
    var maximumSubpathCount: UInt16 { 2 }
    var pointCount: UInt16 { 4 }
    var subpathCount: UInt16 { 2 }
    func point(at index: UInt16) -> Point? {
        guard index < 4, !(fault == 1 && index == 2) else { return nil }
        return Point(x: fault == 3 && index == 3 ? GeometryScalar.max : GeometryScalar(index), y: GeometryScalar(index))
    }
    func subpath(at index: UInt16) -> SubpathRange? {
        guard index < 2, !(fault == 2 && index == 1) else { return nil }
        return SubpathRange(firstPoint: index * 2, pointCount: 2)
    }
    mutating func startFirstSubpath(at point: Point) -> Bool { false }
    mutating func replaceCurrentSubpathStart(with point: Point) -> Bool { false }
    mutating func startNextSubpath(at point: Point) -> Bool { false }
    mutating func appendLine(to point: Point) -> Bool { false }
    mutating func reset() {}
}
let cycleFaultOrigin = Point(x: 1, y: 2)
let cycleFaultHeader = StraightLineStrokeHeader(color: .white, lineWidth: 1, lineCap: .butt, lineJoin: .miter, surfaceOrigin: cycleFaultOrigin, inheritedClip: cycleSurface, pointCount: 4, subpathCount: 2)

package func cycleStaticDrawingRollback() -> Int {
    var bytes: InlineArray<13536, UInt8> = .init(repeating: 0)
    return withUnsafeMutableBytes(of: &bytes) { region in
        var plan = StaticSignalAnalyzerNRFDrawingPlanStorage(region: region, capacity: cycleDrawingLimits)!
        var checks = 0
        func expect(_ value: Bool) { checks += 1; precondition(value, "Static malformed Drawing rollback") }
        for _ in 0..<2 {
            expect(plan.acquire())
            expect(plan.beginCanvas(identity: 1, origin: cycleFaultOrigin))
            expect(plan.appendStroke(header: cycleFaultHeader, path: CycleMalformedPath(fault: 0)))
            for fault: UInt8 in 1...3 {
                expect(!plan.appendStroke(header: cycleFaultHeader, path: CycleMalformedPath(fault: fault)))
                expect(plan.pointCount == 4 && plan.subpathCount == 2 && plan.strokeCount == 1)
            }
            expect(plan.appendStroke(header: cycleFaultHeader, path: CycleMalformedPath(fault: 0)))
            expect(plan.pointCount == 8 && plan.subpathCount == 4 && plan.strokeCount == 2)
            expect(plan.endCanvas())
            guard case .success = plan.seal(canvasOccurrenceCount: 1) else { preconditionFailure("Static rollback seal") }
            checks += 1
            for stroke: UInt16 in 0..<2 {
                expect(plan.strokeHeader(of: 1, at: stroke) == cycleFaultHeader)
                for index: UInt16 in 0..<4 { expect(plan.point(of: 1, stroke: stroke, at: index) == Point(x: GeometryScalar(index) + 1, y: GeometryScalar(index) + 2)) }
                for index: UInt16 in 0..<2 { expect(plan.subpath(of: 1, stroke: stroke, at: index) == SubpathRange(firstPoint: index * 2, pointCount: 2)) }
            }
            plan.discard(); plan.reset()
            expect(plan.pointCount == 0 && plan.subpathCount == 0 && plan.strokeCount == 0)
        }
        return checks
    }
}
