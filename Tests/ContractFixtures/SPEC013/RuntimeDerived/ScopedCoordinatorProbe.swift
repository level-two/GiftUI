import GiftUI
import GiftUIExecution
import GiftUIObservableState
import GiftUIRuntimeCore

// Real P03 storage scope, not a pointer descriptor or mock read domain.
struct ScopedCoordinator<Model: ~Copyable, Schema>:
    ~Copyable, ~Escapable, ExecutionAdmissionSink, ExecutionOpportunityRunner, RuntimeOpportunityQuiescence
{
    typealias StateChangeFact = UInt8
    typealias CompletionFact = UInt16
    typealias OwnerFailure = RuntimeOwnerFailure
    let models: ObservableModelScope<Model, Schema>

    @_lifetime(copy models)
    init(models: consuming ObservableModelScope<Model, Schema>) {
        self.models = consume models
    }
    var isOpportunityQuiescent = false
    mutating func quiesceOpportunity() { isOpportunityQuiescent = true }
    var context: ExecutionContext {
        .init(cycle: nil, semanticRevision: nil, candidateFrame: nil, phase: .idle)
    }
    mutating func submit(pointer: NormalizedPointerEvent) -> ExecutionAdmissionOutcome {
        .init(result: .unavailable, context: context)
    }
    mutating func submit(stateChange: UInt8) -> ExecutionAdmissionOutcome {
        .init(result: .unavailable, context: context)
    }
    mutating func submit(completion: UInt16) -> ExecutionAdmissionOutcome {
        .init(result: .unavailable, context: context)
    }
    mutating func runOpportunity() -> RunCycleResult<RuntimeOwnerFailure> {
        .failure(context, .execution(.requiredFacilityUnavailable), nil)
    }
}

import GiftUIRuntimeStatic
#if !hasFeature(Embedded)
import GiftUIRuntimeDynamic
#endif

struct ScopedBinding<Model: ~Copyable, Schema>: ~Copyable, ~Escapable, StaticExecutionProfileBinding {
    let models: ObservableModelScope<Model, Schema>
    var isQuiescent = false
    @_lifetime(copy models)
    init(models: consuming ObservableModelScope<Model, Schema>) { self.models = consume models }
    var executionContext: ExecutionContext { .init(cycle: nil, semanticRevision: nil, candidateFrame: nil, phase: .idle) }
    mutating func quiesce() { isQuiescent = true }
}
#if !hasFeature(Embedded)
extension ScopedBinding: DynamicExecutionProfileBinding where Model: ~Copyable {}
#endif

func forwardScopedCoordinators<Model: ~Copyable, Schema>(_ models: borrowing ObservableModelScope<Model, Schema>) {
    var fixed = StaticRuntimeExecutionCoordinator(
        binding: ScopedBinding(models: models.borrowedScope()),
        admission: ScopedCoordinator(models: models.borrowedScope()),
        opportunity: ScopedCoordinator(models: models.borrowedScope()))
    _ = fixed.submit(stateChange: 1)
    _ = fixed.runOpportunity()
    fixed.quiesce()
    #if !hasFeature(Embedded)
    var dynamic = DynamicRuntimeExecutionCoordinator(
        binding: ScopedBinding(models: models.borrowedScope()),
        admission: ScopedCoordinator(models: models.borrowedScope()),
        opportunity: ScopedCoordinator(models: models.borrowedScope()))
    _ = dynamic.submit(stateChange: 1)
    _ = dynamic.runOpportunity()
    dynamic.quiesce()
    #endif
}
