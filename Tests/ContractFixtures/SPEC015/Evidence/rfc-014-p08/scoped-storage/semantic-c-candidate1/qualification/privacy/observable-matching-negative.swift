import GiftUI
import GiftUIObservableState
import GiftUISemanticCore
package func forward<Model, Identity>(_ root: borrowing ObservableStateRootScope<Model, Identity>, identity: Identity, ordinal: UInt16) where Model: ObservableStateModel & ~Copyable, Identity: Equatable & Sendable { _ = root.matching(identity, ordinal: ordinal) }
