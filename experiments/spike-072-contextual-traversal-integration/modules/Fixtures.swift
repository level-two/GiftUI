import GiftUI
import GiftUISemanticCore
import GiftUIRenderCore
import GiftUITextResources
import GiftUILayout
import GiftUIExecution
import GiftUIDrawing
// Bounded test adapters. Actual SemanticCore and CanvasPlanProducer are in adapted/.
struct GraphWorkspace: SemanticExpansionWorkspace {
    let maximumPathComponents: UInt16 = 15
    let maximumIdentities: UInt16 = 64
    var isExpanding = false
    var path: UInt64 = 0
    var discarded = false
    mutating func beginExpansion() -> Bool { isExpanding=true; path=0; return true }
    mutating func enter(_ tag: UInt64, identity: inout UInt64?) -> SemanticExpansionError? {
        guard path < (UInt64.max >> 4) else { return .capacityExhausted }
        path = path << 4 | tag; identity=path; return nil
    }
    mutating func enterRoot<D: View>(_ type: D.Type, identity: inout UInt64?) -> SemanticExpansionError? { enter(1,identity:&identity) }
    mutating func enterCustomBody<D: View>(_ type: D.Type, identity: inout UInt64?) -> SemanticExpansionError? { enter(2,identity:&identity) }
    mutating func enterFixedChild(_ index: UInt8, identity: inout UInt64?) -> SemanticExpansionError? { enter(3+UInt64(index),identity:&identity) }
    mutating func enterConditionalBranch(_ index: UInt8, identity: inout UInt64?) -> SemanticExpansionError? { enter(9+UInt64(index),identity:&identity) }
    mutating func enterOptionalPresence(identity: inout UInt64?) -> SemanticExpansionError? { enter(11,identity:&identity) }
    // This fixture tests path sequence, not the full production nominal-role codec.
    mutating func enterDeclarationRole<D>(_ type: D.Type, identity: inout UInt64?) -> SemanticExpansionError? { enter(15,identity:&identity) }
    mutating func leavePathComponent() { path >>= 4 }
    mutating func completeExpansion() {}
    mutating func discardExpansion() { discarded=true }
    mutating func resetExpansion() { isExpanding=false; path=0 }
}
struct Occurrence {
    let identity: UInt64
    let canvas: Meter
}
struct GraphSink: SemanticExpansionSink, CanvasInvocationSource {
    let maximumStructuralOccurrences: UInt16 = 64
    let maximumBodyEvaluations: UInt16 = 16
    let maximumSemanticOccurrences: UInt16 = 16
    let maximumModifierApplications: UInt16 = 16
    let maximumActionOccurrences: UInt16 = 16
    var first: Occurrence?
    var second: Occurrence?
    var third: Occurrence?
    var canvasOccurrenceCount: UInt16 = 0
    var structural: UInt16 = 0
    var bodies: UInt16 = 0
    var published = false
    var discarded = false
    var invoked: UInt32 = 0
    var released: UInt32 = 0
    var releaseMask: UInt32 = 0
    var failAt: UInt16 = UInt16.max
    var savedFirst: UInt64 = 0
    var savedSecond: UInt64 = 0
    var savedThird: UInt64 = 0
    mutating func beginExpansion() -> Bool { true }
    mutating func stageStructuralOccurrence(identity: borrowing UInt64) -> Bool { structural+=1; return true }
    mutating func stageBodyEvaluation(identity: borrowing UInt64) -> Bool { bodies+=1; return true }
    mutating func stageSemanticOccurrence<P: _GiftUISemanticPrimitivePayload>(identity: borrowing UInt64,payload: borrowing P) -> Bool {
        let value=copy payload
        if let canvas=value as? Meter {
            let occurrence=Occurrence(identity:identity,canvas:canvas)
            switch canvasOccurrenceCount {
            case 0: first=occurrence; savedFirst=copy identity
            case 1: second=occurrence; savedSecond=copy identity
            case 2: third=occurrence; savedThird=copy identity
            default: return false
            }
            canvasOccurrenceCount+=1
        }
        return true
    }
    mutating func stageModifierApplication<P: _GiftUISemanticModifierPayload>(identity: borrowing UInt64,payload: borrowing P,chainIndex: UInt16) -> Bool { true }
    mutating func stageActionOccurrence<A: GiftUIAction>(identity: borrowing UInt64,action: borrowing A) -> Bool { true }
    mutating func publishExpansion(_ summary: SemanticExpansionSummary) -> Bool { published=true; return true }
    mutating func discardExpansion() { discarded=true; first=nil; second=nil; third=nil }
    mutating func resetExpansion() {}
    func canvasIdentity(at index: UInt16) -> UInt64? {
        guard index < canvasOccurrenceCount else { return nil }
        switch index { case 0: return savedFirst; case 1: return savedSecond; default: return savedThird }
    }
    mutating func invokeCanvas<R: FrozenAccess & ~Escapable>(at identity: UInt64,context: inout GraphicsContext,size: Size,read: borrowing R) throws(DrawingError) {
        let value: Meter
        let index: UInt16
        if identity == savedFirst, let first { value=first.canvas; index=0 }
        else if identity == savedSecond, let second { value=second.canvas; index=1 }
        else if identity == savedThird, let third { value=third.canvas; index=2 }
        else { throw .invalidScope }
        invoked=invoked*10+UInt32(index+1)
        if index==failAt { try drawBar(value:99,scale:0,context:&context) }
        let bounds=Rect(origin:Point(x:0,y:0),size:size)!
        try value.draw(in:bounds,context:&context,read:read)
    }
    mutating func releaseCanvas(at identity: UInt64) {
        let index: UInt32
        if identity==savedFirst { first=nil; index=1 }
        else if identity==savedSecond { second=nil; index=2 }
        else { third=nil; index=3 }
        released=released*10+index
        releaseMask |= 1 << index
    }
}
struct LayoutFixture: ResolvedRenderLayoutView {
    let first: UInt64
    let second: UInt64
    let third: UInt64
    let layoutScopeCount: UInt16 = 3
    let renderSnapshotVersion: UInt32 = 1
    var rootIdentity: UInt64 { first }
    var rootBounds: Rect { Rect(origin:Point(x:0,y:0),size:Size(width:100,height:10)!)! }
    func layoutIdentity(at ordinal: UInt16) -> UInt64? {
        switch ordinal { case 0:first; case 1:second; case 2:third; default:nil }
    }
    func layoutOrdinal(of identity: UInt64) -> UInt16? {
        if identity==first { return 0 }; if identity==second { return 1 }; if identity==third { return 2 }; return nil
    }
    func bounds(of identity: UInt64) -> Rect? { layoutOrdinal(of:identity) == nil ? nil : rootBounds }
    func clip(of identity: UInt64) -> Rect? { bounds(of:identity) }
    func textLineCount(of identity: UInt64) -> UInt16? { 0 }
    func textLine(of identity: UInt64,at index: UInt16) -> ResolvedRenderTextLine? { nil }
    func glyph(of identity: UInt64,at index: UInt16) -> ResolvedRenderGlyph? { nil }
}
struct DrawingWorkspace: DrawingPlanConstructionWorkspace {
    let capacity=DrawingLimits(maximumLineWidth:4,maximumCanvasOccurrences:3,maximumLivePathPoints:8,maximumLivePathSubpaths:3,maximumPlanStrokes:3,maximumPlanPoints:6,maximumPlanSubpaths:3,maximumNormalizedStrokeOperations:3)!
    var isActive=false
    var recorder=Recorder()
    var discarded=false
    var resetCount=0
    var summary=DrawingPlanSummary(canvasOccurrenceCount:0,strokeCount:0,pointCount:0,subpathCount:0,normalizedStrokeOperationCount:0)
    mutating func acquire() -> Bool { isActive=true; return true }
    mutating func discard() { discarded=true; isActive=false }
    mutating func reset() { isActive=false; resetCount+=1 }
    mutating func withCanvasContext<T>(identity:UInt64,surfaceOrigin:Point,inheritedClip:Rect,_ body:(inout GraphicsContext)throws(DrawingError)->T) throws(DrawingError)->T {
        do throws(DrawingError) {
            return try withUnsafeMutablePointer(to:&recorder) { (pointer: UnsafeMutablePointer<Recorder>) throws(DrawingError) -> T in
                var context=makeContext(UnsafeMutableRawPointer(pointer))
                defer { context.invalidate() }
                return try body(&context)
            }
        } catch { throw error }
    }
    mutating func seal(canvasOccurrenceCount:UInt16)->DrawingPlanResult {
        isActive=false
        summary=DrawingPlanSummary(canvasOccurrenceCount:canvasOccurrenceCount,strokeCount:UInt16(recorder.strokes),pointCount:UInt16(recorder.lines*2),subpathCount:UInt16(recorder.strokes),normalizedStrokeOperationCount:UInt16(recorder.strokes))
        return .success(summary)
    }
    // Geometry is inspected through the recorder, not an immutable production plan.
    func strokeCount(of canvas:UInt64)->UInt16? { 1 }
    func strokeHeader(of canvas:UInt64,at index:UInt16)->StraightLineStrokeHeader? { nil }
    func point(of canvas:UInt64,stroke:UInt16,at index:UInt16)->Point? { nil }
    func subpath(of canvas:UInt64,stroke:UInt16,at index:UInt16)->SubpathRange? { nil }
}
