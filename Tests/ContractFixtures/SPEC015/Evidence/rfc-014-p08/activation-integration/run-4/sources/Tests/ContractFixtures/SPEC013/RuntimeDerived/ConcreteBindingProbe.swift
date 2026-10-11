import GiftUI
import GiftUIExecution
import GiftUIInteraction
import GiftUIRenderCore
import GiftUIRuntimeCore
import GiftUIObservableState

// Compile-only binding proof; actual cycle/provenance evidence is separate.
struct ActualOperationalCoordinator<S, E, M>: ~Copyable, ~Escapable, GiftUIRuntimeProfileCoordinator
where S: RuntimeProfileStorage & ~Copyable, E: SynchronousFrameEndpoint,
      E.Sink: DrawingOperationSink, M: ObservableStateModel & ObservableModelMutation & ~Copyable {
    typealias Endpoint = E
    typealias StateChangeFact = UInt8
    typealias CompletionFact = UInt16
    typealias OwnerFailure = RuntimeOwnerFailure
    var storage: S
    let models: ObservableModelScope<M, M.Schema>
    @_lifetime(copy models, copy target)
    init(storage: consuming S, models: consuming ObservableModelScope<M, M.Schema>, target: consuming ObservableStateRootTargetAccess<M, UInt8>) {
        self.storage = consume storage
        self.models = consume models
        self.target = consume target
    }
    let target: ObservableStateRootTargetAccess<M, UInt8>
    var profile: RuntimeProfileKind { .static }
    var storageAudit: RuntimeStorageAudit { fatalError() }
    var executionContext: ExecutionContext { .init(cycle: nil, semanticRevision: nil, candidateFrame: nil, phase: .idle) }
    var isQuiescent: Bool { false }
    mutating func quiesce() {}
    mutating func submit(pointer: NormalizedPointerEvent) -> ExecutionAdmissionOutcome { .init(result: .unavailable, context: executionContext) }
    mutating func submit(stateChange: UInt8) -> ExecutionAdmissionOutcome { .init(result: .unavailable, context: executionContext) }
    mutating func submit(completion: UInt16) -> ExecutionAdmissionOutcome { .init(result: .unavailable, context: executionContext) }
    mutating func runOpportunity() -> RunCycleResult<RuntimeOwnerFailure> { .failure(executionContext, .execution(.requiredFacilityUnavailable), nil) }
}
