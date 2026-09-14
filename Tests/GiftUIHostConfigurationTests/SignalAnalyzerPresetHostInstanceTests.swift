import GiftUIExecution
import GiftUIRuntimeCore
import Testing

@testable import GiftUIHostConfiguration

private enum PresetStep: UInt8, CaseIterable {
    case runtime
    case application
    case root
    case observation
    case input
    case source
    case loop
}

private final class PresetLifecycleProbe {
    var steps: [PresetStep] = []
    var opportunityCount = 0
}

private struct PresetLiveOwner<Failure: Equatable & Sendable>:
    SignalAnalyzerPresetLiveOwner
{
    let probe: PresetLifecycleProbe
    let failure: Failure?

    mutating func constructRuntimeAndEndpoint() -> HostActivationStepResult<Failure> {
        step(.runtime)
    }
    mutating func constructApplicationOwners() -> HostActivationStepResult<Failure> {
        step(.application)
    }
    mutating func attachRootModelInFirstCandidate() -> HostActivationStepResult<Failure> {
        step(.root)
    }
    mutating func installRepositoryObservationAndAdmitCurrentValues()
        -> HostActivationStepResult<Failure>
    {
        step(.observation)
    }
    mutating func acceptFirstPresentationAndEnableInput() -> HostActivationStepResult<Failure> {
        step(.input)
    }
    mutating func startAcquisitionThroughApplicationOpportunity()
        -> HostActivationStepResult<Failure>
    {
        step(.source)
    }
    mutating func establishWakeAndPacingHostLoop() -> HostActivationStepResult<Failure> {
        step(.loop)
    }

    mutating func runOpportunity() -> RunCycleResult<RuntimeOwnerFailure> {
        probe.opportunityCount += 1
        return .failure(
            ExecutionContext(
                cycle: nil,
                semanticRevision: nil,
                candidateFrame: nil,
                phase: .idle
            ),
            .focusedOwner(.drawing(.invariantViolation)),
            nil
        )
    }

    mutating func stopSourceDeliveryAndRepositoryObservation() {}
    mutating func preventInputEligibility() {}
    mutating func quiesceConstructedRuntime() {}
    mutating func refuseApplicationDeliveryAndInput() {}
    mutating func stopSourceDeliveryAndDetachObservations() {}
    mutating func cancelPointerSequencesAndHostCallbacks() {}
    mutating func quiesceRuntimeAndFinalizeActiveCycle() {}
    mutating func retireObservableRegistrationAndRouting() {}
    mutating func releasePlatformOwners() {}
    mutating func resetProfileStorage() {}
    mutating func invalidateAssemblyReportRuntimeUse() {}

    private func step(_ value: PresetStep) -> HostActivationStepResult<Failure> {
        probe.steps.append(value)
        return failure.map { .failure($0, progress: HostActivationProgress()) } ?? .advanced
    }
}

@Test func fourPresetInstancesActivateInExactOrderAndRunOnlyWhileActive() {
    exerciseMacOSDynamic()
    exerciseMacOSStatic()
    exerciseRaspberryPi()
    exerciseNRF52840()
}

@Test func presetInstanceRejectsWrongReportAndPreservesTypedActivationFailure() {
    let report = presetReport(kind: .nrf52840Static)
    let mismatch = SignalAnalyzerPresetHostInstances.macOSStatic(
        report: report,
        owner: PresetLiveOwner<MacOSStaticHostActivationFailure>(
            probe: PresetLifecycleProbe(),
            failure: nil
        )
    )
    switch consume mismatch {
    case nil:
        break
    case .some:
        Issue.record("wrong preset report must not construct an instance")
    }

    let probe = PresetLifecycleProbe()
    var instance = SignalAnalyzerPresetHostInstances.nrf52840Static(
        report: report,
        owner: PresetLiveOwner<NRF52840StaticHostActivationFailure>(
            probe: probe,
            failure: .runtime(.drawing(.capacityExhausted))
        )
    )!
    #expect(instance.activate() == .failure(.runtime(.drawing(.capacityExhausted))))
    #expect(instance.lifecycleState == .failed)
    #expect(probe.steps == [.runtime])
    #expect(instance.runOpportunity() == .invalidLifecycle)
    #expect(probe.opportunityCount == 0)
}

