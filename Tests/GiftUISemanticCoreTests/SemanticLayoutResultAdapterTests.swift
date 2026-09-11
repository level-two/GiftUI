import GiftUI
import Testing

@testable import GiftUISemanticCore

@Test
func successfulSemanticExpansionIsItsOwnBorrowedLayoutView() {
    let root = AdapterRoot()
    var workspace = AdapterWorkspace()
    var sink = SemanticLayoutResultSink(storage: AdapterStorage())

    let result = expandSemanticTree(
        root,
        limits: SemanticExpansionLimits(
            maximumDepth: 32,
            maximumSemanticNodes: 8,
            maximumBodyEvaluations: 4,
            maximumModifierApplications: 4,
            maximumActionOccurrences: 2
        )!,
        workspace: &workspace,
        sink: &sink
    )

    #expect(
        result
            == .success(
                SemanticExpansionSummary(
                    semanticNodeCount: 4,
                    bodyEvaluationCount: 1,
                    modifierApplicationCount: 1,
                    actionOccurrenceCount: 1,
                    maximumObservedDepth: 9
                )
            )
    )
    #expect(sink.scopeCount == 5)

    let rootIdentity = sink.rootIdentity
    #expect(sink.primitive(at: rootIdentity) == nil)
    #expect(sink.childCount(of: rootIdentity) == 1)
    let stack = sink.child(of: rootIdentity, at: 0)!
    #expect(sink.primitive(at: stack) == .vStack(alignment: .leading, spacing: 3))
    #expect(sink.childCount(of: stack) == 3)

    let action = sink.child(of: stack, at: 0)!
    let spacer = sink.child(of: stack, at: 1)!
    let text = sink.child(of: stack, at: 2)!
    #expect(sink.primitive(at: action) == .proxy)
    #expect(sink.primitive(at: spacer) == .spacer(minLength: 2))
    #expect(sink.primitive(at: text) == .text)
    #expect(sink.modifierCount(of: text) == 1)
    #expect(sink.modifier(of: text, at: 0) == .padding(edges: .all, length: 4))
    #expect(sink.modifierScope(of: text, at: 0) != text)
    #expect(sink.textScalarCount(of: text) == 2)
    #expect(sink.textScalar(of: text, at: 0) == 0x41)
    #expect(sink.textScalar(of: text, at: 1) == 0x00b0)
    #expect(sink.textScalar(of: text, at: 2) == nil)
}

private struct AdapterRoot: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            AdapterActionLeaf()
            Spacer(minLength: 2)
            Text("A°").padding(4)
        }
    }
}

private enum AdapterAction: UInt16, GiftUIAction {
    case run = 1
}

private struct AdapterActionLeaf: View, _GiftUISemanticActionPayload {
    let _giftUIAction = AdapterAction.run

    var body: Never {
        fatalError("AdapterActionLeaf has no view body")
    }

    func _giftUITraverse<Visitor: _GiftUISemanticTraversalVisitor>(
        _ visitor: inout Visitor
    ) {
        visitor.visitActionPrimitive(self)
    }
}

private struct AdapterIdentity: SemanticRecordingIdentity {
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

    func isPrefix(of other: Self) -> Bool {
        guard components.count <= other.components.count else { return false }
        return components.elementsEqual(other.components.prefix(components.count))
    }
}

private struct AdapterWorkspace: SemanticExpansionWorkspace {
    let maximumPathComponents: UInt16 = 32
    let maximumIdentities: UInt16 = 32
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
        identity: inout AdapterIdentity?
    ) -> SemanticExpansionError? {
        enter(.root, identity: &identity)
    }

    mutating func enterCustomBody<Declaration: View>(
        _ declaration: Declaration.Type,
        identity: inout AdapterIdentity?
    ) -> SemanticExpansionError? {
        enter(.customBody, identity: &identity)
    }

    mutating func enterFixedChild(
        _ index: UInt8,
        identity: inout AdapterIdentity?
    ) -> SemanticExpansionError? {
        enter(.fixedChild(index), identity: &identity)
    }

    mutating func enterConditionalBranch(
        _ index: UInt8,
        identity: inout AdapterIdentity?
    ) -> SemanticExpansionError? {
        enter(.conditionalBranch(index), identity: &identity)
    }

    mutating func enterOptionalPresence(
        identity: inout AdapterIdentity?
    ) -> SemanticExpansionError? {
        enter(.optionalPresence, identity: &identity)
    }

    mutating func enterDeclarationRole<Declaration>(
        _ declaration: Declaration.Type,
        identity: inout AdapterIdentity?
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
        path.removeAll(keepingCapacity: true)
        isExpanding = false
    }

    private mutating func enter(
        _ component: SemanticRecordingPathComponent,
        identity: inout AdapterIdentity?
    ) -> SemanticExpansionError? {
        path.append(component)
        let role =
            path.reversed().lazy.compactMap { component in
                if case .declarationRole(let role) = component { return role }
                return nil
            }.first ?? SemanticRecordingRole(rawValue: 0)
        identity = AdapterIdentity(components: path, declarationRole: role)
        return nil
    }
}

private struct AdapterPrimitiveRecord {
    let identity: AdapterIdentity
    let primitive: SemanticLayoutPrimitive
    let scalars: [UInt32]?
}

private struct AdapterModifierRecord {
    let identity: AdapterIdentity
    let modifier: SemanticLayoutModifier
    let chainIndex: UInt16
}

