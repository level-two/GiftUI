import GiftUI
import GiftUIDrawing
import GiftUIInteraction
import GiftUISemanticCore

package struct DynamicSemanticIdentity: SemanticRecordingIdentity {
    package let components: [SemanticRecordingPathComponent]
    package let declarationRole: SemanticRecordingRole
    package let layoutScopeDiscriminator: UInt16?

    package init(
        components: [SemanticRecordingPathComponent],
        declarationRole: SemanticRecordingRole,
        layoutScopeDiscriminator: UInt16? = nil
    ) {
        self.components = components
        self.declarationRole = declarationRole
        self.layoutScopeDiscriminator = layoutScopeDiscriminator
    }

    package var componentCount: UInt16 {
        UInt16(components.count)
    }

    package func component(at index: UInt16) -> SemanticRecordingPathComponent? {
        guard Int(index) < components.count else { return nil }
        return components[Int(index)]
    }

    package func isPrefix(of other: Self) -> Bool {
        guard layoutScopeDiscriminator == nil,
            other.layoutScopeDiscriminator == nil
        else { return false }
        guard components.count <= other.components.count else { return false }
        return components.elementsEqual(other.components.prefix(components.count))
    }

    fileprivate func modifierLayoutScope(discriminator: UInt16) -> Self? {
        guard discriminator > 0 else { return nil }
        return Self(
            components: components,
            declarationRole: declarationRole,
            layoutScopeDiscriminator: discriminator
        )
    }
}

package struct DynamicSemanticExpansionWorkspace: SemanticExpansionWorkspace {
    package let maximumPathComponents: UInt16
    package let maximumIdentities: UInt16
    package private(set) var isExpanding = false

    private var path: [SemanticRecordingPathComponent]
    package private(set) var recordedIdentityCount: UInt16 = 0
    private var nextRole: UInt16 = 0

    package init(maximumPathComponents: UInt16, maximumIdentities: UInt16) {
        self.maximumPathComponents = maximumPathComponents
        self.maximumIdentities = maximumIdentities
        path = []
        path.reserveCapacity(Int(maximumPathComponents))
    }

    package mutating func beginExpansion() -> Bool {
        guard !isExpanding else { return false }
        isExpanding = true
        path.removeAll(keepingCapacity: true)
        recordedIdentityCount = 0
        nextRole = 0
        return true
    }

    package mutating func enterRoot<Declaration: View>(
        _: Declaration.Type,
        identity: inout DynamicSemanticIdentity?
    ) -> SemanticExpansionError? {
        enter(.root, identity: &identity)
    }

    package mutating func enterCustomBody<Declaration: View>(
        _: Declaration.Type,
        identity: inout DynamicSemanticIdentity?
    ) -> SemanticExpansionError? {
        enter(.customBody, identity: &identity)
    }

    package mutating func enterFixedChild(
        _ index: UInt8,
        identity: inout DynamicSemanticIdentity?
    ) -> SemanticExpansionError? {
        enter(.fixedChild(index), identity: &identity)
    }

    package mutating func enterConditionalBranch(
        _ index: UInt8,
        identity: inout DynamicSemanticIdentity?
    ) -> SemanticExpansionError? {
        enter(.conditionalBranch(index), identity: &identity)
    }

    package mutating func enterOptionalPresence(
        identity: inout DynamicSemanticIdentity?
    ) -> SemanticExpansionError? {
        enter(.optionalPresence, identity: &identity)
    }

    package mutating func enterDeclarationRole<Declaration>(
        _: Declaration.Type,
        identity: inout DynamicSemanticIdentity?
    ) -> SemanticExpansionError? {
        let role = SemanticRecordingRole(rawValue: nextRole)
        let successor = nextRole.addingReportingOverflow(1)
        guard !successor.overflow else { return .capacityExhausted }
        nextRole = successor.partialValue
        return enter(.declarationRole(role), identity: &identity)
    }

    package mutating func leavePathComponent() {
        _ = path.popLast()
    }

    package mutating func completeExpansion() {}

    package mutating func discardExpansion() {
        path.removeAll(keepingCapacity: true)
    }

    package mutating func resetExpansion() {
        path.removeAll(keepingCapacity: true)
        isExpanding = false
    }

    private mutating func enter(
        _ component: SemanticRecordingPathComponent,
        identity: inout DynamicSemanticIdentity?
    ) -> SemanticExpansionError? {
        guard path.count < Int(maximumPathComponents),
            recordedIdentityCount < maximumIdentities
        else { return .capacityExhausted }
        path.append(component)
        recordedIdentityCount += 1
        let role =
            path.reversed().lazy.compactMap { component in
                if case .declarationRole(let role) = component { return role }
                return nil
            }.first ?? SemanticRecordingRole(rawValue: 0)
        identity = DynamicSemanticIdentity(
            components: path,
            declarationRole: role
        )
        return nil
    }
}

