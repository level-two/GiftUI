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
    if workspace.isExpanding {
        return .failure(.reentrancyViolation)
    }

    // T2.2 installs the bounded lifecycle and T2.3 installs traversal. Until
    // both are present, the entry point fails closed without starting either
    // caller-owned collaborator or publishing output.
    return .failure(.invariantViolation)
}
