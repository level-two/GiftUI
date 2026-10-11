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
    package var retainedElementCapacity: Int { entries.capacity }
    package var reservedPayloadBytes: Int {
        entries.capacity * MemoryLayout<CanvasStagedEntry<Identity, Table.CaptureStorage>?>.stride
    }

    package mutating func withLifetime<Result>(
        table: borrowing Table, limits: StaticCanvasLimits, configuredCapacity: UInt16? = nil,
        _ body: (borrowing CanvasStagedValues<Identity, Table>) throws(DrawingError) -> Result
    ) throws(DrawingError) -> Result {
        let table = copy table
        return try entries.withUnsafeMutableBufferPointer { (buffer) throws(DrawingError) in
            var span = MutableSpan(_unsafeElements: buffer)
            return try withCanvasStagedValues(
                metadata: &metadata, entries: &span, table: table,
                capacity: configuredCapacity ?? capacity, limits: limits, body)
        }
    }
}
