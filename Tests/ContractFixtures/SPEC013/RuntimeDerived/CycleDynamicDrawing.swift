import GiftUI
import GiftUIDrawing
import GiftUIExecution
import GiftUILayout
import GiftUIObservableState
import GiftUISemanticCore
import CycleSchema
#if !hasFeature(Embedded)
import GiftUIRuntimeCore
import GiftUIRuntimeDynamic

package func cycleDynamicDrawing(
    semantic: borrowing SemanticRecordStore<CanvasSemanticPayload<CycleValueTable.CaptureStorage>>,
    models: borrowing ObservableModelScope<CycleOwnedModel, CycleModelSchema>,
    values: borrowing CanvasStagedValues<SemanticRecordReference, CycleValueTable>,
    shown: Bool
) -> Int {
    let layoutLimits = LayoutLimits(maximumScopes: 98, maximumDepth: 19, maximumTextScalars: 224, maximumTextLines: 98, maximumPositionedGlyphs: 224)!
    var workspace = DynamicLayoutWorkspace(limits: layoutLimits)
    var resolved = DynamicResolvedLayoutStorage(limits: layoutLimits)
    do throws(SemanticExpansionError) {
        try semantic.withCandidateView { bank in
            let result = layout(semantic: SemanticRecordLayoutView(bank), metrics: StaticTextMetricsView(), proposal: ProposedSize(width: 100, height: 100)!, limits: layoutLimits, workspace: &workspace, sink: &resolved)
            guard case .success = result else { preconditionFailure("Dynamic layout") }
        }
    } catch { preconditionFailure("Dynamic semantic borrow") }
    let drawingLimits = DrawingLimits(maximumLineWidth: 4, maximumCanvasOccurrences: 1, maximumLivePathPoints: 4, maximumLivePathSubpaths: 2, maximumPlanStrokes: 1, maximumPlanPoints: 4, maximumPlanSubpaths: 2, maximumNormalizedStrokeOperations: 1)!
    var plan = DynamicDrawingPlanWorkspace(capacity: drawingLimits)
    var source = ObservableCanvasInvocationSource(models: models.borrowedScope(), values: values.borrowedValues(), table: CycleValueTable())
    let context = ExecutionContext(cycle: RunCycleID(rawValue: 1), semanticRevision: nil, candidateFrame: nil, phase: .deriving)
    let canvas = values.identity(at: 0)
    let result = CanvasPlanProducer.derive(source: &source, layout: resolved.renderView, executionContext: context, limits: drawingLimits, workspace: &plan)
    guard case .success(let summary) = result else { preconditionFailure("Dynamic drawing") }
    precondition(summary.canvasOccurrenceCount == (shown ? 1 : 0))
    precondition(summary.strokeCount == (shown ? 1 : 0))
    precondition(values.releaseCount == (shown ? 1 : 0))
    if let canvas {
        precondition(plan.strokeCount(of: canvas) == 1)
        let bounds = resolved.renderView.bounds(of: canvas)!
        precondition(plan.point(of: canvas, stroke: 0, at: 0) == Point(x: bounds.origin.x, y: bounds.origin.y + 3))
    }
    plan.discard(); plan.reset()
    return shown ? 5 : 3
}
#endif
