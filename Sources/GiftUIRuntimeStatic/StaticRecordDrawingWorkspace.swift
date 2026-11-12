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
    @usableFromInline
    var base: Base
    @usableFromInline
    var qualification: SemanticRecordReference?

    @inlinable
    @inline(__always)
    package init(base: consuming Base) { self.base = consume base }
    @inlinable
    @inline(__always)
    package mutating func withBase<Result>(_ body: (inout Base) -> Result) -> Result { body(&base) }
    @inlinable
    @inline(__always)
    package var capacity: DrawingLimits { base.capacity }
    @inlinable
    @inline(__always)
    package var isActive: Bool { base.isActive }
    @inlinable
    @inline(__always)
    package var summary: DrawingPlanSummary { base.summary }
    @inlinable
    @inline(__always)
    package mutating func acquire() -> Bool {
        StaticRecordDrawingQualification.acquire(base: &base, qualification: &qualification)
    }
    @inlinable
    @inline(__always)
    package mutating func withCanvasContext<Result>(
        identity: SemanticRecordReference, surfaceOrigin: Point, inheritedClip: Rect,
        _ body: (inout GraphicsContext) throws(DrawingError) -> Result
    ) throws(DrawingError) -> Result {
        try StaticRecordDrawingQualification.withCanvasContext(
            base: &base, qualification: &qualification, identity: identity,
            surfaceOrigin: surfaceOrigin, inheritedClip: inheritedClip, body)
    }
    @inlinable
    @inline(__always)
    package mutating func seal(canvasOccurrenceCount: UInt16) -> DrawingPlanResult {
        base.seal(canvasOccurrenceCount: canvasOccurrenceCount)
    }
    @inlinable
    @inline(__always)
    package mutating func discard() {
        StaticRecordDrawingQualification.discard(base: &base, qualification: &qualification)
    }
    @inlinable
    @inline(__always)
    package mutating func reset() {
        StaticRecordDrawingQualification.reset(base: &base, qualification: &qualification)
    }
    @inlinable
    @inline(__always)
    package func strokeCount(of canvas: SemanticRecordReference) -> UInt16? {
        matches(canvas) ? base.strokeCount(of: canvas.ordinal) : nil
    }
    @inlinable
    @inline(__always)
    package func strokeHeader(of canvas: SemanticRecordReference, at index: UInt16)
        -> StraightLineStrokeHeader?
    {
        matches(canvas) ? base.strokeHeader(of: canvas.ordinal, at: index) : nil
    }
    @inlinable
    @inline(__always)
    package func point(of canvas: SemanticRecordReference, stroke: UInt16, at index: UInt16)
        -> Point?
    {
        matches(canvas) ? base.point(of: canvas.ordinal, stroke: stroke, at: index) : nil
    }
    @inlinable
    @inline(__always)
    package func subpath(of canvas: SemanticRecordReference, stroke: UInt16, at index: UInt16)
        -> SubpathRange?
    {
        matches(canvas) ? base.subpath(of: canvas.ordinal, stroke: stroke, at: index) : nil
    }
    @inlinable
    @inline(__always)
    internal func matches(_ reference: SemanticRecordReference) -> Bool {
        StaticRecordDrawingQualification.matches(qualification, reference)
    }
}

/// Qualifies a local-ordinal Drawing workspace without moving its base storage.
@usableFromInline
package enum StaticRecordDrawingQualification {
    @inlinable
    @inline(__always)
    package static func acquire<Base: DrawingPlanWorkspace>(
        base: inout Base, qualification: inout SemanticRecordReference?
    ) -> Bool {
        guard base.acquire() else { return false }
        qualification = nil
        return true
    }

    @inlinable
    @inline(__always)
    package static func withCanvasContext<Base: DrawingPlanConstructionWorkspace, Result>(
        base: inout Base, qualification: inout SemanticRecordReference?,
        identity: SemanticRecordReference, surfaceOrigin: Point, inheritedClip: Rect,
        _ body: (inout GraphicsContext) throws(DrawingError) -> Result
    ) throws(DrawingError) -> Result where Base.Identity == UInt16 {
        if qualification == nil { qualification = identity }
        guard matches(qualification, identity) else { throw .invariantViolation }
        return try base.withCanvasContext(
            identity: identity.ordinal, surfaceOrigin: surfaceOrigin, inheritedClip: inheritedClip,
            body)
    }

    @inlinable
    @inline(__always)
    package static func discard<Base: DrawingPlanWorkspace>(
        base: inout Base, qualification: inout SemanticRecordReference?
    ) {
        base.discard()
        qualification = nil
    }

    @inlinable
    @inline(__always)
    package static func reset<Base: DrawingPlanWorkspace>(
        base: inout Base, qualification: inout SemanticRecordReference?
    ) {
        base.reset()
        qualification = nil
    }

    @inlinable
    @inline(__always)
    package static func matches(
        _ qualification: SemanticRecordReference?, _ reference: SemanticRecordReference
    ) -> Bool {
        guard let qualification else { return false }
        return qualification.owner == reference.owner && qualification.bank == reference.bank
            && qualification.revision == reference.revision
    }
}
