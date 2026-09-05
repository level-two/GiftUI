import GiftUI
import XCTest

@testable import GiftUISemanticCore

final class SemanticDeclarationCorpusTests: XCTestCase {
    func testEmptyAndEveryFixedArityHaveExactLeftToRightTranscript() {
        assertExpansion(
            ViewBuilder.buildBlock(),
            expectedEvents: [.structural(path([.root, .role(.empty)]), .empty)],
            expectedSummary: summary(nodes: 0, depth: 2)
        )

        assertExpansion(
            CorpusA(),
            expectedEvents: primitiveEvents(root: .a),
            expectedSummary: summary(nodes: 1, depth: 2)
        )

        assertFixedExpansion(
            ViewBuilder.buildBlock(CorpusA(), CorpusB()),
            tupleRole: .tuple2,
            childRoles: [.a, .b]
        )
        assertFixedExpansion(
            ViewBuilder.buildBlock(CorpusA(), CorpusB(), CorpusC()),
            tupleRole: .tuple3,
            childRoles: [.a, .b, .c]
        )
        assertFixedExpansion(
            ViewBuilder.buildBlock(CorpusA(), CorpusB(), CorpusC(), CorpusD()),
            tupleRole: .tuple4,
            childRoles: [.a, .b, .c, .d]
        )
        assertFixedExpansion(
            ViewBuilder.buildBlock(CorpusA(), CorpusB(), CorpusC(), CorpusD(), CorpusE()),
            tupleRole: .tuple5,
            childRoles: [.a, .b, .c, .d, .e]
        )
    }

    func testNestedCustomViewsEvaluateEachBodyExactlyOnce() {
        let counters = CorpusCounters()
        let root = CorpusOuter(counters: counters)
        let rootPath: [SemanticRecordingPathComponent] = [.root, .role(.outer)]
        let outerBody = rootPath + [.customBody]
        let innerPath = outerBody + [.role(.inner)]
        let innerBody = innerPath + [.customBody]
        let primitivePath = innerBody + [.role(.a)]

        assertExpansion(
            root,
            expectedEvents: [
                .structural(path(rootPath), .outer),
                .body(path(outerBody), .outer),
                .structural(path(innerPath), .inner),
                .body(path(innerBody), .inner),
                .structural(path(primitivePath), .a),
                .semantic(path(primitivePath), .a),
            ],
            expectedSummary: summary(nodes: 1, bodies: 2, depth: 6)
        )
        XCTAssertEqual(counters.outerBodies, 1)
        XCTAssertEqual(counters.innerBodies, 1)
    }

    func testViewReturningPropertyAndFunctionMatchInlineFixedContent() {
        let counters = CorpusCounters()
        let root = CorpusPropertyFunction(counters: counters)
        let rootPath: [SemanticRecordingPathComponent] = [.root, .role(.propertyFunction)]
        let bodyPath = rootPath + [.customBody]
        let tuplePath = bodyPath + [.role(.tuple2)]
        let aPath = tuplePath + [.fixedChild(0), .role(.a)]
        let bPath = tuplePath + [.fixedChild(1), .role(.b)]

        assertExpansion(
            root,
            expectedEvents: [
                .structural(path(rootPath), .propertyFunction),
                .body(path(bodyPath), .propertyFunction),
                .structural(path(tuplePath), .tuple2),
                .structural(path(aPath), .a),
                .semantic(path(aPath), .a),
                .structural(path(bPath), .b),
                .semantic(path(bPath), .b),
            ],
            expectedSummary: summary(nodes: 2, bodies: 1, depth: 6)
        )
        XCTAssertEqual(counters.propertyReads, 1)
        XCTAssertEqual(counters.functionCalls, 1)
    }

    func testBothConditionalBranchesUseOnlyTheirSelectedPath() {
        let first: ConditionalContent<CorpusA, CorpusB> = ViewBuilder.buildEither(
            first: CorpusA()
        )
        let second: ConditionalContent<CorpusA, CorpusB> = ViewBuilder.buildEither(
            second: CorpusB()
        )

        assertExpansion(
            first,
            expectedEvents: conditionalEvents(branch: 0, child: .a),
            expectedSummary: summary(nodes: 1, depth: 5)
        )
        assertExpansion(
            second,
            expectedEvents: conditionalEvents(branch: 1, child: .b),
            expectedSummary: summary(nodes: 1, depth: 5)
        )
    }

