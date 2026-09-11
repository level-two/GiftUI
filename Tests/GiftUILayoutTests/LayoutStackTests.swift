import GiftUI
import GiftUISemanticCore
import GiftUITextResources
import Testing

@testable import GiftUILayout

@Test
func emptyStackPublishesOneZeroSizedScope() {
    let semantic = StackSemanticView(nodes: [1: .init(.vStack(alignment: .center, spacing: 3))])
    let result = runStackLayout(semantic, proposal: ProposedSize(width: 20, height: 10)!)

    #expect(result.result == .success(result.summary!))
    #expect(result.summary?.rootBounds.size == Size(width: 0, height: 0)!)
    #expect(result.scopes.map(\.identity) == [1])
}

@Test
func verticalStackMeasuresAndPlacesFiveChildrenWithOnlyInteriorGaps() {
    let semantic = stackFixture(
        primitive: .vStack(alignment: .center, spacing: 2),
        childCount: 5
    )
    let result = runStackLayout(semantic, proposal: ProposedSize()!)

    #expect(result.summary?.rootBounds.size == Size(width: 0, height: 8)!)
    #expect(result.scopes.map { $0.identity } == [1, 2, 3, 4, 5, 6])
    #expect(result.scopes.dropFirst().map { $0.bounds.origin.y } == [0, 2, 4, 6, 8])
}

@Test
func horizontalStackCapsItsOwnBoundsWithoutCompressingOrClippingChildren() {
    let semantic = stackFixture(
        primitive: .hStack(alignment: .bottom, spacing: 2),
        childCount: 5
    )
    let result = runStackLayout(
        semantic,
        proposal: ProposedSize(width: 1, height: 1)!
    )

    #expect(result.summary?.rootBounds.size == Size(width: 1, height: 0)!)
    #expect(result.scopes.dropFirst().map { $0.bounds.origin.x } == [0, 2, 4, 6, 8])
    #expect(result.scopes.allSatisfy { $0.clip == result.summary?.rootBounds })
}

@Test
func proxyAdoptsAndCoLocatesItsSingleFlattenedChild() {
    let semantic = StackSemanticView(
        nodes: [
            1: .init(.proxy, children: [2]),
            2: .init(.vStack(alignment: .leading, spacing: 4), children: [3, 4]),
            3: .init(.spacer(minLength: 0)),
            4: .init(.spacer(minLength: 0)),
        ]
    )
    let result = runStackLayout(semantic, proposal: ProposedSize()!)

    #expect(result.summary?.rootBounds.size == Size(width: 0, height: 4)!)
    #expect(result.scopes[0].bounds == result.scopes[1].bounds)
    #expect(result.scopes.map { $0.identity } == [1, 2, 3, 4])
}

@Test
func directSpacersReceiveEqualShareAndEarlierRemainder() {
    let semantic = StackSemanticView(
        nodes: [
            1: .init(.vStack(alignment: .leading, spacing: 0), children: [2, 3, 4]),
            2: .init(.spacer(minLength: 0)),
            3: .init(.spacer(minLength: 0)),
            4: .init(.spacer(minLength: 0)),
        ]
    )
    let result = runStackLayout(
        semantic,
        proposal: ProposedSize(width: 7, height: 8)!
    )

    #expect(result.summary?.rootBounds.size == Size(width: 0, height: 8)!)
    #expect(result.scopes.dropFirst().map { $0.bounds.size.height } == [3, 3, 2])
    #expect(result.scopes.dropFirst().map { $0.bounds.origin.y } == [0, 3, 6])
}

