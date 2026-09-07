import GiftUI
import GiftUIRenderCore
import Testing

@testable import GiftUIExecution

private enum FixtureOwnerFailure: UInt32, Equatable, Sendable {
    case semantic = 0x1020_3040
    case layout = 0x5060_7080
}

private let cycleLimits = ExecutionLimits(
    maximumInputEvents: 4,
    maximumStateChangeFacts: 4,
    maximumCompletionFacts: 2,
    maximumSemanticActions: 4,
    maximumActiveInputSources: 2,
    maximumCommittedActions: 4
)!

private let emptyAdmission = AdmissionSummary(
    inputEventCount: 0,
    stateChangeFactCount: 0,
    completionFactCount: 0,
    semanticActionCount: 0,
    includesDirtyRederivation: false,
    includesPresentationRecovery: false,
    limits: cycleLimits
)!

private func makeSummary(
    semanticRevision: SemanticRevision? = nil,
    semanticDisposition: SemanticCycleDisposition = .unchanged,
    logicalFrameDisposition: LogicalFrameDisposition = .notProduced,
    committedPresentationRevision: PresentationRevision? = nil,
    presentationIntentState: PresentationIntentState = .satisfied,
    presentationPending: PresentationPendingIntent? = nil,
    operationalEvents: ExecutionOperationalEvents = []
) -> RunCycleSummary? {
    RunCycleSummary(
        cycle: RunCycleID(rawValue: 7),
        admission: emptyAdmission,
        semanticRevision: semanticRevision,
        semanticDisposition: semanticDisposition,
        logicalFrameDisposition: logicalFrameDisposition,
        committedPresentationRevision: committedPresentationRevision,
        presentationIntentState: presentationIntentState,
        presentationPending: presentationPending,
        operationalEvents: operationalEvents
    )
}

private func requireSendable<T: Sendable>(_: T.Type) {}

@Test
func cycleResultEnumsHaveExactClosedRawValuesAndWidths() {
    let executionErrors: [ExecutionError] = [
        .invalidValue,
        .arithmeticOverflow,
        .capacityExhausted,
        .identityExhausted,
        .invalidProvenance,
        .invalidPhase,
        .reentrancyViolation,
        .requiredFacilityUnavailable,
        .invariantViolation,
    ]
    #expect(executionErrors.map(\.rawValue) == Array(0 ... 8))
    #expect(ExecutionError(rawValue: 9) == nil)

    #expect(SemanticCycleDisposition.unchanged.rawValue == 0)
    #expect(SemanticCycleDisposition.published.rawValue == 1)
    #expect(SemanticCycleDisposition.dirty.rawValue == 2)
    #expect(SemanticCycleDisposition(rawValue: 3) == nil)

    #expect(ExecutionOperational.noChange.rawValue == 0)
    #expect(ExecutionOperational.backpressured.rawValue == 1)
    #expect(ExecutionOperational.retryableRefusal.rawValue == 2)
    #expect(ExecutionOperational.superseded.rawValue == 3)
    #expect(ExecutionOperational.deferredToLaterAdmission.rawValue == 4)
    #expect(ExecutionOperational(rawValue: 5) == nil)

    #expect(PresentationIntentState.satisfied.rawValue == 0)
    #expect(PresentationIntentState.pending.rawValue == 1)
    #expect(PresentationIntentState.unavailable.rawValue == 2)
    #expect(PresentationIntentState(rawValue: 3) == nil)

    #expect(MemoryLayout<ExecutionError>.size == 1)
    #expect(MemoryLayout<SemanticCycleDisposition>.size == 1)
    #expect(MemoryLayout<ExecutionOperational>.size == 1)
    #expect(MemoryLayout<PresentationIntentState>.size == 1)
}

@Test
func operationalEventsMaskUnknownBitsAndKeepExactKnownValues() {
    #expect(ExecutionOperationalEvents.noChange.rawValue == 0x01)
    #expect(ExecutionOperationalEvents.backpressured.rawValue == 0x02)
    #expect(ExecutionOperationalEvents.retryableRefusal.rawValue == 0x04)
    #expect(ExecutionOperationalEvents.superseded.rawValue == 0x08)
    #expect(ExecutionOperationalEvents.deferredToLaterAdmission.rawValue == 0x10)
    #expect(ExecutionOperationalEvents(rawValue: 0xFF).rawValue == 0x1F)
    #expect(ExecutionOperationalEvents(rawValue: 0xE0).isEmpty)
    #expect(MemoryLayout<ExecutionOperationalEvents>.size == 1)
}

@Test
func runCycleFailurePreservesEveryExactFocusedValue() {
    let failures: [RunCycleFailure<FixtureOwnerFailure>] = [
        .execution(.identityExhausted),
        .renderProduction(.incompatibleTextResource),
        .frameOffer(.insufficientCapacity),
        .nonRetryableRefusal(.endpoint),
        .focusedOwner(.semantic),
    ]

    #expect(failures[0] == .execution(.identityExhausted))
    #expect(failures[1] == .renderProduction(.incompatibleTextResource))
    #expect(failures[2] == .frameOffer(.insufficientCapacity))
    #expect(failures[3] == .nonRetryableRefusal(.endpoint))
    #expect(failures[4] == .focusedOwner(.semantic))
    #expect(failures[4] != .focusedOwner(.layout))
    #expect(MemoryLayout<FixtureOwnerFailure>.size <= 4)
    #expect(MemoryLayout<RunCycleFailure<FixtureOwnerFailure>>.size <= 8)
    requireSendable(RunCycleFailure<FixtureOwnerFailure>.self)
}

