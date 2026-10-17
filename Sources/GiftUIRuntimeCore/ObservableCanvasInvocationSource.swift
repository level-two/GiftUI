import GiftUI
import GiftUIDrawing
import GiftUIObservableState

/// The source owns no read or model. Both actual owner and staged backing must
/// outlive this lexical adapter; each invocation creates and ends a fresh read.
package struct ObservableCanvasInvocationSource<
    Model: ~Copyable, Schema,
    Identity: Equatable & Sendable, Table: CanvasValueTable
>:
    ~Copyable, ~Escapable, CanvasInvocationSource
where Table.Domain.Slot == ObservableModelReadSlot<Model> {
    private let models: ObservableModelScope<Model, Schema>
    private let values: CanvasStagedValues<Identity, Table>
    private var table: Table

    @_lifetime(copy models, copy values)
    package init(
        models: consuming ObservableModelScope<Model, Schema>,
        values: consuming CanvasStagedValues<Identity, Table>, table: consuming Table
    ) {
        self.models = consume models
        self.values = consume values
        self.table = consume table
    }
    package var canvasOccurrenceCount: UInt16 { values.count }
    package func canvasIdentity(at index: UInt16) -> Identity? { values.identity(at: index) }
    @inlinable
    @inline(__always)
    package mutating func invokeCanvas(
        at identity: Identity, context: inout GraphicsContext,
        size: Size
    ) throws(DrawingError) {
        let failure: DrawingError?
        do throws(_GiftUIAccessFailure) {
            failure = try models.withRead(Table.Domain.self) { read in
                do throws(DrawingError) {
                    try values.invoke(
                        at: identity, table: &table, context: &context, size: size, read: read)
                    return nil
                } catch { return error }
            }
        } catch { throw DrawingError(accessFailure: error) }
        if let failure { throw failure }
    }
    package mutating func releaseCanvas(at identity: Identity) { values.release(at: identity) }
}
