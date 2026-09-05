import GiftUI
import XCTest

@testable import GiftUISemanticCore

final class SemanticExpansionTraversalTests: XCTestCase {
    func testNestedDeclarationExpandsDepthFirstAndSkipsInactiveContent() {
        let bodyCounter = TraversalBodyCounter()
        var workspace = TraversalWorkspace()
        var sink = TraversalSink()

        let result = expandSemanticTree(
            TraversalRoot(bodyCounter: bodyCounter),
            limits: makeLimits(),
            workspace: &workspace,
            sink: &sink
        )

        XCTAssertEqual(
            result,
            .success(
                SemanticExpansionSummary(
                    semanticNodeCount: 2,
                    bodyEvaluationCount: 1,
                    modifierApplicationCount: 0,
                    actionOccurrenceCount: 0,
                    maximumObservedDepth: 9
                )
            )
        )
        XCTAssertEqual(bodyCounter.count, 1)
        XCTAssertEqual(
            sink.committedEvents.map(\.kind),
            [
                .structural,
                .structural,
                .structural,
                .semantic,
                .structural,
                .structural,
                .semantic,
                .structural,
            ]
        )
        XCTAssertEqual(sink.publishCount, 1)
        XCTAssertTrue(sink.stagedEvents.isEmpty)
        XCTAssertFalse(workspace.isExpanding)
    }

    func testActionNodePrecedesActionAndModifierChainUsesSourceOrder() {
        let root = TraversalModifier(
            content: TraversalModifier(
                content: TraversalActionPrimitive(action: .secondary),
                marker: 1
            ),
            marker: 2
        )
        var workspace = TraversalWorkspace()
        var sink = TraversalSink()

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
            sink.committedEvents.map(\.kind),
            [.structural, .structural, .structural, .semantic, .action, .modifier, .modifier]
        )
        XCTAssertEqual(
            sink.committedEvents.compactMap(\.modifierIndex),
            [0, 1]
        )
        XCTAssertEqual(sink.observedActions, [.secondary])
    }

    func testSiblingModifierChainsDoNotInterleave() {
        let root = ViewBuilder.buildBlock(
            TraversalModifier(
                content: TraversalModifier(
                    content: TraversalPrimitive(marker: 1),
                    marker: 1
                ),
                marker: 2
            ),
            TraversalModifier(
                content: TraversalPrimitive(marker: 2),
                marker: 3
            )
        )
        var workspace = TraversalWorkspace()
        var sink = TraversalSink()

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
                    semanticNodeCount: 2,
                    bodyEvaluationCount: 0,
                    modifierApplicationCount: 3,
                    actionOccurrenceCount: 0,
                    maximumObservedDepth: 6
                )
            )
        )
        XCTAssertEqual(
            sink.committedEvents.compactMap(\.modifierIndex),
            [0, 1, 0]
        )
    }

    func testBodyLimitStopsBeforeTheRejectedBodyAndPublishesNothing() {
        let outerCounter = TraversalBodyCounter()
        let innerCounter = TraversalBodyCounter()
        let root = TraversalNestedCustom(
            bodyCounter: outerCounter,
            child: TraversalLeafCustom(bodyCounter: innerCounter)
        )
        var workspace = TraversalWorkspace()
        var sink = TraversalSink()
        let limits = SemanticExpansionLimits(
            maximumDepth: 8,
            maximumSemanticNodes: 4,
            maximumBodyEvaluations: 1,
            maximumModifierApplications: 4,
            maximumActionOccurrences: 4
        )!

        let result = expandSemanticTree(
            root,
            limits: limits,
            workspace: &workspace,
            sink: &sink
        )

        XCTAssertEqual(result, .failure(.capacityExhausted))
        XCTAssertEqual(outerCounter.count, 1)
        XCTAssertEqual(innerCounter.count, 0)
        XCTAssertTrue(sink.committedEvents.isEmpty)
        XCTAssertTrue(sink.stagedEvents.isEmpty)
        XCTAssertEqual(sink.publishCount, 0)
        XCTAssertEqual(sink.discardCount, 1)
        XCTAssertFalse(workspace.isExpanding)
    }

    func testWorkspacePathCapacityFailsBeforeTheNextEntry() {
        var workspace = TraversalWorkspace(maximumPathComponents: 1)
        var sink = TraversalSink()

        let result = expandSemanticTree(
            ViewBuilder.buildBlock(),
            limits: makeLimits(),
            workspace: &workspace,
            sink: &sink
        )

        XCTAssertEqual(result, .failure(.capacityExhausted))
        XCTAssertEqual(workspace.enterCount, 1)
        XCTAssertTrue(sink.committedEvents.isEmpty)
        XCTAssertTrue(sink.stagedEvents.isEmpty)
    }

    private func makeLimits() -> SemanticExpansionLimits {
        SemanticExpansionLimits(
            maximumDepth: 16,
            maximumSemanticNodes: 16,
            maximumBodyEvaluations: 16,
            maximumModifierApplications: 16,
            maximumActionOccurrences: 16
        )!
    }
}