@Test
func directSpacersKeepMinimumsWhenProposalIsAbsentOrTooSmall() {
    let semantic = StackSemanticView(
        nodes: [
            1: .init(.vStack(alignment: .leading, spacing: 1), children: [2, 3]),
            2: .init(.spacer(minLength: 4)),
            3: .init(.spacer(minLength: 5)),
        ]
    )
    let absent = runStackLayout(semantic, proposal: ProposedSize()!)
    let capped = runStackLayout(semantic, proposal: ProposedSize(height: 3)!)

    #expect(absent.summary?.rootBounds.size.height == 10)
    #expect(absent.scopes.dropFirst().map { $0.bounds.size.height } == [4, 5])
    #expect(capped.summary?.rootBounds.size.height == 3)
    #expect(capped.scopes.dropFirst().map { $0.bounds.size.height } == [4, 5])
    #expect(capped.scopes.dropFirst().map { $0.bounds.origin.y } == [0, 5])
}

@Test
func standaloneAndWrappedSpacersAreOrdinaryZeroSizeScopes() {
    let standalone = runStackLayout(
        StackSemanticView(nodes: [1: .init(.spacer(minLength: 99))]),
        proposal: ProposedSize(width: 30, height: 30)!
    )
    let wrapped = runStackLayout(
        StackSemanticView(
            nodes: [
                1: .init(.vStack(alignment: .leading, spacing: 0), children: [2]),
                2: .init(
                    .spacer(minLength: 99),
                    modifiers: [.passthrough]
                ),
            ]
        ),
        proposal: ProposedSize(width: 30, height: 30)!
    )

    #expect(standalone.summary?.rootBounds.size == Size(width: 0, height: 0)!)
    #expect(wrapped.summary?.rootBounds.size == Size(width: 0, height: 0)!)
    #expect(wrapped.scopes.map { $0.identity } == [1, 102, 2])
}

@Test
func paddingInsetsProposalAndTranslatesChildWithoutAddingClip() {
    let semantic = StackSemanticView(
        nodes: [
            1: .init(
                .spacer(minLength: 0),
                modifiers: [.padding(edges: .all, length: 2)]
            )
        ]
    )
    let result = runStackLayout(
        semantic,
        proposal: ProposedSize(width: 3, height: 10)!
    )

    #expect(result.summary?.rootBounds.size == Size(width: 3, height: 4)!)
    #expect(result.scopes.map { $0.identity } == [101, 1])
    #expect(result.scopes[1].bounds.origin == Point(x: 2, y: 2))
    #expect(result.scopes.allSatisfy { $0.clip == result.summary?.rootBounds })
}

@Test
func nestedPaddingKeepsSourceCallOrder() {
    let semantic = StackSemanticView(
        nodes: [
            1: .init(
                .spacer(minLength: 0),
                modifiers: [
                    .padding(edges: .all, length: 1),
                    .padding(edges: .all, length: 2),
                ]
            )
        ]
    )
    let result = runStackLayout(semantic, proposal: ProposedSize()!)

    #expect(result.summary?.rootBounds.size == Size(width: 6, height: 6)!)
    #expect(result.scopes.map { $0.identity } == [102, 101, 1])
    #expect(result.scopes[1].bounds.origin == Point(x: 2, y: 2))
    #expect(result.scopes[2].bounds.origin == Point(x: 3, y: 3))
}

@Test
func zStackUsesSharedProposalMaximumIdealAndIndependentAlignment() {
    let shortWide = EdgeInsets(top: 0, leading: 0, bottom: 2, trailing: 4)!
    let semantic = StackSemanticView(
        nodes: [
            1: .init(
                .zStack(
                    alignment: Alignment(horizontal: .center, vertical: .bottom)
                ),
                children: [2, 3]
            ),
            2: .init(
                .spacer(minLength: 0),
                modifiers: [.paddingInsets(shortWide)]
            ),
            3: .init(
                .spacer(minLength: 0),
                modifiers: [.padding(edges: .all, length: 3)]
            ),
        ]
    )
    let result = runStackLayout(semantic, proposal: ProposedSize()!)

    #expect(result.summary?.rootBounds.size == Size(width: 6, height: 6)!)
    #expect(result.scopes.map { $0.identity } == [1, 102, 2, 103, 3])
    #expect(result.scopes[1].bounds.origin == Point(x: 1, y: 4))
    #expect(result.scopes[3].bounds.origin == Point(x: 0, y: 0))
    #expect(result.scopes.allSatisfy { $0.clip == result.summary?.rootBounds })
}

