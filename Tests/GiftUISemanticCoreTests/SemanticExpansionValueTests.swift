import GiftUI
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

    func testGenericEntryRejectsAnAlreadyActiveWorkspaceBeforeTouchingTheSink() {
        guard let limits = makeLimits() else {
            return XCTFail("valid limits must construct")
        }
        var workspace = EntryProbeWorkspace(isExpanding: true)
        var sink = EntryProbeSink()

        let result = expandSemanticTree(
            EntryProbeView(),
            limits: limits,
            workspace: &workspace,
            sink: &sink
        )

        XCTAssertEqual(result, .failure(.reentrancyViolation))
        XCTAssertEqual(workspace.beginCalls, 0)
        XCTAssertEqual(sink.beginCalls, 0)
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

private struct EntryProbeIdentity: Equatable {}

private struct EntryProbeView: View {
    var body: Never {
        fatalError("entry probe body is not part of T2.1")
    }
}

private struct EntryProbeWorkspace: SemanticExpansionWorkspace {
    let maximumPathComponents: UInt16 = 1
    let maximumIdentities: UInt16 = 1
    var isExpanding: Bool
    var beginCalls = 0

    mutating func beginExpansion() -> Bool {
        beginCalls += 1
        return true
    }

    mutating func enterRoot<Declaration: View>(
        _ declaration: Declaration.Type,
        identity: inout EntryProbeIdentity?
    ) -> SemanticExpansionError? { nil }

    mutating func enterCustomBody<Declaration: View>(
        _ declaration: Declaration.Type,
        identity: inout EntryProbeIdentity?
    ) -> SemanticExpansionError? { nil }

    mutating func enterFixedChild(
        _ index: UInt8,
        identity: inout EntryProbeIdentity?
    ) -> SemanticExpansionError? { nil }

    mutating func enterConditionalBranch(
        _ index: UInt8,
        identity: inout EntryProbeIdentity?
    ) -> SemanticExpansionError? { nil }

    mutating func enterOptionalPresence(
        identity: inout EntryProbeIdentity?
    ) -> SemanticExpansionError? { nil }

    mutating func enterDeclarationRole<Declaration>(
        _ declaration: Declaration.Type,
        identity: inout EntryProbeIdentity?
    ) -> SemanticExpansionError? { nil }

    mutating func leavePathComponent() {}
    mutating func completeExpansion() {}
    mutating func discardExpansion() {}
    mutating func resetExpansion() {}
}

private struct EntryProbeSink: SemanticExpansionSink {
    let maximumStructuralOccurrences: UInt16 = 1
    let maximumBodyEvaluations: UInt16 = 1
    let maximumSemanticOccurrences: UInt16 = 1
    let maximumModifierApplications: UInt16 = 1
    let maximumActionOccurrences: UInt16 = 1
    var beginCalls = 0

    mutating func beginExpansion() -> Bool {
        beginCalls += 1
        return true
    }

    mutating func stageStructuralOccurrence(
        identity: borrowing EntryProbeIdentity
    ) -> Bool { true }

    mutating func stageBodyEvaluation(
        identity: borrowing EntryProbeIdentity
    ) -> Bool { true }

    mutating func stageSemanticOccurrence<
        Payload: _GiftUISemanticPrimitivePayload
    >(
        identity: borrowing EntryProbeIdentity,
        payload: borrowing Payload
    ) -> Bool { true }

    mutating func stageModifierApplication<
        Payload: _GiftUISemanticModifierPayload
    >(
        identity: borrowing EntryProbeIdentity,
        payload: borrowing Payload,
        chainIndex: UInt16
    ) -> Bool { true }

    mutating func stageActionOccurrence<Action: GiftUIAction>(
        identity: borrowing EntryProbeIdentity,
        action: borrowing Action
    ) -> Bool { true }

    mutating func publishExpansion(_ summary: SemanticExpansionSummary) -> Bool { true }
    mutating func discardExpansion() {}
    mutating func resetExpansion() {}
}