    func testOptionalPresenceAndAbsenceHaveExactDistinctTranscripts() {
        let present = ViewBuilder.buildOptional(CorpusA())
        let absent = ViewBuilder.buildOptional(nil as CorpusA?)
        let rootPath: [SemanticRecordingPathComponent] = [.root, .role(.optional)]
        let childPath = rootPath + [.optionalPresence, .fixedChild(0), .role(.a)]

        assertExpansion(
            present,
            expectedEvents: [
                .structural(path(rootPath), .optional),
                .structural(path(childPath), .a),
                .semantic(path(childPath), .a),
            ],
            expectedSummary: summary(nodes: 1, depth: 5)
        )
        assertExpansion(
            absent,
            expectedEvents: [.structural(path(rootPath), .optional)],
            expectedSummary: summary(nodes: 0, depth: 2)
        )
    }

    func testNestedConditionalAndOptionalCombinationIsDepthFirst() {
        let root = CorpusNestedCombination()
        let rootPath: [SemanticRecordingPathComponent] = [.root, .role(.combination)]
        let bodyPath = rootPath + [.customBody]
        let tuplePath = bodyPath + [.role(.tuple2)]
        let conditionalPath = tuplePath + [.fixedChild(0), .role(.conditional)]
        let aPath = conditionalPath + [.conditionalBranch(0), .fixedChild(0), .role(.a)]
        let optionalPath = tuplePath + [.fixedChild(1), .role(.optional)]
        let cPath = optionalPath + [.optionalPresence, .fixedChild(0), .role(.c)]

        assertExpansion(
            root,
            expectedEvents: [
                .structural(path(rootPath), .combination),
                .body(path(bodyPath), .combination),
                .structural(path(tuplePath), .tuple2),
                .structural(path(conditionalPath), .conditional),
                .structural(path(aPath), .a),
                .semantic(path(aPath), .a),
                .structural(path(optionalPath), .optional),
                .structural(path(cPath), .c),
                .semantic(path(cPath), .c),
            ],
            expectedSummary: summary(nodes: 2, bodies: 1, depth: 9)
        )
    }

    func testSiblingInsertionInInactiveBranchCannotChangeActiveTranscript() {
        let baseline: ConditionalContent<CorpusA, CorpusB> = ViewBuilder.buildEither(
            first: CorpusA()
        )
        let varied: ConditionalContent<CorpusA, TupleView<CorpusB, CorpusC>> =
            ViewBuilder.buildEither(first: CorpusA())

        let baselineResult = expand(baseline)
        let variedResult = expand(varied)

        XCTAssertEqual(baselineResult.result, variedResult.result)
        XCTAssertEqual(baselineResult.events, variedResult.events)
        XCTAssertEqual(
            baselineResult.events,
            conditionalEvents(branch: 0, child: .a)
        )
    }

