import GiftUI
import GiftUIObservableState
import GiftUISemanticCore
package func forward<Model: ~Copyable, Schema>(_ scope: borrowing ObservableModelScope<Model, Schema>) throws(ObservableStateError) { try scope.endFrame() }
