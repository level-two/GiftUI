import GiftUI

package struct SemanticExpansionLimits: Equatable, Sendable {
    package let maximumDepth: UInt16
    package let maximumSemanticNodes: UInt16
    package let maximumBodyEvaluations: UInt16
    package let maximumModifierApplications: UInt16
    package let maximumActionOccurrences: UInt16

    package init?(
        maximumDepth: UInt16,
        maximumSemanticNodes: UInt16,
        maximumBodyEvaluations: UInt16,
        maximumModifierApplications: UInt16,
        maximumActionOccurrences: UInt16
    ) {
        guard maximumDepth > 0,
            maximumSemanticNodes > 0,
            maximumBodyEvaluations > 0
        else { return nil }
        self.maximumDepth = maximumDepth
        self.maximumSemanticNodes = maximumSemanticNodes
        self.maximumBodyEvaluations = maximumBodyEvaluations
        self.maximumModifierApplications = maximumModifierApplications
        self.maximumActionOccurrences = maximumActionOccurrences
    }
}

package struct SemanticExpansionSummary: Equatable, Sendable {
    package let semanticNodeCount: UInt16
    package let bodyEvaluationCount: UInt16
    package let modifierApplicationCount: UInt16
    package let actionOccurrenceCount: UInt16
    package let maximumObservedDepth: UInt16

    package init(
        semanticNodeCount: UInt16,
        bodyEvaluationCount: UInt16,
        modifierApplicationCount: UInt16,
        actionOccurrenceCount: UInt16,
        maximumObservedDepth: UInt16
    ) {
        self.semanticNodeCount = semanticNodeCount
        self.bodyEvaluationCount = bodyEvaluationCount
        self.modifierApplicationCount = modifierApplicationCount
        self.actionOccurrenceCount = actionOccurrenceCount
        self.maximumObservedDepth = maximumObservedDepth
    }
}

package enum SemanticExpansionError: UInt8, Equatable, Sendable {
    case capacityExhausted = 0
    case invalidIdentity = 1
    case reentrancyViolation = 2
    case invariantViolation = 3
}

package enum SemanticExpansionResult: Equatable, Sendable {
    case success(SemanticExpansionSummary)
    case failure(SemanticExpansionError)
}

package protocol SemanticExpansionWorkspace {
    associatedtype Identity: Equatable

    var maximumPathComponents: UInt16 { get }
    var maximumIdentities: UInt16 { get }
    var isExpanding: Bool { get }

    mutating func beginExpansion() -> Bool

    mutating func enterRoot<Declaration: View>(
        _ declaration: Declaration.Type,
        identity: inout Identity?
    ) -> SemanticExpansionError?

    mutating func enterCustomBody<Declaration: View>(
        _ declaration: Declaration.Type,
        identity: inout Identity?
    ) -> SemanticExpansionError?

    mutating func enterFixedChild(
        _ index: UInt8,
        identity: inout Identity?
    ) -> SemanticExpansionError?

    mutating func enterConditionalBranch(
        _ index: UInt8,
        identity: inout Identity?
    ) -> SemanticExpansionError?

    mutating func enterOptionalPresence(
        identity: inout Identity?
    ) -> SemanticExpansionError?

    mutating func enterDeclarationRole<Declaration>(
        _ declaration: Declaration.Type,
        identity: inout Identity?
    ) -> SemanticExpansionError?

    mutating func leavePathComponent()
    mutating func completeExpansion()
    mutating func discardExpansion()
    mutating func resetExpansion()
}

package protocol SemanticExpansionSink {
    associatedtype Identity: Equatable

    var maximumStructuralOccurrences: UInt16 { get }
    var maximumSemanticOccurrences: UInt16 { get }
    var maximumModifierApplications: UInt16 { get }
    var maximumActionOccurrences: UInt16 { get }

    mutating func beginExpansion() -> Bool

    mutating func stageStructuralOccurrence(
        identity: borrowing Identity
    ) -> Bool

    mutating func stageSemanticOccurrence<
        Payload: _GiftUISemanticPrimitivePayload
    >(
        identity: borrowing Identity,
        payload: borrowing Payload
    ) -> Bool

    mutating func stageModifierApplication<
        Payload: _GiftUISemanticModifierPayload
    >(
        identity: borrowing Identity,
        payload: borrowing Payload,
        chainIndex: UInt16
    ) -> Bool

    mutating func stageActionOccurrence<Action: GiftUIAction>(
        identity: borrowing Identity,
        action: borrowing Action
    ) -> Bool

    mutating func publishExpansion(_ summary: SemanticExpansionSummary) -> Bool
    mutating func discardExpansion()
    mutating func resetExpansion()
}

