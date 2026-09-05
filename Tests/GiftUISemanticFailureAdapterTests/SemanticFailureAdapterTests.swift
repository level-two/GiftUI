import GiftUIFailureCore
import XCTest

@testable import GiftUISemanticCore
@testable import GiftUISemanticFailureAdapterFixture

final class SemanticFailureAdapterTests: XCTestCase {
    func testEveryLocalErrorMapsToItsExactFirstOwnerFact() {
        let rows: [(SemanticExpansionError, GiftUIConditionID, GiftUIContainment)] = [
            (.capacityExhausted, .capacityExhausted, .contained),
            (.invalidIdentity, .invalidIdentity, .contained),
            (.reentrancyViolation, .reentrancyViolation, .contained),
            (.invariantViolation, .invariantViolation, .safetyNotProven),
        ]

        for (error, condition, containment) in rows {
            XCTAssertEqual(
                GiftUISemanticFailureAdapterFixture.fact(for: error),
                GiftUIFailureFact(
                    condition: condition,
                    origin: .semantic,
                    affectedScope: .activeCycle,
                    containment: containment
                )
            )
        }
    }

    func testInvalidLimitsMapBeforeCycleToRuntimeInvalidValue() {
        XCTAssertNil(
            SemanticExpansionLimits(
                maximumDepth: 0,
                maximumSemanticNodes: 1,
                maximumBodyEvaluations: 1,
                maximumModifierApplications: 0,
                maximumActionOccurrences: 0
            )
        )
        XCTAssertEqual(
            GiftUISemanticFailureAdapterFixture.invalidLimitsFact,
            GiftUIFailureFact(
                condition: .invalidValue,
                origin: .semantic,
                affectedScope: .runtime,
                containment: .contained
            )
        )
    }

    func testDiagnosticVariantsCannotChangeLocalResultTranscriptCountsOrPrimaryFact() {
        let localResult = SemanticExpansionResult.failure(.invalidIdentity)
        let transcript = [UInt16(10), 11, 12]
        let counts = SemanticExpansionSummary(
            semanticNodeCount: 1,
            bodyEvaluationCount: 2,
            modifierApplicationCount: 3,
            actionOccurrenceCount: 4,
            maximumObservedDepth: 5
        )
        let fact = GiftUISemanticFailureAdapterFixture.fact(for: .invalidIdentity)
        let baseline = OwnerSnapshot(
            localResult: localResult,
            transcript: transcript,
            counts: counts,
            fact: fact
        )

        XCTAssertEqual(
            OwnerSnapshot(
                localResult: localResult,
                transcript: transcript,
                counts: counts,
                fact: fact
            ),
            baseline
        )

        for result in [
            GiftUIDiagnosticSinkResult.accepted,
            .saturated,
            .dropped,
            .failed,
        ] {
            var sink = SemanticDiagnosticSink(result: result)
            XCTAssertEqual(sink.consume(record(for: fact)), result)
            XCTAssertEqual(sink.consumed, 1)
            XCTAssertEqual(
                OwnerSnapshot(
                    localResult: localResult,
                    transcript: transcript,
                    counts: counts,
                    fact: fact
                ),
                baseline
            )
        }
    }

    private func record(for fact: GiftUIFailureFact) -> GiftUIDiagnosticRecord {
        GiftUIDiagnosticRecord(
            kind: .failureOutcome,
            severity: .error,
            flags: 0,
            origin: fact.origin,
            affectedScope: fact.affectedScope,
            condition: fact.condition.rawValue
        )
    }
}

private struct OwnerSnapshot: Equatable {
    let localResult: SemanticExpansionResult
    let transcript: [UInt16]
    let counts: SemanticExpansionSummary
    let fact: GiftUIFailureFact
}

private struct SemanticDiagnosticSink: GiftUIDiagnosticSink {
    let result: GiftUIDiagnosticSinkResult
    var consumed = 0

    mutating func consume(_ record: GiftUIDiagnosticRecord) -> GiftUIDiagnosticSinkResult {
        consumed += 1
        return result
    }
}
