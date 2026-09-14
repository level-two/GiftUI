import GiftUI
import GiftUIExecution
import GiftUIObservableState
import GiftUIRuntimeCore

package enum StaticObservableRootBindingOutcome<Result> {
    case bound(ObservableStateResult, Result)
    case failure(ObservableStateError)
}

package struct StaticObservableRootAdapter<Model, Identity>: ~Copyable
where Model: _GiftUIObservableReference, Identity: Equatable & Sendable {
    private var workspace:
        RuntimeObservableProfileWorkspace<
            StaticObservableProfileSlotStorage<Identity>
        >
    private var storage = StaticObservableModelStorage<Model>()
    private var registration = StaticObservableRegistrationRecord()
    private let structuralIdentity: Identity
    private let declarationOrdinal: UInt16
    private var candidateIntroducedRegistration = false

    package init(
        structuralIdentity: Identity,
        declarationOrdinal: UInt16,
        firstGeneration: UInt32? = 0
    ) {
        self.structuralIdentity = structuralIdentity
        self.declarationOrdinal = declarationOrdinal
        workspace = RuntimeObservableProfileWorkspace(
            storage: StaticObservableProfileSlotStorage(),
            firstGeneration: firstGeneration
        )
    }

    package var isActive: Bool {
        registration.isActive
    }

    package var isDirty: Bool {
        registration.isDirty
    }

    package mutating func beginCandidate() -> ObservableStateResult {
        let result = workspace.beginCandidate()
        if result == .success(.candidateStarted) {
            candidateIntroducedRegistration = false
        }
        return result
    }

    package mutating func withEncounter<Result>(
        state: State<Model>,
        replacementRoute: @escaping (Model) -> Void,
        reportRoute:
            @escaping (
                _GiftUIObservationAttachment
            ) -> _GiftUIObservableChangeReportOutcome,
        body: (borrowing State<Model>) -> Result
    ) -> StaticObservableRootBindingOutcome<Result> {
        var transientState = state
        let encounter = workspace.encounter(
            structuralIdentity: structuralIdentity,
            declarationOrdinal: declarationOrdinal,
            state: &transientState
        )
        switch encounter {
        case .failure(let failure):
            return .failure(failure)
        case .success(.materialized):
            guard
                !registration.isActive,
                let generation = workspace.publishableTargetGeneration(
                    structuralIdentity: structuralIdentity,
                    declarationOrdinal: declarationOrdinal
                ),
                registration.beginAttachment(
                    generation: generation.rawValue
                ) == nil
            else {
                return .failure(.invariantViolation)
            }
            let binding = storage.withMaterializedBoundState(
                transientState,
                replacementRoute: replacementRoute,
                makeSink: {
                    registration.makeSink(reportRoute: reportRoute)
                },
                acceptAttachment: {
                    registration.acceptAttachmentReturn($0)
                },
                body: body
            )
            switch binding {
            case .bound(.materialized, let result):
                candidateIntroducedRegistration = true
                return .bound(encounter, result)
            case .failure(let failure):
                return .failure(failure)
            case .bound:
                return .failure(.invariantViolation)
            }
        case .success(.preserved):
            guard
                registration.isActive,
                workspace.publishableTargetGeneration(
                    structuralIdentity: structuralIdentity,
                    declarationOrdinal: declarationOrdinal
                ) != nil
            else {
                return .failure(.invariantViolation)
            }
            let binding = storage.withBoundState(
                transientState,
                replacementRoute: replacementRoute,
                body: body
            )
            switch binding {
            case .bound(.preserved, let result):
                return .bound(encounter, result)
            case .failure(let failure):
                return .failure(failure)
            case .bound:
                return .failure(.invariantViolation)
            }
        case .success:
            return .failure(.invariantViolation)
        }
    }

    package mutating func finishCandidate(
        _ disposition: ObservableStateCandidateDisposition
    ) -> ObservableStateResult {
        let result = workspace.finishCandidate(disposition)
        guard case .success = result else { return result }

        let shouldRetire: Bool
        switch disposition {
        case .discard:
            shouldRetire = candidateIntroducedRegistration
        case .publish:
            shouldRetire =
                workspace.targetGeneration(
                    structuralIdentity: structuralIdentity,
                    declarationOrdinal: declarationOrdinal
                ) == nil && registration.isActive
        }
        candidateIntroducedRegistration = false
        guard shouldRetire else { return result }
        guard let attachment = registration.liveAttachment,
            registration.retire() == nil,
            storage.detachChangeSink(attachment),
            storage.removeModel() != nil
        else {
            return .failure(.invariantViolation)
        }
        return result
    }

    package mutating func setExecutionPhase(_ phase: ExecutionPhase) {
        registration.setExecutionPhase(phase)
    }

    package mutating func acceptReport(
        _ attachment: _GiftUIObservationAttachment
    ) -> _GiftUIObservableChangeReportOutcome {
        registration.acceptReport(attachment)
    }

    package mutating func replace(
        with replacement: consuming Model,
        reportRoute:
            @escaping (
                _GiftUIObservationAttachment
            ) -> _GiftUIObservableChangeReportOutcome,
        isCompatible: Bool = true,
        candidateAlreadyOwned: Bool = false,
        registrationCapacityAvailable: Bool = true,
        replacementStagingAvailable: Bool = true
    ) -> ObservableStateResult {
        if let failure = registration.preflightReplacement(
            isCompatible: isCompatible,
            candidateAlreadyOwned: candidateAlreadyOwned,
            registrationCapacityAvailable: registrationCapacityAvailable,
            replacementStagingAvailable: replacementStagingAvailable
        ) {
            return .failure(failure)
        }
        let reservation = workspace.beginReplacement(
            structuralIdentity: structuralIdentity,
            declarationOrdinal: declarationOrdinal
        )
        guard case .success(let generation) = reservation else {
            guard case .failure(let failure) = reservation else {
                return .failure(.invariantViolation)
            }
            return .failure(failure)
        }
        guard
            registration.beginReplacement(
                generation: generation,
                isCompatible: isCompatible,
                candidateAlreadyOwned: candidateAlreadyOwned,
                registrationCapacityAvailable: registrationCapacityAvailable,
                replacementStagingAvailable: replacementStagingAvailable
            ) == nil,
            storage.stageReplacement(consume replacement),
            let sink = registration.makeReplacementSink(
                reportRoute: reportRoute
            )
        else {
            _ = registration.discardReplacement()
            storage.discardReplacement()
            _ = workspace.finishReplacement(commit: false)
            return .failure(.invariantViolation)
        }

        let returned = storage.attachCandidateChangeSink(consume sink)
        if let failure = registration.acceptReplacementAttachmentReturn(
            returned
        ) {
            let discarded = registration.discardReplacement()
            if let discarded {
                _ = storage.detachCandidateChangeSink(discarded)
            }
            storage.discardReplacement()
            _ = workspace.finishReplacement(commit: false)
            return .failure(failure)
        }
        guard case .success(let commit) = registration.commitReplacement(),
            storage.detachChangeSink(commit.formerAttachment),
            storage.commitReplacement() != nil,
            workspace.finishReplacement(commit: true) == .success(.replaced)
        else {
            return .failure(.invariantViolation)
        }
        return .success(.replaced)
    }

    package borrowing func targetGeneration() -> ObservableTargetGeneration? {
        workspace.targetGeneration(
            structuralIdentity: structuralIdentity,
            declarationOrdinal: declarationOrdinal
        )
    }

    package borrowing func liveAttachment() -> _GiftUIObservationAttachment? {
        registration.liveAttachment
    }

    package borrowing func withModel<Result>(
        _ body: (borrowing Model) -> Result
    ) -> Result? {
        storage.withModel(body)
    }

    package mutating func withModel(
        matching generation: ObservableTargetGeneration,
        _ body: (borrowing Model) -> Void
    ) -> Bool {
        guard targetGeneration() == generation else { return false }
        guard storage.withModel(body) != nil else { return false }
        return true
    }
}
