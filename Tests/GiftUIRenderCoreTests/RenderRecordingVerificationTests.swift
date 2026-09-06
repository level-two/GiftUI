import GiftUI
import GiftUITextResources
import Testing

@testable import GiftUIRenderCore

private struct RecordingSummary: Equatable {
    let operationCount: UInt16
    let positionedGlyphCount: UInt16
}

private func verifyRecording(
    _ events: [RenderRecordingEvent]
) -> RecordingSummary? {
    guard
        events.count >= 2,
        case .begin(let header) = events.first,
        case .finish = events.last
    else { return nil }

    var operationCount: UInt16 = 0
    var positionedGlyphCount: UInt16 = 0
    var remainingGlyphs: UInt16?

    for event in events.dropFirst().dropLast() {
        switch event {
        case .begin, .finish:
            return nil
        case .fillRect:
            guard remainingGlyphs == nil else { return nil }
            guard increment(&operationCount) else { return nil }
        case .beginPositionedGlyphs(let group):
            guard remainingGlyphs == nil, group.glyphCount > 0 else { return nil }
            guard increment(&operationCount) else { return nil }
            remainingGlyphs = group.glyphCount
        case .positionedGlyph:
            guard let remaining = remainingGlyphs, remaining > 0 else { return nil }
            guard increment(&positionedGlyphCount) else { return nil }
            remainingGlyphs = remaining - 1
        case .endPositionedGlyphs:
            guard remainingGlyphs == 0 else { return nil }
            remainingGlyphs = nil
        }
    }

    guard
        remainingGlyphs == nil,
        operationCount == header.operationCount,
        positionedGlyphCount == header.positionedGlyphCount
    else { return nil }
    return RecordingSummary(
        operationCount: operationCount,
        positionedGlyphCount: positionedGlyphCount
    )
}

private func increment(_ value: inout UInt16) -> Bool {
    let next = value.addingReportingOverflow(1)
    guard !next.overflow else { return false }
    value = next.partialValue
    return true
}

private let verificationSurface = Rect(
    origin: Point(x: 0, y: 0),
    size: Size(width: 80, height: 48)!
)!

private let verificationDamage = Rect(
    origin: Point(x: 4, y: 6),
    size: Size(width: 52, height: 30)!
)!

private let verificationFillBounds = Rect(
    origin: Point(x: 2, y: 3),
    size: Size(width: 60, height: 32)!
)!

private let verificationClip = Rect(
    origin: Point(x: 5, y: 7),
    size: Size(width: 40, height: 20)!
)!

private let verificationResource = FontResourceID(
    rawValue: TextResourceDigest(
        word0: 10,
        word1: 20,
        word2: 30,
        word3: 40,
        word4: 50,
        word5: 60,
        word6: 70,
        word7: 80
    )
)

private let verificationInstance = FontInstanceID(
    resource: verificationResource,
    instanceIndex: 7
)

private let verificationEvents: [RenderRecordingEvent] = {
    let header = RenderPlanHeader(
        surfaceBounds: verificationSurface,
        damageBounds: verificationDamage,
        operationCount: 4,
        positionedGlyphCount: 3,
        maximumObservedClipDepth: 5
    )
    let firstFill = FillRectOperation(
        bounds: verificationFillBounds,
        clip: verificationClip,
        color: Color(red: 11, green: 22, blue: 33)
    )
    let firstGroup = PositionedGlyphOperationHeader(
        instance: verificationInstance,
        clip: verificationClip,
        color: Color(red: 44, green: 55, blue: 66),
        glyphCount: 2
    )
    let secondFill = FillRectOperation(
        bounds: verificationSurface,
        clip: verificationDamage,
        color: Color(red: 77, green: 88, blue: 99)
    )
    let secondGroup = PositionedGlyphOperationHeader(
        instance: verificationInstance,
        clip: verificationDamage,
        color: Color(red: 100, green: 110, blue: 120),
        glyphCount: 1
    )
    return [
        .begin(header),
        .fillRect(firstFill),
        .beginPositionedGlyphs(firstGroup),
        .positionedGlyph(
            PositionedGlyph(glyph: GlyphID(rawValue: 101), baseline: Point(x: 8, y: 19))
        ),
        .positionedGlyph(
            PositionedGlyph(glyph: GlyphID(rawValue: 102), baseline: Point(x: 16, y: 19))
        ),
        .endPositionedGlyphs,
        .fillRect(secondFill),
        .beginPositionedGlyphs(secondGroup),
        .positionedGlyph(
            PositionedGlyph(glyph: GlyphID(rawValue: 103), baseline: Point(x: 9, y: 31))
        ),
        .endPositionedGlyphs,
        .finish,
    ]
}()

