import GiftUI
import GiftUIObservableState
import GiftUISemanticCore
package func forward<Model: ~Copyable, Schema>(_ scope: borrowing ObservableModelScope<Model, Schema>, ticket: inout ObservableModelTicket<Schema>, key: _GiftUIModelKey<Schema>) throws(ObservableStateError) { try scope.validateTicket(ticket); try scope.validateAssociation(key); try scope.validateOperation(discovery: true); try scope.pin(key); try scope.register(ticket); try scope.release(&ticket); scope.requireStop() }
