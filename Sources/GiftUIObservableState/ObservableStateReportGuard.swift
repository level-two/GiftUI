import GiftUI
import GiftUIExecution

enum ObservableStateReportRouteState: UInt8, Equatable, Sendable {
    case attaching = 0
    case candidate = 1
    case live = 2
    case detaching = 3
    case retired = 4
    case shutdown = 5
}

struct ObservableStateReportGuard<Requester>: Sendable
where Requester: ExecutionWakeRequester & Sendable {
    let expectedAttachment: _GiftUIObservationAttachment
    private(set) var routeState: ObservableStateReportRouteState
    private(set) var lastPublishedRevision: SemanticRevision?
    private(set) var isDirty: Bool
    private(set) var semanticWakeOutstanding = false
    private(set) var pacedRederivationRequired = false
    private(set) var normalCycleExcluded = false
    private(set) var partialCandidatePresent: Bool
    private(set) var residualPolicyPermitted = true
    private(set) var requester: Requester

    init(
        attachment: _GiftUIObservationAttachment,
        routeState: ObservableStateReportRouteState,
        lastPublishedRevision: SemanticRevision?,
        isDirty: Bool = false,
        partialCandidatePresent: Bool = false,
        requester: Requester
    ) {
        expectedAttachment = attachment
        self.routeState = routeState
        self.lastPublishedRevision = lastPublishedRevision
        self.isDirty = isDirty
        self.partialCandidatePresent = partialCandidatePresent
        self.requester = requester
    }

    mutating func acceptReport(
        attachment: _GiftUIObservationAttachment,
        phase: ExecutionPhase,
        noModelWriteProven: Bool,
        reportAlreadyActive: Bool = false,
        semanticDispatchActive: Bool = false
    ) -> ObservableStateReportDisposition {
        guard routeState == .live, attachment == expectedAttachment else {
            return ObservableStateReportDisposition(.staleAttachment)
        }
        if reportAlreadyActive || semanticDispatchActive {
            containSafetyNotProven()
            return ObservableStateReportDisposition(.reentrancyViolation)
        }
        guard phase == .mutating else {
            if noModelWriteProven {
                containPacedRederivation()
                return ObservableStateReportDisposition(.invalidPhaseContained)
            }
            containSafetyNotProven()
            return ObservableStateReportDisposition(
                .invalidPhaseSafetyNotProven
            )
        }
        guard !isDirty else {
            return ObservableStateReportDisposition(.coalesced)
        }

        isDirty = true
        requestSemanticWakeIfNeeded()
        return ObservableStateReportDisposition(.dirtied)
    }

    private mutating func containPacedRederivation() {
        isDirty = true
        pacedRederivationRequired = true
        residualPolicyPermitted = false
        requestSemanticWakeIfNeeded()
    }

    private mutating func containSafetyNotProven() {
        partialCandidatePresent = false
        normalCycleExcluded = true
        residualPolicyPermitted = true
    }

    private mutating func requestSemanticWakeIfNeeded() {
        guard !semanticWakeOutstanding else { return }
        semanticWakeOutstanding = true
        requester.requestWake(for: .semanticDirty)
    }
}
