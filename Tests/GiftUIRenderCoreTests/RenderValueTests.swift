import GiftUI
import GiftUITextResources
import Testing

@testable import GiftUIRenderCore

private let sampleRect = Rect(
    origin: Point(x: 1, y: 2),
    size: Size(width: 30, height: 40)!
)!

private let sampleResource = FontResourceID(
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

@Test
func renderCoreValuesPreserveEveryExactField() {
    let capacity = RenderSinkCapacity(maximumOperations: 11, maximumPositionedGlyphs: 12)
    let header = RenderPlanHeader(
        surfaceBounds: sampleRect,
        damageBounds: sampleRect,
        operationCount: 13,
        positionedGlyphCount: 14,
        maximumObservedClipDepth: 15
    )
    let glyph = PositionedGlyph(glyph: GlyphID(rawValue: 16), baseline: Point(x: 17, y: 18))
    let fill = FillRectOperation(bounds: sampleRect, clip: sampleRect, color: .red)
    let instance = FontInstanceID(resource: sampleResource, instanceIndex: 19)
    let glyphHeader = PositionedGlyphOperationHeader(
        instance: instance,
        clip: sampleRect,
        color: .blue,
        glyphCount: 20
    )

    #expect(capacity.maximumOperations == 11)
    #expect(capacity.maximumPositionedGlyphs == 12)
    #expect(header.surfaceBounds == sampleRect)
    #expect(header.damageBounds == sampleRect)
    #expect(header.operationCount == 13)
    #expect(header.positionedGlyphCount == 14)
    #expect(header.maximumObservedClipDepth == 15)
    #expect(glyph.glyph == GlyphID(rawValue: 16))
    #expect(glyph.baseline == Point(x: 17, y: 18))
    #expect(fill.bounds == sampleRect)
    #expect(fill.clip == sampleRect)
    #expect(fill.color == .red)
    #expect(glyphHeader.instance == instance)
    #expect(glyphHeader.clip == sampleRect)
    #expect(glyphHeader.color == .blue)
    #expect(glyphHeader.glyphCount == 20)
}

@Test
func renderCoreValuesMeetExactAndBoundedLayouts() {
    #expect(MemoryLayout<RenderSinkCapacity>.size == 4)
    #expect(MemoryLayout<RenderSinkCapacity>.stride == 4)
    #expect(MemoryLayout<RenderPlanHeader>.size <= 40)
    #expect(MemoryLayout<RenderPlanHeader>.stride <= 40)
    #expect(MemoryLayout<PositionedGlyph>.size <= 12)
    #expect(MemoryLayout<PositionedGlyph>.stride <= 12)
    #expect(MemoryLayout<FillRectOperation>.size <= 36)
    #expect(MemoryLayout<FillRectOperation>.stride <= 36)
    #expect(MemoryLayout<PositionedGlyphOperationHeader>.size <= 60)
    #expect(MemoryLayout<PositionedGlyphOperationHeader>.stride <= 60)
    #expect(MemoryLayout<RenderProductionError>.size == 1)
    #expect(MemoryLayout<RenderProductionError>.stride == 1)
}

@Test
func renderProductionErrorsHaveExactClosedRawValues() {
    #expect(RenderProductionError.invalidInput.rawValue == 0)
    #expect(RenderProductionError.arithmeticOverflow.rawValue == 1)
    #expect(RenderProductionError.capacityExhausted.rawValue == 2)
    #expect(RenderProductionError.incompatibleTextResource.rawValue == 3)
    #expect(RenderProductionError.sinkRefused.rawValue == 4)
    #expect(RenderProductionError.reentrancyViolation.rawValue == 5)
    #expect(RenderProductionError.invariantViolation.rawValue == 6)
}
