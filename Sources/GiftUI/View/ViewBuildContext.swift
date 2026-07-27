public struct ViewBuildContext {
    package private(set) var path: String
    package let stateStorage: (any StateStorage)?
    package private(set) var root: ViewNode?
    private var parents: [ViewNode]

    package init(
        path: String = "root",
        stateStorage: (any StateStorage)? = nil
    ) {
        self.path = path
        self.stateStorage = stateStorage
        root = nil
        parents = []
    }

    private mutating func append(_ node: ViewNode) {
        if let parent = parents.last {
            parent.children.append(node)
        } else {
            precondition(root == nil, "GiftUI traversal produced multiple roots")
            root = node
        }
    }

    private mutating func withPathComponent(
        _ component: String,
        perform: (inout ViewBuildContext) -> Void
    ) {
        let previousPath = path
        path += ".\(component)"
        defer { path = previousPath }
        perform(&self)
    }

    package func evaluateBody<Result>(
        _ body: () -> Result
    ) -> Result {
        guard let stateStorage else {
            return body()
        }
        return StateBindingContext.with(
            storage: stateStorage,
            path: path,
            perform: body
        )
    }

    private mutating func visitNode<Content: View>(
        _ node: ViewNode,
        content: Content,
        flattenGroups: Bool = false
    ) {
        append(node)
        parents.append(node)
        content._visit(&self)
        _ = parents.removeLast()
        if flattenGroups {
            node.children = node.children.flatMap(\.unwrappedGroupChildren)
        }
    }
}

extension ViewBuildContext: ViewVisitor {
    public mutating func visitBody<Content: View>(
        _ content: () -> Content
    ) {
        let evaluated = evaluateBody(content)
        withPathComponent("body") { context in
            evaluated._visit(&context)
        }
    }

    public mutating func visitEmpty() {
        append(ViewNode(kind: .group))
    }

    private mutating func visitTupleChildren(
        _ children: (inout ViewBuildContext) -> Void
    ) {
        let group = ViewNode(kind: .group)
        append(group)
        parents.append(group)
        children(&self)
        _ = parents.removeLast()
    }

    private mutating func visitTupleChild<Content: View>(
        _ content: Content,
        index: Int
    ) {
        withPathComponent("child[\(index)]") { context in
            content._visit(&context)
        }
    }

    public mutating func visitTuple<A: View, B: View>(_ a: A, _ b: B) {
        visitTupleChildren { context in
            context.visitTupleChild(a, index: 0)
            context.visitTupleChild(b, index: 1)
        }
    }

    public mutating func visitTuple<A: View, B: View, C: View>(
        _ a: A, _ b: B, _ c: C
    ) {
        visitTupleChildren { context in
            context.visitTupleChild(a, index: 0)
            context.visitTupleChild(b, index: 1)
            context.visitTupleChild(c, index: 2)
        }
    }

    public mutating func visitTuple<A: View, B: View, C: View, D: View>(
        _ a: A, _ b: B, _ c: C, _ d: D
    ) {
        visitTupleChildren { context in
            context.visitTupleChild(a, index: 0)
            context.visitTupleChild(b, index: 1)
            context.visitTupleChild(c, index: 2)
            context.visitTupleChild(d, index: 3)
        }
    }

    public mutating func visitTuple<A: View, B: View, C: View, D: View, E: View>(
        _ a: A, _ b: B, _ c: C, _ d: D, _ e: E
    ) {
        visitTupleChildren { context in
            context.visitTupleChild(a, index: 0)
            context.visitTupleChild(b, index: 1)
            context.visitTupleChild(c, index: 2)
            context.visitTupleChild(d, index: 3)
            context.visitTupleChild(e, index: 4)
        }
    }

    public mutating func visitConditional<TrueContent: View, FalseContent: View>(
        _ storage: ConditionalContent<TrueContent, FalseContent>.Storage
    ) {
        let group = ViewNode(kind: .group)
        append(group)
        parents.append(group)
        switch storage {
        case .first(let content):
            withPathComponent("first") { context in
                context.withPathComponent("child[0]") { context in
                    content._visit(&context)
                }
            }
        case .second(let content):
            withPathComponent("second") { context in
                context.withPathComponent("child[0]") { context in
                    content._visit(&context)
                }
            }
        }
        _ = parents.removeLast()
    }

    public mutating func visitOptional<Content: View>(_ content: Content?) {
        let group = ViewNode(kind: .group)
        append(group)
        guard let content else { return }
        parents.append(group)
        withPathComponent("child[0]") { context in
            content._visit(&context)
        }
        _ = parents.removeLast()
    }

    public mutating func visitVStack<Content: View>(
        spacing: Int,
        content: Content
    ) {
        let node = ViewNode(kind: .vStack(spacing: spacing))
        withPathComponent("child[0]") { context in
            context.visitNode(node, content: content, flattenGroups: true)
        }
    }

    public mutating func visitHStack<Content: View>(
        spacing: Int,
        content: Content
    ) {
        let node = ViewNode(kind: .hStack(spacing: spacing))
        withPathComponent("child[0]") { context in
            context.visitNode(node, content: content, flattenGroups: true)
        }
    }

    public mutating func visitText(_ content: TextContent) {
        let string: String
        switch content.storage {
        case .staticString(let content):
            string = content.description
        case .boundedInteger(let value, let suffix):
            string = String(value) + suffix.description
        #if !hasFeature(Embedded)
        case .dynamicString(let content):
            string = content
        #endif
        }
        append(ViewNode(kind: .text(string)))
    }

    public mutating func visitButton<Label: View>(
        action: ButtonAction,
        label: Label
    ) {
        let node = ViewNode(kind: .button(action))
        withPathComponent("child[0]") { context in
            context.visitNode(node, content: label)
        }
    }
}
