import GiftUI

package enum SemanticLayoutPrimitive: Equatable, Sendable {
    case proxy
    case vStack(alignment: HorizontalAlignment, spacing: GeometryScalar)
    case hStack(alignment: VerticalAlignment, spacing: GeometryScalar)
    case zStack(alignment: Alignment)
    case spacer(minLength: GeometryScalar)
    case text
}

package enum SemanticLayoutModifier: Equatable, Sendable {
    case passthrough
    case padding(edges: EdgeSet, length: GeometryScalar)
    case paddingInsets(EdgeInsets)
    case fixedFrame(
        width: GeometryScalar?,
        height: GeometryScalar?,
        alignment: Alignment
    )
    case flexibleFrame(
        minWidth: GeometryScalar?,
        maxWidth: FrameLimit?,
        minHeight: GeometryScalar?,
        maxHeight: FrameLimit?,
        alignment: Alignment
    )
}

package protocol SemanticLayoutView {
    associatedtype Identity: Equatable, Sendable

    var rootIdentity: Identity { get }
    var scopeCount: UInt16 { get }

    func primitive(at identity: Identity) -> SemanticLayoutPrimitive?
    func childCount(of identity: Identity) -> UInt16?
    func child(of identity: Identity, at index: UInt16) -> Identity?

    func modifierCount(of identity: Identity) -> UInt16?
    func modifierScope(of identity: Identity, at index: UInt16) -> Identity?
    func modifier(
        of identity: Identity,
        at index: UInt16
    ) -> SemanticLayoutModifier?

    func textScalarCount(of identity: Identity) -> UInt16?
    func textScalar(of identity: Identity, at index: UInt16) -> UInt32?
}