struct SemanticExpansionAttempt {
    let limits: SemanticExpansionLimits

    private(set) var semanticNodeCount: UInt16 = 0
    private(set) var bodyEvaluationCount: UInt16 = 0
    private(set) var modifierApplicationCount: UInt16 = 0
    private(set) var actionOccurrenceCount: UInt16 = 0
    private(set) var maximumObservedDepth: UInt16 = 0

    private var currentDepth: UInt16 = 0
    private var identityCount: UInt16 = 0
    private var structuralOccurrenceCount: UInt16 = 0
    private var workspacePathCapacity: UInt16 = 0
    private var workspaceIdentityCapacity: UInt16 = 0
    private var sinkStructuralCapacity: UInt16 = 0
    private var sinkSemanticCapacity: UInt16 = 0
    private var sinkModifierCapacity: UInt16 = 0
    private var sinkActionCapacity: UInt16 = 0
    private var workspaceBegan = false
    private var sinkBegan = false
    private var firstFailure: SemanticExpansionError?

    init(limits: SemanticExpansionLimits) {
        self.limits = limits
    }

    mutating func begin<Workspace: SemanticExpansionWorkspace, Sink: SemanticExpansionSink>(
        workspace: inout Workspace,
        sink: inout Sink
    ) -> SemanticExpansionError? where Workspace.Identity == Sink.Identity {
        guard firstFailure == nil, !workspaceBegan, !sinkBegan else {
            return record(.invariantViolation)
        }
        guard !workspace.isExpanding else {
            return record(.reentrancyViolation)
        }

        workspacePathCapacity = workspace.maximumPathComponents
        workspaceIdentityCapacity = workspace.maximumIdentities
        sinkStructuralCapacity = sink.maximumStructuralOccurrences
        sinkSemanticCapacity = sink.maximumSemanticOccurrences
        sinkModifierCapacity = sink.maximumModifierApplications
        sinkActionCapacity = sink.maximumActionOccurrences

        guard workspace.beginExpansion() else {
            return record(.invariantViolation)
        }
        workspaceBegan = true

        guard sink.beginExpansion() else {
            return fail(.invariantViolation, workspace: &workspace, sink: &sink)
        }
        sinkBegan = true
        return nil
    }

    mutating func enterRoot<Declaration: View, Workspace: SemanticExpansionWorkspace>(
        _ declaration: Declaration.Type,
        workspace: inout Workspace,
        identity: inout Workspace.Identity?
    ) -> SemanticExpansionError? {
        enterPath(workspace: &workspace, identity: &identity) {
            $0.enterRoot(declaration, identity: &$1)
        }
    }

    mutating func enterCustomBody<Declaration: View, Workspace: SemanticExpansionWorkspace>(
        _ declaration: Declaration.Type,
        workspace: inout Workspace,
        identity: inout Workspace.Identity?
    ) -> SemanticExpansionError? {
        enterPath(workspace: &workspace, identity: &identity) {
            $0.enterCustomBody(declaration, identity: &$1)
        }
    }

    mutating func enterFixedChild<Workspace: SemanticExpansionWorkspace>(
        _ index: UInt8,
        workspace: inout Workspace,
        identity: inout Workspace.Identity?
    ) -> SemanticExpansionError? {
        enterPath(workspace: &workspace, identity: &identity) {
            $0.enterFixedChild(index, identity: &$1)
        }
    }

    mutating func enterConditionalBranch<Workspace: SemanticExpansionWorkspace>(
        _ index: UInt8,
        workspace: inout Workspace,
        identity: inout Workspace.Identity?
    ) -> SemanticExpansionError? {
        enterPath(workspace: &workspace, identity: &identity) {
            $0.enterConditionalBranch(index, identity: &$1)
        }
    }

    mutating func enterOptionalPresence<Workspace: SemanticExpansionWorkspace>(
        workspace: inout Workspace,
        identity: inout Workspace.Identity?
    ) -> SemanticExpansionError? {
        enterPath(workspace: &workspace, identity: &identity) {
            $0.enterOptionalPresence(identity: &$1)
        }
    }

    mutating func enterDeclarationRole<Declaration, Workspace: SemanticExpansionWorkspace>(
        _ declaration: Declaration.Type,
        workspace: inout Workspace,
        identity: inout Workspace.Identity?
    ) -> SemanticExpansionError? {
        enterPath(workspace: &workspace, identity: &identity) {
            $0.enterDeclarationRole(declaration, identity: &$1)
        }
    }

