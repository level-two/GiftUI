import GiftUI
import GiftUIReferenceTextResources
import GiftUISemanticCore
import GiftUITextResources
import Testing

@testable import GiftUILayout

@Test
func successfulLayoutExposesExactResolvedRenderProjection() {
    var workspace = ResolvedWorkspace()
    var sink = ResolvedRenderLayoutResultSink(storage: ResolvedStorage())

    let result = layout(
        semantic: ResolvedSemantic(),
        metrics: GiftUIReferenceTextResources.targetPackage.metrics,
        proposal: ProposedSize(width: 20, height: 12)!,
        limits: ResolvedFixtures.limits,
        workspace: &workspace,
        sink: &sink
    )

    guard case .success(let summary) = result else {
        Issue.record("layout must succeed")
        return
    }
    let view = sink.renderView
    #expect(view.rootIdentity == 2)
    #expect(view.layoutScopeCount == summary.scopeCount)
    #expect(view.rootBounds == summary.rootBounds)
    #expect(view.bounds(of: 2) == summary.rootBounds)
    #expect(
        view.clip(of: 2)
            == Rect(origin: Point(x: 0, y: 0), size: summary.rootBounds.size)!
    )
    #expect(view.textLineCount(of: 2) == 0)
    #expect(view.textLineCount(of: 1) == 2)

    let firstLine = view.textLine(of: 1, at: 0)
    let secondLine = view.textLine(of: 1, at: 1)
    #expect(firstLine?.lineIndex == 0)
    #expect(firstLine?.glyphCount == 1)
    #expect(
        firstLine?.bounds
            == Rect(origin: Point(x: 4, y: 0), size: Size(width: 11, height: 20)!)!
    )
    #expect(firstLine?.baseline == Point(x: 4, y: 16))
    #expect(secondLine?.lineIndex == 1)
    #expect(secondLine?.glyphCount == 1)
    #expect(
        secondLine?.bounds
            == Rect(origin: Point(x: 4, y: 20), size: Size(width: 10, height: 20)!)!
    )
    #expect(secondLine?.baseline == Point(x: 4, y: 36))

    let first = view.glyph(of: 1, at: 0)
    let second = view.glyph(of: 1, at: 1)
    #expect(first?.lineIndex == 0)
    #expect(first?.glyphIndex == 0)
    #expect(first?.glyph == GlyphID(rawValue: 1))
    #expect(first?.instance == ResolvedFixtures.instance)
    #expect(first?.baseline == Point(x: 4, y: 16))
    #expect(first?.clip == firstLine?.clip)
    #expect(second?.lineIndex == 1)
    #expect(second?.glyphIndex == 1)
    #expect(second?.glyph == GlyphID(rawValue: 2))
    #expect(second?.instance == ResolvedFixtures.instance)
    #expect(second?.baseline == Point(x: 4, y: 36))
    #expect(second?.clip == secondLine?.clip)
}

@Test
func resolvedRenderProjectionReturnsNilOutsideItsPublishedIdentityAndIndexRanges() {
    var workspace = ResolvedWorkspace()
    var sink = ResolvedRenderLayoutResultSink(storage: ResolvedStorage())
    _ = layout(
        semantic: ResolvedSemantic(),
        metrics: GiftUIReferenceTextResources.targetPackage.metrics,
        proposal: ProposedSize(width: 20, height: 12)!,
        limits: ResolvedFixtures.limits,
        workspace: &workspace,
        sink: &sink
    )

    let view = sink.renderView
    #expect(view.bounds(of: 99) == nil)
    #expect(view.clip(of: 99) == nil)
    #expect(view.textLineCount(of: 99) == nil)
    #expect(view.textLine(of: 99, at: 0) == nil)
    #expect(view.glyph(of: 99, at: 0) == nil)
    #expect(view.textLine(of: 1, at: 2) == nil)
    #expect(view.glyph(of: 1, at: 2) == nil)
    #expect(view.glyph(of: 2, at: 0) == nil)
}

private enum ResolvedFixtures {
    static let limits = LayoutLimits(
        maximumScopes: 4,
        maximumDepth: 4,
        maximumTextScalars: 4,
        maximumTextLines: 2,
        maximumPositionedGlyphs: 4
    )!
    static let instance =
        GiftUIReferenceTextResources.targetPackage.metrics.instance(at: 0)!.id
}

private struct ResolvedSemantic: SemanticLayoutView {
    let rootIdentity: UInt16 = 1
    let scopeCount: UInt16 = 2

    func primitive(at identity: UInt16) -> SemanticLayoutPrimitive? {
        identity == 1 ? .text : nil
    }

    func childCount(of identity: UInt16) -> UInt16? {
        identity == 1 || identity == 2 ? 0 : nil
    }