package struct DynamicSemanticActionRecord: Equatable, Sendable {
    package let identity: DynamicSemanticIdentity
    package let action: BoundedApplicationAction
}

private struct DynamicSemanticPrimitiveRecord {
    let identity: DynamicSemanticIdentity
    let primitive: SemanticLayoutPrimitive
    let renderScope: SemanticRenderScope
    let scalars: [UInt32]?
}

private struct DynamicSemanticModifierRecord {
    let identity: DynamicSemanticIdentity
    let layoutIdentity: DynamicSemanticIdentity
    let modifier: SemanticLayoutModifier
    let renderScope: SemanticRenderScope
    let chainIndex: UInt16
    let disablesActions: Bool
}

private struct DynamicSemanticRenderRecord {
    let identity: DynamicSemanticIdentity
    var scope: SemanticRenderScope
}

private struct DynamicSemanticRenderProjectionNode {
    let identity: DynamicSemanticIdentity
    let scope: SemanticRenderScope
    let children: [DynamicSemanticIdentity]
}

package struct DynamicSemanticRenderView: SemanticRenderView {
    package let rootIdentity: DynamicSemanticIdentity
    package let renderSnapshotVersion: UInt32
    private let nodes: [DynamicSemanticRenderProjectionNode]

    fileprivate init(
        rootIdentity: DynamicSemanticIdentity,
        renderSnapshotVersion: UInt32,
        nodes: [DynamicSemanticRenderProjectionNode]
    ) {
        self.rootIdentity = rootIdentity
        self.renderSnapshotVersion = renderSnapshotVersion
        self.nodes = nodes
    }

    package var semanticScopeCount: UInt16 {
        UInt16(nodes.count)
    }

    package func semanticIdentity(at ordinal: UInt16) -> DynamicSemanticIdentity? {
        guard Int(ordinal) < nodes.count else { return nil }
        return nodes[Int(ordinal)].identity
    }

    package func semanticOrdinal(of identity: DynamicSemanticIdentity) -> UInt16? {
        nodes.firstIndex { $0.identity == identity }.map(UInt16.init)
    }

    package func scope(at identity: DynamicSemanticIdentity) -> SemanticRenderScope? {
        nodes.first { $0.identity == identity }?.scope
    }

    package func layoutIdentity(
        for identity: DynamicSemanticIdentity
    ) -> DynamicSemanticIdentity? {
        nodes.contains { $0.identity == identity } ? identity : nil
    }

    package func childCount(of identity: DynamicSemanticIdentity) -> UInt16? {
        nodes.first { $0.identity == identity }.map { UInt16($0.children.count) }
    }

    package func child(
        of identity: DynamicSemanticIdentity,
        at index: UInt16
    ) -> DynamicSemanticIdentity? {
        guard let children = nodes.first(where: { $0.identity == identity })?.children,
            Int(index) < children.count
        else { return nil }
        return children[Int(index)]
    }
}