    mutating func leavePathComponent<Workspace: SemanticExpansionWorkspace>(
        workspace: inout Workspace
    ) -> SemanticExpansionError? {
        guard firstFailure == nil else { return firstFailure }
        guard currentDepth > 0 else { return record(.invariantViolation) }
        workspace.leavePathComponent()
        currentDepth -= 1
        return nil
    }

    mutating func reserveBodyEvaluation() -> SemanticExpansionError? {
        guard firstFailure == nil else { return firstFailure }
        guard
            let next = reservedValue(
                after: bodyEvaluationCount,
                limit: limits.maximumBodyEvaluations
            )
        else {
            return record(.capacityExhausted)
        }
        bodyEvaluationCount = next
        return nil
    }

    mutating func stageStructuralOccurrence<Workspace, Sink>(
        identity: borrowing Workspace.Identity,
        workspace: inout Workspace,
        sink: inout Sink
    ) -> SemanticExpansionError?
    where
        Workspace: SemanticExpansionWorkspace,
        Sink: SemanticExpansionSink,
        Workspace.Identity == Sink.Identity
    {
        guard firstFailure == nil else { return firstFailure }
        guard
            let next = reservedValue(
                after: structuralOccurrenceCount,
                limit: sinkStructuralCapacity
            )
        else {
            return record(.capacityExhausted)
        }
        structuralOccurrenceCount = next
        guard sink.stageStructuralOccurrence(identity: identity) else {
            return record(.invariantViolation)
        }
        return nil
    }

    mutating func stageSemanticOccurrence<Payload, Workspace, Sink>(
        identity: borrowing Workspace.Identity,
        payload: borrowing Payload,
        workspace: inout Workspace,
        sink: inout Sink
    ) -> SemanticExpansionError?
    where
        Payload: _GiftUISemanticPrimitivePayload,
        Workspace: SemanticExpansionWorkspace,
        Sink: SemanticExpansionSink,
        Workspace.Identity == Sink.Identity
    {
        guard firstFailure == nil else { return firstFailure }
        guard
            let next = reservedValue(
                after: semanticNodeCount,
                limit: limits.maximumSemanticNodes
            )
        else {
            return record(.capacityExhausted)
        }
        semanticNodeCount = next
        guard semanticNodeCount <= sinkSemanticCapacity else {
            return record(.capacityExhausted)
        }
        guard sink.stageSemanticOccurrence(identity: identity, payload: payload) else {
            return record(.invariantViolation)
        }
        return nil
    }

    mutating func stageModifierApplication<Payload, Workspace, Sink>(
        identity: borrowing Workspace.Identity,
        payload: borrowing Payload,
        chainIndex: UInt16,
        workspace: inout Workspace,
        sink: inout Sink
    ) -> SemanticExpansionError?
    where
        Payload: _GiftUISemanticModifierPayload,
        Workspace: SemanticExpansionWorkspace,
        Sink: SemanticExpansionSink,
        Workspace.Identity == Sink.Identity
    {
        guard firstFailure == nil else { return firstFailure }
        guard
            let next = reservedValue(
                after: modifierApplicationCount,
                limit: limits.maximumModifierApplications
            )
        else {
            return record(.capacityExhausted)
        }
        modifierApplicationCount = next
        guard modifierApplicationCount <= sinkModifierCapacity else {
            return record(.capacityExhausted)
        }
        guard
            sink.stageModifierApplication(
                identity: identity,
                payload: payload,
                chainIndex: chainIndex
            )
        else {
            return record(.invariantViolation)
        }
        return nil
    }

    mutating func stageActionOccurrence<Action, Workspace, Sink>(
        identity: borrowing Workspace.Identity,
        action: borrowing Action,
        workspace: inout Workspace,
        sink: inout Sink
    ) -> SemanticExpansionError?
    where
        Action: GiftUIAction,
        Workspace: SemanticExpansionWorkspace,
        Sink: SemanticExpansionSink,
        Workspace.Identity == Sink.Identity
    {
        guard firstFailure == nil else { return firstFailure }
        guard
            let nextSemanticNode = reservedValue(
                after: semanticNodeCount,
                limit: limits.maximumSemanticNodes
            )
        else {
            return record(.capacityExhausted)
        }
        semanticNodeCount = nextSemanticNode
        guard semanticNodeCount <= sinkSemanticCapacity else {
            return record(.capacityExhausted)
        }
        guard
            let nextAction = reservedValue(
                after: actionOccurrenceCount,
                limit: limits.maximumActionOccurrences
            )
        else {
            return record(.capacityExhausted)
        }
        actionOccurrenceCount = nextAction
        guard actionOccurrenceCount <= sinkActionCapacity else {
            return record(.capacityExhausted)
        }
        guard sink.stageActionOccurrence(identity: identity, action: action) else {
            return record(.invariantViolation)
        }
        return nil
    }

