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

private struct StackNode {
    let primitive: SemanticLayoutPrimitive?
    let children: [UInt16]

    init(_ primitive: SemanticLayoutPrimitive?, children: [UInt16] = []) {
        self.primitive = primitive
        self.children = children
    }
}

private struct StackSemanticView: SemanticLayoutView {
    let nodes: [UInt16: StackNode]
    let rootIdentity: UInt16 = 1
    var scopeCount: UInt16 { UInt16(nodes.values.filter { $0.primitive != nil }.count) }

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
        nodes[identity] == nil ? nil : 0
    }

    func modifierScope(of identity: UInt16, at index: UInt16) -> UInt16? { nil }
    func modifier(of identity: UInt16, at index: UInt16) -> SemanticLayoutModifier? { nil }
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
