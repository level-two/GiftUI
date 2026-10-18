import GiftUI

@usableFromInline
package struct SemanticExpansionLimits: Equatable, Sendable {
    @usableFromInline
    package let maximumDepth: UInt16
    @usableFromInline
    package let maximumSemanticNodes: UInt16
    @usableFromInline
    package let maximumBodyEvaluations: UInt16
    @usableFromInline
    package let maximumModifierApplications: UInt16
    @usableFromInline
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

@usableFromInline
package struct SemanticExpansionSummary: Equatable, Sendable {
    @usableFromInline
    package let semanticNodeCount: UInt16
    @usableFromInline
    package let bodyEvaluationCount: UInt16
    @usableFromInline
    package let modifierApplicationCount: UInt16
    @usableFromInline
    package let actionOccurrenceCount: UInt16
    package let maximumObservedDepth: UInt16

    @usableFromInline
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

@usableFromInline
package enum SemanticExpansionError: UInt8, Error, Equatable, Sendable {
    case capacityExhausted = 0
    case invalidIdentity = 1
    case reentrancyViolation = 2
    case invariantViolation = 3
}

@usableFromInline
package enum SemanticExpansionResult: Equatable, Sendable {
    case success(SemanticExpansionSummary)
    case failure(SemanticExpansionError)
}

/// The body bridge owns State binding and checked model access. Its scoped
/// implementation borrows real backing; Semantic Core owns only traversal.
@usableFromInline
package enum SemanticBodyEvaluation<Body, BindingFailure> {
    case body(Body)
    case semanticFailure(SemanticExpansionError)
    case bindingFailure(BindingFailure)
    case accessFailure(_GiftUIAccessFailure)
}

@usableFromInline
package protocol SemanticStatefulBinding: ~Copyable, ~Escapable {
    associatedtype Domain: _GiftUIReadDomain
    associatedtype Identity: Equatable
    associatedtype Failure: Equatable & Sendable

    borrowing func evaluate<Declaration: View>(
        _ declaration: borrowing Declaration,
        beforeBody: () -> SemanticExpansionError?,
        body: (borrowing _GiftUIFrameRead<Domain>) throws(_GiftUIAccessFailure) -> Declaration.Body
    ) -> SemanticBodyEvaluation<Declaration.Body, Failure>
    where Declaration.Domain == Domain, Declaration.Body.Domain == Domain

    borrowing func evaluateStateful<Declaration: View & _GiftUIObservableStateHost>(
        _ declaration: borrowing Declaration,
        structuralIdentity: Identity,
        beforeBody: () -> SemanticExpansionError?,
        body: (borrowing Declaration, borrowing _GiftUIFrameRead<Domain>)
            throws(_GiftUIAccessFailure) -> Declaration.Body
    ) -> SemanticBodyEvaluation<Declaration.Body, Failure>
    where Declaration.Domain == Domain, Declaration.Body.Domain == Domain
}

@usableFromInline
package enum BoundSemanticExpansionResult<BindingFailure>: Equatable, Sendable
where BindingFailure: Equatable & Sendable {
    case success(SemanticExpansionSummary)
    case semanticFailure(SemanticExpansionError)
    case bindingFailure(BindingFailure)
    case accessFailure(_GiftUIAccessFailure)
}

@usableFromInline
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

@usableFromInline
package protocol SemanticExpansionSink {
    associatedtype Identity: Equatable

    /// A reported independent path/payload bound preserves the exact local error.
    var stagingFailure: SemanticExpansionError? { get }

    var maximumStructuralOccurrences: UInt16 { get }
    var maximumBodyEvaluations: UInt16 { get }
    var maximumSemanticOccurrences: UInt16 { get }
    var maximumModifierApplications: UInt16 { get }
    var maximumActionOccurrences: UInt16 { get }

    mutating func beginExpansion() -> Bool

    mutating func stageStructuralOccurrence(
        identity: borrowing Identity
    ) -> Bool

    mutating func stageBodyEvaluation(
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

extension SemanticExpansionSink {
    // Count-only sinks have no separately bounded payload pool. A refusal after
    // their reported count preflight remains an invariant failure.
    package var stagingFailure: SemanticExpansionError? { nil }
}

@usableFromInline
package struct SemanticRecordingRole: RawRepresentable, Hashable, Sendable {
    @usableFromInline
    package let rawValue: UInt16

    @usableFromInline
    package init(rawValue: UInt16) {
        self.rawValue = rawValue
    }
}

package enum SemanticRecordingPathComponent: Hashable, Sendable {
    case root
    case customBody
    case fixedChild(UInt8)
    case conditionalBranch(UInt8)
    case optionalPresence
    case declarationRole(SemanticRecordingRole)
}

package protocol SemanticRecordingIdentity: Equatable, Sendable {
    var componentCount: UInt16 { get }
    var declarationRole: SemanticRecordingRole { get }

    func component(at index: UInt16) -> SemanticRecordingPathComponent?
}

package enum SemanticRecordingEvent<Identity>: Equatable, Sendable
where Identity: SemanticRecordingIdentity {
    case enterStructuralOccurrence(
        path: Identity,
        declarationRole: SemanticRecordingRole
    )
    case evaluateCustomBody(
        path: Identity,
        declarationRole: SemanticRecordingRole
    )
    case stageSemanticOccurrence(
        path: Identity,
        declarationRole: SemanticRecordingRole
    )
    case applyModifier(
        path: Identity,
        modifierRole: SemanticRecordingRole,
        chainIndex: UInt16
    )
    case associateAction(
        path: Identity,
        actionRole: SemanticRecordingRole
    )
}

package protocol SemanticRecordingStorage {
    associatedtype Identity: SemanticRecordingIdentity

    var maximumStructuralOccurrences: UInt16 { get }
    var maximumBodyEvaluations: UInt16 { get }
    var maximumSemanticOccurrences: UInt16 { get }
    var maximumModifierApplications: UInt16 { get }
    var maximumActionOccurrences: UInt16 { get }

    mutating func beginRecording() -> Bool
    mutating func stage(_ event: borrowing SemanticRecordingEvent<Identity>) -> Bool
    mutating func publishRecording(_ summary: SemanticExpansionSummary) -> Bool
    mutating func discardRecording()
    mutating func resetRecording()
}

package struct SemanticRecordingSink<Storage>: SemanticExpansionSink
where Storage: SemanticRecordingStorage {
    package var storage: Storage

    private var bodyEvaluationCount: UInt16 = 0
    private var semanticNodeCount: UInt16 = 0
    private var modifierApplicationCount: UInt16 = 0
    private var actionOccurrenceCount: UInt16 = 0
    private var maximumObservedDepth: UInt16 = 0

    package init(storage: Storage) {
        self.storage = storage
    }

    package var maximumStructuralOccurrences: UInt16 {
        storage.maximumStructuralOccurrences
    }

    package var maximumBodyEvaluations: UInt16 {
        storage.maximumBodyEvaluations
    }

    package var maximumSemanticOccurrences: UInt16 {
        storage.maximumSemanticOccurrences
    }

    package var maximumModifierApplications: UInt16 {
        storage.maximumModifierApplications
    }

    package var maximumActionOccurrences: UInt16 {
        storage.maximumActionOccurrences
    }

    package mutating func beginExpansion() -> Bool {
        bodyEvaluationCount = 0
        semanticNodeCount = 0
        modifierApplicationCount = 0
        actionOccurrenceCount = 0
        maximumObservedDepth = 0
        return storage.beginRecording()
    }

    package mutating func stageStructuralOccurrence(
        identity: borrowing Storage.Identity
    ) -> Bool {
        guard observeDepth(identity.componentCount) else { return false }
        let event = SemanticRecordingEvent.enterStructuralOccurrence(
            path: copy identity,
            declarationRole: identity.declarationRole
        )
        return storage.stage(event)
    }

    package mutating func stageBodyEvaluation(
        identity: borrowing Storage.Identity
    ) -> Bool {
        guard
            let next = incremented(bodyEvaluationCount),
            observeDepth(identity.componentCount)
        else { return false }
        let event = SemanticRecordingEvent.evaluateCustomBody(
            path: copy identity,
            declarationRole: identity.declarationRole
        )
        guard storage.stage(event) else { return false }
        bodyEvaluationCount = next
        return true
    }

    package mutating func stageSemanticOccurrence<
        Payload: _GiftUISemanticPrimitivePayload
    >(
        identity: borrowing Storage.Identity,
        payload: borrowing Payload
    ) -> Bool {
        guard
            let next = incremented(semanticNodeCount),
            observeDepth(identity.componentCount)
        else { return false }
        let event = SemanticRecordingEvent.stageSemanticOccurrence(
            path: copy identity,
            declarationRole: identity.declarationRole
        )
        guard storage.stage(event) else { return false }
        semanticNodeCount = next
        return true
    }

    package mutating func stageModifierApplication<
        Payload: _GiftUISemanticModifierPayload
    >(
        identity: borrowing Storage.Identity,
        payload: borrowing Payload,
        chainIndex: UInt16
    ) -> Bool {
        guard
            let next = incremented(modifierApplicationCount),
            observeDepth(identity.componentCount)
        else { return false }
        let event = SemanticRecordingEvent.applyModifier(
            path: copy identity,
            modifierRole: identity.declarationRole,
            chainIndex: chainIndex
        )
        guard storage.stage(event) else { return false }
        modifierApplicationCount = next
        return true
    }

    package mutating func stageActionOccurrence<Action: GiftUIAction>(
        identity: borrowing Storage.Identity,
        action: borrowing Action
    ) -> Bool {
        guard
            let nextSemanticNode = incremented(semanticNodeCount),
            let nextAction = incremented(actionOccurrenceCount),
            observeDepth(identity.componentCount)
        else { return false }

        let semanticEvent = SemanticRecordingEvent.stageSemanticOccurrence(
            path: copy identity,
            declarationRole: identity.declarationRole
        )
        guard storage.stage(semanticEvent) else { return false }
        semanticNodeCount = nextSemanticNode

        let actionEvent = SemanticRecordingEvent.associateAction(
            path: copy identity,
            actionRole: identity.declarationRole
        )
        guard storage.stage(actionEvent) else { return false }
        actionOccurrenceCount = nextAction
        return true
    }

    package mutating func publishExpansion(_ summary: SemanticExpansionSummary) -> Bool {
        guard
            summary.semanticNodeCount == semanticNodeCount,
            summary.bodyEvaluationCount == bodyEvaluationCount,
            summary.modifierApplicationCount == modifierApplicationCount,
            summary.actionOccurrenceCount == actionOccurrenceCount,
            summary.maximumObservedDepth == maximumObservedDepth
        else { return false }
        return storage.publishRecording(summary)
    }

    package mutating func discardExpansion() {
        storage.discardRecording()
    }

    package mutating func resetExpansion() {
        storage.resetRecording()
        bodyEvaluationCount = 0
        semanticNodeCount = 0
        modifierApplicationCount = 0
        actionOccurrenceCount = 0
        maximumObservedDepth = 0
    }

    private mutating func observeDepth(_ depth: UInt16) -> Bool {
        guard depth > 0 else { return false }
        if depth > maximumObservedDepth {
            maximumObservedDepth = depth
        }
        return true
    }

    private func incremented(_ value: UInt16) -> UInt16? {
        let next = value.addingReportingOverflow(1)
        guard !next.overflow else { return nil }
        return next.partialValue
    }
}

@usableFromInline
struct SemanticExpansionAttempt {
    @usableFromInline
    let limits: SemanticExpansionLimits

    @usableFromInline
    var semanticNodeCount: UInt16 = 0
    @usableFromInline
    var bodyEvaluationCount: UInt16 = 0
    @usableFromInline
    var modifierApplicationCount: UInt16 = 0
    @usableFromInline
    var actionOccurrenceCount: UInt16 = 0
    @usableFromInline
    var maximumObservedDepth: UInt16 = 0

    @usableFromInline
    var currentDepth: UInt16 = 0
    @usableFromInline
    var identityCount: UInt16 = 0
    @usableFromInline
    var structuralOccurrenceCount: UInt16 = 0
    @usableFromInline
    var workspacePathCapacity: UInt16 = 0
    @usableFromInline
    var workspaceIdentityCapacity: UInt16 = 0
    @usableFromInline
    var sinkStructuralCapacity: UInt16 = 0
    @usableFromInline
    var sinkBodyCapacity: UInt16 = 0
    @usableFromInline
    var sinkSemanticCapacity: UInt16 = 0
    @usableFromInline
    var sinkModifierCapacity: UInt16 = 0
    @usableFromInline
    var sinkActionCapacity: UInt16 = 0
    @usableFromInline
    var workspaceBegan = false
    @usableFromInline
    var sinkBegan = false
    @usableFromInline
    var firstFailure: SemanticExpansionError?

    @usableFromInline
    init(limits: SemanticExpansionLimits) {
        self.limits = limits
    }

    @inlinable
    @inline(__always)
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
        sinkBodyCapacity = sink.maximumBodyEvaluations
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

    @inlinable
    @inline(__always)
    mutating func enterRoot<Declaration: View, Workspace: SemanticExpansionWorkspace>(
        _ declaration: Declaration.Type,
        workspace: inout Workspace,
        identity: inout Workspace.Identity?
    ) -> SemanticExpansionError? {
        enterPath(workspace: &workspace, identity: &identity) {
            $0.enterRoot(declaration, identity: &$1)
        }
    }

    @inlinable
    @inline(__always)
    mutating func enterCustomBody<Declaration: View, Workspace: SemanticExpansionWorkspace>(
        _ declaration: Declaration.Type,
        workspace: inout Workspace,
        identity: inout Workspace.Identity?
    ) -> SemanticExpansionError? {
        enterPath(workspace: &workspace, identity: &identity) {
            $0.enterCustomBody(declaration, identity: &$1)
        }
    }

    @inlinable
    @inline(__always)
    mutating func enterFixedChild<Workspace: SemanticExpansionWorkspace>(
        _ index: UInt8,
        workspace: inout Workspace,
        identity: inout Workspace.Identity?
    ) -> SemanticExpansionError? {
        enterPath(workspace: &workspace, identity: &identity) {
            $0.enterFixedChild(index, identity: &$1)
        }
    }

    @inlinable
    @inline(__always)
    mutating func enterConditionalBranch<Workspace: SemanticExpansionWorkspace>(
        _ index: UInt8,
        workspace: inout Workspace,
        identity: inout Workspace.Identity?
    ) -> SemanticExpansionError? {
        enterPath(workspace: &workspace, identity: &identity) {
            $0.enterConditionalBranch(index, identity: &$1)
        }
    }

    @inlinable
    @inline(__always)
    mutating func enterOptionalPresence<Workspace: SemanticExpansionWorkspace>(
        workspace: inout Workspace,
        identity: inout Workspace.Identity?
    ) -> SemanticExpansionError? {
        enterPath(workspace: &workspace, identity: &identity) {
            $0.enterOptionalPresence(identity: &$1)
        }
    }

    @inlinable
    @inline(__always)
    mutating func enterDeclarationRole<Declaration, Workspace: SemanticExpansionWorkspace>(
        _ declaration: Declaration.Type,
        workspace: inout Workspace,
        identity: inout Workspace.Identity?
    ) -> SemanticExpansionError? {
        enterPath(workspace: &workspace, identity: &identity) {
            $0.enterDeclarationRole(declaration, identity: &$1)
        }
    }

    @inlinable
    @inline(__always)
    mutating func leavePathComponent<Workspace: SemanticExpansionWorkspace>(
        workspace: inout Workspace
    ) -> SemanticExpansionError? {
        guard firstFailure == nil else { return firstFailure }
        guard currentDepth > 0 else { return record(.invariantViolation) }
        workspace.leavePathComponent()
        currentDepth -= 1
        return nil
    }

    @inlinable
    @inline(__always)
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

    @inlinable
    @inline(__always)
    mutating func stageBodyEvaluation<Workspace, Sink>(
        identity: borrowing Workspace.Identity,
        workspace: inout Workspace,
        sink: inout Sink
    ) -> SemanticExpansionError?
    where
        Workspace: SemanticExpansionWorkspace,
        Sink: SemanticExpansionSink,
        Workspace.Identity == Sink.Identity
    {
        if let error = reserveBodyEvaluation() {
            return error
        }
        guard bodyEvaluationCount <= sinkBodyCapacity else {
            return record(.capacityExhausted)
        }
        guard sink.stageBodyEvaluation(identity: identity) else {
            return record(.invariantViolation)
        }
        return nil
    }

    @inlinable
    @inline(__always)
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
            return record(sink.stagingFailure ?? .invariantViolation)
        }
        return nil
    }

    @inlinable
    @inline(__always)
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
            return record(sink.stagingFailure ?? .invariantViolation)
        }
        return nil
    }

    @inlinable
    @inline(__always)
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
            return record(sink.stagingFailure ?? .invariantViolation)
        }
        return nil
    }

    @inlinable
    @inline(__always)
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
            return record(sink.stagingFailure ?? .invariantViolation)
        }
        return nil
    }

    @inlinable
    @inline(__always)
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

    @inlinable
    @inline(__always)
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

    @inlinable
    @inline(__always)
    mutating func discardForOwnerFailure<Workspace, Sink>(
        workspace: inout Workspace,
        sink: inout Sink
    )
    where
        Workspace: SemanticExpansionWorkspace,
        Sink: SemanticExpansionSink,
        Workspace.Identity == Sink.Identity
    {
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
    }

    @inlinable
    @inline(__always)
    mutating func enterPath<Workspace: SemanticExpansionWorkspace>(
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

    @inlinable
    @inline(__always)
    func reservedValue(
        after count: UInt16,
        limit: UInt16
    ) -> UInt16? {
        let next = count.addingReportingOverflow(1)
        guard !next.overflow, next.partialValue <= limit else { return nil }
        return next.partialValue
    }

    @inlinable
    @inline(__always)
    mutating func record(_ error: SemanticExpansionError) -> SemanticExpansionError {
        if firstFailure == nil {
            firstFailure = error
        }
        return firstFailure ?? error
    }
}

