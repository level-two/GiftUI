import P08CounterTable
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
import P08CounterSchema

typealias CounterSource = ObservableCanvasInvocationSource<CounterOwnedModel, CounterModelSchema, SemanticRecordReference, CounterValueTable>
let counterLayoutLimits = LayoutLimits(maximumScopes: 32, maximumDepth: 12, maximumTextScalars: 64, maximumTextLines: 16, maximumPositionedGlyphs: 64)!
let counterDrawingLimits = DrawingLimits(maximumLineWidth: 1, maximumCanvasOccurrences: 1, maximumLivePathPoints: 2, maximumLivePathSubpaths: 1, maximumPlanStrokes: 1, maximumPlanPoints: 2, maximumPlanSubpaths: 1, maximumNormalizedStrokeOperations: 1)!
let counterSurface = Rect(origin: Point(x: 0, y: 0), size: Size(width: 100, height: 120)!)!

// Finite fixture assembly over actual profile owners. No stage is substituted
// by a recorded answer; each method invokes its maintained focused algorithm.
protocol CounterGeometry {
    borrowing func storageMeasurement() -> CounterGeometryMeasurement
    mutating func layout(_ bank: borrowing SemanticRecordView<CounterPayload>, limits: RuntimeProfileLimits) -> LayoutResult
    mutating func draw(source: inout CounterSource, context: ExecutionContext, limits: RuntimeProfileLimits) -> DrawingPlanResult
    mutating func preflight(_ bank: borrowing SemanticRecordView<CounterPayload>, limits: RuntimeProfileLimits) -> RenderProductionResult
    mutating func produce<S: DrawingOperationSink>(_ bank: borrowing SemanticRecordView<CounterPayload>, header: RenderPlanHeader, sink: inout S, limits: RuntimeProfileLimits) -> RenderProductionResult
    func verifyPlan(canvas: SemanticRecordReference, value: UInt8) -> Int
    func bounds(_ record: SemanticRecordReference) -> Rect?
    func clip(_ record: SemanticRecordReference) -> Rect?
    mutating func resetLayout()
    mutating func resetPlan()
    mutating func resetRender()
    mutating func reset()
}
#if !hasFeature(Embedded)
struct DynamicCounterGeometry: CounterGeometry {
    borrowing func storageMeasurement() -> CounterGeometryMeasurement {
        .init(layout: LayoutLimits(maximumScopes: workspace.maximumScopes, maximumDepth: workspace.maximumDepth, maximumTextScalars: workspace.maximumTextScalars, maximumTextLines: workspace.maximumTextLines, maximumPositionedGlyphs: workspace.maximumPositionedGlyphs)!,
            render: render.capacity, renderWorkspace: render.structuralCapacity, drawing: plan.capacity,
            layoutBytes: UInt64(MemoryLayout<Self>.size - MemoryLayout<DynamicRenderWorkspace>.size - MemoryLayout<DynamicDrawingPlanWorkspace>.size) + workspace.reservedPayloadBytes + resolved.reservedPayloadBytes,
            renderBytes: UInt64(MemoryLayout<DynamicRenderWorkspace>.size + render.reservedPayloadBytes),
            pathBytes: plan.livePathReservedPayloadBytes,
            planBytes: UInt64(MemoryLayout<DynamicDrawingPlanWorkspace>.size) + plan.planReservedPayloadBytes)
    }

