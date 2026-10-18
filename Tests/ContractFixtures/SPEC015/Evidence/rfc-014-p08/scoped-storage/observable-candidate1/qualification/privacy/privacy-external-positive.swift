import GiftUI
public func seed<S: _GiftUIModelSchema>(_: S.Type, seed: S.Seed) -> State<S> { State(seed: seed) }
public func key<S: _GiftUIModelSchema>(_ state: State<S>) -> _GiftUIModelKey<S>? { state.wrappedValue }
