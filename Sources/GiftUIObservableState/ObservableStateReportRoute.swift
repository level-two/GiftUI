import GiftUI
import GiftUIExecution

struct ObservableStateReportDisposition: Equatable, Sendable {
    let sinkOutcome: _GiftUIObservableChangeReportOutcome
    let ownerResult: ObservableStateResult

    init(_ sinkOutcome: _GiftUIObservableChangeReportOutcome) {
        self.sinkOutcome = sinkOutcome
        ownerResult =
            switch sinkOutcome {
            case .dirtied:
                .success(.dirtied)
            case .coalesced:
                .success(.coalesced)
            case .staleAttachment:
                .failure(.staleAttachment)
            case .invalidPhaseContained:
                .failure(.invalidPhaseContained)
            case .invalidPhaseSafetyNotProven:
                .failure(.invalidPhaseSafetyNotProven)
            case .reentrancyViolation:
                .failure(.reentrancyViolation)
            case .invariantViolation:
                .failure(.invariantViolation)
            }
    }
}

struct ObservableStateReportRoute<Requester>: Sendable
where Requester: ExecutionWakeRequester & Sendable {
    private var registration = ObservableStateRegistrationLifecycle()
    private(set) var isDirty = false
    private(set) var semanticWakeOutstanding = false
    private(set) var requester: Requester

    init?(
        attachment: _GiftUIObservationAttachment,
        requester: Requester
    ) {
        self.requester = requester
        guard registration.beginAttachment(attachment) == nil else {
            return nil
        }
    }

    var isActive: Bool {
        registration.isActive
    }

    mutating func verifyAttachment(
        _ returned: _GiftUIObservationAttachment?
    ) -> ObservableStateError? {
        registration.acceptAttachmentReturn(returned)
    }

    mutating func acceptReport(
        attachment: _GiftUIObservationAttachment,
        phase: ExecutionPhase
    ) -> ObservableStateReportDisposition {
        guard registration.acceptReport(attachment) == nil else {
            return ObservableStateReportDisposition(.staleAttachment)
        }
        guard phase == .mutating else {
            return ObservableStateReportDisposition(
                .invalidPhaseSafetyNotProven
            )
        }
        guard !isDirty else {
            return ObservableStateReportDisposition(.coalesced)
        }

        isDirty = true
        if !semanticWakeOutstanding {
            semanticWakeOutstanding = true
            requester.requestWake(for: .semanticDirty)
        }
        return ObservableStateReportDisposition(.dirtied)
    }
}

enum ObservableStateMutationReporting {
    static func reportIfChanged(
        _ changed: Bool,
        through sink: inout _GiftUIObservableChangeSink
    ) -> _GiftUIObservableChangeReportOutcome? {
        guard changed else { return nil }
        return sink.reportChange()
    }
}
