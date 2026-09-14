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
    MVPHostActivationOwner, MVPHostTeardownOwner
{
    mutating func runOpportunity() -> RunCycleResult<RuntimeOwnerFailure>
}

package struct SignalAnalyzerPresetHostInstance<Owner>: MVPHostInstance, ~Copyable
where Owner: SignalAnalyzerPresetLiveOwner {
    package let assemblyReport: HostAssemblyReport
    package private(set) var owner: Owner
    package private(set) var controller: MVPHostActivationController<Owner.ActivationFailure>
    private let invariantFailure: Owner.ActivationFailure

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

    package mutating func activate() -> HostActivationResult<Owner.ActivationFailure> {
        controller.activate(owner: &owner, invariantFailure: invariantFailure)
    }

    package mutating func runOpportunity() -> HostOpportunityResult {
        guard lifecycleState == .active else { return .invalidLifecycle }
        return .cycle(owner.runOpportunity())
    }

    package mutating func teardown() {
        controller.teardown(owner: &owner)
    }
}

package enum SignalAnalyzerPresetHostInstances {
    package static func macOSDynamic<Owner: SignalAnalyzerPresetLiveOwner>(
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

    package static func macOSStatic<Owner: SignalAnalyzerPresetLiveOwner>(
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

    package static func raspberryPiDynamic<Owner: SignalAnalyzerPresetLiveOwner>(
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

    package static func nrf52840Static<Owner: SignalAnalyzerPresetLiveOwner>(
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
