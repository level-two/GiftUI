import GiftUI
import GiftUIReferenceTextResources
import GiftUISemanticCore
import GiftUITextResources
import Testing

@testable import GiftUILayout

@Test
func canonicalTextMapsSourceScalarsAndReplacementInOrder() {
    let output = runTextLayout(
        scalars: [0x41, 0x00b0, 0x2603],
        proposal: ProposedSize()!
    )

    #expect(output.summary?.textScalarCount == 3)
    #expect(output.summary?.textLineCount == 1)
    #expect(output.summary?.positionedGlyphCount == 3)
    #expect(
        output.glyphs.map { $0.glyph } == [
            GlyphID(rawValue: 1), GlyphID(rawValue: 3), GlyphID(rawValue: 9),
        ])
    #expect(output.glyphs.map { $0.baseline.x } == [0, 4, 7])
    #expect(output.glyphs.allSatisfy { $0.instance == textInstanceID })
}

@Test
func canonicalTextPreservesCrLfCrLfPairsAndEmptyLines() {
    let output = runTextLayout(
        scalars: [0x0d, 0x0a, 0x41, 0x0a, 0x0d, 0x42],
        proposal: ProposedSize()!
    )

    #expect(output.summary?.textScalarCount == 6)
    #expect(output.summary?.textLineCount == 4)
    #expect(output.summary?.positionedGlyphCount == 2)
    #expect(output.lines.map { $0.lineIndex } == [0, 1, 2, 3])
    #expect(output.lines.map { $0.bounds.size.width } == [0, 4, 0, 5])
    #expect(output.glyphs.map { $0.lineIndex } == [1, 3])
    #expect(output.glyphs.map { $0.glyphIndex } == [0, 1])
}

@Test
func emptyCanonicalTextStillProducesOneLine() {
    let output = runTextLayout(scalars: [], proposal: ProposedSize()!)

    #expect(output.summary?.textScalarCount == 0)
    #expect(output.summary?.textLineCount == 1)
    #expect(output.summary?.positionedGlyphCount == 0)
    #expect(output.summary?.rootBounds.size == Size(width: 0, height: 10)!)
    #expect(output.lines.count == 1)
    #expect(output.lines[0].baseline == Point(x: 0, y: 7))
}

@Test
func positiveWidthWrapsBeforeOnlyTheOverflowingNonfirstGlyph() {
    let output = runTextLayout(
        scalars: [0x41, 0x42, 0x41],
        proposal: ProposedSize(width: 8)!
    )

    #expect(output.summary?.rootBounds.size == Size(width: 5, height: 34)!)
    #expect(output.lines.map { $0.bounds.size.width } == [4, 5, 4])
    #expect(output.glyphs.map { $0.lineIndex } == [0, 1, 2])
    #expect(output.glyphs.map { $0.baseline.x } == [0, 0, 0])
    #expect(output.lines.map { $0.baseline.y } == [7, 19, 31])
    #expect(output.lines.map { $0.bounds.origin.y } == [0, 12, 24])
}

@Test
func zeroWidthProducesOneLinePerGlyphAndRetainsZeroLineWidths() {
    let output = runTextLayout(
        scalars: [0x41, 0x42, 0x41],
        proposal: ProposedSize(width: 0)!
    )

    #expect(output.summary?.rootBounds.size == Size(width: 0, height: 34)!)
    #expect(output.lines.count == 3)
    #expect(output.lines.allSatisfy { $0.bounds.size.width == 0 })
    #expect(output.glyphs.map { $0.lineIndex } == [0, 1, 2])
}

@Test
func absentWidthWrapsOnlyAtExplicitBreaks() {
    let output = runTextLayout(
        scalars: [0x41, 0x42, 0x0a, 0x41],
        proposal: ProposedSize()!
    )

    #expect(output.lines.map { $0.bounds.size.width } == [9, 4])
    #expect(output.glyphs.map { $0.baseline.x } == [0, 4, 0])
    #expect(output.summary?.rootBounds.size == Size(width: 9, height: 22)!)
}

@Test
func overWideFirstGlyphStaysAndItsLogicalLineWidthIsCapped() {
    let output = runTextLayout(
        scalars: [0x41, 0x42],
        proposal: ProposedSize(width: 3)!
    )

    #expect(output.lines.map { $0.bounds.size.width } == [3, 3])
    #expect(output.glyphs.map { $0.lineIndex } == [0, 1])
    #expect(output.summary?.rootBounds.size == Size(width: 3, height: 22)!)
}

