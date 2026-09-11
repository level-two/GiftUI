import GiftUILayout
import GiftUISemanticCore
import Testing

@testable import GiftUIRenderLowering

@Test
func directValidViewsUseSymbolicIdentityAndIndependentDeclaredCounts() {
    let semantic = DirectRenderFixtures.validSemantic
    let layout = DirectRenderFixtures.validLayout

    #expect(semantic.rootIdentity == .root)
    #expect(layout.rootIdentity == .foreground)
    #expect(semantic.layoutIdentity(for: semantic.rootIdentity) == layout.rootIdentity)
    #expect(semantic.semanticScopeCount == 5)
    #expect(layout.layoutScopeCount == 2)
    #expect(semantic.layoutIdentity(for: .root) == .foreground)
    #expect(semantic.layoutIdentity(for: .transparent) == .foreground)
    #expect(semantic.layoutIdentity(for: .foreground) == .foreground)
    #expect(semantic.layoutIdentity(for: .background) == .text)
    #expect(semantic.layoutIdentity(for: .text) == .text)
    #expect(layout.textLine(of: .text, at: 0)?.glyphCount == 2)
    #expect(layout.glyph(of: .text, at: 0)?.glyphIndex == 0)
    #expect(layout.glyph(of: .text, at: 1)?.glyphIndex == 1)
}

@Test
func directViewsRepresentEveryRequiredStructuralMalformedInput() {
    let valid = DirectRenderFixtures.validSemantic
    let missingScope = DirectSemanticRenderView(
        rootIdentity: valid.rootIdentity,
        semanticScopeCount: valid.semanticScopeCount,
        records: valid.records.map {
            $0.identity == .text
                ? SemanticFixtureRecord(
                    identity: $0.identity,
                    scope: nil,
                    layoutIdentity: $0.layoutIdentity,
                    children: $0.children
                ) : $0
        }
    )
    let duplicateIdentity = DirectSemanticRenderView(
        rootIdentity: valid.rootIdentity,
        semanticScopeCount: valid.semanticScopeCount,
        records: valid.records + [valid.records.last!]
    )
    let invalidModifierArity = replacingChildren(
        of: .foreground,
        with: [],
        in: valid
    )
    let prohibitedTextChild = replacingChildren(
        of: .text,
        with: [.alternate],
        in: valid
    )
    let missingTransparentMapping = replacingMapping(
        of: .transparent,
        with: nil,
        in: valid
    )

    #expect(missingScope.scope(at: .text) == nil)
    #expect(duplicateIdentity.records.filter { $0.identity == .text }.count == 2)
    #expect(invalidModifierArity.childCount(of: .foreground) == 0)
    #expect(prohibitedTextChild.childCount(of: .text) == 1)
    #expect(missingTransparentMapping.layoutIdentity(for: .transparent) == nil)
    #expect(valid.scope(at: .missing) == nil)
    #expect(valid.child(of: .root, at: 1) == nil)
}

@Test
func directLayoutsRepresentEveryRequiredLookupAndIndexDisagreement() {
    let valid = DirectRenderFixtures.validLayout
    let unequalRoot = DirectResolvedRenderLayoutView(
        rootIdentity: .alternate,
        layoutScopeCount: valid.layoutScopeCount,
        rootBounds: valid.rootBounds,
        records: valid.records
    )
    let duplicateIdentity = DirectResolvedRenderLayoutView(
        rootIdentity: valid.rootIdentity,
        layoutScopeCount: valid.layoutScopeCount,
        rootBounds: valid.rootBounds,
        records: valid.records + [valid.records[1]]
    )
    let missingBounds = replacingTextRecord(in: valid) { record in
        LayoutFixtureRecord(
            identity: record.identity,
            bounds: nil,
            clip: record.clip,
            lines: record.lines,
            glyphs: record.glyphs
        )
    }
    let missingClip = replacingTextRecord(in: valid) { record in
        LayoutFixtureRecord(
            identity: record.identity,
            bounds: record.bounds,
            clip: nil,
            lines: record.lines,
            glyphs: record.glyphs
        )
    }
    let missingLine = replacingTextRecord(in: valid) { record in
        LayoutFixtureRecord(
            identity: record.identity,
            bounds: record.bounds,
            clip: record.clip,
            lines: [nil],
            glyphs: record.glyphs
        )
    }
    let missingGlyph = replacingTextRecord(in: valid) { record in
        LayoutFixtureRecord(
            identity: record.identity,
            bounds: record.bounds,
            clip: record.clip,
            lines: record.lines,
            glyphs: [nil, record.glyphs[1]]
        )
    }
    let lineGap = replacingLine(in: valid, lineIndex: 1)
    let glyphLineMismatch = replacingFirstGlyph(in: valid, lineIndex: 1, glyphIndex: 0)
    let glyphIndexGap = replacingFirstGlyph(in: valid, lineIndex: 0, glyphIndex: 1)

    #expect(unequalRoot.rootIdentity != .foreground)
    #expect(duplicateIdentity.records.filter { $0.identity == .text }.count == 2)
    #expect(missingBounds.bounds(of: .text) == nil)
    #expect(missingClip.clip(of: .text) == nil)
    #expect(missingLine.textLineCount(of: .text) == 1)
    #expect(missingLine.textLine(of: .text, at: 0) == nil)
    #expect(missingGlyph.glyph(of: .text, at: 0) == nil)
    #expect(lineGap.textLine(of: .text, at: 0)?.lineIndex == 1)
    #expect(glyphLineMismatch.glyph(of: .text, at: 0)?.lineIndex == 1)
    #expect(glyphIndexGap.glyph(of: .text, at: 0)?.glyphIndex == 1)
    #expect(valid.bounds(of: .missing) == nil)
    #expect(valid.textLine(of: .text, at: 1) == nil)
    #expect(valid.glyph(of: .text, at: 2) == nil)
}