    var workspace = DynamicLayoutWorkspace(limits: counterLayoutLimits, maximumSemanticRecords: 126)
    var resolved = DynamicResolvedLayoutStorage(limits: counterLayoutLimits)
    var plan = DynamicDrawingPlanWorkspace(capacity: counterDrawingLimits)
    var render = DynamicRenderWorkspace(capacity: counterRenderLimits, structuralCapacity: counterRenderCapacity)
    mutating func layout(_ bank: borrowing SemanticRecordView<CounterPayload>, limits: RuntimeProfileLimits) -> LayoutResult {
        GiftUILayout.layout(semantic: SemanticRecordLayoutView(bank), metrics: GiftUIReferenceTextMetricsView(), proposal: ProposedSize(width: 100, height: 120)!, limits: limits.layout, workspace: &workspace, sink: &resolved)
    }
    mutating func draw(source: inout CounterSource, context: ExecutionContext, limits: RuntimeProfileLimits) -> DrawingPlanResult {
        precondition(plan.configure(limits: limits.drawing))
        return CanvasPlanProducer.derive(source: &source, layout: resolved.renderView, executionContext: context, limits: limits.drawing, workspace: &plan)
    }
    mutating func preflight(_ bank: borrowing SemanticRecordView<CounterPayload>, limits: RuntimeProfileLimits) -> RenderProductionResult {
        let result = withCounterRenderLimits(&render, limits: limits) { render in CanvasRenderProducer.preflight(semantic: SemanticRecordRenderView(bank), layout: resolved.renderView, textMetrics: GiftUIReferenceTextMetricsView(), drawingPlan: plan, surfaceBounds: counterSurface, damageMode: .initializeCompleteSurface, rootForeground: .white, limits: limits.render, configuredSinkCapacity: limits.renderSink, workspace: &render) }
        if case .success(let header) = result {
            guard header.operationCount >= plan.summary.normalizedStrokeOperationCount,
                header.operationCount - plan.summary.normalizedStrokeOperationCount <= limits.maximumOrdinaryRenderOperations else { return .failure(.capacityExhausted) }
        }
        return result
    }
    mutating func produce<S: DrawingOperationSink>(_ bank: borrowing SemanticRecordView<CounterPayload>, header: RenderPlanHeader, sink: inout S, limits: RuntimeProfileLimits) -> RenderProductionResult {
        return withCounterRenderLimits(&render, limits: limits) { render in CanvasRenderProducer.produce(semantic: SemanticRecordRenderView(bank), layout: resolved.renderView, textMetrics: GiftUIReferenceTextMetricsView(), drawingPlan: plan, surfaceBounds: counterSurface, damageMode: .initializeCompleteSurface, rootForeground: .white, limits: limits.render, expectedHeader: header, workspace: &render, sink: &sink) }
    }
    func verifyPlan(canvas: SemanticRecordReference, value: UInt8) -> Int { counterVerifyPlan(plan, canvas: canvas, bounds: resolved.renderView.bounds(of: canvas)!, value: value) }
    func bounds(_ record: SemanticRecordReference) -> Rect? { resolved.renderView.bounds(of: record) }
    func clip(_ record: SemanticRecordReference) -> Rect? { resolved.renderView.clip(of: record) }
    mutating func resetLayout() { workspace.resetLayout(); resolved.discard() }
    mutating func resetPlan() { plan.discard(); plan.reset() }
    mutating func resetRender() { render.reset() }
    mutating func reset() { resetRender(); resetPlan(); resetLayout() }
}
#endif
struct StaticCounterGeometry: CounterGeometry {
    // Actual supplied extents, retained through the enclosing factory lifetime.
    let scopeRegionBytes: Int
    let textRegionBytes: Int
    let pathRegionBytes: Int
    let planRegionBytes: Int
    borrowing func storageMeasurement() -> CounterGeometryMeasurement {
        .init(layout: LayoutLimits(maximumScopes: workspace.maximumScopes, maximumDepth: workspace.maximumDepth, maximumTextScalars: workspace.maximumTextScalars, maximumTextLines: workspace.maximumTextLines, maximumPositionedGlyphs: workspace.maximumPositionedGlyphs)!,
            render: render.capacity, renderWorkspace: render.structuralCapacity, drawing: plan.capacity,
            layoutBytes: UInt64(scopeRegionBytes + textRegionBytes + MemoryLayout<Self>.size - MemoryLayout<QualifiedRender>.size - MemoryLayout<StaticRecordDrawingWorkspace<StaticCounterDrawingWorkspace>>.size),
            renderBytes: UInt64(MemoryLayout<QualifiedRender>.size),
            pathBytes: UInt64(pathRegionBytes),
            planBytes: UInt64(planRegionBytes + MemoryLayout<StaticRecordDrawingWorkspace<StaticCounterDrawingWorkspace>>.size))
    }