@Test
func leadingTrailingAndConsecutiveBreaksPreserveEveryEmptyLine() {
    let output = runTextLayout(
        scalars: [0x0a, 0x0a, 0x41, 0x0a],
        proposal: ProposedSize()!
    )

    #expect(output.lines.map { $0.bounds.size.width } == [0, 0, 4, 0])
    #expect(output.lines.map { $0.baseline.y } == [7, 19, 31, 43])
    #expect(output.summary?.rootBounds.size.height == 46)
}

@Test
func textLinesAndGlyphBaselinesTranslateToAbsoluteRootCoordinates() {
    let output = runTextLayout(
        scalars: [0x41, 0x42],
        proposal: ProposedSize()!,
        modifiers: [.padding(edges: .all, length: 2)]
    )

    #expect(output.summary?.rootBounds.size == Size(width: 13, height: 14)!)
    #expect(output.lines[0].bounds.origin == Point(x: 2, y: 2))
    #expect(output.lines[0].baseline == Point(x: 2, y: 9))
    #expect(output.glyphs.map { $0.baseline } == [Point(x: 2, y: 9), Point(x: 6, y: 9)])
    #expect(output.glyphs.allSatisfy { $0.clip == output.lines[0].clip })
}

@Test
func heightCapRetainsHiddenLinesAndProducesExactEmptyClips() {
    let output = runTextLayout(
        scalars: [0x41, 0x0a, 0x42],
        proposal: ProposedSize(height: 5)!
    )

    #expect(output.summary?.rootBounds.size == Size(width: 5, height: 5)!)
    #expect(output.lines.count == 2)
    #expect(output.glyphs.count == 2)
    #expect(
        output.lines[0].clip == Rect(origin: Point(x: 0, y: 0), size: Size(width: 4, height: 5)!)!)
    #expect(
        output.lines[1].clip == Rect(origin: Point(x: 0, y: 12), size: Size(width: 0, height: 0)!)!)
    #expect(output.glyphs[1].clip == output.lines[1].clip)
}

@Test
func spec005ReferenceMetricsProduceCanonicalResourceGolden() {
    let metrics = GiftUIReferenceTextResources.targetPackage.metrics
    let output = runTextLayoutWithMetrics(
        scalars: [0x41, 0x00b0, 0x2603],
        proposal: ProposedSize()!,
        modifiers: [],
        metrics: metrics
    )
    let instance = metrics.instance(at: 0)!

    #expect(output.summary?.rootBounds.size == Size(width: 29, height: 20)!)
    #expect(output.lines[0].baseline == Point(x: 0, y: 16))
    #expect(output.glyphs.map { $0.glyph.rawValue } == [1, 96, 0])
    #expect(output.glyphs.map { $0.baseline.x } == [0, 11, 18])
    #expect(output.glyphs.allSatisfy { $0.instance == instance.id })
    #expect(instance.id.instanceIndex == 0)
    #expect(instance.id.resource == metrics.descriptor.resource)
}

@Test(arguments: [OverflowTextMetrics.Mode.lineHeight, .glyphAdvance])
private func canonicalTextReportsCheckedArithmeticOverflow(
    _ mode: OverflowTextMetrics.Mode
) {
    let output = runTextLayoutWithMetrics(
        scalars: mode == .glyphAdvance ? [0x41, 0x41] : [],
        proposal: ProposedSize()!,
        modifiers: [],
        metrics: OverflowTextMetrics(mode: mode)
    )

    #expect(output.result == .failure(.arithmeticOverflow))
    #expect(output.summary == nil)
    #expect(output.lines.isEmpty)
    #expect(output.glyphs.isEmpty)
}

struct CapturedTextLine: Equatable {
    let identity: UInt16
    let lineIndex: UInt16
    let bounds: Rect
    let baseline: Point
    let clip: Rect
}

struct CapturedTextGlyph: Equatable {
    let identity: UInt16
    let lineIndex: UInt16
    let glyphIndex: UInt16
    let instance: FontInstanceID
    let glyph: GlyphID
    let baseline: Point
    let clip: Rect
}

