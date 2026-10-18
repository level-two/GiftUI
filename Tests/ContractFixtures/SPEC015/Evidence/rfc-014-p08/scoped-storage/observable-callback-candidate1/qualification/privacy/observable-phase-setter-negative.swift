import GiftUI
import GiftUIObservableState
import GiftUISemanticCore
package func forward(_ owner: inout ObservableModelOwnership) { owner.phase = .mutating }
