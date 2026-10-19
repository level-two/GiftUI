import GiftUI
import GiftUIObservableState
import GiftUISemanticCore
import CycleSchema
import CyclePresentation
import RuntimeCycleProbe
func reject<S>(_ models: borrowing ObservableModelScope<CycleOwnedModel, S>, _ root: borrowing ObservableStateRootScope<CycleOwnedModel, SemanticCompleteIdentity>) { _ = ObservableSemanticBodyBinding(models: models.borrowedScope(), root: root.borrowedRoot(), domain: CycleDomain.self) }