    func child(of identity: UInt16, at index: UInt16) -> UInt16? {
        nil
    }

    func modifierCount(of identity: UInt16) -> UInt16? {
        identity == 1 ? 1 : (identity == 2 ? 0 : nil)
    }

    func modifierScope(of identity: UInt16, at index: UInt16) -> UInt16? {
        identity == 1 && index == 0 ? 2 : nil
    }

    func modifier(of identity: UInt16, at index: UInt16) -> SemanticLayoutModifier? {
        guard identity == 1, index == 0 else { return nil }
        return .fixedFrame(width: 20, height: 12, alignment: .center)
    }

    func textScalarCount(of identity: UInt16) -> UInt16? {
        identity == 1 ? 2 : nil
    }

    func textScalar(of identity: UInt16, at index: UInt16) -> UInt32? {
        guard identity == 1 else { return nil }
        return switch index {
        case 0: 0x41
        case 1: 0x42
        default: nil
        }
    }
}

private struct ResolvedScope: Equatable {
    let identity: UInt16
    let bounds: Rect
    let clip: Rect
}

private struct ResolvedLine: Equatable {
    let identity: UInt16
    let line: ResolvedRenderTextLine
}

private struct ResolvedGlyphRecord: Equatable {
    let identity: UInt16
    let glyph: ResolvedRenderGlyph
}

private struct ResolvedView: ResolvedRenderLayoutView {
    let rootIdentity: UInt16
    let layoutScopeCount: UInt16
    let renderSnapshotVersion: UInt32 = 1
    let rootBounds: Rect
    let scopes: [ResolvedScope]
    let lines: [ResolvedLine]
    let glyphs: [ResolvedGlyphRecord]

    func layoutIdentity(at ordinal: UInt16) -> UInt16? {
        guard Int(ordinal) < scopes.count else { return nil }
        return scopes[Int(ordinal)].identity
    }

    func layoutOrdinal(of identity: UInt16) -> UInt16? {
        scopes.firstIndex { $0.identity == identity }.map(UInt16.init)
    }

    func bounds(of identity: UInt16) -> Rect? {
        scopes.first { $0.identity == identity }?.bounds
    }

    func clip(of identity: UInt16) -> Rect? {
        scopes.first { $0.identity == identity }?.clip
    }

    func textLineCount(of identity: UInt16) -> UInt16? {
        guard scopes.contains(where: { $0.identity == identity }) else { return nil }
        return UInt16(lines.filter { $0.identity == identity }.count)
    }

    func textLine(of identity: UInt16, at index: UInt16) -> ResolvedRenderTextLine? {
        lines.first { $0.identity == identity && $0.line.lineIndex == index }?.line
    }

    func glyph(of identity: UInt16, at index: UInt16) -> ResolvedRenderGlyph? {
        glyphs.first { $0.identity == identity && $0.glyph.glyphIndex == index }?.glyph
    }
}

private struct ResolvedStorage: ResolvedRenderLayoutResultStorage {
    var isLayoutActive = false
    private var summary: LayoutSummary?
    private var scopes: [ResolvedScope] = []
    private var stagedLines: [(UInt16, UInt16, Rect, Point, Rect)] = []
    private var glyphs: [ResolvedGlyphRecord] = []
    private var isPublished = false

    var renderView: ResolvedView {
        precondition(isPublished)
        let lines = stagedLines.map { identity, lineIndex, bounds, baseline, clip in
            ResolvedLine(
                identity: identity,
                line: ResolvedRenderTextLine(
                    lineIndex: lineIndex,
                    bounds: bounds,
                    baseline: baseline,
                    clip: clip,
                    glyphCount: UInt16(
                        glyphs.filter {
                            $0.identity == identity && $0.glyph.lineIndex == lineIndex
                        }.count
                    )
                )
            )
        }
        return ResolvedView(
            rootIdentity: scopes[0].identity,
            layoutScopeCount: summary!.scopeCount,
            rootBounds: summary!.rootBounds,
            scopes: scopes,
            lines: lines,
            glyphs: glyphs
        )
    }

    mutating func begin(summary: LayoutSummary) -> Bool {
        guard !isLayoutActive else { return false }
        isLayoutActive = true
        self.summary = summary
        scopes.removeAll(keepingCapacity: true)
        stagedLines.removeAll(keepingCapacity: true)
        glyphs.removeAll(keepingCapacity: true)
        isPublished = false
        return true
    }

    mutating func stageScope(identity: UInt16, bounds: Rect, clip: Rect) -> Bool {
        scopes.append(ResolvedScope(identity: identity, bounds: bounds, clip: clip))
        return true
    }

