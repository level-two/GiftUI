import GiftUI
import GiftUITextResources
import Testing

@testable import GiftUIRenderCore

private enum SinkCall: Equatable {
    case begin(RenderPlanHeader)
    case fillRect(FillRectOperation)
    case beginPositionedGlyphs(PositionedGlyphOperationHeader)
    case positionedGlyph(PositionedGlyph)
    case endPositionedGlyphs
    case finish
    case discard
}

private enum RefusalPoint: CaseIterable {
    case begin
    case fillRect
    case beginPositionedGlyphs
    case positionedGlyph
    case endPositionedGlyphs
    case finish
}

private final class CapacityReads {
    var count = 0
}

private struct CheckingSink: RenderOperationSink {
    private enum State {
        case idle
        case begun
        case glyphs(remaining: UInt16)
        case finished
    }

    let reportedCapacity: RenderSinkCapacity
    let capacityReads: CapacityReads
    let refusal: RefusalPoint?
    private(set) var calls: [SinkCall] = []
    private var state = State.idle

    var capacity: RenderSinkCapacity {
        capacityReads.count += 1
        return reportedCapacity
    }

    init(
        capacity: RenderSinkCapacity,
        capacityReads: CapacityReads = CapacityReads(),
        refusal: RefusalPoint? = nil
    ) {
        reportedCapacity = capacity
        self.capacityReads = capacityReads
        self.refusal = refusal
    }

    mutating func begin(_ header: RenderPlanHeader) -> Bool {
        calls.append(.begin(header))
        guard case .idle = state, refusal != .begin else { return false }
        state = .begun
        return true
    }

    mutating func fillRect(_ operation: FillRectOperation) -> Bool {
        calls.append(.fillRect(operation))
        guard case .begun = state, refusal != .fillRect else { return false }
        return true
    }

    mutating func beginPositionedGlyphs(
        _ operation: PositionedGlyphOperationHeader
    ) -> Bool {
        calls.append(.beginPositionedGlyphs(operation))
        guard case .begun = state, refusal != .beginPositionedGlyphs else {
            return false
        }
        state = .glyphs(remaining: operation.glyphCount)
        return true
    }

    mutating func positionedGlyph(_ glyph: PositionedGlyph) -> Bool {
        calls.append(.positionedGlyph(glyph))
        guard case .glyphs(let remaining) = state,
            remaining > 0,
            refusal != .positionedGlyph
        else {
            return false
        }
        state = .glyphs(remaining: remaining - 1)
        return true
    }

    mutating func endPositionedGlyphs() -> Bool {
        calls.append(.endPositionedGlyphs)
        guard case .glyphs(remaining: 0) = state,
            refusal != .endPositionedGlyphs
        else {
            return false
        }
        state = .begun
        return true
    }

    mutating func finish() -> Bool {
        calls.append(.finish)
        guard case .begun = state, refusal != .finish else { return false }
        state = .finished
        return true
    }

    mutating func discard() {
        calls.append(.discard)
        state = .idle
    }
}

private let sinkRect = Rect(
    origin: Point(x: 0, y: 0),
    size: Size(width: 20, height: 20)!
)!

private let sinkResource = FontResourceID(
    rawValue: TextResourceDigest(
        word0: 0,
        word1: 1,
        word2: 2,
        word3: 3,
        word4: 4,
        word5: 5,
        word6: 6,
        word7: 7
    )
)

private let emptySinkHeader = RenderPlanHeader(
    surfaceBounds: sinkRect,
    damageBounds: sinkRect,
    operationCount: 0,
    positionedGlyphCount: 0,
    maximumObservedClipDepth: 1
)

private let sinkHeader = RenderPlanHeader(
    surfaceBounds: sinkRect,
    damageBounds: sinkRect,
    operationCount: 4,
    positionedGlyphCount: 4,
    maximumObservedClipDepth: 2
)

private let sinkFill = FillRectOperation(bounds: sinkRect, clip: sinkRect, color: .red)

private let sinkGlyphHeader = PositionedGlyphOperationHeader(
    instance: FontInstanceID(resource: sinkResource, instanceIndex: 0),
    clip: sinkRect,
    color: .blue,
    glyphCount: 2
)

private let sinkGlyphs = [
    PositionedGlyph(glyph: GlyphID(rawValue: 1), baseline: Point(x: 2, y: 3)),
    PositionedGlyph(glyph: GlyphID(rawValue: 4), baseline: Point(x: 5, y: 6)),
]

@Test
func sinkCapacityCanBeReadExactlyOnceWhileIdle() {
    let reads = CapacityReads()
    let sink = CheckingSink(
        capacity: RenderSinkCapacity(maximumOperations: 3, maximumPositionedGlyphs: 2),
        capacityReads: reads
    )

    let capacity = sink.capacity

    #expect(capacity == RenderSinkCapacity(maximumOperations: 3, maximumPositionedGlyphs: 2))
    #expect(reads.count == 1)
    #expect(sink.calls.isEmpty)
}

@Test
func sinkCapacityMayReportZeroWithoutStartingAStream() {
    let reads = CapacityReads()
    let sink = CheckingSink(
        capacity: RenderSinkCapacity(maximumOperations: 0, maximumPositionedGlyphs: 0),
        capacityReads: reads
    )

    #expect(sink.capacity == RenderSinkCapacity(maximumOperations: 0, maximumPositionedGlyphs: 0))
    #expect(reads.count == 1)
    #expect(sink.calls.isEmpty)
}

