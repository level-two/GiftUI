import GiftUI
import GiftUIDrawing
import GiftUIInteraction
import GiftUIObservableState
import GiftUIRuntimeCore
import GiftUIRuntimeStatic
import GiftUISemanticCore
import CycleSchema

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
                models: supplied.borrowedModels(), root: supplied.borrowedRoot(),
                semantic: supplied.borrowedSemantic(), values: supplied.borrowedValues(),
                geometry: supplied.geometry, interaction: supplied.interaction,
                scopedControl: supplied.borrowedControl(), limits: supplied.audit.limits)
            let binding = CycleExecutionBinding(models: supplied.borrowedModels(),
                root: supplied.borrowedRoot(), scopedControl: supplied.borrowedControl(), audit: supplied.audit)!
            let coordinator = InvestigationCoordinator(binding: binding,
                admission: CycleAdmission(control: supplied.controlPointer, limits: supplied.audit.limits.execution),
                opportunity: pipeline)
            self = .active(consume coordinator)
        case .active(let coordinator):
            self = .active(consume coordinator)
        }
    }
    mutating func runOpportunity() -> Bool {
        switch consume self {
        case .inert(let supplied):
            self = .inert(consume supplied)
            return false
        case .active(var coordinator):
            let success: Bool
            if case .success = coordinator.runOpportunity() { success = true } else { success = false }
            self = .active(consume coordinator)
            return success
        }
    }
    mutating func quiesce() {
        switch consume self {
        case .inert(let supplied): self = .inert(consume supplied)
        case .active(var coordinator):
            coordinator.quiesce()
            precondition(coordinator.isQuiescent)
            self = .active(consume coordinator)
        }
    }
}
typealias InvestigationOwner = LayoutAOwner
