import GiftUI
import Testing

@testable import GiftUIExecution

private let matrixLimits = ExecutionLimits(
    maximumInputEvents: 2,
    maximumStateChangeFacts: 2,
    maximumCompletionFacts: 1,
    maximumSemanticActions: 2,
    maximumActiveInputSources: 1,
    maximumCommittedActions: 2
)!

private func expectedAdmissionValidity(
    inputEvents: UInt16,
    stateChanges: UInt16,
    completions: UInt16,
    semanticActions: UInt16
) -> Bool {
    inputEvents <= matrixLimits.maximumInputEvents
        && stateChanges <= matrixLimits.maximumStateChangeFacts
        && completions <= matrixLimits.maximumCompletionFacts
        && semanticActions <= matrixLimits.maximumSemanticActions
        && semanticActions <= inputEvents
}

private func expectedSummaryValidity(
    semanticRevision: SemanticRevision?,
    semanticDisposition: SemanticCycleDisposition,
    logicalFrameDisposition: LogicalFrameDisposition,
    committedPresentationRevision: PresentationRevision?,
    presentationIntentState: PresentationIntentState,
    presentationPending: PresentationPendingIntent?,
    operationalEvents: ExecutionOperationalEvents
) -> Bool {
    guard (presentationIntentState == .pending) == (presentationPending != nil),
        presentationPending?.semanticRevision == semanticRevision || presentationPending == nil,
        semanticDisposition != .published || semanticRevision != nil,
        logicalFrameDisposition != .committed || committedPresentationRevision != nil,
        logicalFrameDisposition != .committed || presentationIntentState == .satisfied,
        !operationalEvents.contains([.backpressured, .retryableRefusal])
    else { return false }

    if operationalEvents.contains(.noChange) {
        guard
            operationalEvents.intersection([.backpressured, .retryableRefusal, .superseded])
                .isEmpty,
            semanticDisposition == .unchanged,
            logicalFrameDisposition == .notProduced,
            presentationIntentState == .satisfied
        else { return false }
    }
    if operationalEvents.contains(.backpressured) {
        guard logicalFrameDisposition == .aborted,
            presentationIntentState == .pending
        else { return false }
    }
    if operationalEvents.contains(.retryableRefusal) {
        guard logicalFrameDisposition == .aborted,
            presentationIntentState != .satisfied
        else { return false }
    }
    if operationalEvents.contains(.superseded) {
        guard semanticDisposition == .published else { return false }
    }
    return true
}

private enum MatrixTerminalCondition: CaseIterable {
    case noChange
    case prePublicationCleanFailure
    case prePublicationDirtyFailure
    case accepted
    case backpressured
    case retryablePending
    case retryableExhausted
    case nonRetryableRefusal
    case postPublicationFailure
    case candidateIdentityFailure
    case presentationIdentityFailure
    case facilityLostBeforeCandidate
    case facilityLostAfterCandidate
}

private struct MatrixHistory {
    let terminal: MatrixTerminalCondition
    let entrySemanticRevision: SemanticRevision?
    let entryPresentationRevision: PresentationRevision?
    let entryIntentState: PresentationIntentState
    let reservedSemanticRevision: SemanticRevision?
    let reservedCandidate: CandidateFrameID?
    let reservedPresentationRevision: PresentationRevision?
    let summary: RunCycleSummary
}

