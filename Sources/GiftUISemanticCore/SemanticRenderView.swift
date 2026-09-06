import GiftUI

package enum SemanticRenderScope: Equatable, Sendable {
    case structural
    case clipBoundary
    case text
    case foregroundStyle(Color)
    case background(Color)
}

package protocol SemanticRenderView {
    associatedtype Identity: Equatable, Sendable

    var rootIdentity: Identity { get }
    var semanticScopeCount: UInt16 { get }

    func scope(at identity: Identity) -> SemanticRenderScope?
    func layoutIdentity(for identity: Identity) -> Identity?
    func childCount(of identity: Identity) -> UInt16?
    func child(of identity: Identity, at index: UInt16) -> Identity?
}
