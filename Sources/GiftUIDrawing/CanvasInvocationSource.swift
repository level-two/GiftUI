import GiftUI

package protocol CanvasInvocationSource {
    associatedtype Identity: Equatable, Sendable

    var canvasOccurrenceCount: UInt16 { get }

    func canvasIdentity(at index: UInt16) -> Identity?

    mutating func invokeCanvas(
        at identity: Identity,
        context: inout GraphicsContext,
        size: Size
    ) throws(DrawingError)

    mutating func releaseCanvas(at identity: Identity)
}
