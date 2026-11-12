import GiftUI
import GiftUIDrawing

/// The host supplies its bounded inline entries before activation.
@usableFromInline
package struct StaticCanvasValueStorage: ~Copyable {
    // Let concrete callers specialize the loan without capturing a borrowed table.
    @usableFromInline
    internal var metadata = CanvasStagedMetadata()
    #if GIFTUI_FACTORY_INITIALIZATION_QUALIFICATION
        @_noAllocation
    #endif
    package init() {}
    @inlinable
    @inline(__always)
    package mutating func withLifetime<
        Identity: Equatable & Sendable, Table: CanvasValueTable, Result
    >(
        entries: inout MutableSpan<CanvasStagedEntry<Identity, Table.CaptureStorage>?>,
        table: borrowing Table, capacity: UInt16, limits: StaticCanvasLimits,
        _ body: (borrowing CanvasStagedValues<Identity, Table>) throws(DrawingError) -> Result
    ) throws(DrawingError) -> Result {
        try withCanvasStagedValues(
            metadata: &metadata, entries: &entries, table: table,
            capacity: capacity, limits: limits, body)
    }
}
