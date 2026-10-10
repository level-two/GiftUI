import GiftUI
import GiftUIExecution
import GiftUILayout
import GiftUIRenderCore

package protocol CanvasInvocationSource {
    associatedtype Identity: Equatable, Sendable

    var canvasOccurrenceCount: UInt16 { get }

    func canvasIdentity(at index: UInt16) -> Identity?

    mutating func invokeCanvas<Reads: FrozenAccess & ~Escapable>(
        at identity: Identity,
        context: inout GraphicsContext,
        size: Size
    , read: borrowing Reads) throws(DrawingError)

    mutating func releaseCanvas(at identity: Identity)
}