private func matrixAccepts(_ history: MatrixHistory) -> Bool {
    let latestSemantic = history.reservedSemanticRevision ?? history.entrySemanticRevision
    guard history.summary.semanticRevision == latestSemantic else { return false }

    let derivedDisposition: SemanticCycleDisposition =
        history.reservedSemanticRevision == nil ? .unchanged : .published
    let keepsPriorPresentation =
        history.summary.committedPresentationRevision == history.entryPresentationRevision

    switch history.terminal {
    case .noChange:
        return history.reservedSemanticRevision == nil
            && history.reservedCandidate == nil
            && history.reservedPresentationRevision == nil
            && history.summary.semanticDisposition == .unchanged
            && history.summary.logicalFrameDisposition == .notProduced
            && keepsPriorPresentation
            && history.summary.presentationIntentState == .satisfied
            && history.summary.operationalEvents == .noChange
    case .prePublicationCleanFailure:
        return history.reservedSemanticRevision == nil
            && history.reservedCandidate == nil
            && history.reservedPresentationRevision == nil
            && history.summary.semanticDisposition == .unchanged
            && history.summary.logicalFrameDisposition == .notProduced
            && keepsPriorPresentation
            && history.summary.presentationIntentState == history.entryIntentState
    case .prePublicationDirtyFailure:
        return history.reservedSemanticRevision == nil
            && history.reservedCandidate == nil
            && history.reservedPresentationRevision == nil
            && history.summary.semanticDisposition == .dirty
            && history.summary.logicalFrameDisposition == .notProduced
            && keepsPriorPresentation
            && history.summary.presentationIntentState == history.entryIntentState
    case .accepted:
        return history.reservedCandidate != nil
            && history.reservedPresentationRevision != nil
            && history.summary.semanticDisposition == derivedDisposition
            && history.summary.logicalFrameDisposition == .committed
            && history.summary.committedPresentationRevision
                == history.reservedPresentationRevision
            && history.summary.presentationIntentState == .satisfied
    case .backpressured:
        return history.reservedCandidate != nil
            && history.reservedPresentationRevision != nil
            && history.summary.semanticDisposition == derivedDisposition
            && history.summary.logicalFrameDisposition == .aborted
            && keepsPriorPresentation
            && history.summary.presentationIntentState == .pending
            && history.summary.operationalEvents.contains(.backpressured)
    case .retryablePending:
        return history.reservedCandidate != nil
            && history.reservedPresentationRevision != nil
            && history.summary.semanticDisposition == derivedDisposition
            && history.summary.logicalFrameDisposition == .aborted
            && keepsPriorPresentation
            && history.summary.presentationIntentState == .pending
            && history.summary.operationalEvents.contains(.retryableRefusal)
    case .retryableExhausted:
        return history.reservedCandidate != nil
            && history.reservedPresentationRevision != nil
            && history.summary.semanticDisposition == derivedDisposition
            && history.summary.logicalFrameDisposition == .aborted
            && keepsPriorPresentation
            && history.summary.presentationIntentState == .unavailable
            && history.summary.operationalEvents.contains(.retryableRefusal)
    case .nonRetryableRefusal:
        return history.reservedCandidate != nil
            && history.reservedPresentationRevision != nil
            && history.summary.semanticDisposition == derivedDisposition
            && history.summary.logicalFrameDisposition == .aborted
            && keepsPriorPresentation
            && history.summary.presentationIntentState == .unavailable
    case .postPublicationFailure:
        return history.reservedCandidate != nil
            && history.reservedPresentationRevision != nil
            && history.summary.semanticDisposition == derivedDisposition
            && history.summary.logicalFrameDisposition == .aborted
            && keepsPriorPresentation
            && history.summary.presentationIntentState != .pending
    case .candidateIdentityFailure:
        return history.reservedCandidate == nil
            && history.reservedPresentationRevision == nil
            && history.summary.semanticDisposition == derivedDisposition
            && history.summary.logicalFrameDisposition == .notProduced
            && keepsPriorPresentation
            && history.summary.presentationIntentState != .pending
    case .presentationIdentityFailure:
        return history.reservedCandidate != nil
            && history.reservedPresentationRevision == nil
            && history.summary.semanticDisposition == derivedDisposition
            && history.summary.logicalFrameDisposition == .aborted
            && keepsPriorPresentation
            && history.summary.presentationIntentState != .pending
    case .facilityLostBeforeCandidate:
        return history.reservedCandidate == nil
            && history.reservedPresentationRevision == nil
            && history.summary.semanticDisposition == derivedDisposition
            && history.summary.logicalFrameDisposition == .notProduced
            && keepsPriorPresentation
            && history.summary.presentationIntentState == .unavailable
    case .facilityLostAfterCandidate:
        return history.reservedCandidate != nil
            && history.reservedPresentationRevision == nil
            && history.summary.semanticDisposition == derivedDisposition
            && history.summary.logicalFrameDisposition == .aborted
            && keepsPriorPresentation
            && history.summary.presentationIntentState == .unavailable
    }
}

