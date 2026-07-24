@resultBuilder
public enum ViewBuilder {
    public static func buildBlock() -> EmptyView {
        EmptyView()
    }

    public static func buildBlock<Content: View>(_ content: Content) -> Content {
        content
    }

    public static func buildBlock<each Content: View>(
        _ content: repeat each Content
    ) -> TupleView<(repeat each Content)> {
        TupleView((repeat each content)) { context in
            var children: [ViewNode] = []
            var index = 0
            for child in repeat each content {
                children.append(context.makeChild(child, index: index))
                index += 1
            }
            return children
        }
    }

    public static func buildEither<A: View, B: View>(
        first: A
    ) -> ConditionalContent<A, B> {
        ConditionalContent(storage: .first(first))
    }

    public static func buildEither<A: View, B: View>(
        second: B
    ) -> ConditionalContent<A, B> {
        ConditionalContent(storage: .second(second))
    }

    public static func buildOptional<Content: View>(
        _ content: Content?
    ) -> OptionalContent<Content> {
        OptionalContent(content)
    }
}
