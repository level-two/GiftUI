import GiftUI
import GiftUIRenderCore

package protocol DrawingPlanView {
    associatedtype Identity: Equatable, Sendable

    var summary: DrawingPlanSummary { get }

    func strokeCount(of canvas: Identity) -> UInt16?

    func strokeHeader(
        of canvas: Identity,
        at index: UInt16
    ) -> StraightLineStrokeHeader?

    func point(
        of canvas: Identity,
        stroke: UInt16,
        at index: UInt16
    ) -> Point?

    func subpath(
        of canvas: Identity,
        stroke: UInt16,
        at index: UInt16
    ) -> SubpathRange?
}

package protocol DrawingPlanWorkspace: DrawingPlanView {
    var capacity: DrawingLimits { get }
    var isActive: Bool { get }

    mutating func acquire() -> Bool
    mutating func discard()
    mutating func reset()
}

package protocol DrawingPlanConstructionWorkspace: DrawingPlanWorkspace {
    mutating func withCanvasContext<Result>(
        identity: Identity,
        surfaceOrigin: Point,
        inheritedClip: Rect,
        _ body: (
            inout GraphicsContext
        ) throws(DrawingError) -> Result
    ) throws(DrawingError) -> Result

    mutating func seal(
        canvasOccurrenceCount: UInt16
    ) -> DrawingPlanResult
}