private struct TextSemanticView: SemanticLayoutView {
    let scalars: [UInt32]
    let modifiers: [SemanticLayoutModifier]
    let rootIdentity: UInt16 = 1
    var scopeCount: UInt16 { UInt16(1 + modifiers.count) }

    func primitive(at identity: UInt16) -> SemanticLayoutPrimitive? {
        identity == 1 ? .text : nil
    }

    func childCount(of identity: UInt16) -> UInt16? { identity == 1 ? 0 : nil }
    func child(of identity: UInt16, at index: UInt16) -> UInt16? { nil }
    func modifierCount(of identity: UInt16) -> UInt16? {
        identity == 1 ? UInt16(modifiers.count) : nil
    }
    func modifierScope(of identity: UInt16, at index: UInt16) -> UInt16? {
        Int(index) < modifiers.count ? 100 + index : nil
    }
    func modifier(of identity: UInt16, at index: UInt16) -> SemanticLayoutModifier? {
        Int(index) < modifiers.count ? modifiers[Int(index)] : nil
    }
    func textScalarCount(of identity: UInt16) -> UInt16? {
        identity == 1 ? UInt16(scalars.count) : nil
    }
    func textScalar(of identity: UInt16, at index: UInt16) -> UInt32? {
        guard identity == 1, Int(index) < scalars.count else { return nil }
        return scalars[Int(index)]
    }
}

private let textResourceID = FontResourceID(
    rawValue: TextResourceDigest(
        word0: 1,
        word1: 2,
        word2: 3,
        word3: 4,
        word4: 5,
        word5: 6,
        word6: 7,
        word7: 8
    )
)
private let textInstanceID = FontInstanceID(
    resource: textResourceID,
    instanceIndex: 0
)

private struct TextMetricsView: CanonicalTextMetricsView {
    var descriptor: TextResourceDescriptor {
        TextResourceDescriptor(
            schemaVersion: 1,
            resource: textResourceID,
            instanceCount: 1,
            realizationCount: 1,
            canonicalManifestByteCount: 1
        )
    }

    func instance(at index: UInt16) -> FontInstanceDescriptor? {
        guard index == 0 else { return nil }
        return FontInstanceDescriptor(
            id: textInstanceID,
            lineMetrics: FontLineMetrics(ascent: 7, descent: 3, lineGap: 2),
            replacementGlyph: GlyphID(rawValue: 9),
            glyphCount: 10,
            mappingCount: 3
        )
    }

    func mapping(
        at index: UInt16,
        in instance: FontInstanceID
    ) -> ScalarGlyphMappingRecord? { nil }

    func mapScalar(
        _ scalarValue: UInt32,
        in instance: FontInstanceID
    ) -> GlyphMapping? {
        guard instance == textInstanceID else { return nil }
        switch scalarValue {
        case 0x41:
            return .exact(GlyphID(rawValue: 1))
        case 0x42:
            return .exact(GlyphID(rawValue: 2))
        case 0x00b0:
            return .exact(GlyphID(rawValue: 3))
        default:
            return .replacement(GlyphID(rawValue: 9))
        }
    }

    func metrics(
        for glyph: GlyphID,
        in instance: FontInstanceID
    ) -> GlyphMetrics? {
        guard instance == textInstanceID else { return nil }
        let advance: GeometryScalar
        switch glyph.rawValue {
        case 1: advance = 4
        case 2: advance = 5
        case 3: advance = 3
        case 9: advance = 6
        default: return nil
        }
        return GlyphMetrics(
            advanceX: advance,
            offsetX: 0,
            offsetY: 0,
            inkSize: Size(width: advance, height: 10)!
        )
    }
}

private struct OverflowTextMetrics: CanonicalTextMetricsView {
    enum Mode: CaseIterable, Equatable {
        case lineHeight
        case glyphAdvance
    }

    let mode: Mode
    var descriptor: TextResourceDescriptor { TextMetricsView().descriptor }

    func instance(at index: UInt16) -> FontInstanceDescriptor? {
        guard index == 0 else { return nil }
        return FontInstanceDescriptor(
            id: textInstanceID,
            lineMetrics: mode == .lineHeight
                ? FontLineMetrics(ascent: .max, descent: 1, lineGap: 0)
                : FontLineMetrics(ascent: 7, descent: 3, lineGap: 2),
            replacementGlyph: GlyphID(rawValue: 9),
            glyphCount: 10,
            mappingCount: 1
        )
    }

