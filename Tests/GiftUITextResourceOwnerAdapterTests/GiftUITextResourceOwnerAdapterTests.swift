import GiftUIFailureCore
import GiftUIFailureDiagnostics
@testable import GiftUITextResourceFailureAdapterFixture
@testable import GiftUITextResources
import XCTest

final class GiftUITextResourceOwnerAdapterTests: XCTestCase {
    func testEveryLocalValidationErrorMapsToItsExactHostAssemblyFact() {
        let invalidValue: [TextResourceValidationError] = [
            .unsupportedSchema,
            .invalidCount,
            .malformedMetrics,
            .malformedMapping,
            .malformedRasterRecord,
        ]
        let invalidIdentity: [TextResourceValidationError] = [
            .invalidIdentity,
            .incompatibleViews,
            .integrityMismatch,
        ]
        for error in invalidValue {
            XCTAssertEqual(
                GiftUITextResourceFailureAdapterFixture.assemblyFact(for: error),
                assemblyFact(condition: .invalidValue)
            )
        }
        for error in invalidIdentity {
            XCTAssertEqual(
                GiftUITextResourceFailureAdapterFixture.assemblyFact(for: error),
                assemblyFact(condition: .invalidIdentity)
            )
        }
        XCTAssertEqual(
            GiftUITextResourceFailureAdapterFixture.assemblyFact(
                for: .capacityExceeded
            ),
            assemblyFact(condition: .capacityExhausted)
        )
    }

    func testUnexpectedOwnerFailuresUseExactApprovedFacts() {
        XCTAssertEqual(
            GiftUITextResourceFailureAdapterFixture.unexpectedLayoutLookup,
            GiftUIFailureFact(
                condition: .invariantViolation,
                origin: .layout,
                affectedScope: .candidateFrame,
                containment: .safetyNotProven
            )
        )
        XCTAssertEqual(
            GiftUITextResourceFailureAdapterFixture.unexpectedRenderLookup,
            GiftUIFailureFact(
                condition: .invariantViolation,
                origin: .rendering,
                affectedScope: .candidateFrame,
                containment: .safetyNotProven
            )
        )
        XCTAssertEqual(
            GiftUITextResourceFailureAdapterFixture.layoutArithmeticOverflow,
            GiftUIFailureFact(
                condition: .arithmeticOverflow,
                origin: .foundation,
                affectedScope: .operation,
                containment: .contained
            )
        )
        XCTAssertEqual(
            GiftUITextResourceFailureAdapterFixture.requiredRenderRealizationLoss,
            GiftUIFailureFact(
                condition: .requiredFacilityUnavailable,
                origin: .rendering,
                affectedScope: .runtime,
                containment: .contained
            )
        )
    }

    func testDiagnosticsCannotChangeAnyAdapterResult() {
        let before = TextResourceValidationError.allCasesForFixture.map {
            GiftUITextResourceFailureAdapterFixture.assemblyFact(for: $0)
        }
        var diagnostics = GiftUIFixedDiagnosticBuffer()
        for fact in before {
            _ = diagnostics.consume(
                GiftUIDiagnosticRecord(
                    kind: .failureOutcome,
                    severity: .error,
                    flags: 0,
                    origin: fact.origin,
                    affectedScope: fact.affectedScope,
                    condition: fact.condition.rawValue
                )
            )
        }
        let after = TextResourceValidationError.allCasesForFixture.map {
            GiftUITextResourceFailureAdapterFixture.assemblyFact(for: $0)
        }
        XCTAssertEqual(after, before)
    }

    private func assemblyFact(
        condition: GiftUIConditionID
    ) -> GiftUIFailureFact {
        GiftUIFailureFact(
            condition: condition,
            origin: .hostComposition,
            affectedScope: .runtime,
            containment: .contained
        )
    }
}

private extension TextResourceValidationError {
    static let allCasesForFixture: [Self] = [
        .unsupportedSchema,
        .capacityExceeded,
        .invalidCount,
        .invalidIdentity,
        .incompatibleViews,
        .malformedMetrics,
        .malformedMapping,
        .malformedRasterRecord,
        .integrityMismatch,
    ]
}