    func testStructuralIdentityRelationsUseCompleteCanonicalPathsAndEndpointRoles() {
        let repeatedFirst = semanticIdentities(in: expand(CorpusA()).events)
        let repeatedSecond = semanticIdentities(in: expand(CorpusA()).events)
        XCTAssertEqual(repeatedFirst, repeatedSecond)

        let firstBranch: ConditionalContent<CorpusA, CorpusB> = ViewBuilder.buildEither(
            first: CorpusA()
        )
        let secondBranch: ConditionalContent<CorpusA, CorpusB> = ViewBuilder.buildEither(
            second: CorpusB()
        )
        XCTAssertNotEqual(
            semanticIdentities(in: expand(firstBranch).events),
            semanticIdentities(in: expand(secondBranch).events)
        )

        let present = ViewBuilder.buildOptional(CorpusA())
        let absent = ViewBuilder.buildOptional(nil as CorpusA?)
        let originalOptionalIdentity = semanticIdentities(in: expand(present).events)
        XCTAssertTrue(semanticIdentities(in: expand(absent).events).isEmpty)
        XCTAssertEqual(
            originalOptionalIdentity,
            semanticIdentities(in: expand(present).events)
        )

        let siblings = semanticIdentities(
            in: expand(ViewBuilder.buildBlock(CorpusA(), CorpusA())).events
        )
        XCTAssertEqual(siblings.count, 2)
        XCTAssertNotEqual(siblings[0], siblings[1])

        let sameComponents: [SemanticRecordingPathComponent] = [.root, .role(.a)]
        XCTAssertNotEqual(
            CorpusIdentity(
                components: sameComponents,
                declarationRole: CorpusRole.a.recordingRole
            ),
            CorpusIdentity(
                components: sameComponents,
                declarationRole: CorpusRole.b.recordingRole
            )
        )

        XCTAssertNotEqual(
            semanticIdentities(in: expand(CorpusA()).events),
            semanticIdentities(in: expand(CorpusB()).events)
        )

        let nestedEvents = expand(CorpusOuter(counters: CorpusCounters())).events
        let prefix = nestedEvents[0].path
        let descendant = try! XCTUnwrap(
            nestedEvents.first(where: { $0.kind == .semantic })?.path
        )
        XCTAssertTrue(
            Array(descendant.components.prefix(prefix.components.count)) == prefix.components)
        XCTAssertNotEqual(prefix, descendant)
    }

    func testForcedIdentityAliasFailsAtomically() {
        var workspace = CorpusWorkspace(forceIdentityAlias: true)
        var sink = SemanticRecordingSink(storage: CorpusStorage())
        let limits = SemanticExpansionLimits(
            maximumDepth: 16,
            maximumSemanticNodes: 16,
            maximumBodyEvaluations: 16,
            maximumModifierApplications: 16,
            maximumActionOccurrences: 16
        )!

        XCTAssertEqual(
            expandSemanticTree(
                CorpusA(),
                limits: limits,
                workspace: &workspace,
                sink: &sink
            ),
            .failure(.invalidIdentity)
        )
        XCTAssertTrue(sink.storage.committedEvents.isEmpty)
        XCTAssertFalse(workspace.isExpanding)
    }

    private func assertFixedExpansion<Content: View>(
        _ content: Content,
        tupleRole: CorpusRole,
        childRoles: [CorpusRole],
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let tuplePath: [SemanticRecordingPathComponent] = [.root, .role(tupleRole)]
        var events: [CorpusEvent] = [.structural(path(tuplePath), tupleRole)]
        for (index, childRole) in childRoles.enumerated() {
            let childPath = tuplePath + [.fixedChild(UInt8(index)), .role(childRole)]
            events.append(.structural(path(childPath), childRole))
            events.append(.semantic(path(childPath), childRole))
        }
        assertExpansion(
            content,
            expectedEvents: events,
            expectedSummary: summary(
                nodes: UInt16(childRoles.count),
                depth: 4
            ),
            file: file,
            line: line
        )
    }

    private func assertExpansion<Content: View>(
        _ content: Content,
        expectedEvents: [CorpusEvent],
        expectedSummary: SemanticExpansionSummary,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let observed = expand(content)
        XCTAssertEqual(observed.result, .success(expectedSummary), file: file, line: line)
        XCTAssertEqual(observed.events, expectedEvents, file: file, line: line)
    }

    private func expand<Content: View>(
        _ content: Content
    ) -> (result: SemanticExpansionResult, events: [CorpusEvent]) {
        var workspace = CorpusWorkspace()
        var sink = SemanticRecordingSink(storage: CorpusStorage())
        let limits = SemanticExpansionLimits(
            maximumDepth: 16,
            maximumSemanticNodes: 16,
            maximumBodyEvaluations: 16,
            maximumModifierApplications: 16,
            maximumActionOccurrences: 16
        )!
        let result = expandSemanticTree(
            content,
            limits: limits,
            workspace: &workspace,
            sink: &sink
        )
        return (result, sink.storage.committedEvents.map(CorpusEvent.init))
    }

    private func primitiveEvents(root role: CorpusRole) -> [CorpusEvent] {
        let rootPath: [SemanticRecordingPathComponent] = [.root, .role(role)]
        return [
            .structural(path(rootPath), role),
            .semantic(path(rootPath), role),
        ]
    }

