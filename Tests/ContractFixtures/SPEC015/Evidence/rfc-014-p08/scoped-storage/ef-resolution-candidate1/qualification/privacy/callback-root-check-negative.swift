import GiftUI
import GiftUIObservableState
import GiftUISemanticCore
package func forward<Model: ObservableStateModel & ~Copyable, Identity: Equatable & Sendable>(_ root: borrowing ObservableStateRootScope<Model, Identity>) throws(ObservableStateError) { try root.checkOperation(discovery: true) }
