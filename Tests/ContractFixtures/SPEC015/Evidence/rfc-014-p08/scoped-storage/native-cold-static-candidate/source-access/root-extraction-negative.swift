import GiftUIObservableState
func bad<M: ObservableStateModel & ~Copyable, I: Equatable & Sendable>(
    _ input: borrowing ObservableStateRootScope<M, I>) { _ = input.records }
