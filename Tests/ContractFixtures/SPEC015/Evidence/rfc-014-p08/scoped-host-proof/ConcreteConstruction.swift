import GiftUIExecution
import GiftUIRuntimeCore
import GiftUIRuntimeStatic
import GiftUIRuntimeDynamic

// The inert report payload does not participate in the lifetime diagnostic.
package struct HostAssemblyReport: Equatable, Sendable {}

package enum MVPHostLifecycleState: UInt8, Equatable, Sendable {
    case valid = 0
    case activating = 1
    case active = 2
    case failed = 3
    case quiescing = 4
    case quiescent = 5
}

package enum HostActivationResult<Failure: Equatable & Sendable>:
    Equatable, Sendable
{
    case active
    case failure(Failure)
}

package enum HostOpportunityResult<OwnerFailure: Equatable & Sendable>: Equatable, Sendable {
    case cycle(RunCycleResult<OwnerFailure>)
    case invalidLifecycle
}

package protocol MVPHostInstance: ~Copyable, ~Escapable {
    associatedtype ActivationFailure: Equatable & Sendable
    associatedtype OwnerFailure: Equatable & Sendable = RuntimeOwnerFailure
    var lifecycleState: MVPHostLifecycleState { get }
    var assemblyReport: HostAssemblyReport { get }
    mutating func activate() -> HostActivationResult<ActivationFailure>
    mutating func runOpportunity() -> HostOpportunityResult<OwnerFailure>
    mutating func teardown()
}


struct ScopedHost<Coordinator>: ~Copyable, ~Escapable, MVPHostInstance
where Coordinator: GiftUIRuntimeProfileCoordinator & ~Copyable & ~Escapable {
    typealias ActivationFailure = RuntimeOwnerFailure
    typealias OwnerFailure = Coordinator.OwnerFailure
    let assemblyReport: HostAssemblyReport
    var coordinator: Coordinator
    var lifecycleState: MVPHostLifecycleState = .valid
    @_lifetime(copy coordinator)
    init(coordinator: consuming Coordinator) {
        self.assemblyReport = .init()
        self.coordinator = consume coordinator
    }
    mutating func activate() -> HostActivationResult<RuntimeOwnerFailure> {
        lifecycleState = .active
        return .active
    }
    mutating func runOpportunity() -> HostOpportunityResult<Coordinator.OwnerFailure> {
        guard lifecycleState == .active else { return .invalidLifecycle }
        return .cycle(coordinator.runOpportunity())
    }
    mutating func teardown() {
        lifecycleState = .quiescing
        coordinator.quiesce()
        if coordinator.isQuiescent { lifecycleState = .quiescent }
    }
}
func withStatic<B, A, O>(_ coordinator: consuming StaticRuntimeExecutionCoordinator<B, A, O>)
where B: StaticExecutionProfileBinding & RuntimeAuditedExecutionProfileBinding & ~Copyable & ~Escapable,
      A: ExecutionAdmissionSink & ~Copyable & ~Escapable,
      O: ExecutionOpportunityRunner & RuntimeOpportunityQuiescence & ~Copyable & ~Escapable {
    let result = constructScoped(coordinator: consume coordinator)
    guard case .constructed(var host) = consume result else { return }
    _ = host.activate()
    _ = host.runOpportunity()
    host.teardown()
}
func withDynamic<B, A, O>(_ coordinator: consuming DynamicRuntimeExecutionCoordinator<B, A, O>)
where B: DynamicExecutionProfileBinding & RuntimeAuditedExecutionProfileBinding & ~Copyable & ~Escapable,
      A: ExecutionAdmissionSink & ~Copyable & ~Escapable,
      O: ExecutionOpportunityRunner & RuntimeOpportunityQuiescence & ~Copyable & ~Escapable {
    let result = constructScoped(coordinator: consume coordinator)
    guard case .constructed(var host) = consume result else { return }
    _ = host.activate()
    _ = host.runOpportunity()
    host.teardown()
}

// Evidence-only inert validation-result payload. This proof does not validate.
package struct HostValidationResult {}
// Existing internal result cases with explicit generic lifetime constraints.
package enum HostPresetConstructionResult<Instance>: ~Copyable, ~Escapable
where Instance: MVPHostInstance & ~Copyable & ~Escapable {
    case invalid(HostValidationResult)
    case constructed(Instance)
}
// Candidate internal concrete return, dependent on the consumed coordinator.
// No associated Instance and no escaping callback or pointer fallback.
@_lifetime(copy coordinator)
func constructScoped<Coordinator>(coordinator: consuming Coordinator)
    -> HostPresetConstructionResult<ScopedHost<Coordinator>>
where Coordinator: GiftUIRuntimeProfileCoordinator & ~Copyable & ~Escapable {
    .constructed(ScopedHost(coordinator: consume coordinator))
}
