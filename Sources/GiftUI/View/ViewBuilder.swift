@resultBuilder
public enum ViewBuilder {
    public static func buildBlock() -> EmptyView {
        EmptyView()
    }

    public static func buildBlock<Content: View>(_ content: Content) -> Content {
        content
    }

    public static func buildBlock<A: View, B: View>(
        _ a: A,
        _ b: B
    ) -> TupleView<(A, B)> {
        TupleView((a, b)) { context in
            [
                context.makeChild(a, index: 0),
                context.makeChild(b, index: 1),
            ]
        }
    }

    public static func buildBlock<A: View, B: View, C: View>(
        _ a: A,
        _ b: B,
        _ c: C
    ) -> TupleView<(A, B, C)> {
        TupleView((a, b, c)) { context in
            [
                context.makeChild(a, index: 0),
                context.makeChild(b, index: 1),
                context.makeChild(c, index: 2),
            ]
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