@Test
func recordingVerificationChecksEveryHeaderAndOperationField() {
    #expect(
        verifyRecording(verificationEvents)
            == RecordingSummary(operationCount: 4, positionedGlyphCount: 3)
    )

    guard case .begin(let header) = verificationEvents[0] else {
        Issue.record("first event is not begin")
        return
    }
    #expect(header.surfaceBounds == verificationSurface)
    #expect(header.damageBounds == verificationDamage)
    #expect(header.operationCount == 4)
    #expect(header.positionedGlyphCount == 3)
    #expect(header.maximumObservedClipDepth == 5)

    guard case .fillRect(let fill) = verificationEvents[1] else {
        Issue.record("second event is not fill")
        return
    }
    #expect(fill.bounds == verificationFillBounds)
    #expect(fill.clip == verificationClip)
    #expect(fill.color.red == 11)
    #expect(fill.color.green == 22)
    #expect(fill.color.blue == 33)

    guard case .beginPositionedGlyphs(let group) = verificationEvents[2] else {
        Issue.record("third event is not a glyph-group begin")
        return
    }
    #expect(group.instance.resource == verificationResource)
    #expect(group.instance.instanceIndex == 7)
    #expect(group.clip == verificationClip)
    #expect(group.color.red == 44)
    #expect(group.color.green == 55)
    #expect(group.color.blue == 66)
    #expect(group.glyphCount == 2)

    guard case .positionedGlyph(let firstGlyph) = verificationEvents[3] else {
        Issue.record("fourth event is not a glyph")
        return
    }
    #expect(firstGlyph.glyph == GlyphID(rawValue: 101))
    #expect(firstGlyph.baseline == Point(x: 8, y: 19))

    guard case .positionedGlyph(let secondGlyph) = verificationEvents[4] else {
        Issue.record("fifth event is not a glyph")
        return
    }
    #expect(secondGlyph.glyph == GlyphID(rawValue: 102))
    #expect(secondGlyph.baseline == Point(x: 16, y: 19))
    #expect(verificationEvents[5] == .endPositionedGlyphs)

    guard case .fillRect(let secondFill) = verificationEvents[6] else {
        Issue.record("seventh event is not fill")
        return
    }
    #expect(secondFill.bounds == verificationSurface)
    #expect(secondFill.clip == verificationDamage)
    #expect(secondFill.color.red == 77)
    #expect(secondFill.color.green == 88)
    #expect(secondFill.color.blue == 99)

    guard case .beginPositionedGlyphs(let secondGroup) = verificationEvents[7] else {
        Issue.record("eighth event is not a glyph-group begin")
        return
    }
    #expect(secondGroup.instance == verificationInstance)
    #expect(secondGroup.clip == verificationDamage)
    #expect(secondGroup.color.red == 100)
    #expect(secondGroup.color.green == 110)
    #expect(secondGroup.color.blue == 120)
    #expect(secondGroup.glyphCount == 1)

    guard case .positionedGlyph(let thirdGlyph) = verificationEvents[8] else {
        Issue.record("ninth event is not a glyph")
        return
    }
    #expect(thirdGlyph.glyph == GlyphID(rawValue: 103))
    #expect(thirdGlyph.baseline == Point(x: 9, y: 31))
    #expect(verificationEvents[9] == .endPositionedGlyphs)
    #expect(verificationEvents[10] == .finish)
}

@Test
func recordingVerificationRejectsCountOrderAndGroupDisagreement() {
    let wrongHeader: [RenderRecordingEvent] = [
        .begin(
            RenderPlanHeader(
                surfaceBounds: verificationSurface,
                damageBounds: verificationDamage,
                operationCount: 1,
                positionedGlyphCount: 0,
                maximumObservedClipDepth: 1
            )
        ),
        .finish,
    ]
    let incomplete = Array(verificationEvents.dropLast(3)) + [.finish]
    let glyphOutsideGroup: [RenderRecordingEvent] = [
        verificationEvents[0],
        verificationEvents[3],
        .finish,
    ]
    let nestedBegin: [RenderRecordingEvent] = [
        verificationEvents[0],
        verificationEvents[1],
        verificationEvents[0],
        .finish,
    ]

    #expect(verifyRecording(wrongHeader) == nil)
    #expect(verifyRecording(incomplete) == nil)
    #expect(verifyRecording(glyphOutsideGroup) == nil)
    #expect(verifyRecording(nestedBegin) == nil)
}