@usableFromInline
struct SemanticExpansionTraversal<Workspace, Sink, StateBinding>: ~Copyable, ~Escapable,
    _GiftUISemanticTraversalVisitor
where
    Workspace: SemanticExpansionWorkspace,
    Sink: SemanticExpansionSink,
    StateBinding: SemanticStatefulBinding & ~Copyable & ~Escapable,
    Workspace.Identity == Sink.Identity,
    Workspace.Identity == StateBinding.Identity
{
    @usableFromInline
    typealias Domain = StateBinding.Domain

    @usableFromInline
    var attempt: SemanticExpansionAttempt
    @usableFromInline
    var workspace: Workspace
    @usableFromInline
    var sink: Sink
    @usableFromInline
    let stateBinding: StateBinding

    @usableFromInline
    var failure: SemanticExpansionError?
    @usableFromInline
    var bindingFailure: StateBinding.Failure?
    @usableFromInline
    var accessFailure: _GiftUIAccessFailure?
    @inlinable
    var stopped: Bool { failure != nil || bindingFailure != nil || accessFailure != nil }
    @usableFromInline
    var currentIdentity: Workspace.Identity?
    @usableFromInline
    var currentCategoryWasVisited = false
    @usableFromInline
    var nextModifierChainIndex: UInt16 = 0

    @_lifetime(copy stateBinding)
    @usableFromInline
    init(
        attempt: SemanticExpansionAttempt,
        workspace: Workspace,
        sink: Sink,
        stateBinding: consuming StateBinding
    ) {
        self.attempt = attempt
        self.workspace = workspace
        self.sink = sink
        self.stateBinding = consume stateBinding
    }

    @inlinable
    @inline(__always)
    mutating func expandRoot<Root: View>(_ root: borrowing Root) where Root.Domain == Domain {
        guard !stopped else { return }
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
        guard !stopped else { return }
        if let error = attempt.leavePathComponent(workspace: &workspace) {
            stop(error)
        }
    }

    @inlinable
    @inline(__always)
    mutating func visitCustomView<Declaration: View>(
        _ declaration: borrowing Declaration,
        body: (borrowing _GiftUIFrameRead<Domain>) throws(_GiftUIAccessFailure) -> Declaration.Body
    ) where Declaration.Domain == Domain, Declaration.Body.Domain == Domain {
        guard let bodyIdentity = beginBody(Declaration.self) else { return }
        let result = stateBinding.evaluate(
            declaration,
            beforeBody: {
                attempt.stageBodyEvaluation(
                    identity: bodyIdentity, workspace: &workspace, sink: &sink)
            }, body: body)
        finishBody(result)
    }

    @inlinable
    @inline(__always)
    mutating func visitStatefulCustomView<Declaration: View & _GiftUIObservableStateHost>(
        _ declaration: borrowing Declaration,
        body: (borrowing Declaration, borrowing _GiftUIFrameRead<Domain>)
            throws(_GiftUIAccessFailure) -> Declaration.Body
    ) where Declaration.Domain == Domain, Declaration.Body.Domain == Domain {
        guard let bodyIdentity = beginBody(Declaration.self) else { return }
        let result = stateBinding.evaluateStateful(
            declaration, structuralIdentity: bodyIdentity,
            beforeBody: {
                attempt.stageBodyEvaluation(
                    identity: bodyIdentity, workspace: &workspace, sink: &sink)
            }, body: body)
        finishBody(result)
    }

    @inlinable
    @inline(__always)
    mutating func beginBody<Declaration: View>(_ type: Declaration.Type) -> Workspace
        .Identity?
    {
        guard beginCategory() else { return nil }
        var identity: Workspace.Identity?
        if let error = attempt.enterCustomBody(type, workspace: &workspace, identity: &identity) {
            stop(error)
            return nil
        }
        guard let identity else {
            stop(.invalidIdentity)
            return nil
        }
        currentIdentity = identity
        return identity
    }

    @inlinable
    @inline(__always)
    mutating func finishBody<Body: View>(
        _ result: SemanticBodyEvaluation<Body, StateBinding.Failure>
    )
    where Body.Domain == Domain {
        switch result {
        case .body(let body):
            expandDeclaration(body)
            guard !stopped else { return }
            if let error = attempt.leavePathComponent(workspace: &workspace) { stop(error) }
        case .semanticFailure(let error): stop(error)
        case .bindingFailure(let error): bindingFailure = error
        case .accessFailure(let error): accessFailure = error
        }
    }

    @inlinable
    @inline(__always)
    mutating func visitEmpty() {
        _ = beginCategory()
    }

    @inlinable
    mutating func visitFixed<A: View, B: View>(
        _ a: borrowing A,
        _ b: borrowing B
    ) where A.Domain == Domain, B.Domain == Domain {
        guard beginCategory() else { return }
        expandFixedChild(a, index: 0)
        expandFixedChild(b, index: 1)
    }

    @inlinable
    @inline(__always)
    mutating func visitFixed<A: View, B: View, C: View>(
        _ a: borrowing A,
        _ b: borrowing B,
        _ c: borrowing C
    ) where A.Domain == Domain, B.Domain == Domain, C.Domain == Domain {
        guard beginCategory() else { return }
        expandFixedChild(a, index: 0)
        expandFixedChild(b, index: 1)
        expandFixedChild(c, index: 2)
    }

    @inlinable
    @inline(__always)
    mutating func visitFixed<A: View, B: View, C: View, D: View>(
        _ a: borrowing A,
        _ b: borrowing B,
        _ c: borrowing C,
        _ d: borrowing D
    ) where A.Domain == Domain, B.Domain == Domain, C.Domain == Domain, D.Domain == Domain {
        guard beginCategory() else { return }
        expandFixedChild(a, index: 0)
        expandFixedChild(b, index: 1)
        expandFixedChild(c, index: 2)
        expandFixedChild(d, index: 3)
    }

    @inlinable
    @inline(__always)
    mutating func visitFixed<A: View, B: View, C: View, D: View, E: View>(
        _ a: borrowing A,
        _ b: borrowing B,
        _ c: borrowing C,
        _ d: borrowing D,
        _ e: borrowing E
    )
    where
        A.Domain == Domain, B.Domain == Domain, C.Domain == Domain, D.Domain == Domain,
        E.Domain == Domain
    {
        guard beginCategory() else { return }
        expandFixedChild(a, index: 0)
        expandFixedChild(b, index: 1)
        expandFixedChild(c, index: 2)
        expandFixedChild(d, index: 3)
        expandFixedChild(e, index: 4)
    }

    @inlinable
    @inline(__always)
    mutating func visitConditionalFirst<First: View, Second: View>(
        _ content: borrowing First,
        second: Second.Type
    ) where First.Domain == Domain, Second.Domain == Domain {
        guard beginCategory() else { return }
        expandConditionalChild(content, branch: 0)
    }

    @inlinable
    @inline(__always)
    mutating func visitConditionalSecond<First: View, Second: View>(
        first: First.Type,
        _ content: borrowing Second
    ) where First.Domain == Domain, Second.Domain == Domain {
        guard beginCategory() else { return }
        expandConditionalChild(content, branch: 1)
    }

    @inlinable
    @inline(__always)
    mutating func visitOptionalAbsent<Content: View>(_ content: Content.Type)
    where Content.Domain == Domain {
        _ = beginCategory()
    }

    @inlinable
    @inline(__always)
    mutating func visitOptionalPresent<Content: View>(
        _ content: borrowing Content
    ) where Content.Domain == Domain {
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
        guard !stopped else { return }
        if let error = attempt.leavePathComponent(workspace: &workspace) {
            stop(error)
        }
    }

    @inlinable
    @inline(__always)
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

    @inlinable
    @inline(__always)
    mutating func visitPrimitive<
        Content: View,
        Payload: _GiftUISemanticPrimitivePayload
    >(
        content: borrowing Content,
        payload: borrowing Payload
    ) where Content.Domain == Domain {
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
            return
        }

        expandFixedChild(content, index: 0)
    }

    @inlinable
    @inline(__always)
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

    @inlinable
    @inline(__always)
    mutating func visitActionPrimitive<
        Content: View,
        Payload: _GiftUISemanticActionPayload
    >(
        content: borrowing Content,
        payload: borrowing Payload
    ) where Content.Domain == Domain {
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
            return
        }

        expandFixedChild(content, index: 0)
    }

    @inlinable
    @inline(__always)
    mutating func visitModifier<
        Content: View,
        Payload: _GiftUISemanticModifierPayload
    >(
        content: borrowing Content,
        payload: borrowing Payload
    ) where Content.Domain == Domain {
        guard beginCategory(), let modifierIdentity = currentIdentity else {
            if failure == nil {
                stop(.invalidIdentity)
            }
            return
        }

        expandDeclaration(content, continuingModifierChain: true)
        guard !stopped else { return }
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

    @inlinable
    @inline(__always)
    mutating func expandDeclaration<Declaration: View>(
        _ declaration: borrowing Declaration,
        continuingModifierChain: Bool = false
    ) where Declaration.Domain == Domain {
        guard !stopped else { return }
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
        if !stopped, !currentCategoryWasVisited {
            stop(.invariantViolation)
        }
        guard !stopped else { return }
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

    @inlinable
    @inline(__always)
    mutating func expandFixedChild<Content: View>(
        _ content: borrowing Content,
        index: UInt8
    ) where Content.Domain == Domain {
        guard !stopped else { return }
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
        guard !stopped else { return }
        if let error = attempt.leavePathComponent(workspace: &workspace) {
            stop(error)
            return
        }
        currentIdentity = parentIdentity
    }

    @inlinable
    @inline(__always)
    mutating func expandConditionalChild<Content: View>(
        _ content: borrowing Content,
        branch: UInt8
    ) where Content.Domain == Domain {
        guard !stopped else { return }
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
        guard !stopped else { return }
        if let error = attempt.leavePathComponent(workspace: &workspace) {
            stop(error)
            return
        }
        currentIdentity = parentIdentity
    }

    @inlinable
    @inline(__always)
    mutating func beginCategory() -> Bool {
        guard !stopped else { return false }
        guard !currentCategoryWasVisited else {
            stop(.invariantViolation)
            return false
        }
        currentCategoryWasVisited = true
        return true
    }

    @inlinable
    @inline(__always)
    mutating func stop(_ error: SemanticExpansionError) {
        if failure == nil {
            failure = error
        }
    }
}

/// The caller supplies a lexical body bridge. Success makes a complete candidate
/// available to the next owner; it does not commit global semantic publication.
@inlinable
@inline(__always)
package func expandSemanticTreeWithStateBinding<
    Root: View,
    Workspace: SemanticExpansionWorkspace,
    Sink: SemanticExpansionSink,
    StateBinding: SemanticStatefulBinding & ~Copyable & ~Escapable
>(
    _ root: borrowing Root,
    limits: SemanticExpansionLimits,
    workspace: inout Workspace,
    sink: inout Sink,
    stateBinding: consuming StateBinding
) -> BoundSemanticExpansionResult<StateBinding.Failure>
where
    Root.Domain == StateBinding.Domain,
    Workspace.Identity == Sink.Identity,
    Workspace.Identity == StateBinding.Identity
{
    var attempt = SemanticExpansionAttempt(limits: limits)
    if let error = attempt.begin(workspace: &workspace, sink: &sink) {
        return .semanticFailure(error)
    }
    var traversal = SemanticExpansionTraversal(
        attempt: attempt, workspace: workspace, sink: sink, stateBinding: consume stateBinding)
    traversal.expandRoot(root)
    attempt = traversal.attempt
    workspace = traversal.workspace
    sink = traversal.sink
    if let failure = traversal.bindingFailure {
        attempt.discardForOwnerFailure(workspace: &workspace, sink: &sink)
        return .bindingFailure(failure)
    }
    if let failure = traversal.accessFailure {
        attempt.discardForOwnerFailure(workspace: &workspace, sink: &sink)
        return .accessFailure(failure)
    }
    if let failure = traversal.failure {
        return .semanticFailure(attempt.fail(failure, workspace: &workspace, sink: &sink))
    }
    switch attempt.succeed(workspace: &workspace, sink: &sink) {
    case .success(let summary): return .success(summary)
    case .failure(let error): return .semanticFailure(error)
    }
}
