import GiftUI
import GiftUIDrawing

/// Bounded concrete values; this store never retains an escaping draw closure.
package struct DynamicCanvasCallableStorage<
    Identity: Equatable & Sendable, Table: CanvasValueTable
>: ~Copyable {
    private var metadata = CanvasStagedMetadata()
    private var entries: [CanvasStagedEntry<Identity, Table.CaptureStorage>?]
    package let capacity: UInt16
    package init(capacity: UInt16) {
        self.capacity = capacity
        entries = .init(repeating: nil, count: Int(capacity))
    }
    package mutating func withLifetime<Result>(
        table: borrowing Table, limits: StaticCanvasLimits,
        _ body: (borrowing CanvasStagedValues<Identity, Table>) throws(DrawingError) -> Result
    ) throws(DrawingError) -> Result {
        let table = copy table
        return try entries.withUnsafeMutableBufferPointer { (buffer) throws(DrawingError) in
            var span = MutableSpan(_unsafeElements: buffer)
            return try withCanvasStagedValues(
                metadata: &metadata, entries: &span, table: table,
                capacity: capacity, limits: limits, body)
        }
    }
}
