import GiftUI
import GiftUIReferenceTextResources
import GiftUISemanticCore
import GiftUITextResources
import Testing

@testable import GiftUILayout

@Test
func combinedLayoutCorpusPublishesCanonicalLocalEventOrder() {
    let semantic = CombinedSemanticView()
    var workspace = ProbeWorkspace(capacities: [64, 64, 64, 64, 64])
    var sink = CombinedSink()
    let limits = LayoutLimits(
        maximumScopes: 64,
        maximumDepth: 64,
        maximumTextScalars: 64,
        maximumTextLines: 64,
        maximumPositionedGlyphs: 64
    )!

    let result = layout(
        semantic: semantic,
        metrics: GiftUIReferenceTextResources.targetPackage.metrics,
        proposal: ProposedSize(width: 80, height: 60)!,
        limits: limits,
        workspace: &workspace,
        sink: &sink
    )

    #expect(result == .success(sink.summary!))
    #expect(sink.summary?.scopeCount == 8)
    #expect(sink.summary?.textScalarCount == 2)
    #expect(sink.summary?.textLineCount == 1)
    #expect(sink.summary?.positionedGlyphCount == 2)
    #expect(
        sink.events == [
            "begin",
            "scope:1",
            "scope:102",
            "scope:2",
            "line:2:0",
            "glyph:2:0:1",
            "glyph:2:1:96",
            "scope:3",
            "scope:4",
            "scope:5",
            "scope:106",
            "scope:6",
            "publish",
        ]
    )
    #expect(sink.discardCount == 0)
    #expect(!workspace.isLayoutActive)
}

private struct CombinedNode {
    let primitive: SemanticLayoutPrimitive
    let children: [UInt16]
    let modifiers: [SemanticLayoutModifier]
    let scalars: [UInt32]?
}

private struct CombinedSemanticView: SemanticLayoutView {
    let rootIdentity: UInt16 = 1
    let scopeCount: UInt16 = 8
    private let nodes: [UInt16: CombinedNode] = [
        1: CombinedNode(
            primitive: .vStack(alignment: .leading, spacing: 2),
            children: [2, 3, 5],
            modifiers: [],
            scalars: nil
        ),
        2: CombinedNode(
            primitive: .text,
            children: [],
            modifiers: [.padding(edges: .all, length: 1)],
            scalars: [0x41, 0x00b0]
        ),
        3: CombinedNode(
            primitive: .hStack(alignment: .center, spacing: 0),
            children: [4],
            modifiers: [],
            scalars: nil
        ),
        4: CombinedNode(
            primitive: .spacer(minLength: 2),
            children: [],
            modifiers: [],
            scalars: nil
        ),
        5: CombinedNode(
            primitive: .zStack(alignment: .leading),
            children: [6],
            modifiers: [],
            scalars: nil
        ),
        6: CombinedNode(
            primitive: .spacer(minLength: 0),
            children: [],
            modifiers: [
                .flexibleFrame(
                    minWidth: 4,
                    maxWidth: .infinity,
                    minHeight: 3,
                    maxHeight: .points(5),
                    alignment: .center
                )
            ],
            scalars: nil
        ),
    ]

    func primitive(at identity: UInt16) -> SemanticLayoutPrimitive? {
        nodes[identity]?.primitive
    }

    func childCount(of identity: UInt16) -> UInt16? {
        nodes[identity].map { UInt16($0.children.count) }
    }

    func child(of identity: UInt16, at index: UInt16) -> UInt16? {
        guard let children = nodes[identity]?.children, Int(index) < children.count
        else { return nil }
        return children[Int(index)]
    }

    func modifierCount(of identity: UInt16) -> UInt16? {
        nodes[identity].map { UInt16($0.modifiers.count) }
    }

    func modifierScope(of identity: UInt16, at index: UInt16) -> UInt16? {
        guard let modifiers = nodes[identity]?.modifiers,
            Int(index) < modifiers.count
        else { return nil }
        return identity + 100 + index
    }

    func modifier(
        of identity: UInt16,
        at index: UInt16
    ) -> SemanticLayoutModifier? {
        guard let modifiers = nodes[identity]?.modifiers,
            Int(index) < modifiers.count
        else { return nil }
        return modifiers[Int(index)]
    }

    func textScalarCount(of identity: UInt16) -> UInt16? {
        nodes[identity]?.scalars.map { UInt16($0.count) }
    }

    func textScalar(of identity: UInt16, at index: UInt16) -> UInt32? {
        guard let scalars = nodes[identity]?.scalars, Int(index) < scalars.count
        else { return nil }
        return scalars[Int(index)]
    }
}

private struct CombinedSink: LayoutResultSink, LayoutResultSinkState {
    var isLayoutActive = false
    var summary: LayoutSummary?
    var events: [String] = []
    var discardCount = 0

    mutating func begin(summary: LayoutSummary) -> Bool {
        self.summary = summary
        isLayoutActive = true
        events.append("begin")
        return true
    }

    mutating func stageScope(identity: UInt16, bounds: Rect, clip: Rect) -> Bool {
        events.append("scope:\(identity)")
        return true
    }

    mutating func stageTextLine(
        identity: UInt16,
        lineIndex: UInt16,
        bounds: Rect,
        baseline: Point,
        clip: Rect
    ) -> Bool {
        events.append("line:\(identity):\(lineIndex)")
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
        events.append("glyph:\(identity):\(glyphIndex):\(glyph.rawValue)")
        return true
    }

    mutating func publish() -> Bool {
        events.append("publish")
        isLayoutActive = false
        return true
    }

    mutating func discard() {
        events.append("discard")
        discardCount += 1
        isLayoutActive = false
    }
}