private func summary(
    semanticRevision: SemanticRevision?,
    semanticDisposition: SemanticCycleDisposition,
    logicalFrameDisposition: LogicalFrameDisposition,
    committedPresentationRevision: PresentationRevision?,
    presentationIntentState: PresentationIntentState,
    retryCount: UInt8 = 0,
    operationalEvents: ExecutionOperationalEvents = []
) -> RunCycleSummary {
    let pending =
        presentationIntentState == .pending
        ? PresentationPendingIntent(
            semanticRevision: semanticRevision!,
            retryableRefusalCount: retryCount
        )
        : nil
    return RunCycleSummary(
        cycle: RunCycleID(rawValue: 1),
        admission: AdmissionSummary(
            inputEventCount: 0,
            stateChangeFactCount: 0,
            completionFactCount: 0,
            semanticActionCount: 0,
            includesDirtyRederivation: false,
            includesPresentationRecovery: false,
            limits: matrixLimits
        )!,
        semanticRevision: semanticRevision,
        semanticDisposition: semanticDisposition,
        logicalFrameDisposition: logicalFrameDisposition,
        committedPresentationRevision: committedPresentationRevision,
        presentationIntentState: presentationIntentState,
        presentationPending: pending,
        operationalEvents: operationalEvents
    )!
}

@Test
func admissionSummaryExhaustivelyMatchesTheIndependentLimitPredicate() {
    var checked = 0
    for inputEvents: UInt16 in 0 ... 3 {
        for stateChanges: UInt16 in 0 ... 3 {
            for completions: UInt16 in 0 ... 2 {
                for semanticActions: UInt16 in 0 ... 3 {
                    for dirty in [false, true] {
                        for recovery in [false, true] {
                            let value = AdmissionSummary(
                                inputEventCount: inputEvents,
                                stateChangeFactCount: stateChanges,
                                completionFactCount: completions,
                                semanticActionCount: semanticActions,
                                includesDirtyRederivation: dirty,
                                includesPresentationRecovery: recovery,
                                limits: matrixLimits
                            )
                            #expect(
                                (value != nil)
                                    == expectedAdmissionValidity(
                                        inputEvents: inputEvents,
                                        stateChanges: stateChanges,
                                        completions: completions,
                                        semanticActions: semanticActions
                                    )
                            )
                            checked += 1
                        }
                    }
                }
            }
        }
    }
    #expect(checked == 768)
}