package struct DynamicSemanticHostStorage: SemanticExpansionSink,
    SemanticLayoutView, CanvasInvocationSource
{
    package let maximumStructuralOccurrences: UInt16
    package let maximumBodyEvaluations: UInt16
    package let maximumSemanticOccurrences: UInt16
    package let maximumModifierApplications: UInt16
    package let maximumActionOccurrences: UInt16

    private var structural: [DynamicSemanticIdentity] = []
    private var primitives: [DynamicSemanticPrimitiveRecord] = []
    private var modifiers: [DynamicSemanticModifierRecord] = []
    private var renderScopes: [DynamicSemanticRenderRecord] = []
    private var actions: [DynamicSemanticActionRecord] = []
    private var canvasStorage: DynamicCanvasCallableStorage<DynamicSemanticIdentity>
    private var publishedRenderView: DynamicSemanticRenderView?
    private var bodyEvaluationCount: UInt16 = 0
    private var isRecording = false
    private var isPublished = false
    package private(set) var renderSnapshotVersion: UInt32 = 0

    package init(
        limits: SemanticExpansionLimits,
        maximumStructuralOccurrences: UInt16,
        canvasCapacity: UInt16
    ) {
        precondition(maximumStructuralOccurrences >= limits.maximumSemanticNodes)
        self.maximumStructuralOccurrences = maximumStructuralOccurrences
        maximumBodyEvaluations = limits.maximumBodyEvaluations
        maximumSemanticOccurrences = limits.maximumSemanticNodes
        maximumModifierApplications = limits.maximumModifierApplications
        maximumActionOccurrences = limits.maximumActionOccurrences
        canvasStorage = DynamicCanvasCallableStorage(capacity: canvasCapacity)
        structural.reserveCapacity(Int(maximumStructuralOccurrences))
        primitives.reserveCapacity(Int(limits.maximumSemanticNodes))
        modifiers.reserveCapacity(Int(limits.maximumModifierApplications))
        renderScopes.reserveCapacity(Int(limits.maximumSemanticNodes))
        actions.reserveCapacity(Int(limits.maximumActionOccurrences))
    }

    package mutating func beginExpansion() -> Bool {
        guard !isRecording else { return false }
        clearAttempt()
        isRecording = true
        isPublished = false
        return true
    }

    package mutating func stageStructuralOccurrence(
        identity: borrowing DynamicSemanticIdentity
    ) -> Bool {
        guard isRecording,
            structural.count < Int(maximumStructuralOccurrences),
            !structural.contains(identity)
        else { return false }
        let identity = copy identity
        structural.append(identity)
        renderScopes.append(
            DynamicSemanticRenderRecord(identity: identity, scope: .structural)
        )
        return true
    }

    package mutating func stageBodyEvaluation(
        identity _: borrowing DynamicSemanticIdentity
    ) -> Bool {
        guard isRecording, bodyEvaluationCount < maximumBodyEvaluations else {
            return false
        }
        bodyEvaluationCount += 1
        return true
    }

    package mutating func stageSemanticOccurrence<Payload>(
        identity: borrowing DynamicSemanticIdentity,
        payload: borrowing Payload
    ) -> Bool where Payload: _GiftUISemanticPrimitivePayload {
        guard isRecording,
            primitives.count + actions.count < Int(maximumSemanticOccurrences)
        else { return false }
        let payload = copy payload
        let identity = copy identity
        var scalars: [UInt32]?
        if let text = payload as? _GiftUITextPayload {
            switch text.content {
            case .admitted(let content):
                scalars = content.withUTF8 {
                    String(decoding: $0, as: UTF8.self).unicodeScalars.map(\.value)
                }
            case .invalidDeclaration:
                scalars = [0xD800]
            }
        }
        if let canvas = payload as? Canvas,
            !canvasStorage.stage(identity: identity, canvas: canvas)
        {
            return false
        }
        primitives.append(
            DynamicSemanticPrimitiveRecord(
                identity: identity,
                primitive: SemanticLayoutPrimitive(payload: payload),
                renderScope: SemanticRenderScope(primitivePayload: payload),
                scalars: scalars
            )
        )
        setRenderScope(SemanticRenderScope(primitivePayload: payload), for: identity)
        return true
    }

    package mutating func stageModifierApplication<Payload>(
        identity: borrowing DynamicSemanticIdentity,
        payload: borrowing Payload,
        chainIndex: UInt16
    ) -> Bool where Payload: _GiftUISemanticModifierPayload {
        guard isRecording,
            modifiers.count < Int(maximumModifierApplications)
        else { return false }
        let payload = copy payload
        let modifier: SemanticLayoutModifier
        let disablesActions: Bool
        if let disabled = payload as? DisabledSemanticPayload {
            modifier = .passthrough
            disablesActions = disabled.isDisabled
        } else {
            guard let mapped = SemanticLayoutModifier(payload: payload) else {
                return false
            }
            modifier = mapped
            disablesActions = false
        }
        let identity = copy identity
        let scopeOrdinal = UInt16(modifiers.count).addingReportingOverflow(1)
        guard !scopeOrdinal.overflow,
            let layoutIdentity = identity.modifierLayoutScope(
                discriminator: scopeOrdinal.partialValue
            )
        else { return false }
        modifiers.append(
            DynamicSemanticModifierRecord(
                identity: identity,
                layoutIdentity: layoutIdentity,
                modifier: modifier,
                renderScope: SemanticRenderScope(modifierPayload: payload),
                chainIndex: chainIndex,
                disablesActions: disablesActions
            )
        )
        setRenderScope(SemanticRenderScope(modifierPayload: payload), for: identity)
        return true
    }

    package mutating func stageActionOccurrence<Action>(
        identity: borrowing DynamicSemanticIdentity,
        action: borrowing Action
    ) -> Bool where Action: GiftUIAction {
        guard isRecording,
            actions.count < Int(maximumActionOccurrences),
            primitives.count + actions.count < Int(maximumSemanticOccurrences)
        else { return false }
        let identity = copy identity
        actions.append(
            DynamicSemanticActionRecord(
                identity: identity,
                action: BoundedApplicationAction(code: action.rawValue)
            )
        )
        return true
    }

    package mutating func publishExpansion(
        _ summary: SemanticExpansionSummary
    ) -> Bool {
        guard isRecording, !structural.isEmpty,
            summary.bodyEvaluationCount == bodyEvaluationCount,
            summary.semanticNodeCount == UInt16(primitives.count + actions.count),
            summary.modifierApplicationCount == UInt16(modifiers.count),
            summary.actionOccurrenceCount == UInt16(actions.count)
        else { return false }
        let nextVersion = renderSnapshotVersion.addingReportingOverflow(1)
        guard !nextVersion.overflow, nextVersion.partialValue != 0 else { return false }
        guard
            let renderView = makeRenderView(
                snapshotVersion: nextVersion.partialValue
            )
        else { return false }
        renderSnapshotVersion = nextVersion.partialValue
        publishedRenderView = renderView
        isRecording = false
        isPublished = true
        return true
    }

    package mutating func discardExpansion() {
        clearAttempt()
        isRecording = false
        isPublished = false
    }

    package mutating func resetExpansion() {}

    package var rootIdentity: DynamicSemanticIdentity {
        precondition(isPublished && !structural.isEmpty)
        return structural[0]
    }

    package var scopeCount: UInt16 {
        UInt16(primitives.count + modifiers.count + actions.count)
    }

    package var semanticScopeCount: UInt16 {
        UInt16(structural.count)
    }

    package var actionOccurrenceCount: UInt16 {
        UInt16(actions.count)
    }

    package var hasPublishedResult: Bool {
        isPublished
    }

    package var renderView: DynamicSemanticRenderView {
        precondition(isPublished)
        return publishedRenderView!
    }

    package func action(at index: UInt16) -> DynamicSemanticActionRecord? {
        guard isPublished, Int(index) < actions.count else { return nil }
        return actions[Int(index)]
    }

    package func isActionEnabled(at identity: DynamicSemanticIdentity) -> Bool {
        isPublished
            && !modifiers.contains {
                $0.disablesActions && $0.identity.isPrefix(of: identity)
            }
    }

    package func primitive(
        at identity: DynamicSemanticIdentity
    ) -> SemanticLayoutPrimitive? {
        primitives.first { $0.identity == identity }?.primitive
            ?? (actions.contains { $0.identity == identity } ? .proxy : nil)
    }

    package func childCount(of identity: DynamicSemanticIdentity) -> UInt16? {
        guard isPublished, structural.contains(identity) else { return nil }
        return UInt16(children(of: identity).count)
    }

    package func child(
        of identity: DynamicSemanticIdentity,
        at index: UInt16
    ) -> DynamicSemanticIdentity? {
        guard isPublished, structural.contains(identity) else { return nil }
        let children = children(of: identity)
        guard Int(index) < children.count else { return nil }
        return children[Int(index)]
    }

    package func modifierCount(of identity: DynamicSemanticIdentity) -> UInt16? {
        guard isPublished, structural.contains(identity) else { return nil }
        return UInt16(modifiers(of: identity).count)
    }

    package func modifierScope(
        of identity: DynamicSemanticIdentity,
        at index: UInt16
    ) -> DynamicSemanticIdentity? {
        let values = modifiers(of: identity)
        guard Int(index) < values.count else { return nil }
        return values[Int(index)].layoutIdentity
    }

    package func modifier(
        of identity: DynamicSemanticIdentity,
        at index: UInt16
    ) -> SemanticLayoutModifier? {
        let values = modifiers(of: identity)
        guard Int(index) < values.count else { return nil }
        return values[Int(index)].modifier
    }

    package func modifierDisablesActions(
        of identity: DynamicSemanticIdentity,
        at index: UInt16
    ) -> Bool? {
        let values = modifiers(of: identity)
        guard Int(index) < values.count else { return nil }
        return values[Int(index)].disablesActions
    }

    package func textScalarCount(of identity: DynamicSemanticIdentity) -> UInt16? {
        primitives.first { $0.identity == identity }?.scalars.map {
            UInt16($0.count)
        }
    }

    package func textScalar(
        of identity: DynamicSemanticIdentity,
        at index: UInt16
    ) -> UInt32? {
        guard let scalars = primitives.first(where: { $0.identity == identity })?.scalars,
            Int(index) < scalars.count
        else { return nil }
        return scalars[Int(index)]
    }

    package func semanticIdentity(at ordinal: UInt16) -> DynamicSemanticIdentity? {
        guard isPublished, Int(ordinal) < structural.count else { return nil }
        return structural[Int(ordinal)]
    }

    package func semanticOrdinal(of identity: DynamicSemanticIdentity) -> UInt16? {
        guard isPublished else { return nil }
        return structural.firstIndex(of: identity).map(UInt16.init)
    }

    package func scope(at identity: DynamicSemanticIdentity) -> SemanticRenderScope? {
        guard isPublished else { return nil }
        return renderScopes.first { $0.identity == identity }?.scope
    }

    package func layoutIdentity(
        for identity: DynamicSemanticIdentity
    ) -> DynamicSemanticIdentity? {
        guard isPublished, structural.contains(identity) else { return nil }
        if primitive(at: identity) != nil
            || modifiers.contains(where: { $0.identity == identity })
        {
            return identity
        }
        return structural.first { candidate in
            identity != candidate && identity.isPrefix(of: candidate)
                && (primitive(at: candidate) != nil
                    || modifiers.contains(where: { $0.identity == candidate }))
        }
    }

    package var canvasOccurrenceCount: UInt16 {
        canvasStorage.canvasOccurrenceCount
    }

    package func canvasIdentity(at index: UInt16) -> DynamicSemanticIdentity? {
        canvasStorage.canvasIdentity(at: index)
    }

    package mutating func invokeCanvas(
        at identity: DynamicSemanticIdentity,
        context: inout GraphicsContext,
        size: Size
    ) throws(DrawingError) {
        try canvasStorage.invokeCanvas(at: identity, context: &context, size: size)
    }

    package mutating func releaseCanvas(at identity: DynamicSemanticIdentity) {
        canvasStorage.releaseCanvas(at: identity)
    }

    private mutating func clearAttempt() {
        structural.removeAll(keepingCapacity: true)
        primitives.removeAll(keepingCapacity: true)
        modifiers.removeAll(keepingCapacity: true)
        renderScopes.removeAll(keepingCapacity: true)
        actions.removeAll(keepingCapacity: true)
        canvasStorage.discard()
        publishedRenderView = nil
        bodyEvaluationCount = 0
    }

    private mutating func setRenderScope(
        _ scope: SemanticRenderScope,
        for identity: DynamicSemanticIdentity
    ) {
        guard let index = renderScopes.firstIndex(where: { $0.identity == identity }) else {
            return
        }
        renderScopes[index].scope = scope
    }

    private func children(
        of identity: DynamicSemanticIdentity
    ) -> [DynamicSemanticIdentity] {
        let layoutIdentities = primitives.map(\.identity) + actions.map(\.identity)
        return layoutIdentities.filter { candidate in
            guard identity != candidate, identity.isPrefix(of: candidate) else {
                return false
            }
            return !layoutIdentities.contains { intermediate in
                intermediate != identity && intermediate != candidate
                    && identity.isPrefix(of: intermediate)
                    && intermediate.isPrefix(of: candidate)
            }
        }
    }

    private func modifiers(
        of identity: DynamicSemanticIdentity
    ) -> [DynamicSemanticModifierRecord] {
        let layoutIdentities = primitives.map(\.identity) + actions.map(\.identity)
        return modifiers.filter { record in
            record.identity.isPrefix(of: identity)
                && !layoutIdentities.contains { intermediate in
                    intermediate != identity
                        && record.identity.isPrefix(of: intermediate)
                        && intermediate.isPrefix(of: identity)
                }
        }
        .sorted { $0.chainIndex < $1.chainIndex }
    }

    private func makeRenderView(
        snapshotVersion: UInt32
    ) -> DynamicSemanticRenderView? {
        let occurrenceIdentities = primitives.map(\.identity) + actions.map(\.identity)
        guard !occurrenceIdentities.isEmpty else { return nil }

        func entryIdentity(
            for identity: DynamicSemanticIdentity
        ) -> DynamicSemanticIdentity {
            modifiers(of: identity).last?.layoutIdentity ?? identity
        }

        guard let recordedRoot = structural.first else { return nil }
        let rootOccurrences: [DynamicSemanticIdentity]
        if occurrenceIdentities.contains(recordedRoot) {
            rootOccurrences = [recordedRoot]
        } else {
            rootOccurrences = children(of: recordedRoot)
        }
        guard rootOccurrences.count == 1 else { return nil }

        var nodes: [DynamicSemanticRenderProjectionNode] = []
        nodes.reserveCapacity(Int(scopeCount))
        for identity in occurrenceIdentities {
            let modifierRecords = modifiers(of: identity)
            for (index, record) in modifierRecords.enumerated() {
                let child =
                    index == 0
                    ? identity
                    : modifierRecords[index - 1].layoutIdentity
                nodes.append(
                    DynamicSemanticRenderProjectionNode(
                        identity: record.layoutIdentity,
                        scope: record.renderScope,
                        children: [child]
                    )
                )
            }

            let childEntries = children(of: identity).map(entryIdentity(for:))
            let primitiveScope =
                primitives.first {
                    $0.identity == identity
                }?.renderScope ?? .structural
            nodes.append(
                DynamicSemanticRenderProjectionNode(
                    identity: identity,
                    scope: primitiveScope,
                    children: childEntries
                )
            )
        }

        guard nodes.count == Int(scopeCount) else { return nil }
        for (index, node) in nodes.enumerated()
        where nodes[..<index].contains(where: { $0.identity == node.identity }) {
            return nil
        }
        let identities = nodes.map(\.identity)
        guard
            nodes.allSatisfy({ node in
                node.children.allSatisfy(identities.contains)
            })
        else { return nil }

        return DynamicSemanticRenderView(
            rootIdentity: entryIdentity(for: rootOccurrences[0]),
            renderSnapshotVersion: snapshotVersion,
            nodes: nodes
        )
    }
}
