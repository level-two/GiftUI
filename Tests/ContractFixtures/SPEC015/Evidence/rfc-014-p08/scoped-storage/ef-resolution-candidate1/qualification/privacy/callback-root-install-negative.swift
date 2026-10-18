import GiftUI
import GiftUIObservableState
import GiftUISemanticCore
package func forward<Model: ObservableStateModel & ~Copyable, Identity: Equatable & Sendable>(_ root: borrowing ObservableStateRootScope<Model, Identity>, identity: Identity, state: inout State<Model.Schema>, ticket: inout ObservableModelTicket<Model.Schema>) throws(ObservableStateError) { try root.install(identity, ordinal: 0, state: &state, ticket: &ticket) }
