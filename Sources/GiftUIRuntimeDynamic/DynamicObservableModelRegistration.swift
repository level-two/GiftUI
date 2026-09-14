import GiftUI
import GiftUIExecution
import GiftUIObservableState

package final class DynamicObservableModelRegistration<Model>
where Model: _GiftUIObservableReference {
    private let storage = DynamicObservableModelStorage<Model>()
    private var bridge = ObservableStateRegistrationBridge()
    private var replacementBridge: ObservableStateReplacementBridge?
    private var attachment: _GiftUIObservationAttachment?
    private var phase: ExecutionPhase = .idle

    package init() {}

    package var isActive: Bool {
        bridge.isActive
    }

    package var isDirty: Bool {
        replacementBridge?.isDirty ?? bridge.isDirty
    }

    package func bind(
        _ state: inout State<Model>,
        generation: UInt32,
        replacementRoute: @escaping (Model) -> Void
    ) -> ObservableStateResult {
        if isActive {
            return storage.bind(&state, replacementRoute: replacementRoute)
        }

        let binding = storage.bind(&state, replacementRoute: replacementRoute)
        guard binding == .success(.materialized) else {
            storage.removeModel()
            return .failure(.invariantViolation)
        }

        let candidate = _GiftUIObservationAttachment(
            slot: 0,
            generation: generation
        )
        if let failure = bridge.beginAttachment(candidate) {
            storage.removeModel()
            return .failure(failure)
        }
        guard
            let sink = bridge.makeSink(reportRoute: { [weak self] reported in
                self?.acceptReport(reported) ?? .staleAttachment
            })
        else {
            storage.removeModel()
            return .failure(.invariantViolation)
        }
        let returned = storage.attachChangeSink(consume sink)
        if let failure = bridge.acceptAttachmentReturn(returned) {
            if returned != nil {
                _ = storage.detachChangeSink(candidate)
            }
            storage.removeModel()
            return .failure(failure)
        }

        attachment = candidate
        return binding
    }

    package func setExecutionPhase(_ phase: ExecutionPhase) {
        self.phase = phase
    }

    package borrowing func withModel<Result>(
        _ body: (borrowing Model) -> Result
    ) -> Result? {
        storage.withModel(body)
    }

    package func preflightReplacement(
        isCompatible: Bool,
        candidateAlreadyOwned: Bool,
        registrationCapacityAvailable: Bool,
        replacementStagingAvailable: Bool
    ) -> ObservableStateError? {
        guard let attachment else { return .invariantViolation }
        if let replacementBridge {
            return replacementBridge.preflightReplacement(
                executionPhase: phase,
                isCompatible: isCompatible,
                candidateAlreadyOwned: candidateAlreadyOwned,
                registrationCapacityAvailable: registrationCapacityAvailable,
                replacementStagingAvailable: replacementStagingAvailable,
                slot: attachment.slot
            )
        }
        let probe = ObservableStateReplacementBridge(
            liveAttachment: attachment,
            isDirty: bridge.isDirty
        )
        return probe.preflightReplacement(
            executionPhase: phase,
            isCompatible: isCompatible,
            candidateAlreadyOwned: candidateAlreadyOwned,
            registrationCapacityAvailable: registrationCapacityAvailable,
            replacementStagingAvailable: replacementStagingAvailable,
            slot: attachment.slot
        )
    }

    package func replace(
        with replacement: consuming Model,
        generation: ObservableTargetGeneration,
        isCompatible: Bool = true,
        candidateAlreadyOwned: Bool = false,
        registrationCapacityAvailable: Bool = true,
        replacementStagingAvailable: Bool = true
    ) -> ObservableStateResult {
        guard let attachment else {
            return .failure(.invariantViolation)
        }
        let usedInitialBridge = replacementBridge == nil
        if replacementBridge == nil {
            replacementBridge = ObservableStateReplacementBridge(
                liveAttachment: attachment,
                isDirty: bridge.isDirty
            )
        }
        guard replacementBridge != nil else {
            return .failure(.invariantViolation)
        }
        if let failure = replacementBridge!.beginReplacement(
            executionPhase: phase,
            isCompatible: isCompatible,
            candidateAlreadyOwned: candidateAlreadyOwned,
            registrationCapacityAvailable: registrationCapacityAvailable,
            replacementStagingAvailable: replacementStagingAvailable,
            slot: attachment.slot,
            candidateGeneration: generation
        ) {
            if usedInitialBridge {
                replacementBridge = nil
            }
            return .failure(failure)
        }
        guard storage.stageReplacement(consume replacement),
            let candidateAttachment = replacementBridge!.pendingAttachment
        else {
            _ = replacementBridge!.discardCandidate()
            storage.discardReplacement()
            if usedInitialBridge {
                replacementBridge = nil
            }
            return .failure(.invariantViolation)
        }

        let sink = _GiftUIObservableChangeSink(
            attachment: candidateAttachment,
            reportRoute: { [weak self] reported in
                self?.acceptReplacementReport(reported) ?? .staleAttachment
            }
        )
        let returned = storage.attachCandidateChangeSink(consume sink)
        if let failure = replacementBridge!.acceptAttachmentReturn(returned) {
            let discarded = replacementBridge!.discardCandidate()
            if let discarded {
                _ = storage.detachCandidateChangeSink(discarded)
            }
            storage.discardReplacement()
            if usedInitialBridge {
                replacementBridge = nil
            }
            return .failure(failure)
        }
        guard case .success(let commit) = replacementBridge!.commit() else {
            let discarded = replacementBridge!.discardCandidate()
            if let discarded {
                _ = storage.detachCandidateChangeSink(discarded)
            }
            storage.discardReplacement()
            if usedInitialBridge {
                replacementBridge = nil
            }
            return .failure(.invariantViolation)
        }
        if usedInitialBridge, let failure = bridge.retire(attachment) {
            return .failure(failure)
        }
        _ = storage.detachChangeSink(commit.formerAttachment)
        guard storage.commitReplacement() != nil else {
            return .failure(.invariantViolation)
        }
        self.attachment = commit.activeAttachment
        return .success(.replaced)
    }

    package func retire() -> ObservableStateResult {
        guard let attachment else {
            return .failure(.invariantViolation)
        }
        let retirementFailure: ObservableStateError?
        if replacementBridge != nil {
            retirementFailure = replacementBridge!.retireLive()
        } else {
            retirementFailure = bridge.retire(attachment)
        }
        if let retirementFailure {
            return .failure(retirementFailure)
        }
        _ = storage.detachChangeSink(attachment)
        storage.removeModel()
        self.attachment = nil
        return .success(.associationsCommitted)
    }

    private func acceptReport(
        _ reported: _GiftUIObservationAttachment
    ) -> _GiftUIObservableChangeReportOutcome {
        bridge.acceptReport(reported, phase: phase)
    }

    private func acceptReplacementReport(
        _ reported: _GiftUIObservationAttachment
    ) -> _GiftUIObservableChangeReportOutcome {
        guard replacementBridge != nil else { return .staleAttachment }
        if replacementBridge!.pendingAttachment != nil {
            return replacementBridge!.acceptCandidateReport(reported)
        }
        return replacementBridge!.acceptLiveReport(
            reported,
            executionPhase: phase
        )
    }
}
