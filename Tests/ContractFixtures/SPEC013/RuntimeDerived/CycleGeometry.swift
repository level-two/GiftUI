import CycleTable
import GiftUI
import GiftUIDrawing
import GiftUIExecution
import GiftUILayout
import GiftUIObservableState
import GiftUIRenderCore
import GiftUIRenderLowering
import GiftUIReferenceTextResources
import GiftUISemanticCore
import GiftUIRuntimeCore
import GiftUIRuntimeStatic
#if !hasFeature(Embedded)
import GiftUIRuntimeDynamic
#endif
import CycleSchema
import P07TargetWorkspace

typealias CyclePayload = CanvasSemanticPayload<CycleValueTable.CaptureStorage>
typealias CycleSource = ObservableCanvasInvocationSource<CycleOwnedModel, CycleModelSchema, SemanticRecordReference, CycleValueTable>
let cycleLayoutLimits = LayoutLimits(maximumScopes: 98, maximumDepth: 19, maximumTextScalars: 224, maximumTextLines: 128, maximumPositionedGlyphs: 224)!
let cycleDrawingLimits = DrawingLimits(maximumLineWidth: 4, maximumCanvasOccurrences: 5, maximumLivePathPoints: 202, maximumLivePathSubpaths: 12, maximumPlanStrokes: 5, maximumPlanPoints: 832, maximumPlanSubpaths: 16, maximumNormalizedStrokeOperations: 5)!
let cycleSurface = Rect(origin: Point(x: 0, y: 0), size: Size(width: 100, height: 100)!)!

