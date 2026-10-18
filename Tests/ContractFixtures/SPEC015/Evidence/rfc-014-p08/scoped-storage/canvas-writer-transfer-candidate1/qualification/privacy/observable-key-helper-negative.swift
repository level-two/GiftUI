import GiftUI
import GiftUIObservableState
import GiftUISemanticCore
package func forward<Model, Identity>(_ root: borrowing ObservableStateRootScope<Model, Identity>, slot: Int) where Model: ObservableStateModel & ~Copyable, Identity: Equatable & Sendable { _ = root.key(at: slot) }
