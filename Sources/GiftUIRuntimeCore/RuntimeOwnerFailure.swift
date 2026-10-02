import GiftUIDrawing
import GiftUIInteraction
import GiftUILayout
import GiftUIObservableState
import GiftUISemanticCore

package enum RuntimeOwnerFailure: Equatable, Sendable {
    case semantic(SemanticExpansionError)
    case layout(LayoutError)
    case observableState(ObservableStateError)
    case interaction(InteractionError)
    case drawing(DrawingProductionError)
}
