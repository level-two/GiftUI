import GiftUI
import GiftUIDrawing
import GiftUIExecution
import GiftUIInteraction
import GiftUILayout
import GiftUIObservableState
import GiftUIRenderCore
import GiftUISemanticCore

package protocol GiftUIRuntimeProfileCoordinator:
    ExecutionAdmissionSink, ExecutionOpportunityRunner
{
    associatedtype Storage: RuntimeProfileStorage
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
