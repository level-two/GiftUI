import GiftUI
import GiftUIDrawing
import GiftUIRuntimeCore

package enum StaticCanvasOccurrenceState: UInt8, Equatable, Sendable {
    case live = 0
    case released = 1
}

package struct StaticCanvasOccurrence<Identity, Capture>: ~Copyable
where Identity: Equatable & Sendable {
    package let identity: Identity
    package let callableID: UInt16
    package let declaredCaptureByteCount: UInt16
    package private(set) var state: StaticCanvasOccurrenceState
    package private(set) var releaseCount: UInt8
    private var capture: Capture?

    package init?<Metadata>(
        identity: consuming Identity,
        callableID: UInt16,
        declaredCaptureByteCount: UInt16,
        capture: consuming Capture,
        metadata: borrowing Metadata
    ) where Metadata: RuntimeStaticCanvasAuditMetadata {
        guard callableID > 0,
            callableID <= metadata.callableCaseCount,
            metadata.captureByteCount(for: callableID) == declaredCaptureByteCount
        else {
            return nil
        }
        self.identity = consume identity
        self.callableID = callableID
        self.declaredCaptureByteCount = declaredCaptureByteCount
        state = .live
        releaseCount = 0
        self.capture = consume capture
    }

    package mutating func invoke<Table>(
        table: inout Table,
        context: inout GraphicsContext,
        size: Size
    ) throws(DrawingError)
    where
        Table: StaticCanvasCallableTable,
        Table.CaptureStorage == Capture
    {
        guard state == .live, capture != nil else {
            throw .invariantViolation
        }
        defer { releaseIfLive() }
        try table.invoke(
            id: callableID,
            captures: capture!,
            context: &context,
            size: size
        )
    }

    package mutating func discard() {
        releaseIfLive()
    }

    private mutating func releaseIfLive() {
        guard state == .live else { return }
        capture = nil
        state = .released
        releaseCount = 1
    }
}