private final class TraversalBodyCounter {
    var count = 0
}

private struct TraversalRoot: View {
    let bodyCounter: TraversalBodyCounter

    var body: some View {
        bodyCounter.count += 1
        let conditional: ConditionalContent<TraversalInactiveTrap, TraversalPrimitive> =
            ViewBuilder.buildEither(second: TraversalPrimitive(marker: 2))
        let optional = ViewBuilder.buildOptional(nil as TraversalInactiveTrap?)
        return ViewBuilder.buildBlock(
            TraversalPrimitive(marker: 1),
            conditional,
            optional
        )
    }
}

private struct TraversalInactiveTrap: View {
    init() {
        fatalError("inactive traversal content must not initialize")
    }

    var body: Never {
        fatalError("inactive traversal content must not evaluate")
    }
}

private struct TraversalNestedCustom<Child: View>: View {
    let bodyCounter: TraversalBodyCounter
    let child: Child

    var body: some View {
        bodyCounter.count += 1
        return child
    }
}

private struct TraversalLeafCustom: View {
    let bodyCounter: TraversalBodyCounter

    var body: some View {
        bodyCounter.count += 1
        return TraversalPrimitive(marker: 1)
    }
}

private struct TraversalPrimitive: View, _GiftUISemanticPrimitivePayload {
    let marker: UInt8

    var body: Never {
        fatalError("primitive bodies are unreachable")
    }

    func _giftUITraverse<Visitor: _GiftUISemanticTraversalVisitor>(
        _ visitor: inout Visitor
    ) {
        visitor.visitPrimitive(self)
    }
}

private enum TraversalAction: UInt16, GiftUIAction {
    case primary = 1
    case secondary = 2
}

private struct TraversalActionPrimitive: View, _GiftUISemanticActionPayload {
    let action: TraversalAction

    var _giftUIAction: TraversalAction { action }

    var body: Never {
        fatalError("action primitive bodies are unreachable")
    }

    func _giftUITraverse<Visitor: _GiftUISemanticTraversalVisitor>(
        _ visitor: inout Visitor
    ) {
        visitor.visitActionPrimitive(self)
    }
}

private struct TraversalModifier<Content: View>: View, _GiftUISemanticModifierPayload {
    let content: Content
    let marker: UInt8

    var body: Never {
        fatalError("modifier bodies are unreachable")
    }

    func _giftUITraverse<Visitor: _GiftUISemanticTraversalVisitor>(
        _ visitor: inout Visitor
    ) {
        visitor.visitModifier(content: content, payload: self)
    }
}

private enum TraversalPathComponent: Equatable {
    case root
    case customBody
    case fixedChild(UInt8)
    case conditionalBranch(UInt8)
    case optionalPresence
    case declarationRole(UInt16)
}

private struct TraversalIdentity: Equatable {
    let path: [TraversalPathComponent]
}

private struct TraversalWorkspace: SemanticExpansionWorkspace {
    let maximumPathComponents: UInt16
    let maximumIdentities: UInt16
    var isExpanding = false
    var enterCount: UInt16 = 0
    private var path: [TraversalPathComponent] = []
    private var nextDeclarationRole: UInt16 = 0

    init(
        maximumPathComponents: UInt16 = 32,
        maximumIdentities: UInt16 = 64
    ) {
        self.maximumPathComponents = maximumPathComponents
        self.maximumIdentities = maximumIdentities
    }

    mutating func beginExpansion() -> Bool {
        guard !isExpanding else { return false }
        isExpanding = true
        enterCount = 0
        path.removeAll(keepingCapacity: true)
        nextDeclarationRole = 0
        return true
    }

    mutating func enterRoot<Declaration: View>(
        _ declaration: Declaration.Type,
        identity: inout TraversalIdentity?
    ) -> SemanticExpansionError? {
        enter(.root, identity: &identity)
    }

