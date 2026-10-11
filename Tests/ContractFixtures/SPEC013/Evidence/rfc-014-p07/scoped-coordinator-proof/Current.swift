import GiftUI
import GiftUIExecution
import GiftUIObservableState
import GiftUIRuntimeCore

// Real P03 storage scope, not a pointer descriptor or mock read domain.
struct ScopedCoordinator<Model: ~Copyable, Schema>:
    ~Copyable, ~Escapable, ExecutionAdmissionSink, ExecutionOpportunityRunner
{
    typealias StateChangeFact = UInt8
    typealias CompletionFact = UInt16
    typealias OwnerFailure = RuntimeOwnerFailure
    let models: ObservableModelScope<Model, Schema>

    @_lifetime(copy models)
    init(models: consuming ObservableModelScope<Model, Schema>) {
        self.models = consume models
    }
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