    var workspace: StaticCounterLayoutWorkspace
    var resolved: StaticCounterResolvedLayoutStorage
    var references: InlineArray<64, SemanticRecordReference?> = .init(repeating: nil)
    var plan: StaticRecordDrawingWorkspace<StaticCounterDrawingWorkspace>
    var render: QualifiedRender
    init(scopes: UnsafeMutableRawBufferPointer, text: UnsafeMutableRawBufferPointer, path: UnsafeMutableRawBufferPointer, plan: UnsafeMutableRawBufferPointer) {
        scopeRegionBytes = scopes.count; textRegionBytes = text.count
        pathRegionBytes = path.count; planRegionBytes = plan.count
        workspace = StaticCounterLayoutWorkspace(scopes: scopes, text: text)!
        resolved = StaticCounterResolvedLayoutStorage(scopes: scopes, text: text)!
        self.plan = StaticRecordDrawingWorkspace(base: StaticCounterDrawingWorkspace(pathRegion: path, planRegion: plan, capacity: counterDrawingLimits)!)
        render = QualifiedRender(base: StaticCounterRenderWorkspace(region: text, capacity: counterRenderLimits, structuralCapacity: counterRenderCapacity)!)
    }
    var view: QualifiedLayout { QualifiedLayout(base: resolved.renderView, references: references) }
    mutating func layout(_ bank: borrowing SemanticRecordView<CounterPayload>, limits: RuntimeProfileLimits) -> LayoutResult {
        references = .init(repeating: nil)
        for index: UInt16 in 0..<bank.recordCount { references[Int(index)] = bank.reference(at: index) }
        return GiftUILayout.layout(semantic: LocalSemantic(bank), metrics: GiftUIReferenceTextMetricsView(), proposal: ProposedSize(width: 100, height: 120)!, limits: limits.layout, workspace: &workspace, sink: &resolved)
    }
    mutating func draw(source: inout CounterSource, context: ExecutionContext, limits: RuntimeProfileLimits) -> DrawingPlanResult {
        precondition(plan.withBase { $0.configure(limits: limits.drawing) })
        return CanvasPlanProducer.derive(source: &source, layout: view, executionContext: context, limits: limits.drawing, workspace: &plan)
    }
    mutating func preflight(_ bank: borrowing SemanticRecordView<CounterPayload>, limits: RuntimeProfileLimits) -> RenderProductionResult {
        let layout = view
        let result = withCounterRenderLimits(&render, limits: limits) { render in CanvasRenderProducer.preflight(semantic: SemanticRecordRenderView(bank), layout: layout, textMetrics: GiftUIReferenceTextMetricsView(), drawingPlan: plan, surfaceBounds: counterSurface, damageMode: .initializeCompleteSurface, rootForeground: .white, limits: limits.render, configuredSinkCapacity: limits.renderSink, workspace: &render) }
        if case .success(let header) = result {
            guard header.operationCount >= plan.summary.normalizedStrokeOperationCount,
                header.operationCount - plan.summary.normalizedStrokeOperationCount <= limits.maximumOrdinaryRenderOperations else { return .failure(.capacityExhausted) }
        }
        return result
    }
    mutating func produce<S: DrawingOperationSink>(_ bank: borrowing SemanticRecordView<CounterPayload>, header: RenderPlanHeader, sink: inout S, limits: RuntimeProfileLimits) -> RenderProductionResult {
        let layout = view
        return withCounterRenderLimits(&render, limits: limits) { render in CanvasRenderProducer.produce(semantic: SemanticRecordRenderView(bank), layout: layout, textMetrics: GiftUIReferenceTextMetricsView(), drawingPlan: plan, surfaceBounds: counterSurface, damageMode: .initializeCompleteSurface, rootForeground: .white, limits: limits.render, expectedHeader: header, workspace: &render, sink: &sink) }
    }
    func verifyPlan(canvas: SemanticRecordReference, value: UInt8) -> Int { counterVerifyPlan(plan, canvas: canvas, bounds: view.bounds(of: canvas)!, value: value) }
    func bounds(_ record: SemanticRecordReference) -> Rect? { view.bounds(of: record) }
    func clip(_ record: SemanticRecordReference) -> Rect? { view.clip(of: record) }
    mutating func resetLayout() { resolved.discard(); workspace.resetLayout(); references = .init(repeating: nil) }
    mutating func resetPlan() { plan.discard(); plan.reset() }
    mutating func resetRender() { render.reset() }
    mutating func reset() { resetRender(); resetPlan(); resetLayout() }
}

// The pointer is created and destroyed inside this callback; the result is only
// a RenderProductionResult. The underlying typed workspace remains the owner.
private func withCounterRenderLimits<Base: RenderProductionWorkspace>(_ base: inout Base, limits: RuntimeProfileLimits, _ body: (inout CounterConfiguredRender<Base>) -> RenderProductionResult) -> RenderProductionResult {
    precondition(counterRenderWorkspaceCovers(base.structuralCapacity, limits.renderWorkspace))
    return withUnsafeMutablePointer(to: &base) { pointer in
        var bounded = CounterConfiguredRender(base: pointer, capacity: limits.render, structuralCapacity: limits.renderWorkspace)
        return body(&bounded)
    }
}
private struct CounterConfiguredRender<Base: RenderProductionWorkspace>: RenderProductionWorkspace {
    typealias Identity = Base.Identity
    let base: UnsafeMutablePointer<Base>
    let capacity: RenderLimits
    let structuralCapacity: RenderWorkspaceCapacity
    var isActive: Bool { base.pointee.isActive }
    var currentForeground: Color? { base.pointee.currentForeground }
    mutating func acquire() -> Bool { base.pointee.acquire() }
    mutating func visitSemanticScope(at ordinal: UInt16) -> RenderWorkspaceVisit { base.pointee.visitSemanticScope(at: ordinal) }
    mutating func visitLayoutScope(at ordinal: UInt16) -> RenderWorkspaceVisit { base.pointee.visitLayoutScope(at: ordinal) }
    mutating func pushForeground(_ color: Color) -> Bool { base.pointee.pushForeground(color) }
    mutating func popForeground() -> Bool { base.pointee.popForeground() }
    mutating func reset() { base.pointee.reset() }
}

func counterRenderWorkspaceCovers(_ physical: RenderWorkspaceCapacity, _ configured: RenderWorkspaceCapacity) -> Bool {
    physical.maximumSemanticScopes >= configured.maximumSemanticScopes && physical.maximumLayoutScopes >= configured.maximumLayoutScopes && physical.maximumTraversalDepth >= configured.maximumTraversalDepth && physical.maximumTextLines >= configured.maximumTextLines
}

struct CounterGeometryMeasurement: Equatable {
    let layout: LayoutLimits
    let render: RenderLimits
    let renderWorkspace: RenderWorkspaceCapacity
    let drawing: DrawingLimits
    let layoutBytes: UInt64
    let renderBytes: UInt64
    let pathBytes: UInt64
    let planBytes: UInt64
}

