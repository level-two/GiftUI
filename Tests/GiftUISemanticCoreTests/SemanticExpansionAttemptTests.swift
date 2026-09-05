import GiftUI
import XCTest

@testable import GiftUISemanticCore

final class SemanticExpansionAttemptTests: XCTestCase {
    func testSuccessfulAttemptPublishesOnceAndReturnsToIdle() {
        var workspace = AttemptProbeWorkspace()
        var sink = AttemptProbeSink()
        var attempt = makeAttempt()
        var identity: AttemptProbeIdentity?

        XCTAssertNil(attempt.begin(workspace: &workspace, sink: &sink))
        XCTAssertNil(
            attempt.enterRoot(
                AttemptProbeView.self,
                workspace: &workspace,
                identity: &identity
            )
        )
        XCTAssertNil(
            attempt.enterDeclarationRole(
                AttemptProbeView.self,
                workspace: &workspace,
                identity: &identity
            )
        )
        XCTAssertNotNil(identity)
        XCTAssertNil(
            attempt.stageStructuralOccurrence(
                identity: identity!,
                workspace: &workspace,
                sink: &sink
            )
        )
        XCTAssertNil(attempt.reserveBodyEvaluation())
        XCTAssertNil(
            attempt.stageSemanticOccurrence(
                identity: identity!,
                payload: AttemptProbePrimitive(),
                workspace: &workspace,
                sink: &sink
            )
        )
        XCTAssertNil(
            attempt.stageActionOccurrence(
                identity: identity!,
                action: AttemptProbeAction.primary,
                workspace: &workspace,
                sink: &sink
            )
        )
        XCTAssertNil(
            attempt.stageModifierApplication(
                identity: identity!,
                payload: AttemptProbeModifier(),
                chainIndex: 0,
                workspace: &workspace,
                sink: &sink
            )
        )
        XCTAssertNil(attempt.leavePathComponent(workspace: &workspace))
        XCTAssertNil(attempt.leavePathComponent(workspace: &workspace))

        let expectedSummary = SemanticExpansionSummary(
            semanticNodeCount: 2,
            bodyEvaluationCount: 1,
            modifierApplicationCount: 1,
            actionOccurrenceCount: 1,
            maximumObservedDepth: 2
        )
        XCTAssertEqual(
            attempt.succeed(workspace: &workspace, sink: &sink),
            .success(expectedSummary)
        )
        XCTAssertEqual(
            workspace.events, [.begin, .enter, .enter, .leave, .leave, .complete, .reset])
        XCTAssertEqual(
            sink.events,
            [.begin, .structural, .semantic, .action, .modifier, .publish, .reset]
        )
        XCTAssertEqual(sink.publishedSummaries, [expectedSummary])
        XCTAssertFalse(workspace.isExpanding)
    }

    func testDepthRefusalPrecedesWorkspaceEntryAndPreservesFirstFailure() {
        var workspace = AttemptProbeWorkspace()
        var sink = AttemptProbeSink()
        var attempt = makeAttempt(maximumDepth: 1)
        var identity: AttemptProbeIdentity?

        XCTAssertNil(attempt.begin(workspace: &workspace, sink: &sink))
        XCTAssertNil(
            attempt.enterRoot(
                AttemptProbeView.self,
                workspace: &workspace,
                identity: &identity
            )
        )
        XCTAssertEqual(
            attempt.enterDeclarationRole(
                AttemptProbeView.self,
                workspace: &workspace,
                identity: &identity
            ),
            .capacityExhausted
        )
        workspace.nextEntryError = .invalidIdentity
        XCTAssertEqual(
            attempt.enterDeclarationRole(
                AttemptProbeView.self,
                workspace: &workspace,
                identity: &identity
            ),
            .capacityExhausted
        )
        XCTAssertEqual(workspace.events, [.begin, .enter])

        XCTAssertEqual(
            attempt.fail(.invariantViolation, workspace: &workspace, sink: &sink),
            .capacityExhausted
        )
        XCTAssertEqual(workspace.events.suffix(2), [.discard, .reset])
        XCTAssertEqual(sink.events, [.begin, .discard, .reset])
        XCTAssertTrue(sink.publishedSummaries.isEmpty)
    }

