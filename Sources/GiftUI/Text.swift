package enum _GiftUITextContent: Equatable, Sendable {
    case admitted(BoundedText)
    case invalidDeclaration
}

public struct _GiftUITextPayload: _GiftUISemanticPrimitivePayload, Equatable, Sendable {
    package let content: _GiftUITextContent

    package init(content: _GiftUITextContent) {
        self.content = content
    }
}

public struct Text: View {
    public typealias Body = Never

    package let _giftUITextPayload: _GiftUITextPayload

    public init(_ content: StaticString) {
        if let admitted = BoundedText(content) {
            _giftUITextPayload = _GiftUITextPayload(content: .admitted(admitted))
        } else {
            _giftUITextPayload = _GiftUITextPayload(content: .invalidDeclaration)
        }
    }

    public init(_ content: BoundedText) {
        _giftUITextPayload = _GiftUITextPayload(content: .admitted(content))
    }

    public var body: Never {
        fatalError("Text has no view body")
    }

    public func _giftUITraverse<Visitor: _GiftUISemanticTraversalVisitor>(
        _ visitor: inout Visitor
    ) {
        visitor.visitPrimitive(_giftUITextPayload)
    }
}
