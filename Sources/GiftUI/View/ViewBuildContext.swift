public struct ViewBuildContext {
    package private(set) var path: String

    package init(path: String = "root") {
        self.path = path
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
}