    func testIdentityFailurePrecedesOperationAndStorageReservation() {
        var workspace = AttemptProbeWorkspace(nextEntryError: .invalidIdentity)
        var sink = AttemptProbeSink(maximumStructuralOccurrences: 0)
        var attempt = makeAttempt(maximumDepth: 1)
        var identity: AttemptProbeIdentity?

        XCTAssertNil(attempt.begin(workspace: &workspace, sink: &sink))
        XCTAssertEqual(
            attempt.enterRoot(
                AttemptProbeView.self,
                workspace: &workspace,
                identity: &identity
            ),
            .invalidIdentity
        )
        XCTAssertEqual(
            attempt.stageStructuralOccurrence(
                identity: AttemptProbeIdentity(rawValue: 0),
                workspace: &workspace,
                sink: &sink
            ),
            .invalidIdentity
        )
        XCTAssertEqual(sink.events, [.begin])

        XCTAssertEqual(
            attempt.fail(.capacityExhausted, workspace: &workspace, sink: &sink),
            .invalidIdentity
        )
        XCTAssertTrue(sink.publishedSummaries.isEmpty)
    }

    func testDeclaredOperationLimitPrecedesSinkStorageAndHook() {
        var workspace = AttemptProbeWorkspace()
        var sink = AttemptProbeSink(maximumSemanticOccurrences: 0)
        var attempt = makeAttempt(maximumSemanticNodes: 1)
        let identity = AttemptProbeIdentity(rawValue: 1)

        XCTAssertNil(attempt.begin(workspace: &workspace, sink: &sink))
        XCTAssertEqual(
            attempt.stageSemanticOccurrence(
                identity: identity,
                payload: AttemptProbePrimitive(),
                workspace: &workspace,
                sink: &sink
            ),
            .capacityExhausted
        )
        XCTAssertEqual(sink.events, [.begin])
        XCTAssertEqual(
            attempt.stageSemanticOccurrence(
                identity: identity,
                payload: AttemptProbePrimitive(),
                workspace: &workspace,
                sink: &sink
            ),
            .capacityExhausted
        )
        XCTAssertEqual(attempt.semanticNodeCount, 1)

        XCTAssertEqual(
            attempt.fail(.invariantViolation, workspace: &workspace, sink: &sink),
            .capacityExhausted
        )
        XCTAssertTrue(sink.publishedSummaries.isEmpty)
    }

    func testAdvertisedStorageRefusalIsInvariantViolation() {
        var workspace = AttemptProbeWorkspace()
        var sink = AttemptProbeSink(acceptSemantic: false)
        var attempt = makeAttempt()
        let identity = AttemptProbeIdentity(rawValue: 1)

        XCTAssertNil(attempt.begin(workspace: &workspace, sink: &sink))
        XCTAssertEqual(
            attempt.stageSemanticOccurrence(
                identity: identity,
                payload: AttemptProbePrimitive(),
                workspace: &workspace,
                sink: &sink
            ),
            .invariantViolation
        )
        XCTAssertEqual(sink.events, [.begin, .semantic])
        XCTAssertEqual(
            attempt.fail(.capacityExhausted, workspace: &workspace, sink: &sink),
            .invariantViolation
        )
        XCTAssertEqual(sink.events.suffix(2), [.discard, .reset])
        XCTAssertTrue(sink.publishedSummaries.isEmpty)
    }

    func testEveryCounterRefusesBeforeWrapping() {
        var attempt = makeAttempt(maximumBodyEvaluations: .max)

        for _ in 0 ..< UInt32(UInt16.max) {
            XCTAssertNil(attempt.reserveBodyEvaluation())
        }
        XCTAssertEqual(attempt.bodyEvaluationCount, UInt16.max)
        XCTAssertEqual(attempt.reserveBodyEvaluation(), .capacityExhausted)
        XCTAssertEqual(attempt.bodyEvaluationCount, UInt16.max)
    }

