package struct HostActivationProgress: Equatable, Sendable {
    package let runtimeConstructed: Bool
    package let observationInstalled: Bool
    package let sourceStarted: Bool

    package init(
        runtimeConstructed: Bool = false,
        observationInstalled: Bool = false,
        sourceStarted: Bool = false
    ) {
        self.runtimeConstructed = runtimeConstructed
        self.observationInstalled = observationInstalled
        self.sourceStarted = sourceStarted
    }

    func merging(_ other: Self) -> Self {
        Self(
            runtimeConstructed: runtimeConstructed || other.runtimeConstructed,
            observationInstalled: observationInstalled || other.observationInstalled,
            sourceStarted: sourceStarted || other.sourceStarted
        )
    }
}

package enum HostActivationStepResult<Failure: Equatable & Sendable>:
    Equatable, Sendable
{
    case advanced
    case failure(Failure, progress: HostActivationProgress)
}

package protocol MVPHostActivationOwner: ~Copyable {
    associatedtype ActivationFailure: Equatable & Sendable

    mutating func constructRuntimeAndEndpoint()
        -> HostActivationStepResult<ActivationFailure>
    mutating func constructApplicationOwners()
        -> HostActivationStepResult<ActivationFailure>
    mutating func attachRootModelInFirstCandidate()
        -> HostActivationStepResult<ActivationFailure>
    mutating func installRepositoryObservationAndAdmitCurrentValues()
        -> HostActivationStepResult<ActivationFailure>
    mutating func acceptFirstPresentationAndEnableInput()
        -> HostActivationStepResult<ActivationFailure>
    mutating func startAcquisitionThroughApplicationOpportunity()
        -> HostActivationStepResult<ActivationFailure>
    mutating func establishWakeAndPacingHostLoop()
        -> HostActivationStepResult<ActivationFailure>

    mutating func stopSourceDeliveryAndRepositoryObservation()
    mutating func preventInputEligibility()
    mutating func quiesceConstructedRuntime()
}

package protocol MVPHostTeardownOwner: ~Copyable {
    mutating func refuseApplicationDeliveryAndInput()
    mutating func stopSourceDeliveryAndDetachObservations()
    mutating func cancelPointerSequencesAndHostCallbacks()
    mutating func quiesceRuntimeAndFinalizeActiveCycle()
    mutating func retireObservableRegistrationAndRouting()
    mutating func releasePlatformOwners()
    mutating func resetProfileStorage()
    mutating func invalidateAssemblyReportRuntimeUse()
}

package struct MVPHostActivationController<Failure: Equatable & Sendable> {
    package private(set) var lifecycleState: MVPHostLifecycleState = .valid
    package private(set) var progress = HostActivationProgress()
    package private(set) var assemblyReportRuntimeUseIsValid = true

    package init() {}

    package mutating func activate<Owner: MVPHostActivationOwner>(
        owner: inout Owner,
        invariantFailure: Failure
    ) -> HostActivationResult<Failure>
    where Owner.ActivationFailure == Failure {
        guard lifecycleState == .valid else {
            return .failure(invariantFailure)
        }
        lifecycleState = .activating

        if let failure = record(
            owner.constructRuntimeAndEndpoint(),
            successfulProgress: HostActivationProgress(runtimeConstructed: true)
        ) {
            return contain(failure, owner: &owner)
        }
        if let failure = record(owner.constructApplicationOwners()) {
            return contain(failure, owner: &owner)
        }
        if let failure = record(owner.attachRootModelInFirstCandidate()) {
            return contain(failure, owner: &owner)
        }
        if let failure = record(
            owner.installRepositoryObservationAndAdmitCurrentValues(),
            successfulProgress: HostActivationProgress(observationInstalled: true)
        ) {
            return contain(failure, owner: &owner)
        }
        if let failure = record(owner.acceptFirstPresentationAndEnableInput()) {
            return contain(failure, owner: &owner)
        }
        if let failure = record(
            owner.startAcquisitionThroughApplicationOpportunity(),
            successfulProgress: HostActivationProgress(sourceStarted: true)
        ) {
            return contain(failure, owner: &owner)
        }
        if let failure = record(owner.establishWakeAndPacingHostLoop()) {
            return contain(failure, owner: &owner)
        }

        lifecycleState = .active
        return .active
    }

    package mutating func teardown<Owner: MVPHostTeardownOwner>(owner: inout Owner) {
        guard lifecycleState != .quiescing, lifecycleState != .quiescent else {
            return
        }
        lifecycleState = .quiescing

        owner.refuseApplicationDeliveryAndInput()
        owner.stopSourceDeliveryAndDetachObservations()
        owner.cancelPointerSequencesAndHostCallbacks()
        owner.quiesceRuntimeAndFinalizeActiveCycle()
        owner.retireObservableRegistrationAndRouting()
        owner.releasePlatformOwners()
        owner.resetProfileStorage()
        owner.invalidateAssemblyReportRuntimeUse()

        progress = HostActivationProgress()
        assemblyReportRuntimeUseIsValid = false
        lifecycleState = .quiescent
    }

    private mutating func record(
        _ result: HostActivationStepResult<Failure>,
        successfulProgress: HostActivationProgress = HostActivationProgress()
    ) -> Failure? {
        switch result {
        case .advanced:
            progress = progress.merging(successfulProgress)
            return nil
        case .failure(let failure, let partialProgress):
            progress = progress.merging(partialProgress)
            return failure
        }
    }

    private mutating func contain<Owner: MVPHostActivationOwner>(
        _ failure: Failure,
        owner: inout Owner
    ) -> HostActivationResult<Failure>
    where Owner.ActivationFailure == Failure {
        if progress.sourceStarted || progress.observationInstalled {
            owner.stopSourceDeliveryAndRepositoryObservation()
        }
        owner.preventInputEligibility()
        if progress.runtimeConstructed {
            owner.quiesceConstructedRuntime()
        }
        lifecycleState = .failed
        return .failure(failure)
    }
}
