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

private struct SemanticExpansionTraversal<Workspace, Sink>:
    _GiftUISemanticTraversalVisitor
where
    Workspace: SemanticExpansionWorkspace,
    Sink: SemanticExpansionSink,
    Workspace.Identity == Sink.Identity
{
    private(set) var attempt: SemanticExpansionAttempt
    private(set) var workspace: Workspace
    private(set) var sink: Sink

    private(set) var failure: SemanticExpansionError?
    private var currentIdentity: Workspace.Identity?
    private var currentCategoryWasVisited = false
    private var nextModifierChainIndex: UInt16 = 0

    init(
        attempt: SemanticExpansionAttempt,
        workspace: Workspace,
        sink: Sink
    ) {
        self.attempt = attempt
        self.workspace = workspace
        self.sink = sink
    }

    mutating func expandRoot<Root: View>(_ root: borrowing Root) {
        guard failure == nil else { return }
        var rootIdentity: Workspace.Identity?
        if let error = attempt.enterRoot(
            Root.self,
            workspace: &workspace,
            identity: &rootIdentity
        ) {
            stop(error)
            return
        }
        guard let rootIdentity else {
            stop(.invalidIdentity)
            return
        }

        currentIdentity = rootIdentity
        expandDeclaration(root)
        guard failure == nil else { return }
        if let error = attempt.leavePathComponent(workspace: &workspace) {
            stop(error)
        }
    }

    mutating func visitCustomView<Declaration: View>(
        _ declaration: borrowing Declaration,
        body: () -> Declaration.Body
    ) {
        guard beginCategory() else { return }
        var bodyIdentity: Workspace.Identity?
        if let error = attempt.enterCustomBody(
            Declaration.self,
            workspace: &workspace,
            identity: &bodyIdentity
        ) {
            stop(error)
            return
        }
        guard let bodyIdentity else {
            stop(.invalidIdentity)
            return
        }
        currentIdentity = bodyIdentity

        if let error = attempt.reserveBodyEvaluation() {
            stop(error)
            return
        }
        let evaluatedBody = body()
        expandDeclaration(evaluatedBody)
        guard failure == nil else { return }
        if let error = attempt.leavePathComponent(workspace: &workspace) {
            stop(error)
        }
    }

    mutating func visitStatefulCustomView<
        Declaration: View & _GiftUIObservableStateHost
    >(
        _ declaration: borrowing Declaration,
        body: (borrowing Declaration) -> Declaration.Body
    ) {
        guard beginCategory() else { return }

        // SPEC-010's binding decorator owns this category. Milestone 5 installs
        // that combined coordinator; Semantic Core must not evaluate the body
        // or invent state binding before then.
        stop(.invariantViolation)
    }

    mutating func visitEmpty() {
        _ = beginCategory()
    }

    mutating func visitFixed<A: View, B: View>(
        _ a: borrowing A,
        _ b: borrowing B
    ) {
        guard beginCategory() else { return }
        expandFixedChild(a, index: 0)
        expandFixedChild(b, index: 1)
    }

    mutating func visitFixed<A: View, B: View, C: View>(
        _ a: borrowing A,
        _ b: borrowing B,
        _ c: borrowing C
    ) {
        guard beginCategory() else { return }
        expandFixedChild(a, index: 0)
        expandFixedChild(b, index: 1)
        expandFixedChild(c, index: 2)
    }

    mutating func visitFixed<A: View, B: View, C: View, D: View>(
        _ a: borrowing A,
        _ b: borrowing B,
        _ c: borrowing C,
        _ d: borrowing D
    ) {
        guard beginCategory() else { return }
        expandFixedChild(a, index: 0)
        expandFixedChild(b, index: 1)
        expandFixedChild(c, index: 2)
        expandFixedChild(d, index: 3)
    }

    mutating func visitFixed<A: View, B: View, C: View, D: View, E: View>(
        _ a: borrowing A,
        _ b: borrowing B,
        _ c: borrowing C,
        _ d: borrowing D,
        _ e: borrowing E
    ) {
        guard beginCategory() else { return }
        expandFixedChild(a, index: 0)
        expandFixedChild(b, index: 1)
        expandFixedChild(c, index: 2)
        expandFixedChild(d, index: 3)
        expandFixedChild(e, index: 4)
    }

    mutating func visitConditionalFirst<First: View, Second: View>(
        _ content: borrowing First,
        second: Second.Type
    ) {
        guard beginCategory() else { return }
        expandConditionalChild(content, branch: 0)
    }

    mutating func visitConditionalSecond<First: View, Second: View>(
        first: First.Type,
        _ content: borrowing Second
    ) {
        guard beginCategory() else { return }
        expandConditionalChild(content, branch: 1)
    }

    mutating func visitOptionalAbsent<Content: View>(_ content: Content.Type) {
        _ = beginCategory()
    }

    mutating func visitOptionalPresent<Content: View>(
        _ content: borrowing Content
    ) {
        guard beginCategory() else { return }
        var presenceIdentity: Workspace.Identity?
        if let error = attempt.enterOptionalPresence(
            workspace: &workspace,
            identity: &presenceIdentity
        ) {
            stop(error)
            return
        }
        guard let presenceIdentity else {
            stop(.invalidIdentity)
            return
        }
        currentIdentity = presenceIdentity

        expandFixedChild(content, index: 0)
        guard failure == nil else { return }
        if let error = attempt.leavePathComponent(workspace: &workspace) {
            stop(error)
        }
    }

    mutating func visitPrimitive<Payload: _GiftUISemanticPrimitivePayload>(
        _ payload: borrowing Payload
    ) {
        guard beginCategory(), let currentIdentity else {
            if failure == nil {
                stop(.invalidIdentity)
            }
            return
        }
        if let error = attempt.stageSemanticOccurrence(
            identity: currentIdentity,
            payload: payload,
            workspace: &workspace,
            sink: &sink
        ) {
            stop(error)
        }
    }

    mutating func visitActionPrimitive<Payload: _GiftUISemanticActionPayload>(
        _ payload: borrowing Payload
    ) {
        guard beginCategory(), let currentIdentity else {
            if failure == nil {
                stop(.invalidIdentity)
            }
            return
        }
        if let error = attempt.stageActionOccurrence(
            identity: currentIdentity,
            action: payload._giftUIAction,
            workspace: &workspace,
            sink: &sink
        ) {
            stop(error)
        }
    }

    mutating func visitModifier<
        Content: View,
        Payload: _GiftUISemanticModifierPayload
    >(
        content: borrowing Content,
        payload: borrowing Payload
    ) {
        guard beginCategory(), let modifierIdentity = currentIdentity else {
            if failure == nil {
                stop(.invalidIdentity)
            }
            return
        }

        expandDeclaration(content, continuingModifierChain: true)
        guard failure == nil else { return }
        let chainIndex = nextModifierChainIndex
        if let error = attempt.stageModifierApplication(
            identity: modifierIdentity,
            payload: payload,
            chainIndex: chainIndex,
            workspace: &workspace,
            sink: &sink
        ) {
            stop(error)
            return
        }
        nextModifierChainIndex += 1
    }

    private mutating func expandDeclaration<Declaration: View>(
        _ declaration: borrowing Declaration,
        continuingModifierChain: Bool = false
    ) {
        guard failure == nil else { return }
        let parentIdentity = currentIdentity
        let parentCategoryWasVisited = currentCategoryWasVisited
        let parentModifierChainIndex = nextModifierChainIndex
        currentCategoryWasVisited = false
        if !continuingModifierChain {
            nextModifierChainIndex = 0
        }

        var declarationIdentity: Workspace.Identity?
        if let error = attempt.enterDeclarationRole(
            Declaration.self,
            workspace: &workspace,
            identity: &declarationIdentity
        ) {
            stop(error)
            return
        }
        guard let declarationIdentity else {
            stop(.invalidIdentity)
            return
        }
        currentIdentity = declarationIdentity
        if let error = attempt.stageStructuralOccurrence(
            identity: declarationIdentity,
            workspace: &workspace,
            sink: &sink
        ) {
            stop(error)
            return
        }

        declaration._giftUITraverse(&self)
        if failure == nil, !currentCategoryWasVisited {
            stop(.invariantViolation)
        }
        guard failure == nil else { return }
        if let error = attempt.leavePathComponent(workspace: &workspace) {
            stop(error)
            return
        }

        currentIdentity = parentIdentity
        currentCategoryWasVisited = parentCategoryWasVisited
        if !continuingModifierChain {
            nextModifierChainIndex = parentModifierChainIndex
        }
    }

    private mutating func expandFixedChild<Content: View>(
        _ content: borrowing Content,
        index: UInt8
    ) {
        guard failure == nil else { return }
        let parentIdentity = currentIdentity
        var childIdentity: Workspace.Identity?
        if let error = attempt.enterFixedChild(
            index,
            workspace: &workspace,
            identity: &childIdentity
        ) {
            stop(error)
            return
        }
        guard let childIdentity else {
            stop(.invalidIdentity)
            return
        }
        currentIdentity = childIdentity

        expandDeclaration(content)
        guard failure == nil else { return }
        if let error = attempt.leavePathComponent(workspace: &workspace) {
            stop(error)
            return
        }
        currentIdentity = parentIdentity
    }

    private mutating func expandConditionalChild<Content: View>(
        _ content: borrowing Content,
        branch: UInt8
    ) {
        guard failure == nil else { return }
        let parentIdentity = currentIdentity
        var branchIdentity: Workspace.Identity?
        if let error = attempt.enterConditionalBranch(
            branch,
            workspace: &workspace,
            identity: &branchIdentity
        ) {
            stop(error)
            return
        }
        guard let branchIdentity else {
            stop(.invalidIdentity)
            return
        }
        currentIdentity = branchIdentity

        expandFixedChild(content, index: 0)
        guard failure == nil else { return }
        if let error = attempt.leavePathComponent(workspace: &workspace) {
            stop(error)
            return
        }
        currentIdentity = parentIdentity
    }

    private mutating func beginCategory() -> Bool {
        guard failure == nil else { return false }
        guard !currentCategoryWasVisited else {
            stop(.invariantViolation)
            return false
        }
        currentCategoryWasVisited = true
        return true
    }

    private mutating func stop(_ error: SemanticExpansionError) {
        if failure == nil {
            failure = error
        }
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

    var traversal = SemanticExpansionTraversal(
        attempt: attempt,
        workspace: workspace,
        sink: sink
    )
    traversal.expandRoot(root)
    attempt = traversal.attempt
    workspace = traversal.workspace
    sink = traversal.sink

    if let traversalFailure = traversal.failure {
        return .failure(
            attempt.fail(traversalFailure, workspace: &workspace, sink: &sink)
        )
    }
    return attempt.succeed(workspace: &workspace, sink: &sink)
}
