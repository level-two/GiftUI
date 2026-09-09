import Testing

@testable import GiftUIExecution
@testable import GiftUIFailureCore
@testable import GiftUIFailureExecution

private enum AdapterOwnerFailure: UInt8, CaseIterable, Equatable, Sendable {
    case mutation = 0
    case completion = 1
    case semantic = 2
    case layout = 3
    case immutableRenderInput = 4
}

private func ownerFact(for failure: AdapterOwnerFailure) -> GiftUIFailureFact {
    switch failure {
    case .mutation:
        GiftUIFailureFact(
            condition: .invalidValue,
            origin: .observableState,
            affectedScope: .operation,
            containment: .contained
        )
    case .completion:
        GiftUIFailureFact(
            condition: .arithmeticOverflow,
            origin: .interaction,
            affectedScope: .operation,
            containment: .contained
        )
    case .semantic:
        GiftUIFailureFact(
            condition: .invalidIdentity,
            origin: .semantic,
            affectedScope: .activeCycle,
            containment: .contained
        )
    case .layout:
        GiftUIFailureFact(
            condition: .capacityExhausted,
            origin: .layout,
            affectedScope: .activeCycle,
            containment: .contained
        )
    case .immutableRenderInput:
        GiftUIFailureFact(
            condition: .invariantViolation,
            origin: .rendering,
            affectedScope: .candidateFrame,
            containment: .safetyNotProven
        )
    }
}

@Test
func everyFocusedOwnerCasePreservesConcreteValueAndContext() {
    let context = ExecutionContext(
        cycle: RunCycleID(rawValue: 4),
        semanticRevision: SemanticRevision(rawValue: 5),
        candidateFrame: CandidateFrameID(rawValue: 6),
        phase: .deriving
    )

    for failure in AdapterOwnerFailure.allCases {
        let mapped = GiftUIExecutionFailureAdapter.focusedOwner(
            from: RunCycleFailure.focusedOwner(failure),
            context: context
        )
        #expect(mapped?.failure == failure)
        #expect(mapped?.context == context)
        #expect(ownerFact(for: mapped!.failure) == ownerFact(for: failure))
    }
}

@Test
func commonAdapterNeverSubstitutesForNonfocusedFailure() {
    let context = ExecutionContext(
        cycle: nil,
        semanticRevision: nil,
        candidateFrame: nil,
        phase: .idle
    )
    let failures: [RunCycleFailure<AdapterOwnerFailure>] = [
        .execution(.invalidValue),
        .renderProduction(.invalidInput),
        .frameOffer(.contractViolation),
        .nonRetryableRefusal(.endpoint),
    ]
    for failure in failures {
        #expect(
            GiftUIExecutionFailureAdapter.focusedOwner(
                from: failure,
                context: context
            ) == nil
        )
    }
}
