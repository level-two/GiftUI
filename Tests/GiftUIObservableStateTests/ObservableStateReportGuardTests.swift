import GiftUI
import GiftUIExecution
import Testing

@testable import GiftUIObservableState

private struct GuardWakeRequester: ExecutionWakeRequester, Sendable {
    private(set) var requestCount: UInt16 = 0

    mutating func requestWake(for reasons: ExecutionWakeReasons) {
        if reasons.contains(.semanticDirty) { requestCount += 1 }
    }
}

@Test
func inactiveLifecycleStatesAndReusedSlotsRejectAsStale() {
    let attachment = _GiftUIObservationAttachment(slot: 2, generation: 8)
    let inactiveStates: [ObservableStateReportRouteState] = [
        .attaching,
        .candidate,
        .detaching,
        .retired,
        .shutdown,
    ]

    for state in inactiveStates {
        var guardState = makeReportGuard(
            attachment: attachment,
            state: state,
            partialCandidatePresent: state == .candidate
        )
        #expect(
            guardState.acceptReport(
                attachment: attachment,
                phase: .mutating,
                noModelWriteProven: false
            ) == ObservableStateReportDisposition(.staleAttachment)
        )
        #expect(!guardState.isDirty)
        #expect(!guardState.semanticWakeOutstanding)
        #expect(guardState.requester.requestCount == 0)
        #expect(guardState.lastPublishedRevision == SemanticRevision(rawValue: 4))
    }

    var reused = makeReportGuard(
        attachment: _GiftUIObservationAttachment(slot: 2, generation: 9),
        state: .live
    )
    #expect(
        reused.acceptReport(
            attachment: attachment,
            phase: .mutating,
            noModelWriteProven: false
        ) == ObservableStateReportDisposition(.staleAttachment)
    )
    #expect(!reused.isDirty)
}

@Test
func containedPhaseViolationMarksDirtyAndSchedulesOnePacedWake() {
    let phases: [ExecutionPhase] = [
        .idle,
        .admitting,
        .deriving,
        .publishing,
        .offering,
        .finalizing,
    ]
    let attachment = _GiftUIObservationAttachment(slot: 3, generation: 10)

    for phase in phases {
        var guardState = makeReportGuard(
            attachment: attachment,
            state: .live,
            partialCandidatePresent: true
        )
        let first = guardState.acceptReport(
            attachment: attachment,
            phase: phase,
            noModelWriteProven: true
        )
        let second = guardState.acceptReport(
            attachment: attachment,
            phase: phase,
            noModelWriteProven: true
        )

        #expect(first == ObservableStateReportDisposition(.invalidPhaseContained))
        #expect(second == first)
        #expect(guardState.isDirty)
        #expect(guardState.semanticWakeOutstanding)
        #expect(guardState.pacedRederivationRequired)
        #expect(!guardState.normalCycleExcluded)
        #expect(guardState.partialCandidatePresent)
        #expect(!guardState.residualPolicyPermitted)
        #expect(guardState.requester.requestCount == 1)
        #expect(guardState.lastPublishedRevision == SemanticRevision(rawValue: 4))
    }
}

@Test
func safetyNotProvenPhaseViolationDiscardsPartialAndExcludesNormalCycle() {
    let attachment = _GiftUIObservationAttachment(slot: 4, generation: 11)
    var guardState = makeReportGuard(
        attachment: attachment,
        state: .live,
        partialCandidatePresent: true
    )
    let disposition = guardState.acceptReport(
        attachment: attachment,
        phase: .deriving,
        noModelWriteProven: false
    )

    #expect(
        disposition
            == ObservableStateReportDisposition(.invalidPhaseSafetyNotProven)
    )
    #expect(!guardState.partialCandidatePresent)
    #expect(guardState.normalCycleExcluded)
    #expect(!guardState.pacedRederivationRequired)
    #expect(!guardState.isDirty)
    #expect(!guardState.semanticWakeOutstanding)
    #expect(guardState.requester.requestCount == 0)
    #expect(guardState.residualPolicyPermitted)
    #expect(guardState.lastPublishedRevision == SemanticRevision(rawValue: 4))
}

@Test
func activeReportAndSemanticDispatchUseReentrancyContainment() {
    let attachment = _GiftUIObservationAttachment(slot: 5, generation: 12)

    for flags in [(true, false), (false, true), (true, true)] {
        var guardState = makeReportGuard(
            attachment: attachment,
            state: .live,
            isDirty: true,
            partialCandidatePresent: true
        )
        let disposition = guardState.acceptReport(
            attachment: attachment,
            phase: .mutating,
            noModelWriteProven: false,
            reportAlreadyActive: flags.0,
            semanticDispatchActive: flags.1
        )

        #expect(disposition == ObservableStateReportDisposition(.reentrancyViolation))
        #expect(!guardState.partialCandidatePresent)
        #expect(guardState.normalCycleExcluded)
        #expect(guardState.isDirty)
        #expect(!guardState.semanticWakeOutstanding)
        #expect(guardState.requester.requestCount == 0)
        #expect(guardState.residualPolicyPermitted)
        #expect(guardState.lastPublishedRevision == SemanticRevision(rawValue: 4))
    }
}

@Test
func validMutatingReportStillDirtiesThenCoalesces() {
    let attachment = _GiftUIObservationAttachment(slot: 6, generation: 13)
    var guardState = makeReportGuard(
        attachment: attachment,
        state: .live
    )
    #expect(
        guardState.acceptReport(
            attachment: attachment,
            phase: .mutating,
            noModelWriteProven: false
        ) == ObservableStateReportDisposition(.dirtied)
    )
    #expect(
        guardState.acceptReport(
            attachment: attachment,
            phase: .mutating,
            noModelWriteProven: false
        ) == ObservableStateReportDisposition(.coalesced)
    )
    #expect(guardState.requester.requestCount == 1)
}

private func makeReportGuard(
    attachment: _GiftUIObservationAttachment,
    state: ObservableStateReportRouteState,
    isDirty: Bool = false,
    partialCandidatePresent: Bool = false
) -> ObservableStateReportGuard<GuardWakeRequester> {
    ObservableStateReportGuard(
        attachment: attachment,
        routeState: state,
        lastPublishedRevision: SemanticRevision(rawValue: 4),
        isDirty: isDirty,
        partialCandidatePresent: partialCandidatePresent,
        requester: GuardWakeRequester()
    )
}
