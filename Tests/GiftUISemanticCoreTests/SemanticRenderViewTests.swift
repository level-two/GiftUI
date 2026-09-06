import GiftUI
import Testing

@testable import GiftUISemanticCore

private struct RenderIdentity: Equatable, Sendable {
    let rawValue: UInt16
}

private struct RenderScopeRecord {
    let identity: RenderIdentity
    let scope: SemanticRenderScope
    let layoutIdentity: RenderIdentity
    let children: [RenderIdentity]
}

private struct FixtureSemanticRenderView: SemanticRenderView {
    let rootIdentity = RenderIdentity(rawValue: 10)
    let records: [RenderScopeRecord] = [
        RenderScopeRecord(
            identity: RenderIdentity(rawValue: 10),
            scope: .structural,
            layoutIdentity: RenderIdentity(rawValue: 10),
            children: [RenderIdentity(rawValue: 11), RenderIdentity(rawValue: 14)]
        ),
        RenderScopeRecord(
            identity: RenderIdentity(rawValue: 11),
            scope: .foregroundStyle(.red),
            layoutIdentity: RenderIdentity(rawValue: 13),
            children: [RenderIdentity(rawValue: 12)]
        ),
        RenderScopeRecord(
            identity: RenderIdentity(rawValue: 12),
            scope: .background(.blue),
            layoutIdentity: RenderIdentity(rawValue: 13),
            children: [RenderIdentity(rawValue: 13)]
        ),
        RenderScopeRecord(
            identity: RenderIdentity(rawValue: 13),
            scope: .text,
            layoutIdentity: RenderIdentity(rawValue: 13),
            children: []
        ),
        RenderScopeRecord(
            identity: RenderIdentity(rawValue: 14),
            scope: .clipBoundary,
            layoutIdentity: RenderIdentity(rawValue: 14),
            children: []
        ),
    ]

    var semanticScopeCount: UInt16 {
        UInt16(records.count)
    }

    func scope(at identity: RenderIdentity) -> SemanticRenderScope? {
        record(for: identity)?.scope
    }

    func layoutIdentity(for identity: RenderIdentity) -> RenderIdentity? {
        record(for: identity)?.layoutIdentity
    }

    func childCount(of identity: RenderIdentity) -> UInt16? {
        record(for: identity).map { UInt16($0.children.count) }
    }

    func child(of identity: RenderIdentity, at index: UInt16) -> RenderIdentity? {
        guard let children = record(for: identity)?.children,
            Int(index) < children.count
        else { return nil }
        return children[Int(index)]
    }

    private func record(for identity: RenderIdentity) -> RenderScopeRecord? {
        records.first { $0.identity == identity }
    }
}

@Test
func semanticRenderScopeHasTheExactClosedCasesAndValues() {
    #expect(SemanticRenderScope.structural == .structural)
    #expect(SemanticRenderScope.clipBoundary == .clipBoundary)
    #expect(SemanticRenderScope.text == .text)
    #expect(SemanticRenderScope.foregroundStyle(.red) == .foregroundStyle(.red))
    #expect(SemanticRenderScope.background(.blue) == .background(.blue))
    #expect(SemanticRenderScope.foregroundStyle(.red) != .foregroundStyle(.blue))
    #expect(SemanticRenderScope.foregroundStyle(.red) != .background(.red))
}

@Test
func semanticRenderViewPreservesCountsChildOrderAndLayoutIdentitySelection() {
    let view = FixtureSemanticRenderView()
    let root = RenderIdentity(rawValue: 10)
    let foreground = RenderIdentity(rawValue: 11)
    let background = RenderIdentity(rawValue: 12)
    let text = RenderIdentity(rawValue: 13)
    let clip = RenderIdentity(rawValue: 14)

    #expect(view.rootIdentity == root)
    #expect(view.semanticScopeCount == 5)
    #expect(view.scope(at: root) == .structural)
    #expect(view.scope(at: foreground) == .foregroundStyle(.red))
    #expect(view.scope(at: background) == .background(.blue))
    #expect(view.scope(at: text) == .text)
    #expect(view.scope(at: clip) == .clipBoundary)
    #expect(view.childCount(of: root) == 2)
    #expect(view.child(of: root, at: 0) == foreground)
    #expect(view.child(of: root, at: 1) == clip)
    #expect(view.childCount(of: foreground) == 1)
    #expect(view.child(of: foreground, at: 0) == background)
    #expect(view.childCount(of: background) == 1)
    #expect(view.child(of: background, at: 0) == text)
    #expect(view.childCount(of: text) == 0)
    #expect(view.childCount(of: clip) == 0)

    #expect(view.layoutIdentity(for: root) == root)
    #expect(view.layoutIdentity(for: foreground) == text)
    #expect(view.layoutIdentity(for: background) == text)
    #expect(view.layoutIdentity(for: text) == text)
    #expect(view.layoutIdentity(for: clip) == clip)
}

@Test
func semanticRenderViewRejectsUnknownIdentitiesAndOutOfRangeChildren() {
    let view = FixtureSemanticRenderView()
    let root = RenderIdentity(rawValue: 10)
    let text = RenderIdentity(rawValue: 13)
    let unknown = RenderIdentity(rawValue: 99)

    #expect(view.child(of: root, at: 2) == nil)
    #expect(view.child(of: text, at: 0) == nil)
    #expect(view.scope(at: unknown) == nil)
    #expect(view.layoutIdentity(for: unknown) == nil)
    #expect(view.childCount(of: unknown) == nil)
    #expect(view.child(of: unknown, at: 0) == nil)
}
