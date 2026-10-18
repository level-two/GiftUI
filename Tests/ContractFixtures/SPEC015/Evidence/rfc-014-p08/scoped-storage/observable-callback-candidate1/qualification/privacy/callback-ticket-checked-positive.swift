import GiftUI
import GiftUIObservableState
import GiftUISemanticCore
package func forward<Schema>(_ ticket: inout ObservableModelTicket<Schema>) throws(ObservableStateError) { _ = try ticket.requireClaim(); _ = ticket.key; ticket.endOwnership() }