    private func conditionalEvents(branch: UInt8, child: CorpusRole) -> [CorpusEvent] {
        let rootPath: [SemanticRecordingPathComponent] = [.root, .role(.conditional)]
        let childPath = rootPath + [.conditionalBranch(branch), .fixedChild(0), .role(child)]
        return [
            .structural(path(rootPath), .conditional),
            .structural(path(childPath), child),
            .semantic(path(childPath), child),
        ]
    }

    private func semanticIdentities(in events: [CorpusEvent]) -> [CorpusIdentity] {
        events.compactMap { event in
            event.kind == .semantic ? event.path : nil
        }
    }

    private func summary(
        nodes: UInt16,
        bodies: UInt16 = 0,
        depth: UInt16
    ) -> SemanticExpansionSummary {
        SemanticExpansionSummary(
            semanticNodeCount: nodes,
            bodyEvaluationCount: bodies,
            modifierApplicationCount: 0,
            actionOccurrenceCount: 0,
            maximumObservedDepth: depth
        )
    }
}

private enum CorpusRole: UInt16, Sendable {
    case empty = 0
    case tuple2 = 2
    case tuple3 = 3
    case tuple4 = 4
    case tuple5 = 5
    case conditional = 10
    case optional = 11
    case outer = 20
    case inner = 21
    case propertyFunction = 22
    case combination = 23
    case a = 100
    case b = 101
    case c = 102
    case d = 103
    case e = 104

    var recordingRole: SemanticRecordingRole {
        SemanticRecordingRole(rawValue: rawValue)
    }
}

private extension SemanticRecordingPathComponent {
    static func role(_ role: CorpusRole) -> Self {
        .declarationRole(role.recordingRole)
    }
}

private protocol CorpusRoleProviding {
    static var corpusRole: CorpusRole { get }
}

extension EmptyView: CorpusRoleProviding {
    fileprivate static var corpusRole: CorpusRole { .empty }
}

extension TupleView: CorpusRoleProviding {
    fileprivate static var corpusRole: CorpusRole { .tuple2 }
}

extension TupleView3: CorpusRoleProviding {
    fileprivate static var corpusRole: CorpusRole { .tuple3 }
}

extension TupleView4: CorpusRoleProviding {
    fileprivate static var corpusRole: CorpusRole { .tuple4 }
}

extension TupleView5: CorpusRoleProviding {
    fileprivate static var corpusRole: CorpusRole { .tuple5 }
}

extension ConditionalContent: CorpusRoleProviding {
    fileprivate static var corpusRole: CorpusRole { .conditional }
}

extension OptionalContent: CorpusRoleProviding {
    fileprivate static var corpusRole: CorpusRole { .optional }
}

private struct CorpusA: View, _GiftUISemanticPrimitivePayload, CorpusRoleProviding {
    static let corpusRole = CorpusRole.a
    var body: Never { fatalError("primitive body is unreachable") }
    func _giftUITraverse<Visitor: _GiftUISemanticTraversalVisitor>(_ visitor: inout Visitor) {
        visitor.visitPrimitive(self)
    }
}

private struct CorpusB: View, _GiftUISemanticPrimitivePayload, CorpusRoleProviding {
    static let corpusRole = CorpusRole.b
    var body: Never { fatalError("primitive body is unreachable") }
    func _giftUITraverse<Visitor: _GiftUISemanticTraversalVisitor>(_ visitor: inout Visitor) {
        visitor.visitPrimitive(self)
    }
}

private struct CorpusC: View, _GiftUISemanticPrimitivePayload, CorpusRoleProviding {
    static let corpusRole = CorpusRole.c
    var body: Never { fatalError("primitive body is unreachable") }
    func _giftUITraverse<Visitor: _GiftUISemanticTraversalVisitor>(_ visitor: inout Visitor) {
        visitor.visitPrimitive(self)
    }
}

private struct CorpusD: View, _GiftUISemanticPrimitivePayload, CorpusRoleProviding {
    static let corpusRole = CorpusRole.d
    var body: Never { fatalError("primitive body is unreachable") }
    func _giftUITraverse<Visitor: _GiftUISemanticTraversalVisitor>(_ visitor: inout Visitor) {
        visitor.visitPrimitive(self)
    }
}

