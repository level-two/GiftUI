public struct _GiftUIVStackPayload: _GiftUISemanticPrimitivePayload,
    Equatable, Sendable
{
    package let alignment: HorizontalAlignment
    package let spacing: GeometryScalar

    package init(alignment: HorizontalAlignment, spacing: GeometryScalar) {
        self.alignment = alignment
        self.spacing = spacing
    }
}

public struct _GiftUIHStackPayload: _GiftUISemanticPrimitivePayload,
    Equatable, Sendable
{
    package let alignment: VerticalAlignment
    package let spacing: GeometryScalar

    package init(alignment: VerticalAlignment, spacing: GeometryScalar) {
        self.alignment = alignment
        self.spacing = spacing
    }
}

public struct _GiftUIZStackPayload: _GiftUISemanticPrimitivePayload,
    Equatable, Sendable
{
    package let alignment: Alignment

    package init(alignment: Alignment) {
        self.alignment = alignment
    }
}

public struct _GiftUISpacerPayload: _GiftUISemanticPrimitivePayload,
    Equatable, Sendable
{
    package let minLength: GeometryScalar

    package init(minLength: GeometryScalar) {
        self.minLength = minLength
    }
}

public struct VStack<Content: View>: _GiftUILeaf {
    public typealias Body = Never

    package let content: Content
    package let payload: _GiftUIVStackPayload

    public init(
        alignment: HorizontalAlignment = .center,
        spacing: GeometryScalar = 0,
        @ViewBuilder content: () -> Content
    ) {
        self.content = content()
        payload = _GiftUIVStackPayload(alignment: alignment, spacing: spacing)
    }

    public var body: Never {
        fatalError("VStack has no view body")
    }

    public func _giftUITraverse<Visitor: _GiftUISemanticTraversalVisitor, Session: EvaluationSession & ~Copyable>(
        _ visitor: inout Visitor
    , session: inout Session) {
        visitor.visitPrimitive(content: content, payload: payload, session: &session)
    }
}

public struct HStack<Content: View>: _GiftUILeaf {
    public typealias Body = Never

    package let content: Content
    package let payload: _GiftUIHStackPayload

    public init(
        alignment: VerticalAlignment = .center,
        spacing: GeometryScalar = 0,
        @ViewBuilder content: () -> Content
    ) {
        self.content = content()
        payload = _GiftUIHStackPayload(alignment: alignment, spacing: spacing)
    }

    public var body: Never {
        fatalError("HStack has no view body")
    }

    public func _giftUITraverse<Visitor: _GiftUISemanticTraversalVisitor, Session: EvaluationSession & ~Copyable>(
        _ visitor: inout Visitor
    , session: inout Session) {
        visitor.visitPrimitive(content: content, payload: payload, session: &session)
    }
}

public struct ZStack<Content: View>: _GiftUILeaf {
    public typealias Body = Never

    package let content: Content
    package let payload: _GiftUIZStackPayload

    public init(
        alignment: Alignment = .center,
        @ViewBuilder content: () -> Content
    ) {
        self.content = content()
        payload = _GiftUIZStackPayload(alignment: alignment)
    }

    public var body: Never {
        fatalError("ZStack has no view body")
    }

    public func _giftUITraverse<Visitor: _GiftUISemanticTraversalVisitor, Session: EvaluationSession & ~Copyable>(
        _ visitor: inout Visitor
    , session: inout Session) {
        visitor.visitPrimitive(content: content, payload: payload, session: &session)
    }
}

public struct Spacer: _GiftUILeaf {
    public typealias Body = Never

    package let payload: _GiftUISpacerPayload

    public init(minLength: GeometryScalar = 0) {
        payload = _GiftUISpacerPayload(minLength: minLength)
    }

    public var body: Never {
        fatalError("Spacer has no view body")
    }

    public func _giftUITraverse<Visitor: _GiftUISemanticTraversalVisitor, Session: EvaluationSession & ~Copyable>(
        _ visitor: inout Visitor
    , session: inout Session) {
        visitor.visitPrimitive(payload, session: &session)
    }
}
