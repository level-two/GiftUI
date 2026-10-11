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
    var host = ScopedHost(coordinator: consume coordinator)
    _ = host.activate()
    _ = host.runOpportunity()
    host.teardown()
}
func withDynamic<B, A, O>(_ coordinator: consuming DynamicRuntimeExecutionCoordinator<B, A, O>)
where B: DynamicExecutionProfileBinding & RuntimeAuditedExecutionProfileBinding & ~Copyable & ~Escapable,
      A: ExecutionAdmissionSink & ~Copyable & ~Escapable,
      O: ExecutionOpportunityRunner & RuntimeOpportunityQuiescence & ~Copyable & ~Escapable {
    var host = ScopedHost(coordinator: consume coordinator)
    _ = host.activate()
    _ = host.runOpportunity()
    host.teardown()
}

package struct HostConstructedInstanceAudit: Equatable, Sendable {}
package protocol MVPValidatedHostInstanceFactory: ~Copyable {
    associatedtype Instance: MVPHostInstance & ~Copyable & ~Escapable

    mutating func construct(
        validatedBy report: HostAssemblyReport
    ) -> Instance

    borrowing func audit(
        _ instance: borrowing Instance
    ) -> HostConstructedInstanceAudit
}


struct ProbeFactory<C>: MVPValidatedHostInstanceFactory
where C: GiftUIRuntimeProfileCoordinator & ~Copyable & ~Escapable {
    typealias Instance = ScopedHost<C>
    @_lifetime(copy self)
    mutating func construct(validatedBy report: HostAssemblyReport) -> Instance { fatalError() }
    borrowing func audit(_ instance: borrowing Instance) -> HostConstructedInstanceAudit { .init() }
}
