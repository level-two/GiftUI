import GiftUI
import GiftUIObservableState
import GiftUISemanticCore
package func forward<Model: ObservableStateModel & ~Copyable>(_ scope: borrowing ObservableModelScope<Model, Model.Schema>, key: _GiftUIModelKey<Model.Schema>, sink: consuming _GiftUIObservableChangeSink) throws(ObservableStateError) { if let attachment = try scope.attach(key, sink: consume sink) { try scope.detach(key, attachment: attachment) } }
