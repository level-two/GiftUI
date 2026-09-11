import GiftUI
import GiftUILayout
import GiftUISemanticCore
import GiftUITextResources

enum RenderFixtureIdentity: UInt8, Equatable, Sendable {
    case root
    case transparent
    case foreground
    case background
    case text
    case alternate
    case missing
}

struct SemanticFixtureRecord {
    let identity: RenderFixtureIdentity
    let scope: SemanticRenderScope?
    let layoutIdentity: RenderFixtureIdentity?
    let children: [RenderFixtureIdentity]
}

struct DirectSemanticRenderView: SemanticRenderView {
    let rootIdentity: RenderFixtureIdentity
    let semanticScopeCount: UInt16
    let records: [SemanticFixtureRecord]

    func scope(at identity: RenderFixtureIdentity) -> SemanticRenderScope? {
        records.first { $0.identity == identity }?.scope
    }

    func layoutIdentity(
        for identity: RenderFixtureIdentity
    ) -> RenderFixtureIdentity? {
        records.first { $0.identity == identity }?.layoutIdentity
    }

    func childCount(of identity: RenderFixtureIdentity) -> UInt16? {
        records.first { $0.identity == identity }.map { UInt16($0.children.count) }
    }

    func child(
        of identity: RenderFixtureIdentity,
        at index: UInt16
    ) -> RenderFixtureIdentity? {
        guard let children = records.first(where: { $0.identity == identity })?.children,
            Int(index) < children.count
        else { return nil }
        return children[Int(index)]
    }
}

struct LayoutFixtureRecord {
    let identity: RenderFixtureIdentity
    let bounds: Rect?
    let clip: Rect?
    let lines: [ResolvedRenderTextLine?]
    let glyphs: [ResolvedRenderGlyph?]
}

struct DirectResolvedRenderLayoutView: ResolvedRenderLayoutView {
    let rootIdentity: RenderFixtureIdentity
    let layoutScopeCount: UInt16
    let rootBounds: Rect
    let records: [LayoutFixtureRecord]

    func bounds(of identity: RenderFixtureIdentity) -> Rect? {
        records.first { $0.identity == identity }?.bounds
    }

    func clip(of identity: RenderFixtureIdentity) -> Rect? {
        records.first { $0.identity == identity }?.clip
    }

    func textLineCount(of identity: RenderFixtureIdentity) -> UInt16? {
        records.first { $0.identity == identity }.map { UInt16($0.lines.count) }
    }

    func textLine(
        of identity: RenderFixtureIdentity,
        at index: UInt16
    ) -> ResolvedRenderTextLine? {
        guard let lines = records.first(where: { $0.identity == identity })?.lines,
            Int(index) < lines.count
        else { return nil }
        return lines[Int(index)]
    }

    func glyph(
        of identity: RenderFixtureIdentity,
        at index: UInt16
    ) -> ResolvedRenderGlyph? {
        guard let glyphs = records.first(where: { $0.identity == identity })?.glyphs,
            Int(index) < glyphs.count
        else { return nil }
        return glyphs[Int(index)]
    }
}

enum DirectRenderFixtures {
    static let bounds = Rect(
        origin: Point(x: 0, y: 0),
        size: Size(width: 40, height: 20)!
    )!
    static let instance = FontInstanceID(
        resource: FontResourceID(
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
        ),
        instanceIndex: 0
    )

    static var validSemantic: DirectSemanticRenderView {
        DirectSemanticRenderView(
            rootIdentity: .root,
            semanticScopeCount: 5,
            records: [
                SemanticFixtureRecord(
                    identity: .root,
                    scope: .structural,
                    layoutIdentity: .foreground,
                    children: [.transparent]
                ),
                SemanticFixtureRecord(
                    identity: .transparent,
                    scope: .structural,
                    layoutIdentity: .foreground,
                    children: [.foreground]
                ),
                SemanticFixtureRecord(
                    identity: .foreground,
                    scope: .foregroundStyle(.red),
                    layoutIdentity: .foreground,
                    children: [.background]
                ),
                SemanticFixtureRecord(
                    identity: .background,
                    scope: .background(.blue),
                    layoutIdentity: .text,
                    children: [.text]
                ),
                SemanticFixtureRecord(
                    identity: .text,
                    scope: .text,
                    layoutIdentity: .text,
                    children: []
                ),
            ]
        )
    }

    static var validLayout: DirectResolvedRenderLayoutView {
        DirectResolvedRenderLayoutView(
            rootIdentity: .foreground,
            layoutScopeCount: 2,
            rootBounds: bounds,
            records: [
                LayoutFixtureRecord(
                    identity: .foreground,
                    bounds: bounds,
                    clip: bounds,
                    lines: [],
                    glyphs: []
                ),
                LayoutFixtureRecord(
                    identity: .text,
                    bounds: bounds,
                    clip: bounds,
                    lines: [
                        ResolvedRenderTextLine(
                            lineIndex: 0,
                            bounds: bounds,
                            baseline: Point(x: 1, y: 12),
                            clip: bounds,
                            glyphCount: 2
                        )
                    ],
                    glyphs: [
                        ResolvedRenderGlyph(
                            lineIndex: 0,
                            glyphIndex: 0,
                            instance: instance,
                            glyph: GlyphID(rawValue: 1),
                            baseline: Point(x: 1, y: 12),
                            clip: bounds
                        ),
                        ResolvedRenderGlyph(
                            lineIndex: 0,
                            glyphIndex: 1,
                            instance: instance,
                            glyph: GlyphID(rawValue: 2),
                            baseline: Point(x: 5, y: 12),
                            clip: bounds
                        ),
                    ]
                ),
            ]
        )
    }
}
