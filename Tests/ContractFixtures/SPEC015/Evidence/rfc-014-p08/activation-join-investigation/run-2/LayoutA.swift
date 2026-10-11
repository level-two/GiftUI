import GiftUI
import GiftUIDrawing
import GiftUIInteraction
import GiftUIObservableState
import GiftUIRuntimeCore
import GiftUIRuntimeStatic
import GiftUISemanticCore
import CycleSchema
@testable import RuntimeCycleProbe

// Candidate A: internal state storage control; not a new host role or protocol.
enum LayoutAOwner: ~Copyable, ~Escapable {
    case inert(InvestigationSupplied)
    case active(InvestigationCoordinator)
    @_lifetime(copy supplied)
    init(supplied: consuming InvestigationSupplied) { self = .inert(consume supplied) }

    mutating func activate() {
        switch consume self {
        case .inert(let supplied):
            let pipeline = InvestigationPipeline(
                models: supplied.models.borrowedScope(), root: supplied.root.borrowedRoot(),
                semantic: supplied.semantic.borrowedStore(), values: supplied.values.borrowedValues(),
                geometry: supplied.geometry, interaction: supplied.interaction,
                control: supplied.control, limits: supplied.audit.limits)
            let binding = CycleExecutionBinding(models: supplied.models.borrowedScope(),
                root: supplied.root.borrowedRoot(), control: supplied.control, audit: supplied.audit)!
            let coordinator = InvestigationCoordinator(binding: binding,
                admission: CycleAdmission(control: supplied.control, limits: supplied.audit.limits.execution),
                opportunity: pipeline)
            self = .active(consume coordinator)
        case .active(let coordinator):
            self = .active(consume coordinator)
        }
    }
    mutating func quiesce() {
        switch consume self {
        case .inert(let supplied): self = .inert(consume supplied)
        case .active(var coordinator):
            coordinator.quiesce()
            self = .active(consume coordinator)
        }
    }
}
typealias InvestigationOwner = LayoutAOwner
