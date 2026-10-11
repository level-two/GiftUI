import GiftUI
import GiftUIObservableState

// Compile proof only. This declaration retains the actual P03 lifetime-bearing
// model scope, not a copyable raw pointer descriptor or a prebuilt read facade.
package struct ScopedCanvasSource<Model: ~Copyable, Schema>:
    ~Copyable, ~Escapable, CanvasInvocationSource
{
    package typealias Identity = UInt16
    private let models: ObservableModelScope<Model, Schema>
    @_lifetime(copy models)
    package init(models: consuming ObservableModelScope<Model, Schema>) {
        self.models = consume models
    }
    package var canvasOccurrenceCount: UInt16 { 0 }
    package func canvasIdentity(at index: UInt16) -> UInt16? { nil }
    package mutating func invokeCanvas(
        at identity: UInt16, context: inout GraphicsContext, size: Size
    ) throws(DrawingError) { throw .invariantViolation }
    package mutating func releaseCanvas(at identity: UInt16) {}
}
