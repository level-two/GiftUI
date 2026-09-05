import XCTest

@testable import GiftUISemanticCore

final class SemanticExpansionValueTests: XCTestCase {
    func testLimitsAcceptExactMinimumRequiredCountsAndZeroOptionalCounts() {
        let limits = SemanticExpansionLimits(
            maximumDepth: 1,
            maximumSemanticNodes: 1,
            maximumBodyEvaluations: 1,
            maximumModifierApplications: 0,
            maximumActionOccurrences: 0
        )

        XCTAssertEqual(limits?.maximumDepth, 1)
        XCTAssertEqual(limits?.maximumSemanticNodes, 1)
        XCTAssertEqual(limits?.maximumBodyEvaluations, 1)
        XCTAssertEqual(limits?.maximumModifierApplications, 0)
        XCTAssertEqual(limits?.maximumActionOccurrences, 0)
    }

    func testLimitsRejectEachZeroRequiredCount() {
        XCTAssertNil(makeLimits(maximumDepth: 0))
        XCTAssertNil(makeLimits(maximumSemanticNodes: 0))
        XCTAssertNil(makeLimits(maximumBodyEvaluations: 0))
    }

    func testSummaryPreservesEveryExactCounter() {
        let summary = SemanticExpansionSummary(
            semanticNodeCount: 1,
            bodyEvaluationCount: 2,
            modifierApplicationCount: 3,
            actionOccurrenceCount: 4,
            maximumObservedDepth: 5
        )

        XCTAssertEqual(summary.semanticNodeCount, 1)
        XCTAssertEqual(summary.bodyEvaluationCount, 2)
        XCTAssertEqual(summary.modifierApplicationCount, 3)
        XCTAssertEqual(summary.actionOccurrenceCount, 4)
        XCTAssertEqual(summary.maximumObservedDepth, 5)
    }

    func testErrorsUseTheirExactUInt8Codes() {
        XCTAssertEqual(SemanticExpansionError.capacityExhausted.rawValue, 0)
        XCTAssertEqual(SemanticExpansionError.invalidIdentity.rawValue, 1)
        XCTAssertEqual(SemanticExpansionError.reentrancyViolation.rawValue, 2)
        XCTAssertEqual(SemanticExpansionError.invariantViolation.rawValue, 3)
    }

    func testOwnedValuesMeetTheirHostLayoutBounds() {
        XCTAssertLessThanOrEqual(MemoryLayout<SemanticExpansionLimits>.size, 10)
        XCTAssertLessThanOrEqual(MemoryLayout<SemanticExpansionSummary>.size, 10)
        XCTAssertEqual(MemoryLayout<SemanticExpansionError>.size, 1)
        XCTAssertLessThanOrEqual(MemoryLayout<SemanticExpansionResult>.size, 12)
    }

    private func makeLimits(
        maximumDepth: UInt16 = 1,
        maximumSemanticNodes: UInt16 = 1,
        maximumBodyEvaluations: UInt16 = 1
    ) -> SemanticExpansionLimits? {
        SemanticExpansionLimits(
            maximumDepth: maximumDepth,
            maximumSemanticNodes: maximumSemanticNodes,
            maximumBodyEvaluations: maximumBodyEvaluations,
            maximumModifierApplications: 0,
            maximumActionOccurrences: 0
        )
    }
}
