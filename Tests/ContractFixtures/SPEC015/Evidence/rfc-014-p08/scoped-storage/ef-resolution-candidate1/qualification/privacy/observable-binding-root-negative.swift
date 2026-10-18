import GiftUI
import GiftUIObservableState
import GiftUISemanticCore
package func forward<Model, Identity, Domain>(_ binding: borrowing ObservableSemanticBodyBinding<Model, Identity, Domain>, identity: Identity) where Model: ObservableStateModel & ~Copyable, Identity: Equatable & Sendable, Domain: _GiftUIReadDomain, Domain.Slot == ObservableModelReadSlot<Model> { _ = binding.root.modelKey(identity: identity, ordinal: 0) }