@Test
func runCycleSummaryAcceptsIntrinsicLegalCombinations() {
    let revision = SemanticRevision(rawValue: 10)
    let committed = PresentationRevision(rawValue: 20)
    let pending = PresentationPendingIntent(
        semanticRevision: revision,
        retryableRefusalCount: 1
    )

    #expect(makeSummary() != nil)
    #expect(
        makeSummary(
            semanticRevision: revision,
            semanticDisposition: .published,
            logicalFrameDisposition: .committed,
            committedPresentationRevision: committed
        ) != nil
    )
    #expect(
        makeSummary(
            semanticRevision: revision,
            semanticDisposition: .published,
            logicalFrameDisposition: .aborted,
            presentationIntentState: .pending,
            presentationPending: pending,
            operationalEvents: .backpressured
        ) != nil
    )
    #expect(
        makeSummary(
            semanticRevision: revision,
            logicalFrameDisposition: .aborted,
            presentationIntentState: .unavailable,
            operationalEvents: .retryableRefusal
        ) != nil
    )
    #expect(
        makeSummary(
            semanticRevision: revision,
            semanticDisposition: .published,
            operationalEvents: [.superseded, .deferredToLaterAdmission]
        ) != nil
    )
    #expect(makeSummary(operationalEvents: [.noChange, .deferredToLaterAdmission]) != nil)
}

@Test
func runCycleSummaryRejectsPresentationAndPublicationContradictions() {
    let revision = SemanticRevision(rawValue: 10)
    let otherRevision = SemanticRevision(rawValue: 11)
    let pending = PresentationPendingIntent(
        semanticRevision: revision,
        retryableRefusalCount: 0
    )

    #expect(makeSummary(semanticDisposition: .published) == nil)
    #expect(makeSummary(logicalFrameDisposition: .committed) == nil)
    #expect(
        makeSummary(
            logicalFrameDisposition: .committed,
            committedPresentationRevision: PresentationRevision(rawValue: 20),
            presentationIntentState: .unavailable
        ) == nil
    )
    #expect(makeSummary(presentationIntentState: .pending) == nil)
    #expect(makeSummary(presentationPending: pending) == nil)
    #expect(
        makeSummary(
            semanticRevision: otherRevision,
            presentationIntentState: .pending,
            presentationPending: pending
        ) == nil
    )
}

@Test
func runCycleSummaryRejectsOperationalContradictions() {
    let revision = SemanticRevision(rawValue: 10)
    let pending = PresentationPendingIntent(
        semanticRevision: revision,
        retryableRefusalCount: 1
    )

    #expect(
        makeSummary(
            semanticRevision: revision,
            logicalFrameDisposition: .aborted,
            presentationIntentState: .pending,
            presentationPending: pending,
            operationalEvents: [.backpressured, .retryableRefusal]
        ) == nil
    )
    for conflict in [
        ExecutionOperationalEvents.backpressured,
        .retryableRefusal,
        .superseded,
    ] {
        #expect(makeSummary(operationalEvents: [.noChange, conflict]) == nil)
    }
    #expect(makeSummary(semanticDisposition: .dirty, operationalEvents: .noChange) == nil)
    #expect(
        makeSummary(
            logicalFrameDisposition: .aborted,
            operationalEvents: .noChange
        ) == nil
    )
    #expect(
        makeSummary(
            semanticRevision: revision,
            presentationIntentState: .pending,
            presentationPending: pending,
            operationalEvents: .noChange
        ) == nil
    )
    #expect(makeSummary(operationalEvents: .backpressured) == nil)
    #expect(
        makeSummary(
            semanticRevision: revision,
            logicalFrameDisposition: .aborted,
            presentationIntentState: .unavailable,
            operationalEvents: .backpressured
        ) == nil
    )
    #expect(makeSummary(operationalEvents: .retryableRefusal) == nil)
    #expect(makeSummary(operationalEvents: .superseded) == nil)
}

@Test
func runCycleResultsPreserveSummaryContextAndGenericFailure() {
    let summary = makeSummary()!
    let context = ExecutionContext(
        cycle: RunCycleID(rawValue: 7),
        semanticRevision: nil,
        candidateFrame: nil,
        phase: .finalizing
    )
    let success = RunCycleResult<FixtureOwnerFailure>.success(summary)
    let operational = RunCycleResult<FixtureOwnerFailure>.operational(.noChange, summary)
    let failure = RunCycleResult<FixtureOwnerFailure>.failure(
        context,
        .focusedOwner(.layout),
        summary
    )

    #expect(success == .success(summary))
    #expect(operational == .operational(.noChange, summary))
    #expect(failure == .failure(context, .focusedOwner(.layout), summary))
    #expect(failure != .failure(context, .focusedOwner(.semantic), summary))
    #expect(MemoryLayout<RunCycleSummary>.size <= 40)
    #expect(MemoryLayout<RunCycleResult<FixtureOwnerFailure>>.size <= 72)
    requireSendable(RunCycleSummary.self)
    requireSendable(RunCycleResult<FixtureOwnerFailure>.self)
}