private func replacingChildren(
    of identity: RenderFixtureIdentity,
    with children: [RenderFixtureIdentity],
    in view: DirectSemanticRenderView
) -> DirectSemanticRenderView {
    DirectSemanticRenderView(
        rootIdentity: view.rootIdentity,
        semanticScopeCount: view.semanticScopeCount,
        records: view.records.map { record in
            record.identity == identity
                ? SemanticFixtureRecord(
                    identity: record.identity,
                    scope: record.scope,
                    layoutIdentity: record.layoutIdentity,
                    children: children
                ) : record
        }
    )
}

private func replacingMapping(
    of identity: RenderFixtureIdentity,
    with mapping: RenderFixtureIdentity?,
    in view: DirectSemanticRenderView
) -> DirectSemanticRenderView {
    DirectSemanticRenderView(
        rootIdentity: view.rootIdentity,
        semanticScopeCount: view.semanticScopeCount,
        records: view.records.map { record in
            record.identity == identity
                ? SemanticFixtureRecord(
                    identity: record.identity,
                    scope: record.scope,
                    layoutIdentity: mapping,
                    children: record.children
                ) : record
        }
    )
}

private func replacingTextRecord(
    in view: DirectResolvedRenderLayoutView,
    transform: (LayoutFixtureRecord) -> LayoutFixtureRecord
) -> DirectResolvedRenderLayoutView {
    DirectResolvedRenderLayoutView(
        rootIdentity: view.rootIdentity,
        layoutScopeCount: view.layoutScopeCount,
        rootBounds: view.rootBounds,
        records: view.records.map { $0.identity == .text ? transform($0) : $0 }
    )
}

private func replacingLine(
    in view: DirectResolvedRenderLayoutView,
    lineIndex: UInt16
) -> DirectResolvedRenderLayoutView {
    replacingTextRecord(in: view) { record in
        let line = record.lines[0]!
        return LayoutFixtureRecord(
            identity: record.identity,
            bounds: record.bounds,
            clip: record.clip,
            lines: [
                ResolvedRenderTextLine(
                    lineIndex: lineIndex,
                    bounds: line.bounds,
                    baseline: line.baseline,
                    clip: line.clip,
                    glyphCount: line.glyphCount
                )
            ],
            glyphs: record.glyphs
        )
    }
}

private func replacingFirstGlyph(
    in view: DirectResolvedRenderLayoutView,
    lineIndex: UInt16,
    glyphIndex: UInt16
) -> DirectResolvedRenderLayoutView {
    replacingTextRecord(in: view) { record in
        let glyph = record.glyphs[0]!
        return LayoutFixtureRecord(
            identity: record.identity,
            bounds: record.bounds,
            clip: record.clip,
            lines: record.lines,
            glyphs: [
                ResolvedRenderGlyph(
                    lineIndex: lineIndex,
                    glyphIndex: glyphIndex,
                    instance: glyph.instance,
                    glyph: glyph.glyph,
                    baseline: glyph.baseline,
                    clip: glyph.clip
                ),
                record.glyphs[1],
            ]
        )
    }
}
