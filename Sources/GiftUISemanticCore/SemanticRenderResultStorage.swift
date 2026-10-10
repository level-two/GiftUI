import GiftUI

extension SemanticRenderScope {
    package init<Payload>(primitivePayload: borrowing Payload)
    where Payload: _GiftUISemanticPrimitivePayload {
        let payload = copy primitivePayload
        if payload is _GiftUITextPayload {
            self = .text
        } else if payload is Canvas {
            self = .canvas
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

package protocol SemanticRenderResultStorage: SemanticLayoutResultStorage {
    associatedtype RenderView: SemanticRenderView where RenderView.Identity == Identity

    var renderView: RenderView { get }
}
