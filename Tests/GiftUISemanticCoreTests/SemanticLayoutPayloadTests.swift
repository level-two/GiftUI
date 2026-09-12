import GiftUI
import Testing

@testable import GiftUISemanticCore

private struct LayoutNeutralPrimitive: _GiftUISemanticPrimitivePayload {}
private struct UnapprovedModifier: _GiftUISemanticModifierPayload {}

@Test
func semanticLayoutPrimitiveMapsEveryApprovedPayloadExactly() {
    let alignment = Alignment(horizontal: .center, vertical: .bottom)

    #expect(
        SemanticLayoutPrimitive(
            payload: _GiftUIVStackPayload(alignment: .leading, spacing: -1)
        ) == .vStack(alignment: .leading, spacing: -1)
    )
    #expect(
        SemanticLayoutPrimitive(
            payload: _GiftUIHStackPayload(alignment: .bottom, spacing: 2)
        ) == .hStack(alignment: .bottom, spacing: 2)
    )
    #expect(
        SemanticLayoutPrimitive(payload: _GiftUIZStackPayload(alignment: alignment))
            == .zStack(alignment: alignment)
    )
    #expect(
        SemanticLayoutPrimitive(payload: _GiftUISpacerPayload(minLength: -3))
            == .spacer(minLength: -3)
    )
    #expect(SemanticLayoutPrimitive(payload: Text("signal")._giftUITextPayload) == .text)
    #expect(SemanticLayoutPrimitive(payload: Canvas { _, _ in }) == .canvas)
    #expect(SemanticLayoutPrimitive(payload: LayoutNeutralPrimitive()) == .proxy)
}

@Test
func semanticLayoutModifierMapsApprovedPayloadsAndRejectsUnknownOnes() {
    let insets = EdgeInsets(top: 1, leading: 2, bottom: 3, trailing: 4)!
    let alignment = Alignment(horizontal: .center, vertical: .bottom)

    #expect(
        SemanticLayoutModifier(payload: _GiftUIForegroundStylePayload(color: .red))
            == .passthrough
    )
    #expect(
        SemanticLayoutModifier(payload: _GiftUIBackgroundPayload(color: .blue))
            == .passthrough
    )
    #expect(
        SemanticLayoutModifier(
            payload: _GiftUIPaddingPayload(
                edges: EdgeSet(rawValue: 1 << 7),
                length: -1
            )
        ) == .padding(edges: EdgeSet(rawValue: 1 << 7), length: -1)
    )
    #expect(
        SemanticLayoutModifier(payload: _GiftUIPaddingInsetsPayload(insets: insets))
            == .paddingInsets(insets)
    )
    #expect(
        SemanticLayoutModifier(
            payload: _GiftUIFixedFramePayload(
                width: -2,
                height: nil,
                alignment: .leading
            )
        ) == .fixedFrame(width: -2, height: nil, alignment: .leading)
    )
    #expect(
        SemanticLayoutModifier(
            payload: _GiftUIFlexibleFramePayload(
                minWidth: 9,
                maxWidth: .points(8),
                minHeight: -3,
                maxHeight: .infinity,
                alignment: alignment
            )
        )
            == .flexibleFrame(
                minWidth: 9,
                maxWidth: .points(8),
                minHeight: -3,
                maxHeight: .infinity,
                alignment: alignment
            )
    )
    #expect(SemanticLayoutModifier(payload: UnapprovedModifier()) == nil)
}
