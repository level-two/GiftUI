public protocol GiftUIActionHandler {
    associatedtype Action: GiftUIAction
    associatedtype Model: _GiftUIObservableReference

    mutating func handle(_ action: Action, model: borrowing Model)
}
