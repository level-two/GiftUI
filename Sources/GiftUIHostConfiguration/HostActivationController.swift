@usableFromInline
package struct HostActivationProgress: Equatable, Sendable {
    @usableFromInline
    package let runtimeConstructed: Bool
    @usableFromInline
    package let observationInstalled: Bool
    @usableFromInline
    package let sourceStarted: Bool

    @inlinable
    package init(
        runtimeConstructed: Bool = false,
        observationInstalled: Bool = false,
        sourceStarted: Bool = false
    ) {
        self.runtimeConstructed = runtimeConstructed
        self.observationInstalled = observationInstalled
        self.sourceStarted = sourceStarted
    }

    @inlinable
    func merging(_ other: Self) -> Self {
        Self(
            runtimeConstructed: runtimeConstructed || other.runtimeConstructed,
            observationInstalled: observationInstalled || other.observationInstalled,
            sourceStarted: sourceStarted || other.sourceStarted
        )
    }
}

@usableFromInline
package enum HostActivationStepResult<Failure: Equatable & Sendable>:
    Equatable, Sendable
{
    case advanced
    case failure(Failure, progress: HostActivationProgress)
}

@usableFromInline
package protocol MVPHostActivationOwner: ~Copyable, ~Escapable {
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

@usableFromInline
package protocol MVPHostTeardownOwner: ~Copyable, ~Escapable {
    mutating func refuseApplicationDeliveryAndInput()
    mutating func stopSourceDeliveryAndDetachObservations()
    mutating func cancelPointerSequencesAndHostCallbacks()
    mutating func quiesceRuntimeAndFinalizeActiveCycle()
    mutating func retireObservableRegistrationAndRouting()
    mutating func releasePlatformOwners()
    mutating func resetProfileStorage()
    mutating func invalidateAssemblyReportRuntimeUse()
}

@usableFromInline
package struct MVPHostActivationController<Failure: Equatable & Sendable> {
    @usableFromInline
    package internal(set) var lifecycleState: MVPHostLifecycleState = .valid
    @usableFromInline
    package internal(set) var progress = HostActivationProgress()
    @usableFromInline
    package internal(set) var assemblyReportRuntimeUseIsValid = true

    @usableFromInline
    package init() {}

    @usableFromInline
    package init(lifecycleState: MVPHostLifecycleState) {
        self.lifecycleState = lifecycleState
    }

    @inline(__always)
    @inlinable
    package mutating func activate<Owner: MVPHostActivationOwner & ~Copyable & ~Escapable>(
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

    @inline(__always)
    @inlinable
    package mutating func teardown<Owner: MVPHostTeardownOwner & ~Copyable & ~Escapable>(
        owner: inout Owner
    ) {
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

    @inlinable
    internal mutating func record(
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

    @inline(__always)
    @inlinable
    internal mutating func contain<Owner: MVPHostActivationOwner & ~Copyable & ~Escapable>(
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
