import Testing

@testable import GiftUISemanticCore

private struct FixtureSemanticLayoutView: SemanticLayoutView {
    let rootIdentity: UInt16 = 7
    let scopeCount: UInt16 = 1

    func primitive(at identity: UInt16) -> SemanticLayoutPrimitive? {
        identity == rootIdentity ? .proxy : nil
    }

    func childCount(of identity: UInt16) -> UInt16? {
        identity == rootIdentity ? 0 : nil
    }

    func child(of identity: UInt16, at index: UInt16) -> UInt16? {
        nil
    }

    func modifierCount(of identity: UInt16) -> UInt16? {
        identity == rootIdentity ? 0 : nil
    }

    func modifierScope(of identity: UInt16, at index: UInt16) -> UInt16? {
        nil
    }

    func modifier(
        of identity: UInt16,
        at index: UInt16
    ) -> SemanticLayoutModifier? {
        nil
    }

    func textScalarCount(of identity: UInt16) -> UInt16? {
        identity == rootIdentity ? 0 : nil
    }

    func textScalar(of identity: UInt16, at index: UInt16) -> UInt32? {
        nil
    }
}

@Test
func semanticLayoutViewBorrowsOneExactIdentityType() {
    let view = FixtureSemanticLayoutView()

    #expect(view.rootIdentity == 7)
    #expect(view.scopeCount == 1)
    #expect(view.primitive(at: 7) == .proxy)
    #expect(view.primitive(at: 8) == nil)
    #expect(view.childCount(of: 7) == 0)
    #expect(view.childCount(of: 8) == nil)
    #expect(view.modifierCount(of: 7) == 0)
    #expect(view.modifierCount(of: 8) == nil)
    #expect(view.textScalarCount(of: 7) == 0)
    #expect(view.textScalarCount(of: 8) == nil)
    #expect(view.child(of: 7, at: 0) == nil)
    #expect(view.modifierScope(of: 7, at: 0) == nil)
    #expect(view.modifier(of: 7, at: 0) == nil)
    #expect(view.textScalar(of: 7, at: 0) == nil)
}
