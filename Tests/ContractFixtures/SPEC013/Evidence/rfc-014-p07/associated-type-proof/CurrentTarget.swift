import GiftUI
import GiftUIExecution
import GiftUIInteraction
import GiftUIRenderCore
import GiftUIRuntimeCore
import GiftUIObservableState

struct ActualTargetCoordinator<S, E, H, M>: ~Copyable, ~Escapable, GiftUIRuntimeProfileCoordinator
where S: RuntimeProfileStorage, E: SynchronousFrameEndpoint,
      E.Sink: DrawingOperationSink, H: GiftUIActionHandler, M: ObservableStateModel & ObservableModelMutation & ~Copyable {
    typealias Storage = S
    typealias Endpoint = E
    typealias Handler = H
    typealias TargetAccess = ObservableStateRootTargetAccess<M, UInt8>
    typealias StateChangeFact = UInt8
    typealias CompletionFact = UInt16
    typealias OwnerFailure = RuntimeOwnerFailure
    var storage: S
    let models: ObservableModelScope<M, M.Schema>
    @_lifetime(copy models)
    init(storage: consuming S, models: consuming ObservableModelScope<M, M.Schema>) {
        self.storage = consume storage
        self.models = consume models
    }
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
