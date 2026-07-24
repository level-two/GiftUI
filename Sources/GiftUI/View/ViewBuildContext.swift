public struct ViewBuildContext {
    package private(set) var path: String
    package let stateStorage: (any StateStorage)?

    package init(
        path: String = "root",
        stateStorage: (any StateStorage)? = nil
    ) {
        self.path = path
        self.stateStorage = stateStorage
    }

    package mutating func makeChild<Content: View>(
        _ content: Content,
        index: Int
    ) -> ViewNode {
        withPathComponent("child[\(index)]") { context in
            content._makeNode(context: &context)
        }
    }

    package mutating func withPathComponent<Result>(
        _ component: String,
        perform: (inout ViewBuildContext) -> Result
    ) -> Result {
        let previousPath = path
        path += ".\(component)"
        defer { path = previousPath }
        return perform(&self)
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
}
