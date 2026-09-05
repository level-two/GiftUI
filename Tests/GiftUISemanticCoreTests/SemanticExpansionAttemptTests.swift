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

    func testEveryCounterAndDepthRefuseBeforeWrapping() {
        let identity = AttemptProbeIdentity(rawValue: 0)

        var bodyAttempt = makeAttempt(maximumBodyEvaluations: .max)
        for _ in 0 ..< UInt32(UInt16.max) {
            XCTAssertNil(bodyAttempt.reserveBodyEvaluation())
        }
        XCTAssertEqual(bodyAttempt.reserveBodyEvaluation(), .capacityExhausted)
        XCTAssertEqual(bodyAttempt.bodyEvaluationCount, UInt16.max)

        var semanticWorkspace = AttemptProbeWorkspace(recordsEvents: false)
        var semanticSink = AttemptProbeSink(
            maximumSemanticOccurrences: .max,
            recordsEvents: false
        )
        var semanticAttempt = makeAttempt(maximumSemanticNodes: .max)
        XCTAssertNil(semanticAttempt.begin(workspace: &semanticWorkspace, sink: &semanticSink))
        for _ in 0 ..< UInt32(UInt16.max) {
            XCTAssertNil(
                semanticAttempt.stageSemanticOccurrence(
                    identity: identity,
                    payload: AttemptProbePrimitive(),
                    workspace: &semanticWorkspace,
                    sink: &semanticSink
                )
            )
        }
        XCTAssertEqual(
            semanticAttempt.stageSemanticOccurrence(
                identity: identity,
                payload: AttemptProbePrimitive(),
                workspace: &semanticWorkspace,
                sink: &semanticSink
            ),
            .capacityExhausted
        )
        XCTAssertEqual(semanticAttempt.semanticNodeCount, UInt16.max)

        var modifierWorkspace = AttemptProbeWorkspace(recordsEvents: false)
        var modifierSink = AttemptProbeSink(
            maximumModifierApplications: .max,
            recordsEvents: false
        )
        var modifierAttempt = makeAttempt(maximumModifierApplications: .max)
        XCTAssertNil(modifierAttempt.begin(workspace: &modifierWorkspace, sink: &modifierSink))
        for _ in 0 ..< UInt32(UInt16.max) {
            XCTAssertNil(
                modifierAttempt.stageModifierApplication(
                    identity: identity,
                    payload: AttemptProbeModifier(),
                    chainIndex: 0,
                    workspace: &modifierWorkspace,
                    sink: &modifierSink
                )
            )
        }
        XCTAssertEqual(
            modifierAttempt.stageModifierApplication(
                identity: identity,
                payload: AttemptProbeModifier(),
                chainIndex: 0,
                workspace: &modifierWorkspace,
                sink: &modifierSink
            ),
            .capacityExhausted
        )
        XCTAssertEqual(modifierAttempt.modifierApplicationCount, UInt16.max)

        var actionWorkspace = AttemptProbeWorkspace(recordsEvents: false)
        var actionSink = AttemptProbeSink(
            maximumSemanticOccurrences: .max,
            maximumActionOccurrences: .max,
            recordsEvents: false
        )
        var actionAttempt = makeAttempt(
            maximumSemanticNodes: .max,
            maximumActionOccurrences: .max
        )
        XCTAssertNil(actionAttempt.begin(workspace: &actionWorkspace, sink: &actionSink))
        for _ in 0 ..< UInt32(UInt16.max) {
            XCTAssertNil(
                actionAttempt.stageActionOccurrence(
                    identity: identity,
                    action: AttemptProbeAction.primary,
                    workspace: &actionWorkspace,
                    sink: &actionSink
                )
            )
        }
        XCTAssertEqual(
            actionAttempt.stageActionOccurrence(
                identity: identity,
                action: AttemptProbeAction.primary,
                workspace: &actionWorkspace,
                sink: &actionSink
            ),
            .capacityExhausted
        )
        XCTAssertEqual(actionAttempt.semanticNodeCount, UInt16.max)
        XCTAssertEqual(actionAttempt.actionOccurrenceCount, UInt16.max)

        var depthWorkspace = AttemptProbeWorkspace(
            maximumPathComponents: .max,
            maximumIdentities: .max,
            recordsEvents: false
        )
        var depthSink = AttemptProbeSink(recordsEvents: false)
        var depthAttempt = makeAttempt(maximumDepth: .max)
        var depthIdentity: AttemptProbeIdentity?
        XCTAssertNil(depthAttempt.begin(workspace: &depthWorkspace, sink: &depthSink))
        for _ in 0 ..< UInt32(UInt16.max) {
            XCTAssertNil(
                depthAttempt.enterFixedChild(
                    0,
                    workspace: &depthWorkspace,
                    identity: &depthIdentity
                )
            )
        }
        XCTAssertEqual(
            depthAttempt.enterFixedChild(
                0,
                workspace: &depthWorkspace,
                identity: &depthIdentity
            ),
            .capacityExhausted
        )
        XCTAssertEqual(depthAttempt.maximumObservedDepth, UInt16.max)
    }

    func testEachDeclaredLimitAllowsExactBoundaryThenRejectsOneOver() {
        let identity = AttemptProbeIdentity(rawValue: 0)

        var depthWorkspace = AttemptProbeWorkspace()
        var depthSink = AttemptProbeSink()
        var depthAttempt = makeAttempt(maximumDepth: 1)
        var enteredIdentity: AttemptProbeIdentity?
        XCTAssertNil(depthAttempt.begin(workspace: &depthWorkspace, sink: &depthSink))
        XCTAssertNil(
            depthAttempt.enterRoot(
                AttemptProbeView.self,
                workspace: &depthWorkspace,
                identity: &enteredIdentity
            )
        )
        XCTAssertEqual(
            depthAttempt.enterDeclarationRole(
                AttemptProbeView.self,
                workspace: &depthWorkspace,
                identity: &enteredIdentity
            ),
            .capacityExhausted
        )

        var semanticWorkspace = AttemptProbeWorkspace()
        var semanticSink = AttemptProbeSink()
        var semanticAttempt = makeAttempt(maximumSemanticNodes: 1)
        XCTAssertNil(semanticAttempt.begin(workspace: &semanticWorkspace, sink: &semanticSink))
        XCTAssertNil(
            semanticAttempt.stageSemanticOccurrence(
                identity: identity,
                payload: AttemptProbePrimitive(),
                workspace: &semanticWorkspace,
                sink: &semanticSink
            )
        )
        XCTAssertEqual(
            semanticAttempt.stageSemanticOccurrence(
                identity: identity,
                payload: AttemptProbePrimitive(),
                workspace: &semanticWorkspace,
                sink: &semanticSink
            ),
            .capacityExhausted
        )

        var bodyAttempt = makeAttempt(maximumBodyEvaluations: 1)
        XCTAssertNil(bodyAttempt.reserveBodyEvaluation())
        XCTAssertEqual(bodyAttempt.reserveBodyEvaluation(), .capacityExhausted)

        var modifierWorkspace = AttemptProbeWorkspace()
        var modifierSink = AttemptProbeSink()
        var modifierAttempt = makeAttempt(maximumModifierApplications: 1)
        XCTAssertNil(modifierAttempt.begin(workspace: &modifierWorkspace, sink: &modifierSink))
        XCTAssertNil(
            modifierAttempt.stageModifierApplication(
                identity: identity,
                payload: AttemptProbeModifier(),
                chainIndex: 0,
                workspace: &modifierWorkspace,
                sink: &modifierSink
            )
        )
        XCTAssertEqual(
            modifierAttempt.stageModifierApplication(
                identity: identity,
                payload: AttemptProbeModifier(),
                chainIndex: 1,
                workspace: &modifierWorkspace,
                sink: &modifierSink
            ),
            .capacityExhausted
        )

        var actionWorkspace = AttemptProbeWorkspace()
        var actionSink = AttemptProbeSink()
        var actionAttempt = makeAttempt(maximumSemanticNodes: 2, maximumActionOccurrences: 1)
        XCTAssertNil(actionAttempt.begin(workspace: &actionWorkspace, sink: &actionSink))
        XCTAssertNil(
            actionAttempt.stageActionOccurrence(
                identity: identity,
                action: AttemptProbeAction.primary,
                workspace: &actionWorkspace,
                sink: &actionSink
            )
        )
        XCTAssertEqual(
            actionAttempt.stageActionOccurrence(
                identity: identity,
                action: AttemptProbeAction.primary,
                workspace: &actionWorkspace,
                sink: &actionSink
            ),
            .capacityExhausted
        )
        XCTAssertEqual(actionAttempt.actionOccurrenceCount, 1)
    }

    func testEveryCallerOwnedCapacityRejectsBeforeItsHook() {
        let identity = AttemptProbeIdentity(rawValue: 0)

        var pathWorkspace = AttemptProbeWorkspace(maximumPathComponents: 0)
        var pathSink = AttemptProbeSink()
        var pathAttempt = makeAttempt()
        var enteredIdentity: AttemptProbeIdentity?
        XCTAssertNil(pathAttempt.begin(workspace: &pathWorkspace, sink: &pathSink))
        XCTAssertEqual(
            pathAttempt.enterRoot(
                AttemptProbeView.self,
                workspace: &pathWorkspace,
                identity: &enteredIdentity
            ),
            .capacityExhausted
        )
        XCTAssertEqual(pathWorkspace.events, [.begin])

        var identityWorkspace = AttemptProbeWorkspace(maximumIdentities: 0)
        var identitySink = AttemptProbeSink()
        var identityAttempt = makeAttempt()
        XCTAssertNil(identityAttempt.begin(workspace: &identityWorkspace, sink: &identitySink))
        XCTAssertEqual(
            identityAttempt.enterRoot(
                AttemptProbeView.self,
                workspace: &identityWorkspace,
                identity: &enteredIdentity
            ),
            .capacityExhausted
        )
        XCTAssertEqual(identityWorkspace.events, [.begin, .enter])

        assertSinkCapacityFailure(AttemptProbeSink(maximumStructuralOccurrences: 0)) {
            attempt, workspace, sink in
            attempt.stageStructuralOccurrence(
                identity: identity,
                workspace: &workspace,
                sink: &sink
            )
        }
        assertSinkCapacityFailure(AttemptProbeSink(maximumBodyEvaluations: 0)) {
            attempt, workspace, sink in
            attempt.stageBodyEvaluation(identity: identity, workspace: &workspace, sink: &sink)
        }
        assertSinkCapacityFailure(AttemptProbeSink(maximumSemanticOccurrences: 0)) {
            attempt, workspace, sink in
            attempt.stageSemanticOccurrence(
                identity: identity,
                payload: AttemptProbePrimitive(),
                workspace: &workspace,
                sink: &sink
            )
        }
        assertSinkCapacityFailure(AttemptProbeSink(maximumModifierApplications: 0)) {
            attempt, workspace, sink in
            attempt.stageModifierApplication(
                identity: identity,
                payload: AttemptProbeModifier(),
                chainIndex: 0,
                workspace: &workspace,
                sink: &sink
            )
        }
        assertSinkCapacityFailure(AttemptProbeSink(maximumActionOccurrences: 0)) {
            attempt, workspace, sink in
            attempt.stageActionOccurrence(
                identity: identity,
                action: AttemptProbeAction.primary,
                workspace: &workspace,
                sink: &sink
            )
        }
    }

    func testCallerOwnedCapacitiesAllowExactUseAndRejectOneOver() {
        let identity = AttemptProbeIdentity(rawValue: 0)
        var exactWorkspace = AttemptProbeWorkspace(
            maximumPathComponents: 2,
            maximumIdentities: 2
        )
        var exactSink = AttemptProbeSink(
            maximumStructuralOccurrences: 1,
            maximumBodyEvaluations: 1,
            maximumSemanticOccurrences: 2,
            maximumModifierApplications: 1,
            maximumActionOccurrences: 1
        )
        var exactAttempt = makeAttempt(
            maximumDepth: 2,
            maximumSemanticNodes: 2,
            maximumBodyEvaluations: 1,
            maximumModifierApplications: 1,
            maximumActionOccurrences: 1
        )
        var enteredIdentity: AttemptProbeIdentity?
        XCTAssertNil(exactAttempt.begin(workspace: &exactWorkspace, sink: &exactSink))
        XCTAssertNil(
            exactAttempt.enterRoot(
                AttemptProbeView.self,
                workspace: &exactWorkspace,
                identity: &enteredIdentity
            )
        )
        XCTAssertNil(
            exactAttempt.enterDeclarationRole(
                AttemptProbeView.self,
                workspace: &exactWorkspace,
                identity: &enteredIdentity
            )
        )
        XCTAssertNil(
            exactAttempt.stageStructuralOccurrence(
                identity: identity,
                workspace: &exactWorkspace,
                sink: &exactSink
            )
        )
        XCTAssertNil(
            exactAttempt.stageBodyEvaluation(
                identity: identity,
                workspace: &exactWorkspace,
                sink: &exactSink
            )
        )
        XCTAssertNil(
            exactAttempt.stageSemanticOccurrence(
                identity: identity,
                payload: AttemptProbePrimitive(),
                workspace: &exactWorkspace,
                sink: &exactSink
            )
        )
        XCTAssertNil(
            exactAttempt.stageActionOccurrence(
                identity: identity,
                action: AttemptProbeAction.primary,
                workspace: &exactWorkspace,
                sink: &exactSink
            )
        )
        XCTAssertNil(
            exactAttempt.stageModifierApplication(
                identity: identity,
                payload: AttemptProbeModifier(),
                chainIndex: 0,
                workspace: &exactWorkspace,
                sink: &exactSink
            )
        )
        XCTAssertNil(exactAttempt.leavePathComponent(workspace: &exactWorkspace))
        XCTAssertNil(exactAttempt.leavePathComponent(workspace: &exactWorkspace))
        XCTAssertEqual(
            exactAttempt.succeed(workspace: &exactWorkspace, sink: &exactSink),
            .success(
                SemanticExpansionSummary(
                    semanticNodeCount: 2,
                    bodyEvaluationCount: 1,
                    modifierApplicationCount: 1,
                    actionOccurrenceCount: 1,
                    maximumObservedDepth: 2
                )
            )
        )

        var pathWorkspace = AttemptProbeWorkspace(maximumPathComponents: 1)
        var pathSink = AttemptProbeSink()
        var pathAttempt = makeAttempt(maximumDepth: 2)
        XCTAssertNil(pathAttempt.begin(workspace: &pathWorkspace, sink: &pathSink))
        XCTAssertNil(
            pathAttempt.enterRoot(
                AttemptProbeView.self,
                workspace: &pathWorkspace,
                identity: &enteredIdentity
            )
        )
        XCTAssertEqual(
            pathAttempt.enterDeclarationRole(
                AttemptProbeView.self,
                workspace: &pathWorkspace,
                identity: &enteredIdentity
            ),
            .capacityExhausted
        )

        var identityWorkspace = AttemptProbeWorkspace(
            maximumPathComponents: 2,
            maximumIdentities: 1
        )
        var identitySink = AttemptProbeSink()
        var identityAttempt = makeAttempt(maximumDepth: 2)
        XCTAssertNil(identityAttempt.begin(workspace: &identityWorkspace, sink: &identitySink))
        XCTAssertNil(
            identityAttempt.enterRoot(
                AttemptProbeView.self,
                workspace: &identityWorkspace,
                identity: &enteredIdentity
            )
        )
        XCTAssertEqual(
            identityAttempt.enterDeclarationRole(
                AttemptProbeView.self,
                workspace: &identityWorkspace,
                identity: &enteredIdentity
            ),
            .capacityExhausted
        )

        assertSinkOneOverFailure(AttemptProbeSink(maximumStructuralOccurrences: 1)) {
            attempt, workspace, sink in
            attempt.stageStructuralOccurrence(
                identity: identity,
                workspace: &workspace,
                sink: &sink
            )
        }
        assertSinkOneOverFailure(AttemptProbeSink(maximumBodyEvaluations: 1)) {
            attempt, workspace, sink in
            attempt.stageBodyEvaluation(identity: identity, workspace: &workspace, sink: &sink)
        }
        assertSinkOneOverFailure(AttemptProbeSink(maximumSemanticOccurrences: 1)) {
            attempt, workspace, sink in
            attempt.stageSemanticOccurrence(
                identity: identity,
                payload: AttemptProbePrimitive(),
                workspace: &workspace,
                sink: &sink
            )
        }
        assertSinkOneOverFailure(AttemptProbeSink(maximumModifierApplications: 1)) {
            attempt, workspace, sink in
            attempt.stageModifierApplication(
                identity: identity,
                payload: AttemptProbeModifier(),
                chainIndex: 0,
                workspace: &workspace,
                sink: &sink
            )
        }
        assertSinkOneOverFailure(AttemptProbeSink(maximumActionOccurrences: 1)) {
            attempt, workspace, sink in
            attempt.stageActionOccurrence(
                identity: identity,
                action: AttemptProbeAction.primary,
                workspace: &workspace,
                sink: &sink
            )
        }
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

    private func assertSinkCapacityFailure(
        _ initialSink: AttemptProbeSink,
        operation: (
            inout SemanticExpansionAttempt,
            inout AttemptProbeWorkspace,
            inout AttemptProbeSink
        ) -> SemanticExpansionError?,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        var workspace = AttemptProbeWorkspace()
        var sink = initialSink
        var attempt = makeAttempt(maximumSemanticNodes: 2)
        XCTAssertNil(attempt.begin(workspace: &workspace, sink: &sink), file: file, line: line)
        XCTAssertEqual(
            operation(&attempt, &workspace, &sink),
            .capacityExhausted,
            file: file,
            line: line
        )
        XCTAssertEqual(
            attempt.fail(.invariantViolation, workspace: &workspace, sink: &sink),
            .capacityExhausted,
            file: file,
            line: line
        )
        XCTAssertTrue(sink.publishedSummaries.isEmpty, file: file, line: line)
        XCTAssertFalse(workspace.isExpanding, file: file, line: line)
    }

    private func assertSinkOneOverFailure(
        _ initialSink: AttemptProbeSink,
        operation: (
            inout SemanticExpansionAttempt,
            inout AttemptProbeWorkspace,
            inout AttemptProbeSink
        ) -> SemanticExpansionError?,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        var workspace = AttemptProbeWorkspace()
        var sink = initialSink
        var attempt = makeAttempt(
            maximumSemanticNodes: 2,
            maximumBodyEvaluations: 2,
            maximumModifierApplications: 2,
            maximumActionOccurrences: 2
        )
        XCTAssertNil(attempt.begin(workspace: &workspace, sink: &sink), file: file, line: line)
        XCTAssertNil(operation(&attempt, &workspace, &sink), file: file, line: line)
        XCTAssertEqual(
            operation(&attempt, &workspace, &sink),
            .capacityExhausted,
            file: file,
            line: line
        )
        XCTAssertEqual(
            attempt.fail(.invariantViolation, workspace: &workspace, sink: &sink),
            .capacityExhausted,
            file: file,
            line: line
        )
        XCTAssertTrue(sink.publishedSummaries.isEmpty, file: file, line: line)
        XCTAssertFalse(workspace.isExpanding, file: file, line: line)
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
    let recordsEvents: Bool
    var events: [AttemptProbeEvent] = []
    private var nextIdentity: UInt16 = 0

    init(
        maximumPathComponents: UInt16 = 8,
        maximumIdentities: UInt16 = 8,
        nextEntryError: SemanticExpansionError? = nil,
        producesIdentity: Bool = true,
        recordsEvents: Bool = true
    ) {
        self.maximumPathComponents = maximumPathComponents
        self.maximumIdentities = maximumIdentities
        self.nextEntryError = nextEntryError
        self.producesIdentity = producesIdentity
        self.recordsEvents = recordsEvents
    }

    mutating func beginExpansion() -> Bool {
        if recordsEvents { events.append(.begin) }
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
        if recordsEvents { events.append(.leave) }
    }

    mutating func completeExpansion() {
        if recordsEvents { events.append(.complete) }
    }

    mutating func discardExpansion() {
        if recordsEvents { events.append(.discard) }
    }

    mutating func resetExpansion() {
        if recordsEvents { events.append(.reset) }
        isExpanding = false
        nextIdentity = 0
    }

    private mutating func enter(
        identity: inout AttemptProbeIdentity?
    ) -> SemanticExpansionError? {
        if recordsEvents { events.append(.enter) }
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
    let maximumBodyEvaluations: UInt16
    let maximumSemanticOccurrences: UInt16
    let maximumModifierApplications: UInt16
    let maximumActionOccurrences: UInt16
    let acceptBegin: Bool
    let acceptSemantic: Bool
    let acceptPublish: Bool
    let recordsEvents: Bool
    var events: [AttemptProbeEvent] = []
    var publishedSummaries: [SemanticExpansionSummary] = []

    init(
        maximumStructuralOccurrences: UInt16 = 8,
        maximumBodyEvaluations: UInt16 = 8,
        maximumSemanticOccurrences: UInt16 = 8,
        maximumModifierApplications: UInt16 = 8,
        maximumActionOccurrences: UInt16 = 8,
        acceptBegin: Bool = true,
        acceptSemantic: Bool = true,
        acceptPublish: Bool = true,
        recordsEvents: Bool = true
    ) {
        self.maximumStructuralOccurrences = maximumStructuralOccurrences
        self.maximumBodyEvaluations = maximumBodyEvaluations
        self.maximumSemanticOccurrences = maximumSemanticOccurrences
        self.maximumModifierApplications = maximumModifierApplications
        self.maximumActionOccurrences = maximumActionOccurrences
        self.acceptBegin = acceptBegin
        self.acceptSemantic = acceptSemantic
        self.acceptPublish = acceptPublish
        self.recordsEvents = recordsEvents
    }

    mutating func beginExpansion() -> Bool {
        if recordsEvents { events.append(.begin) }
        return acceptBegin
    }

    mutating func stageStructuralOccurrence(
        identity: borrowing AttemptProbeIdentity
    ) -> Bool {
        if recordsEvents { events.append(.structural) }
        return true
    }

    mutating func stageBodyEvaluation(
        identity: borrowing AttemptProbeIdentity
    ) -> Bool {
        return true
    }

    mutating func stageSemanticOccurrence<Payload: _GiftUISemanticPrimitivePayload>(
        identity: borrowing AttemptProbeIdentity,
        payload: borrowing Payload
    ) -> Bool {
        if recordsEvents { events.append(.semantic) }
        return acceptSemantic
    }

    mutating func stageModifierApplication<Payload: _GiftUISemanticModifierPayload>(
        identity: borrowing AttemptProbeIdentity,
        payload: borrowing Payload,
        chainIndex: UInt16
    ) -> Bool {
        if recordsEvents { events.append(.modifier) }
        return true
    }

    mutating func stageActionOccurrence<Action: GiftUIAction>(
        identity: borrowing AttemptProbeIdentity,
        action: borrowing Action
    ) -> Bool {
        if recordsEvents { events.append(.action) }
        return true
    }

    mutating func publishExpansion(_ summary: SemanticExpansionSummary) -> Bool {
        if recordsEvents { events.append(.publish) }
        guard acceptPublish else { return false }
        publishedSummaries.append(summary)
        return true
    }

    mutating func discardExpansion() {
        if recordsEvents { events.append(.discard) }
        publishedSummaries.removeAll(keepingCapacity: true)
    }

    mutating func resetExpansion() {
        if recordsEvents { events.append(.reset) }
    }
}
