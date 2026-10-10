public struct _GiftUIPaddingPayload: _GiftUISemanticModifierPayload, Equatable, Sendable {
    package let edges: EdgeSet
    package let length: GeometryScalar

    package init(edges: EdgeSet, length: GeometryScalar) {
        self.edges = edges
        self.length = length
    }
}

public struct _GiftUIPaddingInsetsPayload: _GiftUISemanticModifierPayload,
    Equatable, Sendable
{
    package let insets: EdgeInsets

    package init(insets: EdgeInsets) {
        self.insets = insets
    }
}

public struct _GiftUIFixedFramePayload: _GiftUISemanticModifierPayload,
    Equatable, Sendable
{
    package let width: GeometryScalar?
    package let height: GeometryScalar?
    package let alignment: Alignment

    package init(
        width: GeometryScalar?,
        height: GeometryScalar?,
        alignment: Alignment
    ) {
        self.width = width
        self.height = height
        self.alignment = alignment
    }
}

public struct _GiftUIFlexibleFramePayload: _GiftUISemanticModifierPayload,
    Equatable, Sendable
{
    package let minWidth: GeometryScalar?
    package let maxWidth: FrameLimit?
    package let minHeight: GeometryScalar?
    package let maxHeight: FrameLimit?
    package let alignment: Alignment

    package init(
        minWidth: GeometryScalar?,
        maxWidth: FrameLimit?,
        minHeight: GeometryScalar?,
        maxHeight: FrameLimit?,
        alignment: Alignment
    ) {
        self.minWidth = minWidth
        self.maxWidth = maxWidth
        self.minHeight = minHeight
        self.maxHeight = maxHeight
        self.alignment = alignment
    }
}

private struct GiftUILayoutModifiedContent<
    Content: View,
    Payload: _GiftUISemanticModifierPayload
>: View {
    typealias Body = Never

    let content: Content
    let payload: Payload

    var body: Never {
        fatalError("GiftUI layout modifiers have no view body")
    }

    func _giftUITraverse<Visitor: _GiftUISemanticTraversalVisitor>(
        _ visitor: inout Visitor
    ) {
        visitor.visitModifier(content: content, payload: payload)
    }
}

public extension View {
    func padding(_ length: GeometryScalar) -> some View {
        padding(.all, length)
    }

    func padding(_ edges: EdgeSet, _ length: GeometryScalar) -> some View {
        GiftUILayoutModifiedContent(
            content: self,
            payload: _GiftUIPaddingPayload(edges: edges, length: length)
        )
    }

    func padding(_ insets: EdgeInsets) -> some View {
        GiftUILayoutModifiedContent(
            content: self,
            payload: _GiftUIPaddingInsetsPayload(insets: insets)
        )
    }

    func frame(
        width: GeometryScalar? = nil,
        height: GeometryScalar? = nil,
        alignment: Alignment = .center
    ) -> some View {
        GiftUILayoutModifiedContent(
            content: self,
            payload: _GiftUIFixedFramePayload(
                width: width,
                height: height,
                alignment: alignment
            )
        )
    }

    func frame(
        minWidth: GeometryScalar? = nil,
        maxWidth: FrameLimit? = nil,
        minHeight: GeometryScalar? = nil,
        maxHeight: FrameLimit? = nil,
        alignment: Alignment = .center
    ) -> some View {
        GiftUILayoutModifiedContent(
            content: self,
            payload: _GiftUIFlexibleFramePayload(
                minWidth: minWidth,
                maxWidth: maxWidth,
                minHeight: minHeight,
                maxHeight: maxHeight,
                alignment: alignment
            )
        )
    }
}
