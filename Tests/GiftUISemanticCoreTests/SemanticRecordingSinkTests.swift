import GiftUI
import XCTest

@testable import GiftUISemanticCore

final class SemanticRecordingSinkTests: XCTestCase {
    func testEmptyRootPublishesOneExactStructuralEventAtDepthTwo() {
        var workspace = RecordingWorkspace()
        var sink = makeSink()
        let limits = makeLimits()

        let result = expandSemanticTree(
            ViewBuilder.buildBlock(),
            limits: limits,
            workspace: &workspace,
            sink: &sink
        )

        let role = SemanticRecordingRole(rawValue: 0)
        let identity = RecordingIdentity(
            components: [.root, .declarationRole(role)],
            declarationRole: role
        )
        let summary = SemanticExpansionSummary(
            semanticNodeCount: 0,
            bodyEvaluationCount: 0,
            modifierApplicationCount: 0,
            actionOccurrenceCount: 0,
            maximumObservedDepth: 2
        )
        XCTAssertEqual(result, .success(summary))
        XCTAssertEqual(
            sink.storage.committedEvents,
            [.enterStructuralOccurrence(path: identity, declarationRole: role)]
        )
        XCTAssertEqual(sink.storage.publishedSummaries, [summary])
        XCTAssertTrue(sink.storage.stagedEvents.isEmpty)
    }

    func testCustomBodyEventOccursImmediatelyBeforeReturnedDeclaration() {
        let counter = RecordingBodyCounter()
        var workspace = RecordingWorkspace()
        var sink = makeSink()

        let result = expandSemanticTree(
            RecordingCustom(bodyCounter: counter),
            limits: makeLimits(),
            workspace: &workspace,
            sink: &sink
        )

        XCTAssertEqual(counter.count, 1)
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
        XCTAssertEqual(
            sink.storage.committedEvents.map(\.kind),
            [.structural, .body, .structural, .semantic]
        )
        XCTAssertEqual(sink.storage.committedEvents[1].path.componentCount, 3)
        XCTAssertEqual(
            sink.storage.committedEvents[1].path.component(at: 2),
            .customBody
        )
        XCTAssertEqual(sink.storage.committedEvents[1].role.rawValue, 0)
        XCTAssertEqual(sink.storage.committedEvents[2].role.rawValue, 1)
    }

    func testActionAndModifiersPublishClosedOrderedVocabulary() {
        let root = RecordingModifier(
            content: RecordingModifier(
                content: RecordingActionPrimitive(action: .secondary)
            )
        )
        var workspace = RecordingWorkspace()
        var sink = makeSink()

        let result = expandSemanticTree(
            root,
            limits: makeLimits(),
            workspace: &workspace,
            sink: &sink
        )

        XCTAssertEqual(
            result,
            .success(
                SemanticExpansionSummary(
                    semanticNodeCount: 1,
                    bodyEvaluationCount: 0,
                    modifierApplicationCount: 2,
                    actionOccurrenceCount: 1,
                    maximumObservedDepth: 4
                )
            )
        )
        XCTAssertEqual(
            sink.storage.committedEvents.map(\.kind),
            [.structural, .structural, .structural, .semantic, .action, .modifier, .modifier]
        )
        XCTAssertEqual(
            sink.storage.committedEvents.compactMap(\.chainIndex),
            [0, 1]
        )
    }

