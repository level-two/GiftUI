import GiftUI
import GiftUIExecution
import Testing

@testable import GiftUIObservableState

private struct FixturePresentationFact: Equatable, Sendable {
    let producer: UInt16
    let sequence: UInt16
    let value: Int16
}

private struct FixtureCompletionFact: Sendable {}

private struct FixtureExecutionAdmission: ExecutionAdmissionSink {
    var result: ExecutionAdmissionResult
    var submittedFacts: UInt16 = 0
    var lastFact: FixturePresentationFact?

    mutating func submit(pointer: NormalizedPointerEvent) -> ExecutionAdmissionOutcome {
        outcome()
    }

    mutating func submit(
        stateChange: FixturePresentationFact
    ) -> ExecutionAdmissionOutcome {
        submittedFacts += 1
        lastFact = stateChange
        return outcome()
    }

    mutating func submit(
        completion: FixtureCompletionFact
    ) -> ExecutionAdmissionOutcome {
        outcome()
    }

    private func outcome() -> ExecutionAdmissionOutcome {
        ExecutionAdmissionOutcome(
            result: result,
            context: ExecutionContext(
                cycle: nil,
                semanticRevision: nil,
                candidateFrame: nil,
                phase: .idle
            )
        )
    }
}

private struct FixturePresentationAdapter: PresentationFactAdmissionAdapter {
    var admission: FixtureExecutionAdmission

    mutating func submit(
        _ fact: FixturePresentationFact
    ) -> ExecutionAdmissionOutcome {
        admission.submit(stateChange: fact)
    }
}

@Test
func presentationFactAdapterForwardsOneCompleteTypedFactAndExactOutcome() {
    let fact = FixturePresentationFact(producer: 1, sequence: 2, value: 3)
    var adapter = FixturePresentationAdapter(
        admission: FixtureExecutionAdmission(result: .queued)
    )

    let outcome = adapter.submit(fact)

    #expect(outcome.result == .queued)
    #expect(outcome.context.phase == .idle)
    #expect(adapter.admission.submittedFacts == 1)
    #expect(adapter.admission.lastFact == fact)
}

@Test
func presentationFactRefusalIsReturnedWithoutFallbackOrSecondQueue() {
    let fact = FixturePresentationFact(producer: 5, sequence: 8, value: 13)
    let refusals: [ExecutionAdmissionResult] = [
        .capacityRefused,
        .unavailable,
        .invalidValue,
        .invalidProvenance,
    ]

    for refusal in refusals {
        var adapter = FixturePresentationAdapter(
            admission: FixtureExecutionAdmission(result: refusal)
        )
        let outcome = adapter.submit(fact)

        #expect(outcome.result == refusal)
        #expect(adapter.admission.submittedFacts == 1)
        #expect(adapter.admission.lastFact == fact)
    }
}

@Test
func fixturePresentationFactIsFiniteImmutableAndSendable() {
    #expect(MemoryLayout<FixturePresentationFact>.size == 6)
    #expect(MemoryLayout<FixturePresentationFact>.stride == 6)
    requireSendable(FixturePresentationFact.self)
}

private func requireSendable<Value: Sendable>(_: Value.Type) {}
