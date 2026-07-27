public struct ConditionalContent<TrueContent: View, FalseContent: View>: View, PrimitiveView {
    public enum Storage {
        case first(TrueContent)
        case second(FalseContent)
    }

    package let storage: Storage

    package init(storage: Storage) {
        self.storage = storage
    }

    public func _visit<Visitor: ViewVisitor>(_ visitor: inout Visitor) {
        visitor.visitConditional(storage)
    }
}
