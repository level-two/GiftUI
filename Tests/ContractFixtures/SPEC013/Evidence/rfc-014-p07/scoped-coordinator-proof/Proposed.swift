import GiftUI
import GiftUIExecution
import GiftUIObservableState
import GiftUIRuntimeCore

// Real P03 storage scope, not a pointer descriptor or mock read domain.
struct ScopedCoordinator<Model: ~Copyable, Schema>:
    ~Copyable, ~Escapable, ProposedAdmissionSink, ProposedOpportunityRunner
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

// Proposed declaration correction only. Exact fact/result signatures retained.
protocol ProposedAdmissionSink: ~Copyable, ~Escapable {
    associatedtype StateChangeFact: Sendable
    associatedtype CompletionFact: Sendable
    mutating func submit(pointer: NormalizedPointerEvent) -> ExecutionAdmissionOutcome
    mutating func submit(stateChange: StateChangeFact) -> ExecutionAdmissionOutcome
    mutating func submit(completion: CompletionFact) -> ExecutionAdmissionOutcome
}
protocol ProposedOpportunityRunner: ~Copyable, ~Escapable {
    associatedtype OwnerFailure: Equatable & Sendable
    mutating func runOpportunity() -> RunCycleResult<OwnerFailure>
}
func run<Model: ~Copyable, Schema>(_ models: borrowing ObservableModelScope<Model, Schema>) {
    var coordinator = ScopedCoordinator(models: models.borrowedScope())
    _ = coordinator.submit(stateChange: 1)
    _ = coordinator.runOpportunity()
}