    func mapping(
        at index: UInt16,
        in instance: FontInstanceID
    ) -> ScalarGlyphMappingRecord? { nil }

    func mapScalar(
        _ scalarValue: UInt32,
        in instance: FontInstanceID
    ) -> GlyphMapping? {
        .exact(GlyphID(rawValue: 1))
    }

    func metrics(
        for glyph: GlyphID,
        in instance: FontInstanceID
    ) -> GlyphMetrics? {
        GlyphMetrics(
            advanceX: .max,
            offsetX: 0,
            offsetY: 0,
            inkSize: Size(width: 0, height: 0)!
        )
    }
}

private struct TextSink: LayoutResultSink, LayoutResultSinkState {
    var isLayoutActive = false
    var summary: LayoutSummary?
    var stagedLines: [CapturedTextLine] = []
    var stagedGlyphs: [CapturedTextGlyph] = []
    var currentLines: [CapturedTextLine] = []
    var currentGlyphs: [CapturedTextGlyph] = []

    mutating func begin(summary: LayoutSummary) -> Bool {
        isLayoutActive = true
        self.summary = summary
        stagedLines.removeAll(keepingCapacity: true)
        stagedGlyphs.removeAll(keepingCapacity: true)
        return true
    }

    mutating func stageScope(identity: UInt16, bounds: Rect, clip: Rect) -> Bool { true }

    mutating func stageTextLine(
        identity: UInt16,
        lineIndex: UInt16,
        bounds: Rect,
        baseline: Point,
        clip: Rect
    ) -> Bool {
        stagedLines.append(
            CapturedTextLine(
                identity: identity,
                lineIndex: lineIndex,
                bounds: bounds,
                baseline: baseline,
                clip: clip
            )
        )
        return true
    }

    mutating func stageGlyph(
        identity: UInt16,
        lineIndex: UInt16,
        glyphIndex: UInt16,
        instance: FontInstanceID,
        glyph: GlyphID,
        baseline: Point,
        clip: Rect
    ) -> Bool {
        stagedGlyphs.append(
            CapturedTextGlyph(
                identity: identity,
                lineIndex: lineIndex,
                glyphIndex: glyphIndex,
                instance: instance,
                glyph: glyph,
                baseline: baseline,
                clip: clip
            )
        )
        return true
    }

    mutating func publish() -> Bool {
        currentLines = stagedLines
        currentGlyphs = stagedGlyphs
        isLayoutActive = false
        return true
    }

    mutating func discard() {
        stagedLines.removeAll(keepingCapacity: true)
        stagedGlyphs.removeAll(keepingCapacity: true)
        isLayoutActive = false
    }
}

func runTextLayout(
    scalars: [UInt32],
    proposal: ProposedSize,
    modifiers: [SemanticLayoutModifier] = []
) -> (
    result: LayoutResult,
    summary: LayoutSummary?,
    lines: [CapturedTextLine],
    glyphs: [CapturedTextGlyph]
) {
    runTextLayoutWithMetrics(
        scalars: scalars,
        proposal: proposal,
        modifiers: modifiers,
        metrics: TextMetricsView()
    )
}

private func runTextLayoutWithMetrics<Metrics: CanonicalTextMetricsView>(
    scalars: [UInt32],
    proposal: ProposedSize,
    modifiers: [SemanticLayoutModifier],
    metrics: Metrics
) -> (
    result: LayoutResult,
    summary: LayoutSummary?,
    lines: [CapturedTextLine],
    glyphs: [CapturedTextGlyph]
) {
    var workspace = ProbeWorkspace(capacities: [64, 64, 64, 64, 64])
    var sink = TextSink()
    let result = layout(
        semantic: TextSemanticView(scalars: scalars, modifiers: modifiers),
        metrics: metrics,
        proposal: proposal,
        limits: LayoutLimits(
            maximumScopes: 64,
            maximumDepth: 64,
            maximumTextScalars: 64,
            maximumTextLines: 64,
            maximumPositionedGlyphs: 64
        )!,
        workspace: &workspace,
        sink: &sink
    )
    return (result, sink.summary, sink.currentLines, sink.currentGlyphs)
}
