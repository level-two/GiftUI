import GiftUIExecution
import Testing

@testable import GiftUIRuntimeCore

@Test
func focusedFailureStateRetainsFirstExactValueAndExecutionContext() {
    let firstContext = ExecutionContext(
        cycle: RunCycleID(rawValue: 1),
        semanticRevision: nil,
        candidateFrame: nil,
        phase: .deriving
    )
    let laterContext = ExecutionContext(
        cycle: RunCycleID(rawValue: 1),
        semanticRevision: nil,
        candidateFrame: CandidateFrameID(rawValue: 2),
        phase: .finalizing
    )
    var state = RuntimeFocusedFailureState()
    state.captureFirst(.semantic(.capacityExhausted), context: firstContext)
    state.captureFirst(.layout(.invariantViolation), context: laterContext)

    #expect(state.firstFailure == .semantic(.capacityExhausted))
    #expect(state.detectingContext == firstContext)
    guard let selected = state.selectedFailure() else {
        Issue.record("expected a selected focused failure")
        return
    }
    #expect(selected.context == firstContext)
    #expect(selected.failure == .focusedOwner(.semantic(.capacityExhausted)))
}

@Test
func cleanupFailureCanOnlyWidenAndNeverReplacePrimaryFailure() {
    let context = ExecutionContext(
        cycle: RunCycleID(rawValue: 3),
        semanticRevision: SemanticRevision(rawValue: 4),
        candidateFrame: nil,
        phase: .deriving
    )
    var state = RuntimeFocusedFailureState()
    state.captureFirst(.drawing(.invalidValue), context: context)
    state.recordCleanupFailure(containment: .contained)
    state.recordCleanupFailure(containment: .none)
    #expect(state.cleanupContainment == .contained)
    state.recordCleanupFailure(containment: .safetyNotProven)
    state.recordCleanupFailure(containment: .contained)

    #expect(state.cleanupContainment == .safetyNotProven)
    #expect(state.firstFailure == .drawing(.invalidValue))
    #expect(state.detectingContext == context)
}