    func testBeginAndPublishFailuresDiscardAndResetWithoutPublication() {
        var beginWorkspace = AttemptProbeWorkspace()
        var rejectingBeginSink = AttemptProbeSink(acceptBegin: false)
        var beginAttempt = makeAttempt()

        XCTAssertEqual(
            beginAttempt.begin(workspace: &beginWorkspace, sink: &rejectingBeginSink),
            .invariantViolation
        )
        XCTAssertEqual(beginWorkspace.events, [.begin, .discard, .reset])
        XCTAssertEqual(rejectingBeginSink.events, [.begin])

        var publishWorkspace = AttemptProbeWorkspace()
        var rejectingPublishSink = AttemptProbeSink(acceptPublish: false)
        var publishAttempt = makeAttempt(maximumDepth: 1)
        var identity: AttemptProbeIdentity?
        XCTAssertNil(
            publishAttempt.begin(workspace: &publishWorkspace, sink: &rejectingPublishSink))
        XCTAssertNil(
            publishAttempt.enterRoot(
                AttemptProbeView.self,
                workspace: &publishWorkspace,
                identity: &identity
            )
        )
        XCTAssertNil(publishAttempt.leavePathComponent(workspace: &publishWorkspace))

        XCTAssertEqual(
            publishAttempt.succeed(workspace: &publishWorkspace, sink: &rejectingPublishSink),
            .failure(.invariantViolation)
        )
        XCTAssertEqual(
            publishWorkspace.events,
            [.begin, .enter, .leave, .complete, .discard, .reset]
        )
        XCTAssertEqual(rejectingPublishSink.events, [.begin, .publish, .discard, .reset])
        XCTAssertTrue(rejectingPublishSink.publishedSummaries.isEmpty)
    }

    func testFailedWorkspaceCanBeReusedByALaterValidAttempt() {
        var workspace = AttemptProbeWorkspace()
        var sink = AttemptProbeSink()
        var failedAttempt = makeAttempt(maximumDepth: 1)
        var identity: AttemptProbeIdentity?

        XCTAssertNil(failedAttempt.begin(workspace: &workspace, sink: &sink))
        XCTAssertNil(
            failedAttempt.enterRoot(
                AttemptProbeView.self,
                workspace: &workspace,
                identity: &identity
            )
        )
        XCTAssertEqual(
            failedAttempt.enterDeclarationRole(
                AttemptProbeView.self,
                workspace: &workspace,
                identity: &identity
            ),
            .capacityExhausted
        )
        XCTAssertEqual(
            failedAttempt.fail(.capacityExhausted, workspace: &workspace, sink: &sink),
            .capacityExhausted
        )

        workspace.events.removeAll(keepingCapacity: true)
        sink.events.removeAll(keepingCapacity: true)
        var validAttempt = makeAttempt(maximumDepth: 1)
        XCTAssertNil(validAttempt.begin(workspace: &workspace, sink: &sink))
        XCTAssertNil(
            validAttempt.enterRoot(
                AttemptProbeView.self,
                workspace: &workspace,
                identity: &identity
            )
        )
        XCTAssertNil(validAttempt.leavePathComponent(workspace: &workspace))

        XCTAssertEqual(
            validAttempt.succeed(workspace: &workspace, sink: &sink),
            .success(
                SemanticExpansionSummary(
                    semanticNodeCount: 0,
                    bodyEvaluationCount: 0,
                    modifierApplicationCount: 0,
                    actionOccurrenceCount: 0,
                    maximumObservedDepth: 1
                )
            )
        )
        XCTAssertEqual(workspace.events, [.begin, .enter, .leave, .complete, .reset])
        XCTAssertEqual(sink.events, [.begin, .publish, .reset])
    }