    mutating func stageTextLine(
        identity: UInt16,
        lineIndex: UInt16,
        bounds: Rect,
        baseline: Point,
        clip: Rect
    ) -> Bool {
        stagedLines.append((identity, lineIndex, bounds, baseline, clip))
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
        glyphs.append(
            ResolvedGlyphRecord(
                identity: identity,
                glyph: ResolvedRenderGlyph(
                    lineIndex: lineIndex,
                    glyphIndex: glyphIndex,
                    instance: instance,
                    glyph: glyph,
                    baseline: baseline,
                    clip: clip
                )
            )
        )
        return true
    }

    mutating func publish() -> Bool {
        isPublished = true
        isLayoutActive = false
        return true
    }

    mutating func discard() {
        scopes.removeAll(keepingCapacity: true)
        stagedLines.removeAll(keepingCapacity: true)
        glyphs.removeAll(keepingCapacity: true)
        isLayoutActive = false
    }
}

private struct ResolvedWorkspace: LayoutWorkspace {
    let maximumScopes: UInt16 = 4
    let maximumDepth: UInt16 = 4
    let maximumTextScalars: UInt16 = 4
    let maximumTextLines: UInt16 = 2
    let maximumPositionedGlyphs: UInt16 = 4
    var isLayoutActive = false
    private var scopes: [(UInt16, LayoutMeasurement, LayoutPlacement?)] = []
    private var lines: [LayoutTextLine<UInt16>] = []
    private var glyphs: [LayoutPositionedGlyph<UInt16>] = []
    private var depth: [UInt16] = []

    mutating func acquireLayout() -> Bool {
        guard !isLayoutActive else { return false }
        isLayoutActive = true
        return true
    }

    mutating func appendScope(identity: borrowing UInt16, measurement: LayoutMeasurement) -> Bool {
        scopes.append((copy identity, measurement, nil))
        return true
    }

    var scopeCount: UInt16 { UInt16(scopes.count) }
    func scopeIdentity(at index: UInt16) -> UInt16? {
        Int(index) < scopes.count ? scopes[Int(index)].0 : nil
    }
    func measurement(for identity: borrowing UInt16) -> LayoutMeasurement? {
        let key = copy identity
        return scopes.first { $0.0 == key }?.1
    }
    mutating func storeMeasurement(
        _ measurement: LayoutMeasurement,
        for identity: borrowing UInt16
    ) -> Bool {
        let key = copy identity
        guard let index = scopes.firstIndex(where: { $0.0 == key }) else { return false }
        scopes[index].1 = measurement
        return true
    }
    mutating func storePlacement(
        _ placement: LayoutPlacement,
        for identity: borrowing UInt16
    ) -> Bool {
        let key = copy identity
        guard let index = scopes.firstIndex(where: { $0.0 == key }) else { return false }
        scopes[index].2 = placement
        return true
    }
    func placement(for identity: borrowing UInt16) -> LayoutPlacement? {
        let key = copy identity
        return scopes.first { $0.0 == key }?.2
    }
    var textLineCount: UInt16 { UInt16(lines.count) }
    mutating func appendTextLine(_ line: LayoutTextLine<UInt16>) -> Bool {
        lines.append(line)
        return true
    }
    func textLine(at index: UInt16) -> LayoutTextLine<UInt16>? {
        Int(index) < lines.count ? lines[Int(index)] : nil
    }
    mutating func storeTextLine(_ line: LayoutTextLine<UInt16>, at index: UInt16) -> Bool {
        guard Int(index) < lines.count else { return false }
        lines[Int(index)] = line
        return true
    }
    var positionedGlyphCount: UInt16 { UInt16(glyphs.count) }
    mutating func appendPositionedGlyph(_ glyph: LayoutPositionedGlyph<UInt16>) -> Bool {
        glyphs.append(glyph)
        return true
    }
    func positionedGlyph(at index: UInt16) -> LayoutPositionedGlyph<UInt16>? {
        Int(index) < glyphs.count ? glyphs[Int(index)] : nil
    }
    mutating func storePositionedGlyph(
        _ glyph: LayoutPositionedGlyph<UInt16>,
        at index: UInt16
    ) -> Bool {
        guard Int(index) < glyphs.count else { return false }
        glyphs[Int(index)] = glyph
        return true
    }
    mutating func pushScope(_ identity: borrowing UInt16) -> Bool {
        depth.append(copy identity)
        return true
    }
    mutating func popScope() { _ = depth.popLast() }
    mutating func resetLayout() {
        scopes.removeAll(keepingCapacity: true)
        lines.removeAll(keepingCapacity: true)
        glyphs.removeAll(keepingCapacity: true)
        depth.removeAll(keepingCapacity: true)
        isLayoutActive = false
    }
}
