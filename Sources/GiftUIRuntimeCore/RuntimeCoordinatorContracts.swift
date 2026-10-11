import GiftUI
import GiftUIDrawing
import GiftUIExecution
import GiftUIInteraction
import GiftUILayout
import GiftUIObservableState
import GiftUIRenderCore
import GiftUISemanticCore

package protocol GiftUIRuntimeProfileCoordinator:
    ~Copyable, ~Escapable, ExecutionAdmissionSink, ExecutionOpportunityRunner
{
    associatedtype Endpoint: SynchronousFrameEndpoint
    where Endpoint.Sink: DrawingOperationSink

    var profile: RuntimeProfileKind { get }
    var storageAudit: RuntimeStorageAudit { get }
    var executionContext: ExecutionContext { get }
    var isQuiescent: Bool { get }

    mutating func quiesce()
}

/// A concrete factory supplies this retained audit only after validating the
/// same owners whose scopes are lent to the execution opportunity.
package protocol RuntimeAuditedExecutionProfileBinding: ~Copyable, ~Escapable {
    associatedtype Endpoint: SynchronousFrameEndpoint
    where Endpoint.Sink: DrawingOperationSink
    var storageAudit: RuntimeStorageAudit { get }
}