    func testGenericEntryExpandsAnEmptyRootAndPublishesOnce() {
        guard let limits = makeLimits() else {
            return XCTFail("valid limits must construct")
        }
        var workspace = AttemptProbeWorkspace()
        var sink = AttemptProbeSink()

        XCTAssertEqual(
            expandSemanticTree(
                ViewBuilder.buildBlock(),
                limits: limits,
                workspace: &workspace,
                sink: &sink
            ),
            .success(
                SemanticExpansionSummary(
                    semanticNodeCount: 0,
                    bodyEvaluationCount: 0,
                    modifierApplicationCount: 0,
                    actionOccurrenceCount: 0,
                    maximumObservedDepth: 2
                )
            )
        )
        XCTAssertEqual(
            workspace.events,
            [.begin, .enter, .enter, .leave, .leave, .complete, .reset]
        )
        XCTAssertEqual(sink.events, [.begin, .structural, .publish, .reset])
        XCTAssertFalse(workspace.isExpanding)
        XCTAssertEqual(sink.publishedSummaries.count, 1)
    }

    private func makeAttempt(
        maximumDepth: UInt16 = 2,
        maximumSemanticNodes: UInt16 = 2,
        maximumBodyEvaluations: UInt16 = 1,
        maximumModifierApplications: UInt16 = 1,
        maximumActionOccurrences: UInt16 = 1
    ) -> SemanticExpansionAttempt {
        SemanticExpansionAttempt(
            limits: SemanticExpansionLimits(
                maximumDepth: maximumDepth,
                maximumSemanticNodes: maximumSemanticNodes,
                maximumBodyEvaluations: maximumBodyEvaluations,
                maximumModifierApplications: maximumModifierApplications,
                maximumActionOccurrences: maximumActionOccurrences
            )!
        )
    }

    private func makeLimits() -> SemanticExpansionLimits? {
        SemanticExpansionLimits(
            maximumDepth: 2,
            maximumSemanticNodes: 1,
            maximumBodyEvaluations: 1,
            maximumModifierApplications: 1,
            maximumActionOccurrences: 1
        )
    }
}

private struct AttemptProbeIdentity: Equatable {
    let rawValue: UInt16
}

private struct AttemptProbeView: View {
    var body: Never {
        fatalError("the T2.2 attempt fixture does not traverse a body")
    }
}

private struct AttemptProbePrimitive: _GiftUISemanticPrimitivePayload {}
private struct AttemptProbeModifier: _GiftUISemanticModifierPayload {}

private enum AttemptProbeAction: UInt16, GiftUIAction {
    case primary = 1
}

private enum AttemptProbeEvent: Equatable {
    case begin
    case enter
    case leave
    case structural
    case semantic
    case modifier
    case action
    case complete
    case publish
    case discard
    case reset
}

private struct AttemptProbeWorkspace: SemanticExpansionWorkspace {
    let maximumPathComponents: UInt16
    let maximumIdentities: UInt16
    var isExpanding = false
    var nextEntryError: SemanticExpansionError?
    var producesIdentity: Bool
    var events: [AttemptProbeEvent] = []
    private var nextIdentity: UInt16 = 0

    init(
        maximumPathComponents: UInt16 = 8,
        maximumIdentities: UInt16 = 8,
        nextEntryError: SemanticExpansionError? = nil,
        producesIdentity: Bool = true
    ) {
        self.maximumPathComponents = maximumPathComponents
        self.maximumIdentities = maximumIdentities
        self.nextEntryError = nextEntryError
        self.producesIdentity = producesIdentity
    }

    mutating func beginExpansion() -> Bool {
        events.append(.begin)
        guard !isExpanding else { return false }
        isExpanding = true
        return true
    }

    mutating func enterRoot<Declaration: View>(
        _ declaration: Declaration.Type,
        identity: inout AttemptProbeIdentity?
    ) -> SemanticExpansionError? {
        enter(identity: &identity)
    }

    mutating func enterCustomBody<Declaration: View>(
        _ declaration: Declaration.Type,
        identity: inout AttemptProbeIdentity?
    ) -> SemanticExpansionError? {
        enter(identity: &identity)
    }

    mutating func enterFixedChild(
        _ index: UInt8,
        identity: inout AttemptProbeIdentity?
    ) -> SemanticExpansionError? {
        enter(identity: &identity)
    }