@Test
func runCycleSummaryExhaustivelyMatchesTheIndependentIntrinsicPredicate() {
    let revisions: [SemanticRevision?] = [nil, SemanticRevision(rawValue: 1)]
    let semanticDispositions: [SemanticCycleDisposition] = [.unchanged, .published, .dirty]
    let logicalDispositions: [LogicalFrameDisposition] = [.notProduced, .committed, .aborted]
    let presentationRevisions: [PresentationRevision?] = [nil, PresentationRevision(rawValue: 1)]
    let intentStates: [PresentationIntentState] = [.satisfied, .pending, .unavailable]
    let pendingIntents: [PresentationPendingIntent?] = [
        nil,
        PresentationPendingIntent(
            semanticRevision: SemanticRevision(rawValue: 1),
            retryableRefusalCount: 0
        ),
        PresentationPendingIntent(
            semanticRevision: SemanticRevision(rawValue: 2),
            retryableRefusalCount: 1
        ),
    ]
    var checked = 0

    for semanticRevision in revisions {
        for semanticDisposition in semanticDispositions {
            for logicalDisposition in logicalDispositions {
                for presentationRevision in presentationRevisions {
                    for intentState in intentStates {
                        for pendingIntent in pendingIntents {
                            for rawEvents: UInt8 in 0 ... 31 {
                                let events = ExecutionOperationalEvents(rawValue: rawEvents)
                                let value = RunCycleSummary(
                                    cycle: RunCycleID(rawValue: 1),
                                    admission: summary(
                                        semanticRevision: nil,
                                        semanticDisposition: .unchanged,
                                        logicalFrameDisposition: .notProduced,
                                        committedPresentationRevision: nil,
                                        presentationIntentState: .satisfied
                                    ).admission,
                                    semanticRevision: semanticRevision,
                                    semanticDisposition: semanticDisposition,
                                    logicalFrameDisposition: logicalDisposition,
                                    committedPresentationRevision: presentationRevision,
                                    presentationIntentState: intentState,
                                    presentationPending: pendingIntent,
                                    operationalEvents: events
                                )
                                #expect(
                                    (value != nil)
                                        == expectedSummaryValidity(
                                            semanticRevision: semanticRevision,
                                            semanticDisposition: semanticDisposition,
                                            logicalFrameDisposition: logicalDisposition,
                                            committedPresentationRevision: presentationRevision,
                                            presentationIntentState: intentState,
                                            presentationPending: pendingIntent,
                                            operationalEvents: events
                                        )
                                )
                                checked += 1
                            }
                        }
                    }
                }
            }
        }
    }
    #expect(checked == 10_368)
}

