import GiftUI
import GiftUIObservableState
import GiftUISemanticCore
package func forward(owner: UInt32, generation: UInt32, slot: UInt16) -> ObservableModelOwnership.Address { ObservableModelOwnership.Address(owner: owner, generation: generation, slot: slot) }