    mutating func enterConditionalBranch(
        _ index: UInt8,
        identity: inout AttemptProbeIdentity?
    ) -> SemanticExpansionError? {
        enter(identity: &identity)
    }

    mutating func enterOptionalPresence(
        identity: inout AttemptProbeIdentity?
    ) -> SemanticExpansionError? {
        enter(identity: &identity)
    }

    mutating func enterDeclarationRole<Declaration>(
        _ declaration: Declaration.Type,
        identity: inout AttemptProbeIdentity?
    ) -> SemanticExpansionError? {
        enter(identity: &identity)
    }

    mutating func leavePathComponent() {
        events.append(.leave)
    }

    mutating func completeExpansion() {
        events.append(.complete)
    }

    mutating func discardExpansion() {
        events.append(.discard)
    }

    mutating func resetExpansion() {
        events.append(.reset)
        isExpanding = false
        nextIdentity = 0
    }

    private mutating func enter(
        identity: inout AttemptProbeIdentity?
    ) -> SemanticExpansionError? {
        events.append(.enter)
        if let nextEntryError {
            self.nextEntryError = nil
            return nextEntryError
        }
        if producesIdentity {
            identity = AttemptProbeIdentity(rawValue: nextIdentity)
            nextIdentity &+= 1
        }
        return nil
    }
}

private struct AttemptProbeSink: SemanticExpansionSink {
    let maximumStructuralOccurrences: UInt16
    let maximumSemanticOccurrences: UInt16
    let maximumModifierApplications: UInt16
    let maximumActionOccurrences: UInt16
    let acceptBegin: Bool
    let acceptSemantic: Bool
    let acceptPublish: Bool
    var events: [AttemptProbeEvent] = []
    var publishedSummaries: [SemanticExpansionSummary] = []

    init(
        maximumStructuralOccurrences: UInt16 = 8,
        maximumSemanticOccurrences: UInt16 = 8,
        maximumModifierApplications: UInt16 = 8,
        maximumActionOccurrences: UInt16 = 8,
        acceptBegin: Bool = true,
        acceptSemantic: Bool = true,
        acceptPublish: Bool = true
    ) {
        self.maximumStructuralOccurrences = maximumStructuralOccurrences
        self.maximumSemanticOccurrences = maximumSemanticOccurrences
        self.maximumModifierApplications = maximumModifierApplications
        self.maximumActionOccurrences = maximumActionOccurrences
        self.acceptBegin = acceptBegin
        self.acceptSemantic = acceptSemantic
        self.acceptPublish = acceptPublish
    }

    mutating func beginExpansion() -> Bool {
        events.append(.begin)
        return acceptBegin
    }

    mutating func stageStructuralOccurrence(
        identity: borrowing AttemptProbeIdentity
    ) -> Bool {
        events.append(.structural)
        return true
    }

    mutating func stageSemanticOccurrence<Payload: _GiftUISemanticPrimitivePayload>(
        identity: borrowing AttemptProbeIdentity,
        payload: borrowing Payload
    ) -> Bool {
        events.append(.semantic)
        return acceptSemantic
    }

    mutating func stageModifierApplication<Payload: _GiftUISemanticModifierPayload>(
        identity: borrowing AttemptProbeIdentity,
        payload: borrowing Payload,
        chainIndex: UInt16
    ) -> Bool {
        events.append(.modifier)
        return true
    }

    mutating func stageActionOccurrence<Action: GiftUIAction>(
        identity: borrowing AttemptProbeIdentity,
        action: borrowing Action
    ) -> Bool {
        events.append(.action)
        return true
    }

    mutating func publishExpansion(_ summary: SemanticExpansionSummary) -> Bool {
        events.append(.publish)
        guard acceptPublish else { return false }
        publishedSummaries.append(summary)
        return true
    }

    mutating func discardExpansion() {
        events.append(.discard)
        publishedSummaries.removeAll(keepingCapacity: true)
    }

    mutating func resetExpansion() {
        events.append(.reset)
    }
}
