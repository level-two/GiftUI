import Testing

@testable import GiftUIHostConfiguration

private enum ActivationStage: UInt8, CaseIterable, Equatable, Sendable {
    case runtimeAndEndpoint
    case applicationOwners
    case rootAttachment
    case observation
    case inputEligibility
    case acquisition
    case hostLoop
}

private enum FixtureActivationFailure: UInt8, Equatable, Sendable {
    case runtimeAndEndpoint
    case applicationOwners
    case rootAttachment
    case observation
    case inputEligibility
    case acquisition
    case hostLoop
    case invariant

    init(_ stage: ActivationStage) {
        self =
            switch stage {
            case .runtimeAndEndpoint: .runtimeAndEndpoint
            case .applicationOwners: .applicationOwners
            case .rootAttachment: .rootAttachment
            case .observation: .observation
            case .inputEligibility: .inputEligibility
            case .acquisition: .acquisition
            case .hostLoop: .hostLoop
            }
    }
}

private enum ActivationCall: Equatable {
    case step(ActivationStage)
    case stopSourceAndObservation
    case preventInput
    case quiesceRuntime
}

private final class ActivationProbe {
    var calls: [ActivationCall] = []
}

private struct FixtureActivationOwner: MVPHostActivationOwner {
    let probe: ActivationProbe
    let failingStage: ActivationStage?

    mutating func constructRuntimeAndEndpoint() -> HostActivationStepResult<
        FixtureActivationFailure
    > {
        result(for: .runtimeAndEndpoint)
    }

    mutating func constructApplicationOwners() -> HostActivationStepResult<FixtureActivationFailure>
    {
        result(for: .applicationOwners)
    }

    mutating func attachRootModelInFirstCandidate() -> HostActivationStepResult<
        FixtureActivationFailure
    > {
        result(for: .rootAttachment)
    }

    mutating func installRepositoryObservationAndAdmitCurrentValues()
        -> HostActivationStepResult<FixtureActivationFailure>
    {
        result(for: .observation)
    }

    mutating func acceptFirstPresentationAndEnableInput()
        -> HostActivationStepResult<FixtureActivationFailure>
    {
        result(for: .inputEligibility)
    }

    mutating func startAcquisitionThroughApplicationOpportunity()
        -> HostActivationStepResult<FixtureActivationFailure>
    {
        result(for: .acquisition)
    }

    mutating func establishWakeAndPacingHostLoop()
        -> HostActivationStepResult<FixtureActivationFailure>
    {
        result(for: .hostLoop)
    }

    mutating func stopSourceDeliveryAndRepositoryObservation() {
        probe.calls.append(.stopSourceAndObservation)
    }

    mutating func preventInputEligibility() {
        probe.calls.append(.preventInput)
    }

    mutating func quiesceConstructedRuntime() {
        probe.calls.append(.quiesceRuntime)
    }

    private func result(
        for stage: ActivationStage
    ) -> HostActivationStepResult<FixtureActivationFailure> {
        probe.calls.append(.step(stage))
        guard stage == failingStage else { return .advanced }
        return .failure(FixtureActivationFailure(stage), progress: partialProgress(at: stage))
    }

    private func partialProgress(at stage: ActivationStage) -> HostActivationProgress {
        switch stage {
        case .runtimeAndEndpoint:
            HostActivationProgress(runtimeConstructed: true)
        case .observation:
            HostActivationProgress(observationInstalled: true)
        case .acquisition:
            HostActivationProgress(sourceStarted: true)
        default:
            HostActivationProgress()
        }
    }
}

private struct ActivationFixtureInstance: MVPHostInstance {
    let assemblyReport: HostAssemblyReport
    var owner: FixtureActivationOwner
    var controller = MVPHostActivationController<FixtureActivationFailure>()

    var lifecycleState: MVPHostLifecycleState { controller.lifecycleState }

    mutating func activate() -> HostActivationResult<FixtureActivationFailure> {
        controller.activate(owner: &owner, invariantFailure: .invariant)
    }

    mutating func runOpportunity() -> HostOpportunityResult {
        .invalidLifecycle
    }

    mutating func teardown() {}
}

@Test func successfulActivationUsesAllSevenStepsInOrder() {
    let probe = ActivationProbe()
    var instance = ActivationFixtureInstance(
        assemblyReport: makeActivationReport(),
        owner: FixtureActivationOwner(probe: probe, failingStage: nil)
    )

    #expect(instance.activate() == .active)
    #expect(instance.lifecycleState == .active)
    #expect(
        probe.calls
            == ActivationStage.allCases.map(ActivationCall.step)
    )
    #expect(instance.controller.progress.runtimeConstructed)
    #expect(instance.controller.progress.observationInstalled)
    #expect(instance.controller.progress.sourceStarted)
}

@Test(arguments: ActivationStage.allCases)
private func everyActivationStepPreservesFailureAndContainsPartialWork(
    failingStage: ActivationStage
) {
    let probe = ActivationProbe()
    var instance = ActivationFixtureInstance(
        assemblyReport: makeActivationReport(),
        owner: FixtureActivationOwner(probe: probe, failingStage: failingStage)
    )

    #expect(instance.activate() == .failure(FixtureActivationFailure(failingStage)))
    #expect(instance.lifecycleState == .failed)

    let attemptedSteps = Array(ActivationStage.allCases.prefix(Int(failingStage.rawValue) + 1))
    var expected = attemptedSteps.map(ActivationCall.step)
    if failingStage.rawValue >= ActivationStage.observation.rawValue {
        expected.append(.stopSourceAndObservation)
    }
    expected.append(.preventInput)
    expected.append(.quiesceRuntime)
    #expect(probe.calls == expected)
}

@Test func repeatedActivationFromActiveReturnsInvariantWithoutOwnerCall() {
    let probe = ActivationProbe()
    var instance = ActivationFixtureInstance(
        assemblyReport: makeActivationReport(),
        owner: FixtureActivationOwner(probe: probe, failingStage: nil)
    )
    #expect(instance.activate() == .active)
    probe.calls.removeAll(keepingCapacity: true)

    #expect(instance.activate() == .failure(.invariant))
    #expect(instance.lifecycleState == .active)
    #expect(probe.calls.isEmpty)
}

@Test func repeatedActivationFromFailedReturnsInvariantWithoutOwnerCall() {
    let probe = ActivationProbe()
    var instance = ActivationFixtureInstance(
        assemblyReport: makeActivationReport(),
        owner: FixtureActivationOwner(probe: probe, failingStage: .rootAttachment)
    )
    #expect(instance.activate() == .failure(.rootAttachment))
    probe.calls.removeAll(keepingCapacity: true)

    #expect(instance.activate() == .failure(.invariant))
    #expect(instance.lifecycleState == .failed)
    #expect(probe.calls.isEmpty)
}

private func makeActivationReport() -> HostAssemblyReport {
    var validator = makeValidHostValidator()
    switch validator.validate() {
    case .valid(let report): return report
    case .invalid:
        fatalError("activation fixture requires a valid assembly report")
    }
}
