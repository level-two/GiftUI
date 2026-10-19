import GiftUI
import GiftUIObservableState
import GiftUISemanticCore
import CycleSchema
import CyclePresentation
import RuntimeCycleProbe
enum ForeignAction: UInt16, GiftUIAction { case increment = 1 }; func reject() { _ = CycleHandler.operation(ForeignAction.increment) }
