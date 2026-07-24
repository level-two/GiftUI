public protocol View {
    associatedtype Body: View

    @ViewBuilder
    var body: Body { get }

    func _makeNode(
        context: inout ViewBuildContext
    ) -> ViewNode
}

extension View {
    public func _makeNode(
        context: inout ViewBuildContext
    ) -> ViewNode {
        let content = context.evaluateBody { body }
        return context.withPathComponent("body") { context in
            content._makeNode(context: &context)
        }
    }
}

extension Never: View {
    public var body: Never {
        fatalError("Never cannot produce a GiftUI view body")
    }

    public func _makeNode(
        context: inout ViewBuildContext
    ) -> ViewNode {
        fatalError("Never cannot produce a GiftUI layout node")
    }
}
