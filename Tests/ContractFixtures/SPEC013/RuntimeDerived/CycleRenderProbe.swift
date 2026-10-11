import GiftUI
import GiftUIDrawing
import GiftUILayout
import GiftUIRenderCore
import GiftUIRenderLowering
import GiftUIReferenceTextResources
import GiftUISemanticCore

package struct CycleRenderSink: DrawingOperationSink {
    package let capacity = RenderSinkCapacity(maximumOperations: 128, maximumPositionedGlyphs: 224)
    var header: RenderPlanHeader?
    var operations: UInt16 = 0
    var glyphs: UInt16 = 0
    var strokes: UInt16 = 0
    var points: UInt16 = 0
    var finishes = 0
    var discards = 0
    package mutating func begin(_ header: RenderPlanHeader) -> Bool { self.header = header; return true }
    package mutating func fillRect(_ operation: FillRectOperation) -> Bool { operations += 1; return true }
    package mutating func beginPositionedGlyphs(_ operation: PositionedGlyphOperationHeader) -> Bool { operations += 1; return true }
    package mutating func positionedGlyph(_ glyph: PositionedGlyph) -> Bool { glyphs += 1; return true }
    package mutating func endPositionedGlyphs() -> Bool { true }
    package mutating func finish() -> Bool { finishes += 1; return true }
    package mutating func discard() { discards += 1 }
    package mutating func straightLineStroke<S: StraightLineStrokeView>(_ stroke: borrowing S) -> Bool {
        operations += 1; strokes += 1
        for i: UInt16 in 0..<stroke.header.pointCount { let point = stroke.point(at: i); precondition(point != nil); points += 1 }
        for i: UInt16 in 0..<stroke.header.subpathCount { let subpath = stroke.subpath(at: i); precondition(subpath != nil) }
        return true
    }
}
package let cycleRenderLimits = RenderLimits(maximumOperations: 128, maximumPositionedGlyphs: 224, maximumClipDepth: 19)!
package let cycleRenderCapacity = RenderWorkspaceCapacity(maximumSemanticScopes: 98, maximumLayoutScopes: 98, maximumTraversalDepth: 19, maximumTextLines: 128)!
package func cycleRender<Layout: ResolvedRenderLayoutView, Plan: DrawingPlanView, Workspace: RenderProductionWorkspace>(semantic: borrowing SemanticRecordStore<CanvasSemanticPayload<CycleValueTable.CaptureStorage>>, layout: borrowing Layout, plan: borrowing Plan, workspace: inout Workspace, shown: Bool) -> Int where Layout.Identity == SemanticRecordReference, Plan.Identity == SemanticRecordReference, Workspace.Identity == SemanticRecordReference {
    let layout = copy layout
    let plan = copy plan
    var sink = CycleRenderSink()
    do throws(SemanticExpansionError) {
        try semantic.withCandidateView { bank in
            let view = SemanticRecordRenderView(bank)
            let surface = Rect(origin: Point(x: 0, y: 0), size: Size(width: 100, height: 100)!)!
            let preflight = CanvasRenderProducer.preflight(semantic: view, layout: layout, textMetrics: GiftUIReferenceTextMetricsView(), drawingPlan: plan, surfaceBounds: surface, damageMode: .initializeCompleteSurface, rootForeground: .white, limits: cycleRenderLimits, configuredSinkCapacity: sink.capacity, workspace: &workspace)
            guard case .success(let header) = preflight else { preconditionFailure("combined preflight") }
            let result = CanvasRenderProducer.produce(semantic: view, layout: layout, textMetrics: GiftUIReferenceTextMetricsView(), drawingPlan: plan, surfaceBounds: surface, damageMode: .initializeCompleteSurface, rootForeground: .white, limits: cycleRenderLimits, expectedHeader: header, workspace: &workspace, sink: &sink)
            precondition(result == .success(header))
            precondition(sink.header == header && sink.operations == header.operationCount && sink.glyphs == header.positionedGlyphCount)
        }
    } catch { preconditionFailure("render bank borrow") }
    precondition(sink.strokes == (shown ? 1 : 0) && sink.points == (shown ? 2 : 0))
    precondition(sink.finishes == 1 && sink.discards == 0)
    precondition(!workspace.isActive)
    return 5
}