private struct CorpusE: View, _GiftUISemanticPrimitivePayload, CorpusRoleProviding {
    static let corpusRole = CorpusRole.e
    var body: Never { fatalError("primitive body is unreachable") }
    func _giftUITraverse<Visitor: _GiftUISemanticTraversalVisitor>(_ visitor: inout Visitor) {
        visitor.visitPrimitive(self)
    }
}

private final class CorpusCounters {
    var outerBodies = 0
    var innerBodies = 0
    var propertyReads = 0
    var functionCalls = 0
}

private struct CorpusOuter: View, CorpusRoleProviding {
    static let corpusRole = CorpusRole.outer
    let counters: CorpusCounters
    var body: some View {
        counters.outerBodies += 1
        return CorpusInner(counters: counters)
    }
}

private struct CorpusInner: View, CorpusRoleProviding {
    static let corpusRole = CorpusRole.inner
    let counters: CorpusCounters
    var body: some View {
        counters.innerBodies += 1
        return CorpusA()
    }
}

private struct CorpusPropertyFunction: View, CorpusRoleProviding {
    static let corpusRole = CorpusRole.propertyFunction
    let counters: CorpusCounters
    var body: some View { content }
    private var content: some View {
        counters.propertyReads += 1
        return makeContent()
    }
    private func makeContent() -> some View {
        counters.functionCalls += 1
        return ViewBuilder.buildBlock(CorpusA(), CorpusB())
    }
}

private struct CorpusNestedCombination: View, CorpusRoleProviding {
    static let corpusRole = CorpusRole.combination
    var body: some View {
        let conditional: ConditionalContent<CorpusA, CorpusB> = ViewBuilder.buildEither(
            first: CorpusA()
        )
        let optional = ViewBuilder.buildOptional(CorpusC())
        return ViewBuilder.buildBlock(conditional, optional)
    }
}

private struct CorpusIdentity: SemanticRecordingIdentity {
    let components: [SemanticRecordingPathComponent]
    let declarationRole: SemanticRecordingRole
    var componentCount: UInt16 { UInt16(components.count) }
    func component(at index: UInt16) -> SemanticRecordingPathComponent? {
        let offset = Int(index)
        return offset < components.count ? components[offset] : nil
    }
}

private struct CorpusWorkspace: SemanticExpansionWorkspace {
    let maximumPathComponents: UInt16 = 32
    let maximumIdentities: UInt16 = 128
    var isExpanding = false
    private let forceIdentityAlias: Bool
    private var path: [SemanticRecordingPathComponent] = []
    private var identities: [CorpusIdentity] = []

    init(forceIdentityAlias: Bool = false) {
        self.forceIdentityAlias = forceIdentityAlias
    }

    mutating func beginExpansion() -> Bool {
        guard !isExpanding else { return false }
        isExpanding = true
        path.removeAll(keepingCapacity: true)
        identities.removeAll(keepingCapacity: true)
        return true
    }
    mutating func enterRoot<Declaration: View>(
        _ declaration: Declaration.Type,
        identity: inout CorpusIdentity?
    ) -> SemanticExpansionError? { enter(.root, identity: &identity) }
    mutating func enterCustomBody<Declaration: View>(
        _ declaration: Declaration.Type,
        identity: inout CorpusIdentity?
    ) -> SemanticExpansionError? { enter(.customBody, identity: &identity) }
    mutating func enterFixedChild(
        _ index: UInt8,
        identity: inout CorpusIdentity?
    ) -> SemanticExpansionError? { enter(.fixedChild(index), identity: &identity) }
    mutating func enterConditionalBranch(
        _ index: UInt8,
        identity: inout CorpusIdentity?
    ) -> SemanticExpansionError? { enter(.conditionalBranch(index), identity: &identity) }
    mutating func enterOptionalPresence(
        identity: inout CorpusIdentity?
    ) -> SemanticExpansionError? { enter(.optionalPresence, identity: &identity) }
    mutating func enterDeclarationRole<Declaration>(
        _ declaration: Declaration.Type,
        identity: inout CorpusIdentity?
    ) -> SemanticExpansionError? {
        guard let role = (Declaration.self as? any CorpusRoleProviding.Type)?.corpusRole else {
            return .invalidIdentity
        }
        return enter(.role(role), identity: &identity)
    }
    mutating func leavePathComponent() { _ = path.popLast() }
    mutating func completeExpansion() {}
    mutating func discardExpansion() {}
    mutating func resetExpansion() {
        isExpanding = false
        path.removeAll(keepingCapacity: true)
        identities.removeAll(keepingCapacity: true)
    }
    private mutating func enter(
        _ component: SemanticRecordingPathComponent,
        identity: inout CorpusIdentity?
    ) -> SemanticExpansionError? {
        path.append(component)
        let role =
            path.reversed().lazy.compactMap { component -> SemanticRecordingRole? in
                if case .declarationRole(let role) = component { return role }
                return nil
            }.first ?? SemanticRecordingRole(rawValue: 0)
        let candidate =
            forceIdentityAlias
            ? CorpusIdentity(
                components: [.root],
                declarationRole: SemanticRecordingRole(rawValue: 0)
            )
            : CorpusIdentity(components: path, declarationRole: role)
        guard !identities.contains(candidate) else { return .invalidIdentity }
        identities.append(candidate)
        identity = candidate
        return nil
    }
}

