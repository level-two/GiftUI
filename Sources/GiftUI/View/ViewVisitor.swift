/// Runtime-owned traversal operations for the portable view declaration tree.
///
/// A `View` describes its semantics through this protocol without naming a
/// retained node representation. Allocating and bounded runtimes can therefore
/// build different storage from the same declaration.
public protocol ViewVisitor {
    mutating func visitBody<Content: View>(
        _ content: () -> Content
    )

    mutating func visitEmpty()

    mutating func visitTuple<each Content: View>(
        _ content: repeat each Content
    )

    mutating func visitConditional<TrueContent: View, FalseContent: View>(
        _ storage: ConditionalContent<TrueContent, FalseContent>.Storage
    )

    mutating func visitOptional<Content: View>(_ content: Content?)

    mutating func visitVStack<Content: View>(
        spacing: Int,
        content: Content
    )

    mutating func visitHStack<Content: View>(
        spacing: Int,
        content: Content
    )

    mutating func visitText(_ content: TextContent)

    mutating func visitButton<Label: View>(
        action: ButtonAction,
        label: Label
    )
}
