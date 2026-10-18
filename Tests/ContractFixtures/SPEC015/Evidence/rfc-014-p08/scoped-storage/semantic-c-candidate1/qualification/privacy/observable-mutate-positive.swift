import GiftUI
import GiftUIObservableState
import GiftUISemanticCore
package func forward<Model, Identity>(_ root: borrowing ObservableStateRootScope<Model, Identity>, key: _GiftUIModelKey<Model.Schema>, mutation: Model.Mutation) -> ObservableStateResult where Model: ObservableStateModel & ObservableModelMutation & ~Copyable, Identity: Equatable & Sendable { root.mutate(key, mutation: mutation) }