    func testRefusedAttemptIsObservableButCannotReplaceCommittedRecording() {
        var workspace = RecordingWorkspace()
        var sink = makeSink()

        XCTAssertEqual(
            expandSemanticTree(
                ViewBuilder.buildBlock(),
                limits: makeLimits(),
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
        let committed = sink.storage.committedEvents
        sink.storage.refuseAttemptedEvent = 2
        sink.storage.attemptedEvents.removeAll(keepingCapacity: true)

        XCTAssertEqual(
            expandSemanticTree(
                RecordingCustom(bodyCounter: RecordingBodyCounter()),
                limits: makeLimits(),
                workspace: &workspace,
                sink: &sink
            ),
            .failure(.invariantViolation)
        )
        XCTAssertEqual(sink.storage.attemptedEvents.map(\.kind), [.structural, .body])
        XCTAssertEqual(sink.storage.committedEvents, committed)
        XCTAssertTrue(sink.storage.stagedEvents.isEmpty)
        XCTAssertEqual(sink.storage.discardCount, 1)
    }

    func testSummaryMismatchRefusesPublication() {
        let role = SemanticRecordingRole(rawValue: 7)
        let identity = RecordingIdentity(
            components: [.root, .declarationRole(role)],
            declarationRole: role
        )
        var sink = makeSink()

        XCTAssertTrue(sink.beginExpansion())
        XCTAssertTrue(sink.stageStructuralOccurrence(identity: identity))
        XCTAssertFalse(
            sink.publishExpansion(
                SemanticExpansionSummary(
                    semanticNodeCount: 0,
                    bodyEvaluationCount: 0,
                    modifierApplicationCount: 0,
                    actionOccurrenceCount: 0,
                    maximumObservedDepth: 1
                )
            )
        )
        XCTAssertTrue(sink.storage.committedEvents.isEmpty)
    }

    private func makeLimits() -> SemanticExpansionLimits {
        SemanticExpansionLimits(
            maximumDepth: 12,
            maximumSemanticNodes: 8,
            maximumBodyEvaluations: 8,
            maximumModifierApplications: 8,
            maximumActionOccurrences: 8
        )!
    }

    private func makeSink() -> SemanticRecordingSink<DynamicRecordingStorage> {
        SemanticRecordingSink(storage: DynamicRecordingStorage())
    }
}

private final class RecordingBodyCounter {
    var count = 0
}

private struct RecordingCustom: View {
    let bodyCounter: RecordingBodyCounter

    var body: some View {
        bodyCounter.count += 1
        return RecordingPrimitive()
    }
}

private struct RecordingPrimitive: View, _GiftUISemanticPrimitivePayload {
    var body: Never {
        fatalError("recording primitive body is unreachable")
    }

    func _giftUITraverse<Visitor: _GiftUISemanticTraversalVisitor>(
        _ visitor: inout Visitor
    ) {
        visitor.visitPrimitive(self)
    }
}

private enum RecordingAction: UInt16, GiftUIAction {
    case primary = 1
    case secondary = 2
}

private struct RecordingActionPrimitive: View, _GiftUISemanticActionPayload {
    let action: RecordingAction

    var _giftUIAction: RecordingAction { action }

    var body: Never {
        fatalError("recording action primitive body is unreachable")
    }

    func _giftUITraverse<Visitor: _GiftUISemanticTraversalVisitor>(
        _ visitor: inout Visitor
    ) {
        visitor.visitActionPrimitive(self)
    }
}

private struct RecordingModifier<Content: View>: View, _GiftUISemanticModifierPayload {
    let content: Content

    var body: Never {
        fatalError("recording modifier body is unreachable")
    }

    func _giftUITraverse<Visitor: _GiftUISemanticTraversalVisitor>(
        _ visitor: inout Visitor
    ) {
        visitor.visitModifier(content: content, payload: self)
    }
}

private struct RecordingIdentity: SemanticRecordingIdentity {
    let components: [SemanticRecordingPathComponent]
    let declarationRole: SemanticRecordingRole

    var componentCount: UInt16 {
        UInt16(components.count)
    }

    func component(at index: UInt16) -> SemanticRecordingPathComponent? {
        let offset = Int(index)
        guard offset < components.count else { return nil }
        return components[offset]
    }
}

private struct RecordingWorkspace: SemanticExpansionWorkspace {
    let maximumPathComponents: UInt16 = 32
    let maximumIdentities: UInt16 = 64
    var isExpanding = false
    private var path: [SemanticRecordingPathComponent] = []
    private var nextRole: UInt16 = 0

    mutating func beginExpansion() -> Bool {
        guard !isExpanding else { return false }
        isExpanding = true
        path.removeAll(keepingCapacity: true)
        nextRole = 0
        return true
    }

    mutating func enterRoot<Declaration: View>(
        _ declaration: Declaration.Type,
        identity: inout RecordingIdentity?
    ) -> SemanticExpansionError? {
        enter(.root, identity: &identity)
    }

    mutating func enterCustomBody<Declaration: View>(
        _ declaration: Declaration.Type,
        identity: inout RecordingIdentity?
    ) -> SemanticExpansionError? {
        enter(.customBody, identity: &identity)
    }

    mutating func enterFixedChild(
        _ index: UInt8,
        identity: inout RecordingIdentity?
    ) -> SemanticExpansionError? {
        enter(.fixedChild(index), identity: &identity)
    }

    mutating func enterConditionalBranch(
        _ index: UInt8,
        identity: inout RecordingIdentity?
    ) -> SemanticExpansionError? {
        enter(.conditionalBranch(index), identity: &identity)
    }

    mutating func enterOptionalPresence(
        identity: inout RecordingIdentity?
    ) -> SemanticExpansionError? {
        enter(.optionalPresence, identity: &identity)
    }

    mutating func enterDeclarationRole<Declaration>(
        _ declaration: Declaration.Type,
        identity: inout RecordingIdentity?
    ) -> SemanticExpansionError? {
        let role = SemanticRecordingRole(rawValue: nextRole)
        nextRole += 1
        return enter(.declarationRole(role), identity: &identity)
    }

    mutating func leavePathComponent() {
        _ = path.popLast()
    }

    mutating func completeExpansion() {}
    mutating func discardExpansion() {}

    mutating func resetExpansion() {
        isExpanding = false
        path.removeAll(keepingCapacity: true)
    }

    private mutating func enter(
        _ component: SemanticRecordingPathComponent,
        identity: inout RecordingIdentity?
    ) -> SemanticExpansionError? {
        path.append(component)
        guard
            let role = path.reversed().lazy.compactMap({ component -> SemanticRecordingRole? in
                if case .declarationRole(let role) = component {
                    return role
                }
                return nil
            }).first
        else {
            identity = RecordingIdentity(
                components: path,
                declarationRole: SemanticRecordingRole(rawValue: 0)
            )
            return nil
        }
        identity = RecordingIdentity(components: path, declarationRole: role)
        return nil
    }
}

private enum RecordingEventKind: Equatable {
    case structural
    case body
    case semantic
    case modifier
    case action
}

private extension SemanticRecordingEvent where Identity == RecordingIdentity {
    var kind: RecordingEventKind {
        switch self {
        case .enterStructuralOccurrence:
            .structural
        case .evaluateCustomBody:
            .body
        case .stageSemanticOccurrence:
            .semantic
        case .applyModifier:
            .modifier
        case .associateAction:
            .action
        }
    }

    var path: RecordingIdentity {
        switch self {
        case .enterStructuralOccurrence(let path, _),
            .evaluateCustomBody(let path, _),
            .stageSemanticOccurrence(let path, _),
            .applyModifier(let path, _, _),
            .associateAction(let path, _):
            path
        }
    }

    var role: SemanticRecordingRole {
        switch self {
        case .enterStructuralOccurrence(_, let role),
            .evaluateCustomBody(_, let role),
            .stageSemanticOccurrence(_, let role),
            .applyModifier(_, let role, _),
            .associateAction(_, let role):
            role
        }
    }

    var chainIndex: UInt16? {
        if case .applyModifier(_, _, let index) = self {
            return index
        }
        return nil
    }
}

private struct DynamicRecordingStorage: SemanticRecordingStorage {
    let maximumStructuralOccurrences: UInt16 = 64
    let maximumBodyEvaluations: UInt16 = 64
    let maximumSemanticOccurrences: UInt16 = 64
    let maximumModifierApplications: UInt16 = 64
    let maximumActionOccurrences: UInt16 = 64
    var stagedEvents: [SemanticRecordingEvent<RecordingIdentity>] = []
    var committedEvents: [SemanticRecordingEvent<RecordingIdentity>] = []
    var attemptedEvents: [SemanticRecordingEvent<RecordingIdentity>] = []
    var publishedSummaries: [SemanticExpansionSummary] = []
    var refuseAttemptedEvent: Int?
    var discardCount = 0

    mutating func beginRecording() -> Bool {
        stagedEvents.removeAll(keepingCapacity: true)
        return true
    }

    mutating func stage(
        _ event: borrowing SemanticRecordingEvent<RecordingIdentity>
    ) -> Bool {
        let attemptedEvent = copy event
        attemptedEvents.append(attemptedEvent)
        if attemptedEvents.count == refuseAttemptedEvent {
            return false
        }
        stagedEvents.append(copy event)
        return true
    }

    mutating func publishRecording(_ summary: SemanticExpansionSummary) -> Bool {
        committedEvents = stagedEvents
        publishedSummaries.append(summary)
        stagedEvents.removeAll(keepingCapacity: true)
        return true
    }

    mutating func discardRecording() {
        discardCount += 1
        stagedEvents.removeAll(keepingCapacity: true)
    }

    mutating func resetRecording() {}
}