@Test
func sinkCarriesEmptyAndMultipleOperationStreamsInExactOrder() {
    var empty = CheckingSink(
        capacity: RenderSinkCapacity(maximumOperations: 0, maximumPositionedGlyphs: 0)
    )
    let emptyBegan = empty.begin(emptySinkHeader)
    let emptyFinished = empty.finish()
    #expect(emptyBegan)
    #expect(emptyFinished)
    #expect(empty.calls == [.begin(emptySinkHeader), .finish])

    var populated = CheckingSink(
        capacity: RenderSinkCapacity(maximumOperations: 4, maximumPositionedGlyphs: 4)
    )
    let populatedBegan = populated.begin(sinkHeader)
    let firstFill = populated.fillRect(sinkFill)
    let secondFill = populated.fillRect(sinkFill)
    let firstGroupBegan = populated.beginPositionedGlyphs(sinkGlyphHeader)
    let firstGroupFirstGlyph = populated.positionedGlyph(sinkGlyphs[0])
    let firstGroupSecondGlyph = populated.positionedGlyph(sinkGlyphs[1])
    let firstGroupEnded = populated.endPositionedGlyphs()
    let secondGroupBegan = populated.beginPositionedGlyphs(sinkGlyphHeader)
    let secondGroupFirstGlyph = populated.positionedGlyph(sinkGlyphs[0])
    let secondGroupSecondGlyph = populated.positionedGlyph(sinkGlyphs[1])
    let secondGroupEnded = populated.endPositionedGlyphs()
    let populatedFinished = populated.finish()
    #expect(populatedBegan)
    #expect(firstFill)
    #expect(secondFill)
    #expect(firstGroupBegan)
    #expect(firstGroupFirstGlyph)
    #expect(firstGroupSecondGlyph)
    #expect(firstGroupEnded)
    #expect(secondGroupBegan)
    #expect(secondGroupFirstGlyph)
    #expect(secondGroupSecondGlyph)
    #expect(secondGroupEnded)
    #expect(populatedFinished)
    #expect(
        populated.calls == [
            .begin(sinkHeader),
            .fillRect(sinkFill),
            .fillRect(sinkFill),
            .beginPositionedGlyphs(sinkGlyphHeader),
            .positionedGlyph(sinkGlyphs[0]),
            .positionedGlyph(sinkGlyphs[1]),
            .endPositionedGlyphs,
            .beginPositionedGlyphs(sinkGlyphHeader),
            .positionedGlyph(sinkGlyphs[0]),
            .positionedGlyph(sinkGlyphs[1]),
            .endPositionedGlyphs,
            .finish,
        ]
    )
}

@Test
func incompleteGlyphGroupsAreRefusedAndCanBeDiscarded() {
    var sink = CheckingSink(
        capacity: RenderSinkCapacity(maximumOperations: 1, maximumPositionedGlyphs: 2)
    )

    let began = sink.begin(sinkHeader)
    let groupBegan = sink.beginPositionedGlyphs(sinkGlyphHeader)
    let glyphAccepted = sink.positionedGlyph(sinkGlyphs[0])
    let groupEnded = sink.endPositionedGlyphs()
    let finished = sink.finish()
    #expect(began)
    #expect(groupBegan)
    #expect(glyphAccepted)
    #expect(!groupEnded)
    #expect(!finished)
    sink.discard()
    #expect(sink.calls.suffix(3) == [.endPositionedGlyphs, .finish, .discard])
}

@Test
func everyExplicitSinkCallCanRefuse() {
    for refusal in RefusalPoint.allCases {
        var sink = CheckingSink(
            capacity: RenderSinkCapacity(maximumOperations: 2, maximumPositionedGlyphs: 2),
            refusal: refusal
        )

        let began = sink.begin(sinkHeader)
        if refusal == .begin {
            #expect(!began)
            continue
        }
        #expect(began)

        if refusal == .fillRect {
            let accepted = sink.fillRect(sinkFill)
            #expect(!accepted)
            continue
        }
        let fillAccepted = sink.fillRect(sinkFill)
        #expect(fillAccepted)

        if refusal == .beginPositionedGlyphs {
            let accepted = sink.beginPositionedGlyphs(sinkGlyphHeader)
            #expect(!accepted)
            continue
        }
        let groupAccepted = sink.beginPositionedGlyphs(sinkGlyphHeader)
        #expect(groupAccepted)

        if refusal == .positionedGlyph {
            let accepted = sink.positionedGlyph(sinkGlyphs[0])
            #expect(!accepted)
            continue
        }
        let firstGlyphAccepted = sink.positionedGlyph(sinkGlyphs[0])
        let secondGlyphAccepted = sink.positionedGlyph(sinkGlyphs[1])
        #expect(firstGlyphAccepted)
        #expect(secondGlyphAccepted)

        if refusal == .endPositionedGlyphs {
            let accepted = sink.endPositionedGlyphs()
            #expect(!accepted)
            continue
        }
        let groupEnded = sink.endPositionedGlyphs()
        #expect(groupEnded)

        if refusal == .finish {
            let accepted = sink.finish()
            #expect(!accepted)
        }
    }
}
