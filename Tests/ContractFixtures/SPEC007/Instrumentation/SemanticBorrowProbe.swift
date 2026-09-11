import GiftUISemanticCore

package struct StaticSemanticLayoutView: SemanticLayoutView {
    package let rootIdentity: UInt16 = 1
    package let scopeCount: UInt16 = 1

    package func primitive(at identity: UInt16) -> SemanticLayoutPrimitive? {
        identity == rootIdentity ? .spacer(minLength: 0) : nil
    }

    package func childCount(of identity: UInt16) -> UInt16? {
        identity == rootIdentity ? 0 : nil
    }

    package func child(of identity: UInt16, at index: UInt16) -> UInt16? { nil }

    package func modifierCount(of identity: UInt16) -> UInt16? {
        identity == rootIdentity ? 0 : nil
    }

    package func modifierScope(of identity: UInt16, at index: UInt16) -> UInt16? {
        nil
    }

    package func modifier(
        of identity: UInt16,
        at index: UInt16
    ) -> SemanticLayoutModifier? { nil }

    package func textScalarCount(of identity: UInt16) -> UInt16? { nil }
    package func textScalar(of identity: UInt16, at index: UInt16) -> UInt32? { nil }
}

@inline(never)
package func spec007BorrowedStaticExposure<View: SemanticLayoutView>(
    _ view: borrowing View
) -> UInt16 {
    var checksum = view.scopeCount
    let root = view.rootIdentity
    checksum &+= view.childCount(of: root) ?? 0
    checksum &+= view.modifierCount(of: root) ?? 0
    checksum &+= view.textScalarCount(of: root) ?? 0
    if view.primitive(at: root) != nil {
        checksum &+= 1
    }
    return checksum
}

@inline(never)
package func spec007StaticExposureEntry() -> UInt16 {
    spec007BorrowedStaticExposure(StaticSemanticLayoutView())
}
