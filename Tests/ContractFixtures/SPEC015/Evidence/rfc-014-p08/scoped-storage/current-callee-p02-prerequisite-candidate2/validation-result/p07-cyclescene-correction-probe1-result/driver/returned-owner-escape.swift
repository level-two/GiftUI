import GiftUI
import GiftUIObservableState
import GiftUIRuntimeStatic
@_lifetime(immortal) func reject<M: ~Copyable, S>(_ coordinator: consuming StaticRuntimeExecutionCoordinator<ScopedBinding<M, S>, ScopedCoordinator<M, S>, ScopedCoordinator<M, S>>) -> ScopedCoordinator<M, S> { coordinator.takeQuiescedOpportunity()! }