private struct AdapterStorage: SemanticLayoutResultStorage {
    let maximumStructuralOccurrences: UInt16 = 32
    let maximumBodyEvaluations: UInt16 = 8
    let maximumSemanticOccurrences: UInt16 = 8
    let maximumModifierApplications: UInt16 = 8
    let maximumActionOccurrences: UInt16 = 2

    private var structural: [AdapterIdentity] = []
    private var primitives: [AdapterPrimitiveRecord] = []
    private var modifiers: [AdapterModifierRecord] = []
    private var isPublished = false

    mutating func beginSemanticResult() -> Bool {
        structural.removeAll(keepingCapacity: true)
        primitives.removeAll(keepingCapacity: true)
        modifiers.removeAll(keepingCapacity: true)
        isPublished = false
        return true
    }

    mutating func stageStructuralOccurrence(
        identity: borrowing AdapterIdentity
    ) -> Bool {
        structural.append(copy identity)
        return true
    }

    mutating func stageBodyEvaluation(
        identity: borrowing AdapterIdentity
    ) -> Bool {
        true
    }

    mutating func stagePrimitive<Payload>(
        identity: borrowing AdapterIdentity,
        primitive: SemanticLayoutPrimitive,
        payload: borrowing Payload
    ) -> Bool where Payload: _GiftUISemanticPrimitivePayload {
        var scalars: [UInt32]?
        if let text = copy payload as? _GiftUITextPayload {
            switch text.content {
            case .admitted(let content):
                scalars = content.withUTF8 { bytes in
                    String(decoding: bytes, as: UTF8.self).unicodeScalars.map(\.value)
                }
            case .invalidDeclaration:
                scalars = [0xd800]
            }
        }
        primitives.append(
            AdapterPrimitiveRecord(
                identity: copy identity,
                primitive: primitive,
                scalars: scalars
            )
        )
        return true
    }

    mutating func stageModifier(
        identity: borrowing AdapterIdentity,
        modifier: SemanticLayoutModifier,
        chainIndex: UInt16
    ) -> Bool {
        modifiers.append(
            AdapterModifierRecord(
                identity: copy identity,
                modifier: modifier,
                chainIndex: chainIndex
            )
        )
        return true
    }

    mutating func stageActionOccurrence(
        identity: borrowing AdapterIdentity
    ) -> Bool {
        primitives.append(
            AdapterPrimitiveRecord(
                identity: copy identity,
                primitive: .proxy,
                scalars: nil
            )
        )
        return true
    }

    mutating func publishSemanticResult(
        _ summary: SemanticExpansionSummary
    ) -> Bool {
        isPublished = true
        return true
    }

    mutating func discardSemanticResult() {
        structural.removeAll(keepingCapacity: true)
        primitives.removeAll(keepingCapacity: true)
        modifiers.removeAll(keepingCapacity: true)
    }

    mutating func resetSemanticResult() {}

    var rootIdentity: AdapterIdentity {
        precondition(isPublished)
        return structural[0]
    }

    var scopeCount: UInt16 {
        UInt16(primitives.count + modifiers.count)
    }

    func primitive(at identity: AdapterIdentity) -> SemanticLayoutPrimitive? {
        primitives.first { $0.identity == identity }?.primitive
    }

    func childCount(of identity: AdapterIdentity) -> UInt16? {
        guard structural.contains(identity) else { return nil }
        return UInt16(children(of: identity).count)
    }

    func child(
        of identity: AdapterIdentity,
        at index: UInt16
    ) -> AdapterIdentity? {
        let children = children(of: identity)
        guard Int(index) < children.count else { return nil }
        return children[Int(index)]
    }

    func modifierCount(of identity: AdapterIdentity) -> UInt16? {
        guard structural.contains(identity) else { return nil }
        return UInt16(modifiers(of: identity).count)
    }

    func modifierScope(
        of identity: AdapterIdentity,
        at index: UInt16
    ) -> AdapterIdentity? {
        let values = modifiers(of: identity)
        guard Int(index) < values.count else { return nil }
        return values[Int(index)].identity
    }

    func modifier(
        of identity: AdapterIdentity,
        at index: UInt16
    ) -> SemanticLayoutModifier? {
        let values = modifiers(of: identity)
        guard Int(index) < values.count else { return nil }
        return values[Int(index)].modifier
    }

    func textScalarCount(of identity: AdapterIdentity) -> UInt16? {
        primitives.first { $0.identity == identity }?.scalars.map { UInt16($0.count) }
    }

    func textScalar(of identity: AdapterIdentity, at index: UInt16) -> UInt32? {
        guard let scalars = primitives.first(where: { $0.identity == identity })?.scalars,
            Int(index) < scalars.count
        else { return nil }
        return scalars[Int(index)]
    }

    private func children(of identity: AdapterIdentity) -> [AdapterIdentity] {
        primitives.compactMap(\.identity).filter { candidate in
            guard identity != candidate, identity.isPrefix(of: candidate) else {
                return false
            }
            return !primitives.contains { intermediate in
                intermediate.identity != identity
                    && intermediate.identity != candidate
                    && identity.isPrefix(of: intermediate.identity)
                    && intermediate.identity.isPrefix(of: candidate)
            }
        }
    }

    private func modifiers(of identity: AdapterIdentity) -> [AdapterModifierRecord] {
        modifiers.filter { $0.identity.isPrefix(of: identity) }
            .sorted { $0.chainIndex < $1.chainIndex }
    }
}