@Test
func fixedAndMinimumFramesDifferUnderSmallerParentProposal() {
    let fixed = runStackLayout(
        StackSemanticView(
            nodes: [
                1: .init(
                    .hStack(alignment: .center, spacing: 0),
                    children: [2],
                    modifiers: [
                        .fixedFrame(width: 100, height: 10, alignment: .center)
                    ]
                ),
                2: .init(.spacer(minLength: 0)),
            ]
        ),
        proposal: ProposedSize(width: 50, height: 5)!
    )
    let minimum = runStackLayout(
        StackSemanticView(
            nodes: [
                1: .init(
                    .hStack(alignment: .center, spacing: 0),
                    children: [2],
                    modifiers: [
                        .flexibleFrame(
                            minWidth: 100,
                            maxWidth: nil,
                            minHeight: nil,
                            maxHeight: nil,
                            alignment: .center
                        )
                    ]
                ),
                2: .init(.spacer(minLength: 0)),
            ]
        ),
        proposal: ProposedSize(width: 50, height: 5)!
    )

    #expect(fixed.summary?.rootBounds.size == Size(width: 50, height: 5)!)
    #expect(fixed.scopes[1].bounds.size == Size(width: 100, height: 0)!)
    #expect(fixed.scopes[1].bounds.origin == Point(x: -25, y: 2))
    #expect(minimum.summary?.rootBounds.size == Size(width: 50, height: 0)!)
    #expect(minimum.scopes[1].bounds.size == Size(width: 50, height: 0)!)
    #expect(minimum.scopes[1].bounds.origin == Point(x: 0, y: 0))
}

@Test
func infiniteFlexibleFrameExpandsOnlyToPresentParentProposal() {
    let modifier = SemanticLayoutModifier.flexibleFrame(
        minWidth: nil,
        maxWidth: .infinity,
        minHeight: nil,
        maxHeight: nil,
        alignment: .leading
    )
    let semantic = StackSemanticView(
        nodes: [1: .init(.spacer(minLength: 0), modifiers: [modifier])]
    )
    let present = runStackLayout(
        semantic,
        proposal: ProposedSize(width: 50)!
    )
    let absent = runStackLayout(semantic, proposal: ProposedSize()!)

    #expect(present.summary?.rootBounds.size.width == 50)
    #expect(absent.summary?.rootBounds.size.width == 0)
}

@Test
func frameAndPaddingOrderChangesBoundsAndFrameClip() {
    let paddingThenFrame = runStackLayout(
        StackSemanticView(
            nodes: [
                1: .init(
                    .spacer(minLength: 0),
                    modifiers: [
                        .padding(edges: .all, length: 10),
                        .fixedFrame(width: 100, height: nil, alignment: .center),
                    ]
                )
            ]
        ),
        proposal: ProposedSize(width: 50)!
    )
    let frameThenPadding = runStackLayout(
        StackSemanticView(
            nodes: [
                1: .init(
                    .spacer(minLength: 0),
                    modifiers: [
                        .fixedFrame(width: 100, height: nil, alignment: .center),
                        .padding(edges: .all, length: 10),
                    ]
                )
            ]
        ),
        proposal: ProposedSize(width: 50)!
    )

    #expect(paddingThenFrame.scopes.map { $0.identity } == [102, 101, 1])
    #expect(paddingThenFrame.scopes[1].bounds.origin.x == 15)
    #expect(paddingThenFrame.scopes[2].bounds.origin.x == 25)
    #expect(frameThenPadding.scopes[1].bounds.origin.x == 10)
    #expect(frameThenPadding.scopes[1].bounds.size.width == 30)
    #expect(frameThenPadding.scopes[1].clip.minX == 10)
    #expect(frameThenPadding.scopes[1].clip.maxX == 40)
    #expect(frameThenPadding.scopes[2].bounds.origin.x == 25)
}

