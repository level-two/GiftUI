import GiftUI
import GiftUIDrawing
import GiftUIInteraction
import GiftUIObservableState
import GiftUIRuntimeCore
import GiftUIRuntimeStatic
import GiftUISemanticCore
import CycleSchema
@testable import RuntimeCycleProbe

// Candidate B: same anchored states, transferred through an optional field.
enum LayoutBState: ~Copyable, ~Escapable {
    case inert(InvestigationSupplied)
    case active(InvestigationCoordinator)
}
struct LayoutBOwner: ~Copyable, ~Escapable {
    private var state: LayoutBState?
    @_lifetime(copy supplied)
    init(supplied: consuming InvestigationSupplied) { state = .some(.inert(consume supplied)) }

    mutating func activate() {
        switch state.take()! {
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
            state = .some(.active(consume coordinator))
        case .active(let coordinator):
            state = .some(.active(consume coordinator))
        }
    }
    mutating func quiesce() {
        switch state.take()! {
        case .inert(let supplied): state = .some(.inert(consume supplied))
        case .active(var coordinator):
            coordinator.quiesce()
            state = .some(.active(consume coordinator))
        }
    }
}
typealias InvestigationOwner = LayoutBOwner
