import GiftUI
import GiftUIDrawing
import GiftUIRenderCore
import GiftUISemanticCore

/// Qualifies a fixed Drawing workspace's local ordinals with the complete
/// candidate-bank identity. Geometry remains owned by the supplied workspace;
/// no model, read, or semantic-bank borrow is retained in the plan.
package struct StaticRecordDrawingWorkspace<Base: DrawingPlanConstructionWorkspace>:
    DrawingPlanConstructionWorkspace
where Base.Identity == UInt16 {
    package typealias Identity = SemanticRecordReference
    private var base: Base
    private var qualification: SemanticRecordReference?

    package init(base: consuming Base) { self.base = consume base }
    package mutating func withBase<Result>(_ body: (inout Base) -> Result) -> Result { body(&base) }
    package var capacity: DrawingLimits { base.capacity }
    package var isActive: Bool { base.isActive }
    package var summary: DrawingPlanSummary { base.summary }
    package mutating func acquire() -> Bool {
        guard base.acquire() else { return false }
        qualification = nil
        return true
    }
    package mutating func withCanvasContext<Result>(
        identity: SemanticRecordReference, surfaceOrigin: Point, inheritedClip: Rect,
        _ body: (inout GraphicsContext) throws(DrawingError) -> Result
    ) throws(DrawingError) -> Result {
        if qualification == nil { qualification = identity }
        guard matches(identity) else { throw .invariantViolation }
        return try base.withCanvasContext(
            identity: identity.ordinal, surfaceOrigin: surfaceOrigin, inheritedClip: inheritedClip,
            body)
    }
    package mutating func seal(canvasOccurrenceCount: UInt16) -> DrawingPlanResult {
        base.seal(canvasOccurrenceCount: canvasOccurrenceCount)
    }
    package mutating func discard() {
        base.discard()
        qualification = nil
    }
    package mutating func reset() {
        base.reset()
        qualification = nil
    }
    package func strokeCount(of canvas: SemanticRecordReference) -> UInt16? {
        matches(canvas) ? base.strokeCount(of: canvas.ordinal) : nil
    }
    package func strokeHeader(of canvas: SemanticRecordReference, at index: UInt16)
        -> StraightLineStrokeHeader?
    {
        matches(canvas) ? base.strokeHeader(of: canvas.ordinal, at: index) : nil
    }
    package func point(of canvas: SemanticRecordReference, stroke: UInt16, at index: UInt16)
        -> Point?
    {
        matches(canvas) ? base.point(of: canvas.ordinal, stroke: stroke, at: index) : nil
    }
    package func subpath(of canvas: SemanticRecordReference, stroke: UInt16, at index: UInt16)
        -> SubpathRange?
    {
        matches(canvas) ? base.subpath(of: canvas.ordinal, stroke: stroke, at: index) : nil
    }
    private func matches(_ reference: SemanticRecordReference) -> Bool {
        guard let qualification else { return false }
        return qualification.owner == reference.owner && qualification.bank == reference.bank
            && qualification.revision == reference.revision
    }
}
