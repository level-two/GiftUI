import GiftUI
import GiftUIExecution
import GiftUIObservableState
import GiftUIRuntimeCore

package final class DynamicObservableRootAdapter<Model, Identity>
where Model: _GiftUIObservableReference, Identity: Equatable & Sendable {
    private var workspace:
        RuntimeObservableProfileWorkspace<
            DynamicObservableProfileSlotStorage<Identity>
        >
    private let registration = DynamicObservableModelRegistration<Model>()
    private var registeredIdentity: Identity?
    private var registeredOrdinal: UInt16 = 0
    private var candidateIntroducedRegistration = false

    package init(capacity: UInt16, firstGeneration: UInt32? = 0) {
        workspace = RuntimeObservableProfileWorkspace(
            storage: DynamicObservableProfileSlotStorage(capacity: capacity),
            firstGeneration: firstGeneration
        )
    }

    package var isActive: Bool {
        registration.isActive
    }

    package var isDirty: Bool {
        registration.isDirty
    }

    package func beginCandidate() -> ObservableStateResult {
        let result = workspace.beginCandidate()
        if result == .success(.candidateStarted) {
            candidateIntroducedRegistration = false
        }
        return result
    }

    package func encounter(
        structuralIdentity: Identity,
        declarationOrdinal: UInt16,
        state: inout State<Model>,
        replacementRoute: @escaping (Model) -> Void
    ) -> ObservableStateResult {
        let encounter = workspace.encounter(
            structuralIdentity: structuralIdentity,
            declarationOrdinal: declarationOrdinal,
            state: &state
        )
        switch encounter {
        case .failure:
            return encounter
        case .success(.materialized):
            guard
                !registration.isActive,
                let generation = workspace.publishableTargetGeneration(
                    structuralIdentity: structuralIdentity,
                    declarationOrdinal: declarationOrdinal
                )
            else {
                return .failure(.invariantViolation)
            }
            let binding = registration.bind(
                &state,
                generation: generation.rawValue,
                replacementRoute: replacementRoute
            )
            guard binding == .success(.materialized) else { return binding }
            registeredIdentity = structuralIdentity
            registeredOrdinal = declarationOrdinal
            candidateIntroducedRegistration = true
            return binding
        case .success(.preserved):
            guard
                registration.isActive,
                registeredIdentity == structuralIdentity,
                registeredOrdinal == declarationOrdinal,
                let generation = workspace.publishableTargetGeneration(
                    structuralIdentity: structuralIdentity,
                    declarationOrdinal: declarationOrdinal
                )
            else {
                return .failure(.invariantViolation)
            }
            return registration.bind(
                &state,
                generation: generation.rawValue,
                replacementRoute: replacementRoute
            )
        case .success:
            return .failure(.invariantViolation)
        }
    }

    package func finishCandidate(
        _ disposition: ObservableStateCandidateDisposition
    ) -> ObservableStateResult {
        let result = workspace.finishCandidate(disposition)
        guard case .success = result else { return result }

        let shouldRetire: Bool
        switch disposition {
        case .discard:
            shouldRetire = candidateIntroducedRegistration
        case .publish:
            if let registeredIdentity {
                shouldRetire =
                    workspace.targetGeneration(
                        structuralIdentity: registeredIdentity,
                        declarationOrdinal: registeredOrdinal
                    ) == nil
            } else {
                shouldRetire = false
            }
        }
        candidateIntroducedRegistration = false
        guard shouldRetire else {
            if case .publish = disposition {
                registration.clearDirtyAfterPublication()
            }
            return result
        }
        guard case .success = registration.retire() else {
            return .failure(.invariantViolation)
        }
        registeredIdentity = nil
        registeredOrdinal = 0
        return result
    }

    package func setExecutionPhase(_ phase: ExecutionPhase) {
        registration.setExecutionPhase(phase)
    }

    package func replace(
        with replacement: consuming Model,
        isCompatible: Bool = true,
        candidateAlreadyOwned: Bool = false,
        registrationCapacityAvailable: Bool = true,
        replacementStagingAvailable: Bool = true
    ) -> ObservableStateResult {
        guard let registeredIdentity else {
            return .failure(.invariantViolation)
        }
        if let failure = registration.preflightReplacement(
            isCompatible: isCompatible,
            candidateAlreadyOwned: candidateAlreadyOwned,
            registrationCapacityAvailable: registrationCapacityAvailable,
            replacementStagingAvailable: replacementStagingAvailable
        ) {
            return .failure(failure)
        }
        let reservation = workspace.beginReplacement(
            structuralIdentity: registeredIdentity,
            declarationOrdinal: registeredOrdinal
        )
        guard case .success(let generation) = reservation else {
            guard case .failure(let failure) = reservation else {
                return .failure(.invariantViolation)
            }
            return .failure(failure)
        }
        let replacementResult = registration.replace(
            with: consume replacement,
            generation: generation,
            isCompatible: isCompatible,
            candidateAlreadyOwned: candidateAlreadyOwned,
            registrationCapacityAvailable: registrationCapacityAvailable,
            replacementStagingAvailable: replacementStagingAvailable
        )
        switch replacementResult {
        case .success(.replaced):
            let finish = workspace.finishReplacement(commit: true)
            return finish == .success(.replaced)
                ? replacementResult
                : .failure(.invariantViolation)
        case .failure:
            let finish = workspace.finishReplacement(commit: false)
            return finish == .success(.candidateDiscarded)
                ? replacementResult
                : .failure(.invariantViolation)
        case .success:
            _ = workspace.finishReplacement(commit: false)
            return .failure(.invariantViolation)
        }
    }

    package borrowing func targetGeneration(
        structuralIdentity: Identity,
        declarationOrdinal: UInt16
    ) -> ObservableTargetGeneration? {
        workspace.targetGeneration(
            structuralIdentity: structuralIdentity,
            declarationOrdinal: declarationOrdinal
        )
    }

    package borrowing func currentTargetGeneration()
        -> ObservableTargetGeneration?
    {
        guard let registeredIdentity else { return nil }
        return workspace.targetGeneration(
            structuralIdentity: registeredIdentity,
            declarationOrdinal: registeredOrdinal
        )
    }

    package borrowing func withModel<Result>(
        _ body: (borrowing Model) -> Result
    ) -> Result? {
        registration.withModel(body)
    }

    package func withModel(
        matching generation: ObservableTargetGeneration,
        _ body: (borrowing Model) -> Void
    ) -> Bool {
        guard currentTargetGeneration() == generation else { return false }
        guard registration.withModel(body) != nil else { return false }
        return true
    }
}
