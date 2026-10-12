import GiftUI
import GiftUIDrawing

/// The host supplies its bounded inline entries before activation.
package struct StaticCanvasValueStorage: ~Copyable {
    private var metadata = CanvasStagedMetadata()
    package init() {}
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