@Test
func lifecycleMatrixAcceptsAllThirteenTerminalRows() {
    let priorSemantic = SemanticRevision(rawValue: 5)
    let publishedSemantic = SemanticRevision(rawValue: 6)
    let priorPresentation = PresentationRevision(rawValue: 7)
    let reservedPresentation = PresentationRevision(rawValue: 8)
    let candidate = CandidateFrameID(rawValue: 9)

    let histories = [
        MatrixHistory(
            terminal: .noChange,
            entrySemanticRevision: priorSemantic,
            entryPresentationRevision: priorPresentation,
            entryIntentState: .satisfied,
            reservedSemanticRevision: nil,
            reservedCandidate: nil,
            reservedPresentationRevision: nil,
            summary: summary(
                semanticRevision: priorSemantic,
                semanticDisposition: .unchanged,
                logicalFrameDisposition: .notProduced,
                committedPresentationRevision: priorPresentation,
                presentationIntentState: .satisfied,
                operationalEvents: .noChange
            )
        ),
        MatrixHistory(
            terminal: .prePublicationCleanFailure,
            entrySemanticRevision: priorSemantic,
            entryPresentationRevision: priorPresentation,
            entryIntentState: .satisfied,
            reservedSemanticRevision: nil,
            reservedCandidate: nil,
            reservedPresentationRevision: nil,
            summary: summary(
                semanticRevision: priorSemantic,
                semanticDisposition: .unchanged,
                logicalFrameDisposition: .notProduced,
                committedPresentationRevision: priorPresentation,
                presentationIntentState: .satisfied
            )
        ),
        MatrixHistory(
            terminal: .prePublicationDirtyFailure,
            entrySemanticRevision: priorSemantic,
            entryPresentationRevision: priorPresentation,
            entryIntentState: .satisfied,
            reservedSemanticRevision: nil,
            reservedCandidate: nil,
            reservedPresentationRevision: nil,
            summary: summary(
                semanticRevision: priorSemantic,
                semanticDisposition: .dirty,
                logicalFrameDisposition: .notProduced,
                committedPresentationRevision: priorPresentation,
                presentationIntentState: .satisfied
            )
        ),
        MatrixHistory(
            terminal: .accepted,
            entrySemanticRevision: priorSemantic,
            entryPresentationRevision: priorPresentation,
            entryIntentState: .satisfied,
            reservedSemanticRevision: publishedSemantic,
            reservedCandidate: candidate,
            reservedPresentationRevision: reservedPresentation,
            summary: summary(
                semanticRevision: publishedSemantic,
                semanticDisposition: .published,
                logicalFrameDisposition: .committed,
                committedPresentationRevision: reservedPresentation,
                presentationIntentState: .satisfied
            )
        ),
        MatrixHistory(
            terminal: .backpressured,
            entrySemanticRevision: priorSemantic,
            entryPresentationRevision: priorPresentation,
            entryIntentState: .satisfied,
            reservedSemanticRevision: publishedSemantic,
            reservedCandidate: candidate,
            reservedPresentationRevision: reservedPresentation,
            summary: summary(
                semanticRevision: publishedSemantic,
                semanticDisposition: .published,
                logicalFrameDisposition: .aborted,
                committedPresentationRevision: priorPresentation,
                presentationIntentState: .pending,
                operationalEvents: .backpressured
            )
        ),
        MatrixHistory(
            terminal: .retryablePending,
            entrySemanticRevision: priorSemantic,
            entryPresentationRevision: priorPresentation,
            entryIntentState: .satisfied,
            reservedSemanticRevision: publishedSemantic,
            reservedCandidate: candidate,
            reservedPresentationRevision: reservedPresentation,
            summary: summary(
                semanticRevision: publishedSemantic,
                semanticDisposition: .published,
                logicalFrameDisposition: .aborted,
                committedPresentationRevision: priorPresentation,
                presentationIntentState: .pending,
                retryCount: 1,
                operationalEvents: .retryableRefusal
            )
        ),
        MatrixHistory(
            terminal: .retryableExhausted,
            entrySemanticRevision: priorSemantic,
            entryPresentationRevision: priorPresentation,
            entryIntentState: .satisfied,
            reservedSemanticRevision: publishedSemantic,
            reservedCandidate: candidate,
            reservedPresentationRevision: reservedPresentation,
            summary: summary(
                semanticRevision: publishedSemantic,
                semanticDisposition: .published,
                logicalFrameDisposition: .aborted,
                committedPresentationRevision: priorPresentation,
                presentationIntentState: .unavailable,
                operationalEvents: .retryableRefusal
            )
        ),
        MatrixHistory(
            terminal: .nonRetryableRefusal,
            entrySemanticRevision: priorSemantic,
            entryPresentationRevision: priorPresentation,
            entryIntentState: .satisfied,
            reservedSemanticRevision: publishedSemantic,
            reservedCandidate: candidate,
            reservedPresentationRevision: reservedPresentation,
            summary: summary(
                semanticRevision: publishedSemantic,
                semanticDisposition: .published,
                logicalFrameDisposition: .aborted,
                committedPresentationRevision: priorPresentation,
                presentationIntentState: .unavailable
            )
        ),
        MatrixHistory(
            terminal: .postPublicationFailure,
            entrySemanticRevision: priorSemantic,
            entryPresentationRevision: priorPresentation,
            entryIntentState: .satisfied,
            reservedSemanticRevision: publishedSemantic,
            reservedCandidate: candidate,
            reservedPresentationRevision: reservedPresentation,
            summary: summary(
                semanticRevision: publishedSemantic,
                semanticDisposition: .published,
                logicalFrameDisposition: .aborted,
                committedPresentationRevision: priorPresentation,
                presentationIntentState: .satisfied
            )
        ),
        MatrixHistory(
            terminal: .candidateIdentityFailure,
            entrySemanticRevision: priorSemantic,
            entryPresentationRevision: priorPresentation,
            entryIntentState: .satisfied,
            reservedSemanticRevision: publishedSemantic,
            reservedCandidate: nil,
            reservedPresentationRevision: nil,
            summary: summary(
                semanticRevision: publishedSemantic,
                semanticDisposition: .published,
                logicalFrameDisposition: .notProduced,
                committedPresentationRevision: priorPresentation,
                presentationIntentState: .satisfied
            )
        ),
        MatrixHistory(
            terminal: .presentationIdentityFailure,
            entrySemanticRevision: priorSemantic,
            entryPresentationRevision: priorPresentation,
            entryIntentState: .satisfied,
            reservedSemanticRevision: publishedSemantic,
            reservedCandidate: candidate,
            reservedPresentationRevision: nil,
            summary: summary(
                semanticRevision: publishedSemantic,
                semanticDisposition: .published,
                logicalFrameDisposition: .aborted,
                committedPresentationRevision: priorPresentation,
                presentationIntentState: .satisfied
            )
        ),
        MatrixHistory(
            terminal: .facilityLostBeforeCandidate,
            entrySemanticRevision: priorSemantic,
            entryPresentationRevision: priorPresentation,
            entryIntentState: .satisfied,
            reservedSemanticRevision: publishedSemantic,
            reservedCandidate: nil,
            reservedPresentationRevision: nil,
            summary: summary(
                semanticRevision: publishedSemantic,
                semanticDisposition: .published,
                logicalFrameDisposition: .notProduced,
                committedPresentationRevision: priorPresentation,
                presentationIntentState: .unavailable
            )
        ),
        MatrixHistory(
            terminal: .facilityLostAfterCandidate,
            entrySemanticRevision: priorSemantic,
            entryPresentationRevision: priorPresentation,
            entryIntentState: .satisfied,
            reservedSemanticRevision: publishedSemantic,
            reservedCandidate: candidate,
            reservedPresentationRevision: nil,
            summary: summary(
                semanticRevision: publishedSemantic,
                semanticDisposition: .published,
                logicalFrameDisposition: .aborted,
                committedPresentationRevision: priorPresentation,
                presentationIntentState: .unavailable
            )
        ),
    ]

    #expect(histories.count == MatrixTerminalCondition.allCases.count)
    for history in histories {
        #expect(matrixAccepts(history))
    }
}

