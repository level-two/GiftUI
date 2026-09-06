import GiftUI
import GiftUITextResources
import Testing

@testable import GiftUIRenderCore

private struct BoundedRecordingStorage: RenderRecordingStorage {
    let capacity: RenderSinkCapacity
    var current: [RenderRecordingEvent] = []
    var staged: [RenderRecordingEvent] = []
    var attempted: [RenderRecordingEvent] = []
    var refusedAttempt: UInt32?
    var refusePublish = false
    var publishAttempts: UInt32 = 0
    var discardAttempts: UInt32 = 0

    mutating func beginRecording(_ event: borrowing RenderRecordingEvent) -> Bool {
        attempted.append(copy event)
        let inspectedEvent = copy event
        guard
            admitsCurrentAttempt(),
            case .begin(let header) = inspectedEvent,
            header.operationCount <= capacity.maximumOperations,
            header.positionedGlyphCount <= capacity.maximumPositionedGlyphs
        else { return false }
        staged = [copy event]
        return true
    }

    mutating func stage(_ event: borrowing RenderRecordingEvent) -> Bool {
        attempted.append(copy event)
        let maximumEvents =
            2 + (Int(capacity.maximumOperations) * 2)
            + Int(capacity.maximumPositionedGlyphs)
        guard
            admitsCurrentAttempt(),
            !staged.isEmpty,
            staged.count < maximumEvents
        else { return false }
        staged.append(copy event)
        return true
    }

    mutating func publishRecording() -> Bool {
        publishAttempts += 1
        guard !refusePublish, !staged.isEmpty else { return false }
        current = staged
        staged.removeAll(keepingCapacity: true)
        return true
    }

    mutating func discardRecording() {
        discardAttempts += 1
        staged.removeAll(keepingCapacity: true)
    }

    private func admitsCurrentAttempt() -> Bool {
        refusedAttempt != UInt32(attempted.count)
    }
}

private let recordingRect = Rect(
    origin: Point(x: 0, y: 0),
    size: Size(width: 24, height: 18)!
)!

private let recordingHeader = RenderPlanHeader(
    surfaceBounds: recordingRect,
    damageBounds: recordingRect,
    operationCount: 2,
    positionedGlyphCount: 2,
    maximumObservedClipDepth: 2
)

private let recordingFill = FillRectOperation(
    bounds: recordingRect,
    clip: recordingRect,
    color: .green
)

private let recordingResource = FontResourceID(
    rawValue: TextResourceDigest(
        word0: 7,
        word1: 6,
        word2: 5,
        word3: 4,
        word4: 3,
        word5: 2,
        word6: 1,
        word7: 0
    )
)

private let recordingGlyphHeader = PositionedGlyphOperationHeader(
    instance: FontInstanceID(resource: recordingResource, instanceIndex: 3),
    clip: recordingRect,
    color: .blue,
    glyphCount: 2
)

private let recordingGlyphs = [
    PositionedGlyph(glyph: GlyphID(rawValue: 8), baseline: Point(x: 2, y: 12)),
    PositionedGlyph(glyph: GlyphID(rawValue: 9), baseline: Point(x: 10, y: 12)),
]

private let expectedRecording: [RenderRecordingEvent] = [
    .begin(recordingHeader),
    .fillRect(recordingFill),
    .beginPositionedGlyphs(recordingGlyphHeader),
    .positionedGlyph(recordingGlyphs[0]),
    .positionedGlyph(recordingGlyphs[1]),
    .endPositionedGlyphs,
    .finish,
]

@Test
func recordingSinkPublishesClosedValueEventsAtomically() {
    var sink = makeRecordingSink()

    #expect(emitCompleteRecording(into: &sink))
    #expect(sink.storage.current == expectedRecording)
    #expect(sink.storage.staged.isEmpty)
    #expect(sink.storage.attempted == expectedRecording)
    #expect(
        sink.attemptedCalls
            == RenderSinkAttemptCounts(
                begin: 1,
                fillRect: 1,
                beginPositionedGlyphs: 1,
                positionedGlyph: 2,
                endPositionedGlyphs: 1,
                finish: 1,
                discard: 0
            )
    )
}

@Test
func recordingSinkRefusalPreservesCurrentAndDiscardClearsOnlyStaged() {
    var sink = makeRecordingSink()
    #expect(emitCompleteRecording(into: &sink))
    let committed = sink.storage.current

    sink.storage.attempted.removeAll(keepingCapacity: true)
    sink.storage.refusedAttempt = 3
    let began = sink.begin(recordingHeader)
    let filled = sink.fillRect(recordingFill)
    let groupBegan = sink.beginPositionedGlyphs(recordingGlyphHeader)

    #expect(began)
    #expect(filled)
    #expect(!groupBegan)
    #expect(sink.storage.current == committed)
    #expect(sink.storage.staged == [.begin(recordingHeader), .fillRect(recordingFill)])
    #expect(
        sink.storage.attempted == [
            .begin(recordingHeader),
            .fillRect(recordingFill),
            .beginPositionedGlyphs(recordingGlyphHeader),
        ]
    )

    sink.discard()
    #expect(sink.storage.current == committed)
    #expect(sink.storage.staged.isEmpty)
    #expect(sink.storage.discardAttempts == 1)
    #expect(sink.attemptedCalls.discard == 1)
}

@Test
func recordingSinkPublishRefusalRequiresExplicitDiscard() {
    var sink = makeRecordingSink()
    #expect(emitCompleteRecording(into: &sink))
    let committed = sink.storage.current

    sink.storage.attempted.removeAll(keepingCapacity: true)
    sink.storage.refusePublish = true
    #expect(!emitCompleteRecording(into: &sink))
    #expect(sink.storage.current == committed)
    #expect(sink.storage.staged == expectedRecording)
    #expect(sink.storage.publishAttempts == 2)

    sink.discard()
    #expect(sink.storage.current == committed)
    #expect(sink.storage.staged.isEmpty)
}

@Test
func recordingSinkBeginRefusalLeavesNoAttemptedTranscript() {
    var sink = makeRecordingSink(refusedAttempt: 1)

    let began = sink.begin(recordingHeader)

    #expect(!began)
    #expect(sink.storage.current.isEmpty)
    #expect(sink.storage.staged.isEmpty)
    #expect(sink.storage.attempted == [.begin(recordingHeader)])
    #expect(sink.attemptedCalls.begin == 1)
    #expect(sink.attemptedCalls.discard == 0)
}

private func makeRecordingSink(
    refusedAttempt: UInt32? = nil
) -> RenderRecordingSink<BoundedRecordingStorage> {
    RenderRecordingSink(
        storage: BoundedRecordingStorage(
            capacity: RenderSinkCapacity(
                maximumOperations: 2,
                maximumPositionedGlyphs: 2
            ),
            refusedAttempt: refusedAttempt
        )
    )
}

private func emitCompleteRecording(
    into sink: inout RenderRecordingSink<BoundedRecordingStorage>
) -> Bool {
    guard sink.begin(recordingHeader) else { return false }
    guard sink.fillRect(recordingFill) else { return false }
    guard sink.beginPositionedGlyphs(recordingGlyphHeader) else { return false }
    guard sink.positionedGlyph(recordingGlyphs[0]) else { return false }
    guard sink.positionedGlyph(recordingGlyphs[1]) else { return false }
    guard sink.endPositionedGlyphs() else { return false }
    return sink.finish()
}
