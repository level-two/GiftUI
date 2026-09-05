import GiftUI
import XCTest

@testable import GiftUISemanticCore

final class SemanticReentrancyTests: XCTestCase {
    func testCallbackInvalidationAndExternalInputCannotReenterActiveRoot() {
        let sharedState = ReentryWorkspaceState()
        let probe = ReentryProbe(workspaceState: sharedState)
        var workspace = ReentryWorkspace(state: sharedState)
        var sink = ReentrySink()

        let result = expandSemanticTree(
            ReentryRoot(probe: probe),
            limits: reentryLimits,
            workspace: &workspace,
            sink: &sink
        )

        XCTAssertEqual(
            result,
            .success(
                SemanticExpansionSummary(
                    semanticNodeCount: 1,
                    bodyEvaluationCount: 1,
                    modifierApplicationCount: 0,
                    actionOccurrenceCount: 0,
                    maximumObservedDepth: 4
                )
            )
        )
        XCTAssertEqual(probe.sources, [.callback, .invalidation, .externalInput])
        XCTAssertEqual(
            probe.results,
            [
                .failure(.reentrancyViolation),
                .failure(.reentrancyViolation),
                .failure(.reentrancyViolation),
            ]
        )
        XCTAssertEqual(probe.nestedSinkBeginCounts, [0, 0, 0])
        XCTAssertEqual(sink.publishCount, 1)
        XCTAssertEqual(sink.discardCount, 0)
        XCTAssertFalse(workspace.isExpanding)
    }
}

private enum ReentrySource: Equatable {
    case callback
    case invalidation
    case externalInput
}

private final class ReentryProbe {
    let workspaceState: ReentryWorkspaceState
    var sources: [ReentrySource] = []
    var results: [SemanticExpansionResult] = []
    var nestedSinkBeginCounts: [Int] = []

    init(workspaceState: ReentryWorkspaceState) {
        self.workspaceState = workspaceState
    }

    func attempt(_ source: ReentrySource) {
        sources.append(source)
        var workspace = ReentryWorkspace(state: workspaceState)
        var sink = ReentrySink()
        results.append(
            expandSemanticTree(
                ReentryPrimitive(),
                limits: reentryLimits,
                workspace: &workspace,
                sink: &sink
            )
        )
        nestedSinkBeginCounts.append(sink.beginCount)
    }
}

private struct ReentryRoot: View {
    let probe: ReentryProbe

    var body: some View {
        probe.attempt(.callback)
        probe.attempt(.invalidation)
        probe.attempt(.externalInput)
        return ReentryPrimitive()
    }
}

private struct ReentryPrimitive: View, _GiftUISemanticPrimitivePayload {
    var body: Never { fatalError("primitive body is unreachable") }
    func _giftUITraverse<Visitor: _GiftUISemanticTraversalVisitor>(
        _ visitor: inout Visitor
    ) {
        visitor.visitPrimitive(self)
    }
}

private struct ReentryIdentity: Equatable {
    let path: [UInt8]
}

private final class ReentryWorkspaceState {
    var isExpanding = false
    var path: [UInt8] = []
}

private struct ReentryWorkspace: SemanticExpansionWorkspace {
    let maximumPathComponents: UInt16 = 16
    let maximumIdentities: UInt16 = 16
    let state: ReentryWorkspaceState
    var isExpanding: Bool { state.isExpanding }

    mutating func beginExpansion() -> Bool {
        guard !state.isExpanding else { return false }
        state.isExpanding = true
        state.path.removeAll(keepingCapacity: true)
        return true
    }
    mutating func enterRoot<Declaration: View>(
        _ declaration: Declaration.Type,
        identity: inout ReentryIdentity?
    ) -> SemanticExpansionError? { enter(0, identity: &identity) }
    mutating func enterCustomBody<Declaration: View>(
        _ declaration: Declaration.Type,
        identity: inout ReentryIdentity?
    ) -> SemanticExpansionError? { enter(1, identity: &identity) }
    mutating func enterFixedChild(
        _ index: UInt8,
        identity: inout ReentryIdentity?
    ) -> SemanticExpansionError? { enter(2 &+ index, identity: &identity) }
    mutating func enterConditionalBranch(
        _ index: UInt8,
        identity: inout ReentryIdentity?
    ) -> SemanticExpansionError? { enter(8 &+ index, identity: &identity) }
    mutating func enterOptionalPresence(
        identity: inout ReentryIdentity?
    ) -> SemanticExpansionError? { enter(10, identity: &identity) }
    mutating func enterDeclarationRole<Declaration>(
        _ declaration: Declaration.Type,
        identity: inout ReentryIdentity?
    ) -> SemanticExpansionError? { enter(11, identity: &identity) }
    mutating func leavePathComponent() { _ = state.path.popLast() }
    mutating func completeExpansion() {}
    mutating func discardExpansion() {}
    mutating func resetExpansion() {
        state.path.removeAll(keepingCapacity: true)
        state.isExpanding = false
    }
    private func enter(
        _ component: UInt8,
        identity: inout ReentryIdentity?
    ) -> SemanticExpansionError? {
        state.path.append(component)
        identity = ReentryIdentity(path: state.path)
        return nil
    }
}

private struct ReentrySink: SemanticExpansionSink {
    let maximumStructuralOccurrences: UInt16 = 16
    let maximumBodyEvaluations: UInt16 = 16
    let maximumSemanticOccurrences: UInt16 = 16
    let maximumModifierApplications: UInt16 = 16
    let maximumActionOccurrences: UInt16 = 16
    var beginCount = 0
    var publishCount = 0
    var discardCount = 0

    mutating func beginExpansion() -> Bool {
        beginCount += 1
        return true
    }
    mutating func stageStructuralOccurrence(identity: borrowing ReentryIdentity) -> Bool { true }
    mutating func stageBodyEvaluation(identity: borrowing ReentryIdentity) -> Bool { true }
    mutating func stageSemanticOccurrence<Payload: _GiftUISemanticPrimitivePayload>(
        identity: borrowing ReentryIdentity,
        payload: borrowing Payload
    ) -> Bool { true }
    mutating func stageModifierApplication<Payload: _GiftUISemanticModifierPayload>(
        identity: borrowing ReentryIdentity,
        payload: borrowing Payload,
        chainIndex: UInt16
    ) -> Bool { true }
    mutating func stageActionOccurrence<Action: GiftUIAction>(
        identity: borrowing ReentryIdentity,
        action: borrowing Action
    ) -> Bool { true }
    mutating func publishExpansion(_ summary: SemanticExpansionSummary) -> Bool {
        publishCount += 1
        return true
    }
    mutating func discardExpansion() { discardCount += 1 }
    mutating func resetExpansion() {}
}

private let reentryLimits = SemanticExpansionLimits(
    maximumDepth: 16,
    maximumSemanticNodes: 16,
    maximumBodyEvaluations: 16,
    maximumModifierApplications: 16,
    maximumActionOccurrences: 16
)!