private func exerciseMacOSDynamic() {
    let probe = PresetLifecycleProbe()
    var instance = SignalAnalyzerPresetHostInstances.macOSDynamic(
        report: presetReport(kind: .macOSDynamic),
        owner: PresetLiveOwner<MacOSDynamicHostActivationFailure>(
            probe: probe, failure: nil)
    )!
    exercise(&instance, probe: probe)
}

private func exerciseMacOSStatic() {
    let probe = PresetLifecycleProbe()
    var instance = SignalAnalyzerPresetHostInstances.macOSStatic(
        report: presetReport(kind: .macOSStatic),
        owner: PresetLiveOwner<MacOSStaticHostActivationFailure>(probe: probe, failure: nil)
    )!
    exercise(&instance, probe: probe)
}

private func exerciseRaspberryPi() {
    let probe = PresetLifecycleProbe()
    var instance = SignalAnalyzerPresetHostInstances.raspberryPiDynamic(
        report: presetReport(kind: .raspberryPiDynamic),
        owner: PresetLiveOwner<RaspberryPiDynamicHostActivationFailure>(
            probe: probe, failure: nil)
    )!
    exercise(&instance, probe: probe)
}

private func exerciseNRF52840() {
    let probe = PresetLifecycleProbe()
    var instance = SignalAnalyzerPresetHostInstances.nrf52840Static(
        report: presetReport(kind: .nrf52840Static),
        owner: PresetLiveOwner<NRF52840StaticHostActivationFailure>(
            probe: probe, failure: nil)
    )!
    exercise(&instance, probe: probe)
}

private func exercise<Owner: SignalAnalyzerPresetLiveOwner>(
    _ instance: inout SignalAnalyzerPresetHostInstance<Owner>,
    probe: PresetLifecycleProbe
) {
    #expect(instance.runOpportunity() == .invalidLifecycle)
    #expect(instance.activate() == .active)
    #expect(probe.steps == PresetStep.allCases)
    guard case .cycle = instance.runOpportunity() else {
        Issue.record("active instance must enter its runtime owner")
        return
    }
    #expect(probe.opportunityCount == 1)
    let steps = probe.steps
    let repeated = instance.activate()
    #expect(repeated != .active)
    #expect(probe.steps == steps)
}

private func presetReport(kind: MVPHostKind) -> HostAssemblyReport {
    var validator = makeValidHostValidator()
    guard case .valid(let source) = validator.validate() else {
        fatalError("valid fixture must produce an assembly report")
    }
    return HostAssemblyReport(
        kind: kind,
        profile: kind == .macOSDynamic || kind == .raspberryPiDynamic ? .dynamic : .static,
        storageAudit: source.storageAudit,
        capabilitySnapshot: source.capabilitySnapshot,
        effectivePresentation: source.effectivePresentation,
        drawingPlanOperationLimit: source.drawingPlanOperationLimit,
        minimumSinkOperationCapacity: source.minimumSinkOperationCapacity,
        cardinality: source.cardinality,
        minimumFrameIntervalMicroseconds: source.minimumFrameIntervalMicroseconds,
        maximumFactServiceLatencyMicroseconds: source.maximumFactServiceLatencyMicroseconds,
        minimumAcceptedTransitionSpacingMicroseconds:
            source.minimumAcceptedTransitionSpacingMicroseconds,
        maximumCompactFactsPerServiceWindow: source.maximumCompactFactsPerServiceWindow,
        maximumRetryableRefusals: source.maximumRetryableRefusals
    )
}