private struct StackNode {
    let primitive: SemanticLayoutPrimitive?
    let children: [UInt16]
    let modifiers: [SemanticLayoutModifier]

    init(
        _ primitive: SemanticLayoutPrimitive?,
        children: [UInt16] = [],
        modifiers: [SemanticLayoutModifier] = []
    ) {
        self.primitive = primitive
        self.children = children
        self.modifiers = modifiers
    }
}

private struct StackSemanticView: SemanticLayoutView {
    let nodes: [UInt16: StackNode]
    let rootIdentity: UInt16 = 1
    var scopeCount: UInt16 {
        UInt16(
            nodes.values.reduce(0) {
                $0 + ($1.primitive == nil ? 0 : 1) + $1.modifiers.count
            }
        )
    }

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
    func textScalarCount(of identity: UInt16) -> UInt16? { nil }
    func textScalar(of identity: UInt16, at index: UInt16) -> UInt32? { nil }
}

private struct CapturedScope: Equatable {
    let identity: UInt16
    let bounds: Rect
    let clip: Rect
}

private struct StackSink: LayoutResultSink, LayoutResultSinkState {
    var isLayoutActive = false
    var staged: [CapturedScope] = []
    var current: [CapturedScope] = []
    var summary: LayoutSummary?

    mutating func begin(summary: LayoutSummary) -> Bool {
        isLayoutActive = true
        self.summary = summary
        staged.removeAll(keepingCapacity: true)
        return true
    }

    mutating func stageScope(identity: UInt16, bounds: Rect, clip: Rect) -> Bool {
        staged.append(CapturedScope(identity: identity, bounds: bounds, clip: clip))
        return true
    }

    mutating func stageTextLine(
        identity: UInt16,
        lineIndex: UInt16,
        bounds: Rect,
        baseline: Point,
        clip: Rect
    ) -> Bool { true }

    mutating func stageGlyph(
        identity: UInt16,
        lineIndex: UInt16,
        glyphIndex: UInt16,
        instance: FontInstanceID,
        glyph: GlyphID,
        baseline: Point,
        clip: Rect
    ) -> Bool { true }

    mutating func publish() -> Bool {
        current = staged
        staged.removeAll(keepingCapacity: true)
        isLayoutActive = false
        return true
    }

    mutating func discard() {
        staged.removeAll(keepingCapacity: true)
        isLayoutActive = false
    }
}

private func stackFixture(
    primitive: SemanticLayoutPrimitive,
    childCount: UInt16
) -> StackSemanticView {
    var nodes: [UInt16: StackNode] = [:]
    var children: [UInt16] = []
    for identity in UInt16(2) ..< 2 + childCount {
        children.append(identity)
        nodes[identity] = StackNode(.spacer(minLength: 0))
    }
    nodes[1] = StackNode(primitive, children: children)
    return StackSemanticView(nodes: nodes)
}

private func runStackLayout(
    _ semantic: StackSemanticView,
    proposal: ProposedSize
) -> (result: LayoutResult, summary: LayoutSummary?, scopes: [CapturedScope]) {
    var workspace = ProbeWorkspace(capacities: [32, 32, 32, 32, 32])
    var sink = StackSink()
    let limits = LayoutLimits(
        maximumScopes: 32,
        maximumDepth: 32,
        maximumTextScalars: 32,
        maximumTextLines: 32,
        maximumPositionedGlyphs: 32
    )!
    let result = layout(
        semantic: semantic,
        metrics: ProbeMetricsView(),
        proposal: proposal,
        limits: limits,
        workspace: &workspace,
        sink: &sink
    )
    return (result, sink.summary, sink.current)
}
