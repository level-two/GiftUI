package enum RenderRecordingEvent: Equatable, Sendable {
    case begin(RenderPlanHeader)
    case fillRect(FillRectOperation)
    case beginPositionedGlyphs(PositionedGlyphOperationHeader)
    case positionedGlyph(PositionedGlyph)
    case endPositionedGlyphs
    case finish
}

package struct RenderSinkAttemptCounts: Equatable, Sendable {
    package fileprivate(set) var begin: UInt32 = 0
    package fileprivate(set) var fillRect: UInt32 = 0
    package fileprivate(set) var beginPositionedGlyphs: UInt32 = 0
    package fileprivate(set) var positionedGlyph: UInt32 = 0
    package fileprivate(set) var endPositionedGlyphs: UInt32 = 0
    package fileprivate(set) var finish: UInt32 = 0
    package fileprivate(set) var discard: UInt32 = 0
}

package protocol RenderRecordingStorage {
    var capacity: RenderSinkCapacity { get }

    mutating func beginRecording(_ event: borrowing RenderRecordingEvent) -> Bool
    mutating func stage(_ event: borrowing RenderRecordingEvent) -> Bool
    mutating func publishRecording() -> Bool
    mutating func discardRecording()
}

package struct RenderRecordingSink<Storage>: RenderOperationSink
where Storage: RenderRecordingStorage {
    package var storage: Storage
    package private(set) var attemptedCalls = RenderSinkAttemptCounts()

    package init(storage: Storage) {
        self.storage = storage
    }

    package var capacity: RenderSinkCapacity {
        storage.capacity
    }

    package mutating func begin(_ header: RenderPlanHeader) -> Bool {
        increment(&attemptedCalls.begin)
        let event = RenderRecordingEvent.begin(header)
        return storage.beginRecording(event)
    }

    package mutating func fillRect(_ operation: FillRectOperation) -> Bool {
        increment(&attemptedCalls.fillRect)
        let event = RenderRecordingEvent.fillRect(operation)
        return storage.stage(event)
    }

    package mutating func beginPositionedGlyphs(
        _ operation: PositionedGlyphOperationHeader
    ) -> Bool {
        increment(&attemptedCalls.beginPositionedGlyphs)
        let event = RenderRecordingEvent.beginPositionedGlyphs(operation)
        return storage.stage(event)
    }

    package mutating func positionedGlyph(_ glyph: PositionedGlyph) -> Bool {
        increment(&attemptedCalls.positionedGlyph)
        let event = RenderRecordingEvent.positionedGlyph(glyph)
        return storage.stage(event)
    }

    package mutating func endPositionedGlyphs() -> Bool {
        increment(&attemptedCalls.endPositionedGlyphs)
        return storage.stage(.endPositionedGlyphs)
    }

    package mutating func finish() -> Bool {
        increment(&attemptedCalls.finish)
        guard storage.stage(.finish) else { return false }
        return storage.publishRecording()
    }

    package mutating func discard() {
        increment(&attemptedCalls.discard)
        storage.discardRecording()
    }

    private func increment(_ value: inout UInt32) {
        if value < UInt32.max {
            value += 1
        }
    }
}