@Test
func lifecycleMatrixRejectsContradictoryHistoryNotVisibleInTheSummaryAlone() {
    let priorSemantic = SemanticRevision(rawValue: 5)
    let publishedSemantic = SemanticRevision(rawValue: 6)
    let priorPresentation = PresentationRevision(rawValue: 7)
    let reservedPresentation = PresentationRevision(rawValue: 8)
    let candidate = CandidateFrameID(rawValue: 9)
    let acceptedSummary = summary(
        semanticRevision: publishedSemantic,
        semanticDisposition: .published,
        logicalFrameDisposition: .committed,
        committedPresentationRevision: reservedPresentation,
        presentationIntentState: .satisfied
    )

    let rejected = [
        MatrixHistory(
            terminal: .accepted,
            entrySemanticRevision: priorSemantic,
            entryPresentationRevision: priorPresentation,
            entryIntentState: .satisfied,
            reservedSemanticRevision: nil,
            reservedCandidate: candidate,
            reservedPresentationRevision: reservedPresentation,
            summary: acceptedSummary
        ),
        MatrixHistory(
            terminal: .accepted,
            entrySemanticRevision: priorSemantic,
            entryPresentationRevision: priorPresentation,
            entryIntentState: .satisfied,
            reservedSemanticRevision: publishedSemantic,
            reservedCandidate: nil,
            reservedPresentationRevision: reservedPresentation,
            summary: acceptedSummary
        ),
        MatrixHistory(
            terminal: .accepted,
            entrySemanticRevision: priorSemantic,
            entryPresentationRevision: priorPresentation,
            entryIntentState: .satisfied,
            reservedSemanticRevision: publishedSemantic,
            reservedCandidate: candidate,
            reservedPresentationRevision: PresentationRevision(rawValue: 99),
            summary: acceptedSummary
        ),
        MatrixHistory(
            terminal: .postPublicationFailure,
            entrySemanticRevision: priorSemantic,
            entryPresentationRevision: PresentationRevision(rawValue: 99),
            entryIntentState: .satisfied,
            reservedSemanticRevision: publishedSemantic,
            reservedCandidate: candidate,
            reservedPresentationRevision: reservedPresentation,
            summary: summary(
                semanticRevision: publishedSemantic,
                semanticDisposition: .published,
                logicalFrameDisposition: .aborted,
                committedPresentationRevision: priorPresentation,
                presentationIntentState: .satisfied
            )
        ),
    ]

    for history in rejected {
        #expect(!matrixAccepts(history))
    }
}
