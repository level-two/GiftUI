public struct ConditionalContent<TrueContent: View, FalseContent: View>: View, PrimitiveView {
    package enum Storage {
        case first(TrueContent)
        case second(FalseContent)
    }

    package let storage: Storage

    package init(storage: Storage) {
        self.storage = storage
    }

    package func _makePrimitiveNode(
        context: inout ViewBuildContext
    ) -> ViewNode {
        let child: ViewNode
        switch storage {
        case .first(let content):
            child = context.makeChild(content, index: 0)
        case .second(let content):
            child = context.makeChild(content, index: 0)
        }
        return ViewNode(kind: .group, children: [child])
    }
}
