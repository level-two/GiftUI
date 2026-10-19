import GiftUI
import GiftUIObservableState
import GiftUIRuntimeStatic
func reject<M: ~Copyable, S>(_ coordinator: consuming StaticRuntimeExecutionCoordinator<ScopedBinding<M, S>, ScopedCoordinator<M, S>, ScopedCoordinator<M, S>>) { _ = coordinator.takeQuiescedOpportunity(); _ = coordinator.runOpportunity() }
