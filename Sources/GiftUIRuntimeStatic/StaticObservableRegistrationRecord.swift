import GiftUI
import GiftUIExecution
import GiftUIObservableState

package struct StaticObservableRegistrationRecord {
    private var bridge = ObservableStateRegistrationBridge()
    private var replacementBridge: ObservableStateReplacementBridge?
    private var replacementOwnsLive = false
    private var replacementSinkWasIssued = false
    private var attachment: _GiftUIObservationAttachment?
    private var phase: ExecutionPhase = .idle

    package init() {}

    package var isActive: Bool {
        replacementOwnsLive ? attachment != nil : bridge.isActive
    }

    package var isDirty: Bool {
        replacementBridge?.isDirty ?? bridge.isDirty
    }

    package mutating func beginAttachment(
        slot: UInt16 = 0,
        generation: UInt32
    ) -> ObservableStateError? {
        let candidate = _GiftUIObservationAttachment(
            slot: slot,
            generation: generation
        )
        if let failure = bridge.beginAttachment(candidate) {
            return failure
        }
        attachment = candidate
        return nil
    }

    package mutating func makeSink(
        reportRoute:
            @escaping (
                _GiftUIObservationAttachment
            ) -> _GiftUIObservableChangeReportOutcome
    ) -> _GiftUIObservableChangeSink? {
        bridge.makeSink(reportRoute: reportRoute)
    }

    package mutating func acceptAttachmentReturn(
        _ returned: _GiftUIObservationAttachment?
    ) -> ObservableStateError? {
        let failure = bridge.acceptAttachmentReturn(returned)
        if failure != nil {
            attachment = nil
        }
        return failure
    }

    package mutating func setExecutionPhase(_ phase: ExecutionPhase) {
        self.phase = phase
    }

    package mutating func acceptReport(
        _ reported: _GiftUIObservationAttachment
    ) -> _GiftUIObservableChangeReportOutcome {
        if replacementBridge != nil {
            if replacementBridge!.pendingAttachment != nil {
                return replacementBridge!.acceptCandidateReport(reported)
            }
            return replacementBridge!.acceptLiveReport(
                reported,
                executionPhase: phase
            )
        }
        return bridge.acceptReport(reported, phase: phase)
    }

    package borrowing func preflightReplacement(
        isCompatible: Bool,
        candidateAlreadyOwned: Bool,
        registrationCapacityAvailable: Bool,
        replacementStagingAvailable: Bool
    ) -> ObservableStateError? {
        guard let attachment else { return .invariantViolation }
        let replacement: ObservableStateReplacementBridge
        if let replacementBridge {
            replacement = replacementBridge
        } else {
            replacement = ObservableStateReplacementBridge(
                liveAttachment: attachment,
                isDirty: bridge.isDirty
            )
        }
        return replacement.preflightReplacement(
            executionPhase: phase,
            isCompatible: isCompatible,
            candidateAlreadyOwned: candidateAlreadyOwned,
            registrationCapacityAvailable: registrationCapacityAvailable,
            replacementStagingAvailable: replacementStagingAvailable,
            slot: attachment.slot
        )
    }

    package mutating func beginReplacement(
        generation: ObservableTargetGeneration,
        isCompatible: Bool = true,
        candidateAlreadyOwned: Bool = false,
        registrationCapacityAvailable: Bool = true,
        replacementStagingAvailable: Bool = true
    ) -> ObservableStateError? {
        guard let attachment else { return .invariantViolation }
        if replacementBridge == nil {
            replacementBridge = ObservableStateReplacementBridge(
                liveAttachment: attachment,
                isDirty: bridge.isDirty
            )
        }
        let failure = replacementBridge!.beginReplacement(
            executionPhase: phase,
            isCompatible: isCompatible,
            candidateAlreadyOwned: candidateAlreadyOwned,
            registrationCapacityAvailable: registrationCapacityAvailable,
            replacementStagingAvailable: replacementStagingAvailable,
            slot: attachment.slot,
            candidateGeneration: generation
        )
        if failure != nil, !replacementOwnsLive {
            replacementBridge = nil
        }
        if failure == nil {
            replacementSinkWasIssued = false
        }
        return failure
    }

    package mutating func makeReplacementSink(
        reportRoute:
            @escaping (
                _GiftUIObservationAttachment
            ) -> _GiftUIObservableChangeReportOutcome
    ) -> _GiftUIObservableChangeSink? {
        guard
            let candidate = replacementBridge?.pendingAttachment,
            !replacementSinkWasIssued
        else {
            return nil
        }
        replacementSinkWasIssued = true
        return _GiftUIObservableChangeSink(
            attachment: candidate,
            reportRoute: reportRoute
        )
    }

    package mutating func acceptReplacementAttachmentReturn(
        _ returned: _GiftUIObservationAttachment?
    ) -> ObservableStateError? {
        guard replacementBridge != nil, replacementSinkWasIssued else {
            return .invariantViolation
        }
        replacementSinkWasIssued = false
        return replacementBridge!.acceptAttachmentReturn(returned)
    }

    package mutating func commitReplacement()
        -> ObservableStateReplacementBridgeCommitResult
    {
        guard replacementBridge != nil else {
            return .failure(.invariantViolation)
        }
        replacementSinkWasIssued = false
        let result = replacementBridge!.commit()
        guard case .success(let commit) = result else { return result }
        if !replacementOwnsLive,
            let failure = bridge.retire(commit.formerAttachment)
        {
            return .failure(failure)
        }
        replacementOwnsLive = true
        attachment = commit.activeAttachment
        return result
    }

    package mutating func discardReplacement()
        -> _GiftUIObservationAttachment?
    {
        guard replacementBridge != nil else { return nil }
        replacementSinkWasIssued = false
        let discarded = replacementBridge!.discardCandidate()
        if !replacementOwnsLive {
            replacementBridge = nil
        }
        return discarded
    }

    package mutating func retire() -> ObservableStateError? {
        guard let attachment else { return .invariantViolation }
        let failure =
            replacementOwnsLive
            ? replacementBridge?.retireLive()
            : bridge.retire(attachment)
        if failure == nil {
            self.attachment = nil
        }
        return failure
    }

    package mutating func shutdown() -> Bool {
        if replacementOwnsLive {
            let shouldDetach = replacementBridge?.retireLive() == nil
            replacementBridge = nil
            replacementOwnsLive = false
            replacementSinkWasIssued = false
            attachment = nil
            return shouldDetach
        }
        replacementBridge = nil
        replacementSinkWasIssued = false
        attachment = nil
        return bridge.shutdown()
    }
}
