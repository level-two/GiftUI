import GiftUI
import GiftUIDrawing
package func forward<I: Equatable & Sendable, T: CanvasValueTable, Result>(metadata: inout CanvasStagedMetadata, entries: inout MutableSpan<CanvasStagedEntry<I,T.CaptureStorage>?>, table: borrowing T, capacity: UInt16, limits: StaticCanvasLimits, _ body: (borrowing CanvasStagedValues<I,T>) throws(DrawingError) -> Result) throws(DrawingError) -> Result { try withCanvasStagedValues(metadata: &metadata, entries: &entries, table: table, capacity: capacity, limits: limits, body) }
