import CycleTable
import GiftUI
import GiftUIDrawing
import GiftUIExecution
import GiftUILayout
import GiftUIRenderCore
import GiftUIReferenceTextResources
import GiftUIObservableState
@testable import GiftUISemanticCore
import CycleSchema
#if !hasFeature(Embedded)
import GiftUIRuntimeCore
import GiftUIInteraction
@testable import GiftUIRuntimeDynamic

package func cycleDynamicDrawing(
    semantic: borrowing SemanticRecordStore,
    models: borrowing ObservableModelScope<CycleOwnedModel, CycleModelSchema>,
    values: borrowing CanvasStagedValues<SemanticRecordReference, CycleValueTable>,
    shown: Bool
) -> Int {
    let layoutLimits = LayoutLimits(maximumScopes: 98, maximumDepth: 19, maximumTextScalars: 224, maximumTextLines: 98, maximumPositionedGlyphs: 224)!
    var workspace = DynamicLayoutWorkspace(limits: layoutLimits, maximumSemanticRecords: 126)
    let layoutBytes = workspace.reservedPayloadBytes
    var resolved = DynamicResolvedLayoutStorage(limits: layoutLimits)
    let resolvedBytes = resolved.reservedPayloadBytes
    do throws(SemanticExpansionError) {
        try semantic.withCandidateView { bank in
            let result = layout(semantic: SemanticRecordLayoutView(bank), metrics: GiftUIReferenceTextMetricsView(), proposal: ProposedSize(width: 100, height: 100)!, limits: layoutLimits, workspace: &workspace, sink: &resolved)
            guard case .success = result else { preconditionFailure("Dynamic layout") }
        }
    } catch { preconditionFailure("Dynamic semantic borrow") }
    let drawingLimits = DrawingLimits(maximumLineWidth: 4, maximumCanvasOccurrences: 1, maximumLivePathPoints: 4, maximumLivePathSubpaths: 2, maximumPlanStrokes: 1, maximumPlanPoints: 4, maximumPlanSubpaths: 2, maximumNormalizedStrokeOperations: 1)!
    var plan = DynamicDrawingPlanWorkspace(capacity: drawingLimits)
    let planBytes = plan.planReservedPayloadBytes
    let pathBytes = plan.livePathReservedPayloadBytes
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
    var render = DynamicRenderWorkspace(capacity: cycleRenderLimits, structuralCapacity: cycleRenderCapacity)
    let renderBytes = render.reservedPayloadBytes
    let renderChecks = cycleRender(semantic: semantic, layout: resolved.renderView, plan: plan, workspace: &render, shown: shown)
    plan.discard(); plan.reset()
    precondition(render.reservedPayloadBytes == renderBytes)
    precondition(workspace.reservedPayloadBytes == layoutBytes)
    precondition(resolved.reservedPayloadBytes == resolvedBytes)
    precondition(plan.planReservedPayloadBytes == planBytes && plan.livePathReservedPayloadBytes == pathBytes)
    return (shown ? 5 : 3) + renderChecks + 4
}
package func cycleDynamicStorageEdges() -> Int {
    var checks = 0
    func expect(_ value: Bool) { checks += 1; precondition(value) }
    var candidates = DynamicInteractionCandidateStorage<SemanticCompleteIdentity>(capacity: 6)
    var committed = DynamicInteractionCommittedStorage<SemanticCompleteIdentity>(capacity: 6)
    var hits = DynamicInteractionHitStorage<SemanticCompleteIdentity>(capacity: 6)
    let candidateBytes = candidates.reservedPayloadBytes, committedBytes = committed.reservedPayloadBytes, hitBytes = hits.reservedPayloadBytes
    expect(candidates.retainedElementCapacity >= 6 && committed.retainedElementCapacity >= 6 && hits.retainedElementCapacity >= 6)
    candidates.reset(); committed.reset(); hits.reset()
    expect(candidates.reservedPayloadBytes == candidateBytes && committed.reservedPayloadBytes == committedBytes && hits.reservedPayloadBytes == hitBytes)
    let limits = LayoutLimits(maximumScopes: 2, maximumDepth: 2, maximumTextScalars: 2, maximumTextLines: 2, maximumPositionedGlyphs: 2)!
    var workspace = DynamicLayoutWorkspace(limits: limits, maximumSemanticRecords: 4)
    let bytes = workspace.reservedPayloadBytes
    let measurement = LayoutMeasurement(idealSize: Size(width: 1, height: 1)!, resolvedSize: Size(width: 1, height: 1)!)
    var namespace = SemanticRecordOwnerNamespace()
    let firstOwner = try! namespace.issue(), secondOwner = try! namespace.issue()
    func ref(_ ordinal: UInt16, _ owner: UInt32 = 1, _ bank: UInt8 = 0, _ revision: UInt32 = 1) -> SemanticRecordReference {
        .init(owner: owner == 1 ? firstOwner : secondOwner, bank: bank, revision: revision, ordinal: ordinal)
    }
    expect(workspace.acquireLayout())
    expect(workspace.appendScope(identity: ref(3), measurement: measurement))
    expect(workspace.measurement(for: ref(3)) == measurement)
    expect(workspace.measurement(for: ref(3, 2)) == nil)
    expect(workspace.measurement(for: ref(3, 1, 1)) == nil)
    expect(workspace.measurement(for: ref(3, 1, 0, 2)) == nil)
    expect(!workspace.appendScope(identity: ref(3), measurement: measurement))
    expect(!workspace.appendScope(identity: ref(4), measurement: measurement))
    expect(workspace.appendScope(identity: ref(0), measurement: measurement))
    expect(!workspace.appendScope(identity: ref(1), measurement: measurement))
    expect(workspace.scopeCount == 2)
    workspace.resetLayout()
    expect(workspace.measurement(for: ref(3)) == nil)
    expect(workspace.appendScope(identity: ref(3, 2, 1, 2), measurement: measurement))
    expect(workspace.reservedPayloadBytes == bytes)

    let drawing = DrawingLimits(maximumLineWidth: 4, maximumCanvasOccurrences: 1, maximumLivePathPoints: 2, maximumLivePathSubpaths: 1, maximumPlanStrokes: 1, maximumPlanPoints: 2, maximumPlanSubpaths: 1, maximumNormalizedStrokeOperations: 1)!
    var plan = DynamicDrawingPlanWorkspace(capacity: drawing)
    let planBytes = plan.planReservedPayloadBytes, pathBytes = plan.livePathReservedPayloadBytes
    for _ in 0..<2 {
        expect(plan.acquire())
        do throws(DrawingError) {
            try plan.withCanvasContext(identity: ref(0), surfaceOrigin: Point(x: 0, y: 0), inheritedClip: Rect(origin: Point(x: 0, y: 0), size: Size(width: 10, height: 10)!)!) { (context) throws(DrawingError) in
                try context.withPath { (context, path) throws(DrawingError) in
                    try path.move(to: Point(x: 0, y: 0))
                    try path.addLine(to: Point(x: 1, y: 1))
                    do throws(DrawingError) { try path.addLine(to: Point(x: 2, y: 2)); preconditionFailure("live first excess accepted") }
                    catch { expect(error == .capacityExhausted) }
                    try context.stroke(path, with: .color(.white), lineWidth: 1)
                    do throws(DrawingError) { try context.stroke(path, with: .color(.white), lineWidth: 1); preconditionFailure("plan first excess accepted") }
                    catch { expect(error == .capacityExhausted) }
                }
            }
        } catch { preconditionFailure("drawing edges") }
        expect(plan.pointCount == 2 && plan.subpathCount == 1 && plan.strokeCount == 1)
        guard case .success = plan.seal(canvasOccurrenceCount: 1) else { preconditionFailure("seal") }
        expect(plan.point(of: ref(0), stroke: 0, at: 1) == Point(x: 1, y: 1))
        plan.reset()
        expect(plan.pointCount == 0 && plan.subpathCount == 0 && plan.strokeCount == 0)
        expect(plan.planReservedPayloadBytes == planBytes && plan.livePathReservedPayloadBytes == pathBytes)
    }
    return checks
}
package func cycleDynamicDrawingRollback() -> Int {
    var namespace = SemanticRecordOwnerNamespace()
    let canvas = SemanticRecordReference(owner: try! namespace.issue(), bank: 0, revision: 1, ordinal: 0)
    var plan = DynamicDrawingPlanWorkspace(capacity: cycleDrawingLimits)
    let planBytes = plan.planReservedPayloadBytes, pathBytes = plan.livePathReservedPayloadBytes
    var checks = 0
    func expect(_ value: Bool) { checks += 1; precondition(value, "Dynamic malformed Drawing rollback") }
    for _ in 0..<2 {
        expect(plan.acquire())
        do throws(DrawingError) {
            try plan.withCanvasContext(identity: canvas, surfaceOrigin: cycleFaultOrigin, inheritedClip: cycleSurface) { (_: inout GraphicsContext) throws(DrawingError) in }
        } catch { preconditionFailure("Dynamic rollback canvas") }
        expect(plan.appendSnapshot(header: cycleFaultHeader, path: CycleMalformedPath(fault: 0), canvas: canvas, origin: cycleFaultOrigin))
        for fault: UInt8 in 1...3 {
            expect(!plan.appendSnapshot(header: cycleFaultHeader, path: CycleMalformedPath(fault: fault), canvas: canvas, origin: cycleFaultOrigin))
            expect(plan.pointCount == 4 && plan.subpathCount == 2 && plan.strokeCount == 1)
        }
        expect(plan.appendSnapshot(header: cycleFaultHeader, path: CycleMalformedPath(fault: 0), canvas: canvas, origin: cycleFaultOrigin))
        expect(plan.pointCount == 8 && plan.subpathCount == 4 && plan.strokeCount == 2)
        guard case .success = plan.seal(canvasOccurrenceCount: 1) else { preconditionFailure("Dynamic rollback seal") }
        checks += 1
        for stroke: UInt16 in 0..<2 {
            expect(plan.strokeHeader(of: canvas, at: stroke) == cycleFaultHeader)
            for index: UInt16 in 0..<4 { expect(plan.point(of: canvas, stroke: stroke, at: index) == Point(x: GeometryScalar(index) + 1, y: GeometryScalar(index) + 2)) }
            for index: UInt16 in 0..<2 { expect(plan.subpath(of: canvas, stroke: stroke, at: index) == SubpathRange(firstPoint: index * 2, pointCount: 2)) }
        }
        plan.discard(); plan.reset()
        expect(plan.pointCount == 0 && plan.subpathCount == 0 && plan.strokeCount == 0)
        expect(plan.planReservedPayloadBytes == planBytes && plan.livePathReservedPayloadBytes == pathBytes)
    }
    return checks
}

#endif
