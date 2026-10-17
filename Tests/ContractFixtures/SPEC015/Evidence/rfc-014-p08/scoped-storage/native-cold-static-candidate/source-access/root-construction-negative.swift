import GiftUIObservableState
func bad<M: ObservableStateModel & ~Copyable, I: Equatable & Sendable>(
    _ input: borrowing ObservableStateRootScope<M, I>) {
    let constructor = ObservableStateRootScope<M, I>.init
    _ = constructor
}
