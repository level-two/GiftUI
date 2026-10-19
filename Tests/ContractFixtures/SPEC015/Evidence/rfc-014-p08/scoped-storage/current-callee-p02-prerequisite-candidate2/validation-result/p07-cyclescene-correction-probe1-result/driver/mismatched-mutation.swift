import GiftUI
import GiftUIObservableState
import GiftUISemanticCore
import CycleSchema
import CyclePresentation
import RuntimeCycleProbe
enum ForeignMutation { case increment }; func reject(_ root: borrowing ObservableStateRootScope<CycleOwnedModel, SemanticCompleteIdentity>, _ key: _GiftUIModelKey<CycleModelSchema>) { _ = root.mutate(key, mutation: ForeignMutation.increment) }