// Finite fixture assembly over actual profile owners. No stage is substituted
// by a recorded answer; each method invokes its maintained focused algorithm.
protocol CycleGeometry {
    mutating func layout(_ bank: borrowing SemanticRecordView<CyclePayload>) -> LayoutResult
    mutating func draw(source: inout CycleSource, context: ExecutionContext) -> DrawingPlanResult
    mutating func preflight(_ bank: borrowing SemanticRecordView<CyclePayload>) -> RenderProductionResult
    mutating func produce(_ bank: borrowing SemanticRecordView<CyclePayload>, header: RenderPlanHeader, sink: inout CycleRenderSink) -> RenderProductionResult
    func bounds(_ record: SemanticRecordReference) -> Rect?
    func clip(_ record: SemanticRecordReference) -> Rect?
    mutating func resetLayout()
    mutating func resetPlan()
    mutating func resetRender()
    mutating func reset()
}
#if !hasFeature(Embedded)
struct DynamicCycleGeometry: CycleGeometry {
    var workspace = DynamicLayoutWorkspace(limits: cycleLayoutLimits, maximumSemanticRecords: 126)
    var resolved = DynamicResolvedLayoutStorage(limits: cycleLayoutLimits)
    var plan = DynamicDrawingPlanWorkspace(capacity: cycleDrawingLimits)
    var render = DynamicRenderWorkspace(capacity: cycleRenderLimits, structuralCapacity: cycleRenderCapacity)
    mutating func layout(_ bank: borrowing SemanticRecordView<CyclePayload>) -> LayoutResult {
        GiftUILayout.layout(semantic: SemanticRecordLayoutView(bank), metrics: GiftUIReferenceTextMetricsView(), proposal: ProposedSize(width: 100, height: 100)!, limits: cycleLayoutLimits, workspace: &workspace, sink: &resolved)
    }
    mutating func draw(source: inout CycleSource, context: ExecutionContext) -> DrawingPlanResult {
        CanvasPlanProducer.derive(source: &source, layout: resolved.renderView, executionContext: context, limits: cycleDrawingLimits, workspace: &plan)
    }
    mutating func preflight(_ bank: borrowing SemanticRecordView<CyclePayload>) -> RenderProductionResult {
        CanvasRenderProducer.preflight(semantic: SemanticRecordRenderView(bank), layout: resolved.renderView, textMetrics: GiftUIReferenceTextMetricsView(), drawingPlan: plan, surfaceBounds: cycleSurface, damageMode: .initializeCompleteSurface, rootForeground: .white, limits: cycleRenderLimits, configuredSinkCapacity: CycleRenderSink().capacity, workspace: &render)
    }
    mutating func produce(_ bank: borrowing SemanticRecordView<CyclePayload>, header: RenderPlanHeader, sink: inout CycleRenderSink) -> RenderProductionResult {
        CanvasRenderProducer.produce(semantic: SemanticRecordRenderView(bank), layout: resolved.renderView, textMetrics: GiftUIReferenceTextMetricsView(), drawingPlan: plan, surfaceBounds: cycleSurface, damageMode: .initializeCompleteSurface, rootForeground: .white, limits: cycleRenderLimits, expectedHeader: header, workspace: &render, sink: &sink)
    }
    func bounds(_ record: SemanticRecordReference) -> Rect? { resolved.renderView.bounds(of: record) }
    func clip(_ record: SemanticRecordReference) -> Rect? { resolved.renderView.clip(of: record) }
    mutating func resetLayout() { workspace.resetLayout(); resolved.discard() }
    mutating func resetPlan() { plan.discard(); plan.reset() }
    mutating func resetRender() { render.reset() }
    mutating func reset() { resetRender(); resetPlan(); resetLayout() }
}
#endif
struct StaticCycleGeometry: CycleGeometry {
    var workspace: StaticSignalAnalyzerNRFLayoutWorkspace
    var resolved: StaticSignalAnalyzerNRFResolvedLayoutStorage
    var references: InlineArray<126, SemanticRecordReference?> = .init(repeating: nil)
    var plan: StaticRecordDrawingWorkspace<StaticSignalAnalyzerNRFDrawingWorkspace>
    var render: QualifiedRender
    init(scopes: UnsafeMutableRawBufferPointer, text: UnsafeMutableRawBufferPointer, path: UnsafeMutableRawBufferPointer, plan: UnsafeMutableRawBufferPointer) {
        workspace = StaticSignalAnalyzerNRFLayoutWorkspace(scopes: scopes, text: text)!
        resolved = StaticSignalAnalyzerNRFResolvedLayoutStorage(scopes: scopes, text: text)!
        self.plan = StaticRecordDrawingWorkspace(base: StaticSignalAnalyzerNRFDrawingWorkspace(pathRegion: path, planRegion: plan, capacity: cycleDrawingLimits)!)
        render = QualifiedRender(base: StaticSignalAnalyzerNRFRenderWorkspace(region: text, capacity: cycleRenderLimits, structuralCapacity: cycleRenderCapacity)!)
    }
    var view: QualifiedLayout { QualifiedLayout(base: resolved.renderView, references: references) }
    mutating func layout(_ bank: borrowing SemanticRecordView<CyclePayload>) -> LayoutResult {
        references = .init(repeating: nil)
        for index: UInt16 in 0..<bank.recordCount { references[Int(index)] = bank.reference(at: index) }
        return GiftUILayout.layout(semantic: LocalSemantic(bank), metrics: GiftUIReferenceTextMetricsView(), proposal: ProposedSize(width: 100, height: 100)!, limits: cycleLayoutLimits, workspace: &workspace, sink: &resolved)
    }
    mutating func draw(source: inout CycleSource, context: ExecutionContext) -> DrawingPlanResult {
        CanvasPlanProducer.derive(source: &source, layout: view, executionContext: context, limits: cycleDrawingLimits, workspace: &plan)
    }
    mutating func preflight(_ bank: borrowing SemanticRecordView<CyclePayload>) -> RenderProductionResult {
        CanvasRenderProducer.preflight(semantic: SemanticRecordRenderView(bank), layout: view, textMetrics: GiftUIReferenceTextMetricsView(), drawingPlan: plan, surfaceBounds: cycleSurface, damageMode: .initializeCompleteSurface, rootForeground: .white, limits: cycleRenderLimits, configuredSinkCapacity: CycleRenderSink().capacity, workspace: &render)
    }
    mutating func produce(_ bank: borrowing SemanticRecordView<CyclePayload>, header: RenderPlanHeader, sink: inout CycleRenderSink) -> RenderProductionResult {
        CanvasRenderProducer.produce(semantic: SemanticRecordRenderView(bank), layout: view, textMetrics: GiftUIReferenceTextMetricsView(), drawingPlan: plan, surfaceBounds: cycleSurface, damageMode: .initializeCompleteSurface, rootForeground: .white, limits: cycleRenderLimits, expectedHeader: header, workspace: &render, sink: &sink)
    }
    func bounds(_ record: SemanticRecordReference) -> Rect? { view.bounds(of: record) }
    func clip(_ record: SemanticRecordReference) -> Rect? { view.clip(of: record) }
    mutating func resetLayout() { resolved.discard(); workspace.resetLayout(); references = .init(repeating: nil) }
    mutating func resetPlan() { plan.discard(); plan.reset() }
    mutating func resetRender() { render.reset() }
    mutating func reset() { resetRender(); resetPlan(); resetLayout() }
}