private enum CorpusEventKind: Equatable {
    case structural
    case body
    case semantic
}

private struct CorpusEvent: Equatable {
    let path: CorpusIdentity
    let kind: CorpusEventKind
    let role: SemanticRecordingRole

    init(path: CorpusIdentity, kind: CorpusEventKind, role: SemanticRecordingRole) {
        self.path = path
        self.kind = kind
        self.role = role
    }

    init(_ event: SemanticRecordingEvent<CorpusIdentity>) {
        switch event {
        case .enterStructuralOccurrence(let path, let role):
            self.init(path: path, kind: .structural, role: role)
        case .evaluateCustomBody(let path, let role):
            self.init(path: path, kind: .body, role: role)
        case .stageSemanticOccurrence(let path, let role):
            self.init(path: path, kind: .semantic, role: role)
        case .applyModifier, .associateAction:
            preconditionFailure("T3.2 declaration corpus contains no modifiers or actions")
        }
    }

    static func structural(_ path: CorpusIdentity, _ role: CorpusRole) -> Self {
        Self(path: path, kind: .structural, role: role.recordingRole)
    }
    static func body(_ path: CorpusIdentity, _ role: CorpusRole) -> Self {
        Self(path: path, kind: .body, role: role.recordingRole)
    }
    static func semantic(_ path: CorpusIdentity, _ role: CorpusRole) -> Self {
        Self(path: path, kind: .semantic, role: role.recordingRole)
    }
}

private func path(_ components: [SemanticRecordingPathComponent]) -> CorpusIdentity {
    let role =
        components.reversed().lazy.compactMap { component -> SemanticRecordingRole? in
            if case .declarationRole(let role) = component { return role }
            return nil
        }.first ?? SemanticRecordingRole(rawValue: 0)
    return CorpusIdentity(components: components, declarationRole: role)
}

private struct CorpusStorage: SemanticRecordingStorage {
    let maximumStructuralOccurrences: UInt16 = 128
    let maximumBodyEvaluations: UInt16 = 32
    let maximumSemanticOccurrences: UInt16 = 64
    let maximumModifierApplications: UInt16 = 0
    let maximumActionOccurrences: UInt16 = 0
    var stagedEvents: [SemanticRecordingEvent<CorpusIdentity>] = []
    var committedEvents: [SemanticRecordingEvent<CorpusIdentity>] = []
    mutating func beginRecording() -> Bool {
        stagedEvents.removeAll(keepingCapacity: true)
        return true
    }
    mutating func stage(_ event: borrowing SemanticRecordingEvent<CorpusIdentity>) -> Bool {
        stagedEvents.append(copy event)
        return true
    }
    mutating func publishRecording(_ summary: SemanticExpansionSummary) -> Bool {
        committedEvents = stagedEvents
        stagedEvents.removeAll(keepingCapacity: true)
        return true
    }
    mutating func discardRecording() { stagedEvents.removeAll(keepingCapacity: true) }
    mutating func resetRecording() {}
}