    mutating func enterCustomBody<Declaration: View>(
        _ declaration: Declaration.Type,
        identity: inout TraversalIdentity?
    ) -> SemanticExpansionError? {
        enter(.customBody, identity: &identity)
    }

    mutating func enterFixedChild(
        _ index: UInt8,
        identity: inout TraversalIdentity?
    ) -> SemanticExpansionError? {
        enter(.fixedChild(index), identity: &identity)
    }

    mutating func enterConditionalBranch(
        _ index: UInt8,
        identity: inout TraversalIdentity?
    ) -> SemanticExpansionError? {
        enter(.conditionalBranch(index), identity: &identity)
    }

    mutating func enterOptionalPresence(
        identity: inout TraversalIdentity?
    ) -> SemanticExpansionError? {
        enter(.optionalPresence, identity: &identity)
    }

    mutating func enterDeclarationRole<Declaration>(
        _ declaration: Declaration.Type,
        identity: inout TraversalIdentity?
    ) -> SemanticExpansionError? {
        let role = nextDeclarationRole
        nextDeclarationRole += 1
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
        _ component: TraversalPathComponent,
        identity: inout TraversalIdentity?
    ) -> SemanticExpansionError? {
        enterCount += 1
        path.append(component)
        identity = TraversalIdentity(path: path)
        return nil
    }
}

private enum TraversalEventKind: Equatable {
    case structural
    case semantic
    case modifier
    case action
}

private struct TraversalEvent: Equatable {
    let identity: TraversalIdentity
    let kind: TraversalEventKind
    let modifierIndex: UInt16?
}

private struct TraversalSink: SemanticExpansionSink {
    let maximumStructuralOccurrences: UInt16 = 64
    let maximumSemanticOccurrences: UInt16 = 64
    let maximumModifierApplications: UInt16 = 64
    let maximumActionOccurrences: UInt16 = 64
    var stagedEvents: [TraversalEvent] = []
    var committedEvents: [TraversalEvent] = []
    var observedActions: [TraversalAction] = []
    var publishCount = 0
    var discardCount = 0

    mutating func beginExpansion() -> Bool {
        stagedEvents.removeAll(keepingCapacity: true)
        return true
    }

    mutating func stageStructuralOccurrence(
        identity: borrowing TraversalIdentity
    ) -> Bool {
        let storedIdentity = copy identity
        stagedEvents.append(
            TraversalEvent(identity: storedIdentity, kind: .structural, modifierIndex: nil)
        )
        return true
    }

    mutating func stageSemanticOccurrence<Payload: _GiftUISemanticPrimitivePayload>(
        identity: borrowing TraversalIdentity,
        payload: borrowing Payload
    ) -> Bool {
        let storedIdentity = copy identity
        stagedEvents.append(
            TraversalEvent(identity: storedIdentity, kind: .semantic, modifierIndex: nil)
        )
        return true
    }

    mutating func stageModifierApplication<Payload: _GiftUISemanticModifierPayload>(
        identity: borrowing TraversalIdentity,
        payload: borrowing Payload,
        chainIndex: UInt16
    ) -> Bool {
        let storedIdentity = copy identity
        stagedEvents.append(
            TraversalEvent(identity: storedIdentity, kind: .modifier, modifierIndex: chainIndex)
        )
        return true
    }

    mutating func stageActionOccurrence<Action: GiftUIAction>(
        identity: borrowing TraversalIdentity,
        action: borrowing Action
    ) -> Bool {
        let semanticIdentity = copy identity
        let actionIdentity = copy identity
        stagedEvents.append(
            TraversalEvent(identity: semanticIdentity, kind: .semantic, modifierIndex: nil)
        )
        stagedEvents.append(
            TraversalEvent(identity: actionIdentity, kind: .action, modifierIndex: nil)
        )
        if let action = TraversalAction(rawValue: action.rawValue) {
            observedActions.append(action)
        }
        return true
    }

    mutating func publishExpansion(_ summary: SemanticExpansionSummary) -> Bool {
        publishCount += 1
        committedEvents = stagedEvents
        stagedEvents.removeAll(keepingCapacity: true)
        return true
    }

    mutating func discardExpansion() {
        discardCount += 1
        stagedEvents.removeAll(keepingCapacity: true)
    }

    mutating func resetExpansion() {}
}
