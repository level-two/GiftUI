import GiftUI
import GiftUIObservableState
import GiftUISemanticCore
package func forward<Model: ObservableStateModel & ~Copyable, Identity: Equatable & Sendable>(_ root: borrowing ObservableStateRootScope<Model, Identity>, identity: Identity, state: inout State<Model.Schema>) throws(ObservableStateError) { _ = try root.preserved(identity, ordinal: 0, state: &state) }
