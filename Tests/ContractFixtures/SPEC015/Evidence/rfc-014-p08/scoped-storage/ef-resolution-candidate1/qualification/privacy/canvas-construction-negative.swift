import GiftUI
import GiftUIDrawing
package func reject<I: Equatable & Sendable, T: CanvasValueTable>(_: I.Type, _: T.Type, state: borrowing UnsafeMutablePointer<CanvasStagedMetadata>, entries: borrowing UnsafeMutableBufferPointer<CanvasStagedEntry<I,T.CaptureStorage>?>, capacity: UInt16) { _ = CanvasStagedValues<I,T>(state: state, entries: entries, capacity: capacity) }
