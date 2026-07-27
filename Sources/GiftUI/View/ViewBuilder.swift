@resultBuilder
public enum ViewBuilder {
    public static func buildBlock() -> EmptyView {
        EmptyView()
    }

    public static func buildBlock<Content: View>(_ content: Content) -> Content {
        content
    }

    public static func buildBlock<A: View, B: View>(
        _ a: A, _ b: B
    ) -> TupleView<A, B> {
        TupleView(a, b)
    }

    public static func buildBlock<A: View, B: View, C: View>(
        _ a: A, _ b: B, _ c: C
    ) -> TupleView3<A, B, C> {
        TupleView3(a, b, c)
    }

    public static func buildBlock<A: View, B: View, C: View, D: View>(
        _ a: A, _ b: B, _ c: C, _ d: D
    ) -> TupleView4<A, B, C, D> {
        TupleView4(a, b, c, d)
    }

    public static func buildBlock<
        A: View, B: View, C: View, D: View, E: View
    >(
        _ a: A, _ b: B, _ c: C, _ d: D, _ e: E
    ) -> TupleView5<A, B, C, D, E> {
        TupleView5(a, b, c, d, e)
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
