import GiftUIObservableState
@_lifetime(copy input)
func model<M: ~Copyable, S>(_ input: borrowing ObservableModelScope<M, S>) -> ObservableModelScope<M, S> {
    input.borrowedScope()
}
@_lifetime(copy input)
func root<M: ObservableStateModel & ~Copyable, I: Equatable & Sendable>(
    _ input: borrowing ObservableStateRootScope<M, I>) -> ObservableStateRootScope<M, I> {
    input.borrowedRoot()
}
