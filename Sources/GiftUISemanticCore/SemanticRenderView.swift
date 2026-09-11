import GiftUI

package enum SemanticRenderScope: Equatable, Sendable {
    case structural
    case clipBoundary
    case text
    case foregroundStyle(Color)
    case background(Color)

    package init<Payload>(primitivePayload: borrowing Payload)
    where Payload: _GiftUISemanticPrimitivePayload {
        if copy primitivePayload is _GiftUITextPayload {
            self = .text
        } else {
            self = .structural
        }
    }

    package init<Payload>(modifierPayload: borrowing Payload)
    where Payload: _GiftUISemanticModifierPayload {
        let payload = copy modifierPayload
        if let foreground = payload as? _GiftUIForegroundStylePayload {
            self = .foregroundStyle(foreground.color)
        } else if let background = payload as? _GiftUIBackgroundPayload {
            self = .background(background.color)
        } else if payload is _GiftUIFixedFramePayload
            || payload is _GiftUIFlexibleFramePayload
        {
            self = .clipBoundary
        } else {
            self = .structural
        }
    }
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

package protocol SemanticRenderResultStorage: SemanticLayoutResultStorage {
    associatedtype RenderView: SemanticRenderView where RenderView.Identity == Identity

    var renderView: RenderView { get }
}