    mutating func succeed<Workspace, Sink>(
        workspace: inout Workspace,
        sink: inout Sink
    ) -> SemanticExpansionResult
    where
        Workspace: SemanticExpansionWorkspace,
        Sink: SemanticExpansionSink,
        Workspace.Identity == Sink.Identity
    {
        if let firstFailure {
            return .failure(fail(firstFailure, workspace: &workspace, sink: &sink))
        }
        guard workspaceBegan, sinkBegan, currentDepth == 0, maximumObservedDepth > 0 else {
            return .failure(
                fail(.invariantViolation, workspace: &workspace, sink: &sink)
            )
        }

        let summary = SemanticExpansionSummary(
            semanticNodeCount: semanticNodeCount,
            bodyEvaluationCount: bodyEvaluationCount,
            modifierApplicationCount: modifierApplicationCount,
            actionOccurrenceCount: actionOccurrenceCount,
            maximumObservedDepth: maximumObservedDepth
        )
        workspace.completeExpansion()
        guard sink.publishExpansion(summary) else {
            return .failure(
                fail(.invariantViolation, workspace: &workspace, sink: &sink)
            )
        }
        workspace.resetExpansion()
        sink.resetExpansion()
        workspaceBegan = false
        sinkBegan = false
        return .success(summary)
    }

    mutating func fail<Workspace, Sink>(
        _ error: SemanticExpansionError,
        workspace: inout Workspace,
        sink: inout Sink
    ) -> SemanticExpansionError
    where
        Workspace: SemanticExpansionWorkspace,
        Sink: SemanticExpansionSink,
        Workspace.Identity == Sink.Identity
    {
        let error = record(error)
        if workspaceBegan {
            workspace.discardExpansion()
        }
        if sinkBegan {
            sink.discardExpansion()
        }
        if workspaceBegan {
            workspace.resetExpansion()
        }
        if sinkBegan {
            sink.resetExpansion()
        }
        workspaceBegan = false
        sinkBegan = false
        return error
    }

    private mutating func enterPath<Workspace: SemanticExpansionWorkspace>(
        workspace: inout Workspace,
        identity: inout Workspace.Identity?,
        enter: (inout Workspace, inout Workspace.Identity?) -> SemanticExpansionError?
    ) -> SemanticExpansionError? {
        guard firstFailure == nil else { return firstFailure }
        let nextDepth = currentDepth.addingReportingOverflow(1)
        guard !nextDepth.overflow,
            nextDepth.partialValue <= limits.maximumDepth,
            nextDepth.partialValue <= workspacePathCapacity
        else {
            return record(.capacityExhausted)
        }

        identity = nil
        if let error = enter(&workspace, &identity) {
            return record(error)
        }
        guard identity != nil else { return record(.invalidIdentity) }
        guard
            let nextIdentityCount = reservedValue(
                after: identityCount,
                limit: workspaceIdentityCapacity
            )
        else {
            return record(.capacityExhausted)
        }
        identityCount = nextIdentityCount

        currentDepth = nextDepth.partialValue
        if currentDepth > maximumObservedDepth {
            maximumObservedDepth = currentDepth
        }
        return nil
    }

    private func reservedValue(
        after count: UInt16,
        limit: UInt16
    ) -> UInt16? {
        let next = count.addingReportingOverflow(1)
        guard !next.overflow, next.partialValue <= limit else { return nil }
        return next.partialValue
    }

    private mutating func record(_ error: SemanticExpansionError) -> SemanticExpansionError {
        if firstFailure == nil {
            firstFailure = error
        }
        return firstFailure ?? error
    }
}

package func expandSemanticTree<
    Root: View,
    Workspace: SemanticExpansionWorkspace,
    Sink: SemanticExpansionSink
>(
    _ root: borrowing Root,
    limits: SemanticExpansionLimits,
    workspace: inout Workspace,
    sink: inout Sink
) -> SemanticExpansionResult where Workspace.Identity == Sink.Identity {
    var attempt = SemanticExpansionAttempt(limits: limits)
    if let error = attempt.begin(workspace: &workspace, sink: &sink) {
        return .failure(error)
    }

    // T2.3 installs traversal through the bounded attempt coordinator. Until
    // then, fail atomically after exercising the complete caller-owned begin,
    // discard, and idle-reset lifecycle.
    return .failure(
        attempt.fail(.invariantViolation, workspace: &workspace, sink: &sink)
    )
}
