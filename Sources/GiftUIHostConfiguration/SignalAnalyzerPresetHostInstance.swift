import GiftUIDisplayCore
import GiftUIExecution
import GiftUIRasterCore
import GiftUIRuntimeCore

package enum MacOSDynamicHostActivationFailure: Equatable, Sendable {
    case runtime(RuntimeOwnerFailure)
    case endpoint(RasterBackendError)
    case display(DisplayTargetError)
    case configuration(HostConfigurationError)
    case pacing(HostWakePacingError)
    case invariant
}

package enum MacOSStaticHostActivationFailure: Equatable, Sendable {
    case runtime(RuntimeOwnerFailure)
    case endpoint(RasterBackendError)
    case display(DisplayTargetError)
    case configuration(HostConfigurationError)
    case pacing(HostWakePacingError)
    case invariant
}

package enum RaspberryPiDynamicHostActivationFailure: Equatable, Sendable {
    case runtime(RuntimeOwnerFailure)
    case endpoint(RasterBackendError)
    case display(DisplayTargetError)
    case configuration(HostConfigurationError)
    case pacing(HostWakePacingError)
    case invariant
}

package enum NRF52840StaticHostActivationFailure: Equatable, Sendable {
    case runtime(RuntimeOwnerFailure)
    case endpoint(RasterBackendError)
    case display(DisplayTargetError)
    case configuration(HostConfigurationError)
    case pacing(HostWakePacingError)
    case invariant
}

package protocol SignalAnalyzerPresetLiveOwner:
    ~Copyable, ~Escapable, MVPHostActivationOwner, MVPHostTeardownOwner
{
    @inlinable
    @inline(__always)
    mutating func runOpportunity() -> RunCycleResult<RuntimeOwnerFailure>
}

package struct SignalAnalyzerPresetHostInstance<Owner>: MVPHostInstance, ~Copyable, ~Escapable
where Owner: SignalAnalyzerPresetLiveOwner & ~Copyable & ~Escapable {
    package let assemblyReport: HostAssemblyReport
    package private(set) var owner: Owner
    package private(set) var controller: MVPHostActivationController<Owner.ActivationFailure>
    private let invariantFailure: Owner.ActivationFailure

    @_lifetime(copy owner)
    fileprivate init?(
        expectedKind: MVPHostKind,
        assemblyReport: HostAssemblyReport,
        owner: consuming Owner,
        invariantFailure: Owner.ActivationFailure
    ) {
        guard assemblyReport.kind == expectedKind else { return nil }
        self.assemblyReport = assemblyReport
        self.owner = consume owner
        controller = MVPHostActivationController()
        self.invariantFailure = invariantFailure
    }

    package var lifecycleState: MVPHostLifecycleState {
        controller.lifecycleState
    }

    @inlinable
    @inline(__always)
    package mutating func activate() -> HostActivationResult<Owner.ActivationFailure> {
        controller.activate(owner: &owner, invariantFailure: invariantFailure)
    }

    @inlinable
    package mutating func runOpportunity() -> HostOpportunityResult<RuntimeOwnerFailure> {
        guard lifecycleState == .active else { return .invalidLifecycle }
        return .cycle(owner.runOpportunity())
    }

    @inlinable
    @inline(__always)
    package mutating func teardown() {
        controller.teardown(owner: &owner)
    }
}

package enum SignalAnalyzerPresetHostInstances {
    @_lifetime(copy owner)
    package static func macOSDynamic<Owner: SignalAnalyzerPresetLiveOwner & ~Copyable & ~Escapable>(
        report: HostAssemblyReport,
        owner: consuming Owner
    ) -> SignalAnalyzerPresetHostInstance<Owner>?
    where Owner.ActivationFailure == MacOSDynamicHostActivationFailure {
        SignalAnalyzerPresetHostInstance(
            expectedKind: .macOSDynamic,
            assemblyReport: report,
            owner: consume owner,
            invariantFailure: .invariant
        )
    }

    @_lifetime(copy owner)
    package static func macOSStatic<Owner: SignalAnalyzerPresetLiveOwner & ~Copyable & ~Escapable>(
        report: HostAssemblyReport,
        owner: consuming Owner
    ) -> SignalAnalyzerPresetHostInstance<Owner>?
    where Owner.ActivationFailure == MacOSStaticHostActivationFailure {
        SignalAnalyzerPresetHostInstance(
            expectedKind: .macOSStatic,
            assemblyReport: report,
            owner: consume owner,
            invariantFailure: .invariant
        )
    }

    @_lifetime(copy owner)
    package static func raspberryPiDynamic<
        Owner: SignalAnalyzerPresetLiveOwner & ~Copyable & ~Escapable
    >(
        report: HostAssemblyReport,
        owner: consuming Owner
    ) -> SignalAnalyzerPresetHostInstance<Owner>?
    where Owner.ActivationFailure == RaspberryPiDynamicHostActivationFailure {
        SignalAnalyzerPresetHostInstance(
            expectedKind: .raspberryPiDynamic,
            assemblyReport: report,
            owner: consume owner,
            invariantFailure: .invariant
        )
    }

    @_lifetime(copy owner)
    package static func nrf52840Static<
        Owner: SignalAnalyzerPresetLiveOwner & ~Copyable & ~Escapable
    >(
        report: HostAssemblyReport,
        owner: consuming Owner
    ) -> SignalAnalyzerPresetHostInstance<Owner>?
    where Owner.ActivationFailure == NRF52840StaticHostActivationFailure {
        SignalAnalyzerPresetHostInstance(
            expectedKind: .nrf52840Static,
            assemblyReport: report,
            owner: consume owner,
            invariantFailure: .invariant
        )
    }
}

// Ordinary owned hosts retain their previous escapable construction surface.
extension SignalAnalyzerPresetHostInstance: Escapable where Owner: Escapable & ~Copyable {}
