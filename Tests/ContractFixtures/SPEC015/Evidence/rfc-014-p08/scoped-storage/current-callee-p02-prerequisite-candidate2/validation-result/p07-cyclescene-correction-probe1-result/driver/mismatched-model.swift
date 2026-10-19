import GiftUI
import GiftUIObservableState
import GiftUISemanticCore
import CycleSchema
import CyclePresentation
import RuntimeCycleProbe
func reject<M: ObservableStateModel & ~Copyable>(_ models: borrowing ObservableModelScope<M, M.Schema>, _ root: borrowing ObservableStateRootScope<CycleOwnedModel, SemanticCompleteIdentity>) { _ = ObservableSemanticBodyBinding(models: models.borrowedScope(), root: root.borrowedRoot(), domain: CycleDomain.self) }
