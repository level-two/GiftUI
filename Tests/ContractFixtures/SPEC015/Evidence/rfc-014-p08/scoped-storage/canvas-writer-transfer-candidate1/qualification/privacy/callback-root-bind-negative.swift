import GiftUI
import GiftUIObservableState
import GiftUISemanticCore
package func forward<Model: ObservableStateModel & ~Copyable, Identity: Equatable & Sendable>(_ root: borrowing ObservableStateRootScope<Model, Identity>, state: inout State<Model.Schema>) throws(ObservableStateError) { try root.bind(&state, slot: 0) }
