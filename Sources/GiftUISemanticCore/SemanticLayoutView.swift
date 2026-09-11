import GiftUI

package enum SemanticLayoutPrimitive: Equatable, Sendable {
    case proxy
    case vStack(alignment: HorizontalAlignment, spacing: GeometryScalar)
    case hStack(alignment: VerticalAlignment, spacing: GeometryScalar)
    case zStack(alignment: Alignment)
    case spacer(minLength: GeometryScalar)
    case text

    package init<Payload>(
        payload: borrowing Payload
    ) where Payload: _GiftUISemanticPrimitivePayload {
        let payloadCopy = copy payload
        if let stack = payloadCopy as? _GiftUIVStackPayload {
            self = .vStack(alignment: stack.alignment, spacing: stack.spacing)
        } else if let stack = payloadCopy as? _GiftUIHStackPayload {
            self = .hStack(alignment: stack.alignment, spacing: stack.spacing)
        } else if let stack = payloadCopy as? _GiftUIZStackPayload {
            self = .zStack(alignment: stack.alignment)
        } else if let spacer = payloadCopy as? _GiftUISpacerPayload {
            self = .spacer(minLength: spacer.minLength)
        } else if payloadCopy is _GiftUITextPayload {
            self = .text
        } else {
            self = .proxy
        }
    }
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

    package init?<Payload>(
        payload: borrowing Payload
    ) where Payload: _GiftUISemanticModifierPayload {
        let payloadCopy = copy payload
        if payloadCopy is _GiftUIForegroundStylePayload
            || payloadCopy is _GiftUIBackgroundPayload
        {
            self = .passthrough
        } else if let padding = payloadCopy as? _GiftUIPaddingPayload {
            self = .padding(edges: padding.edges, length: padding.length)
        } else if let padding = payloadCopy as? _GiftUIPaddingInsetsPayload {
            self = .paddingInsets(padding.insets)
        } else if let frame = payloadCopy as? _GiftUIFixedFramePayload {
            self = .fixedFrame(
                width: frame.width,
                height: frame.height,
                alignment: frame.alignment
            )
        } else if let frame = payloadCopy as? _GiftUIFlexibleFramePayload {
            self = .flexibleFrame(
                minWidth: frame.minWidth,
                maxWidth: frame.maxWidth,
                minHeight: frame.minHeight,
                maxHeight: frame.maxHeight,
                alignment: frame.alignment
            )
        } else {
            return nil
        }
    }
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
