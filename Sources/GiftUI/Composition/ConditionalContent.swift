public struct ConditionalContent<TrueContent: View, FalseContent: View>: View, PrimitiveView {
    package enum Storage {
        case first(TrueContent)
        case second(FalseContent)
    }

    package let storage: Storage

    package init(storage: Storage) {
        self.storage = storage
    }
}
