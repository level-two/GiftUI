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
    case inert(InvestigationSupplied, Span<UInt8>)
    case active(InvestigationCoordinator, Span<UInt8>)
    @_lifetime(copy supplied, copy activationSpan)
    init(supplied: consuming InvestigationSupplied, activationSpan: Span<UInt8>) { self = .inert(consume supplied, activationSpan) }

    @_lifetime(self: copy self)
    mutating func activate() {
        switch consume self {
        case .inert(let supplied, let activationSpan):
            checkRetainedActivationSpan(activationSpan)
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
            self = .active(consume coordinator, activationSpan)
        case .active(let coordinator, let activationSpan):
            checkRetainedActivationSpan(activationSpan)
            self = .active(consume coordinator, activationSpan)
        }
    }
    @_lifetime(self: copy self)
    mutating func runOpportunity() -> Bool {
        switch consume self {
        case .inert(let supplied, let activationSpan):
            checkRetainedActivationSpan(activationSpan)
            self = .inert(consume supplied, activationSpan)
            return false
        case .active(var coordinator, let activationSpan):
            checkRetainedActivationSpan(activationSpan)
            let success: Bool
            if case .success = coordinator.runOpportunity() { success = true } else { success = false }
            self = .active(consume coordinator, activationSpan)
            return success
        }
    }
    @_lifetime(self: copy self)
    mutating func quiesce() {
        switch consume self {
        case .inert(let supplied, let activationSpan): self = .inert(consume supplied, activationSpan)
        case .active(var coordinator, let activationSpan):
            checkRetainedActivationSpan(activationSpan)
            coordinator.quiesce()
            precondition(coordinator.isQuiescent)
            self = .active(consume coordinator, activationSpan)
        }
    }
}
typealias InvestigationOwner = LayoutAOwner

@inline(never)
func checkRetainedActivationSpan(_ span: borrowing Span<UInt8>) {
    precondition(span.count == 1 && span[0] != 0)
}
