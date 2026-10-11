import GiftUI
import GiftUIDrawing
import GiftUIExecution
import GiftUIInteraction
import GiftUILayout
import GiftUIObservableState
import GiftUIRenderCore
import GiftUISemanticCore

protocol AmendedRuntimeProfileCoordinator:
    ~Copyable, ~Escapable, ExecutionAdmissionSink, ExecutionOpportunityRunner
{
    associatedtype Storage: RuntimeProfileStorage & ~Copyable
    associatedtype Endpoint: SynchronousFrameEndpoint
    where Endpoint.Sink: DrawingOperationSink
    associatedtype Handler: GiftUIActionHandler
    associatedtype TargetAccess: ActionModelTargetAccess
    where TargetAccess.Model == Handler.Model

    var profile: RuntimeProfileKind { get }
    var storageAudit: RuntimeStorageAudit { get }
    var executionContext: ExecutionContext { get }
    var isQuiescent: Bool { get }

    mutating func quiesce()
}

import GiftUI
import GiftUIExecution
import GiftUIInteraction
import GiftUIRenderCore
import GiftUIRuntimeCore
import GiftUIObservableState

struct ActualStorageCoordinator<S, E, H, T>: ~Copyable, ~Escapable, AmendedRuntimeProfileCoordinator
where S: RuntimeProfileStorage & ~Copyable, E: SynchronousFrameEndpoint,
      E.Sink: DrawingOperationSink, H: GiftUIActionHandler, T: ActionModelTargetAccess,
      T.Model == H.Model {
    typealias Storage = S
    typealias Endpoint = E
    typealias Handler = H
    typealias TargetAccess = T
    typealias StateChangeFact = UInt8
    typealias CompletionFact = UInt16
    typealias OwnerFailure = RuntimeOwnerFailure
    var storage: S
    let models: ObservableModelScope<UInt8, UInt8>
    @_lifetime(copy models)
    init(storage: consuming S, models: consuming ObservableModelScope<UInt8, UInt8>) {
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
