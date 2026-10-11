import GiftUI
import GiftUIObservableState
package func producer<Source: CanvasInvocationSource & ~Copyable & ~Escapable>(source: inout Source) {}
package func call<Model: ~Copyable, Schema>(source: inout ScopedCanvasSource<Model, Schema>) {
    producer(source: &source)
}
