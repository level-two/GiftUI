import GiftUI
import GiftUIExecution
import GiftUIInteraction
import GiftUIObservableState
import GiftUISemanticCore

/// The host's finite action lowering supplies a typed operation, never an
/// unrestricted model callback. Observable State still owns phase/generation
/// checks, mutation preflight, exclusive commit and synchronous reporting.
@usableFromInline
package enum RuntimeRecordInteractionBridge {
    package static func append<Candidate, Committed, Hits, Model, RootIdentity, Action, Roles>(
        record: SemanticRecordReference,
        semantic: borrowing SemanticRecordView<SemanticStandardPayload>,
        root: borrowing ObservableStateRootScope<Model, RootIdentity>, rootIdentity: RootIdentity,
        rootOrdinal: UInt16, actionType: Action.Type, roles: Roles.Type,
        isEnabled: Bool, bounds: Rect, clip: Rect, paintOrder: UInt16,
        interaction: inout InteractionOwnedKeyState<Candidate, Committed, Hits>
    ) -> InteractionCandidateAppendResult
    where
        Candidate: InteractionCandidateRecordStorage & ~Copyable & ~Escapable,
        Committed: InteractionCommittedRecordStorage & ~Copyable & ~Escapable,
        Hits: InteractionHitRegionStorage & ~Copyable & ~Escapable,
        Candidate.Identity == SemanticCompleteIdentity,
        Committed.Identity == SemanticCompleteIdentity, Hits.Identity == SemanticCompleteIdentity,
        Model: ObservableStateModel & ~Copyable, RootIdentity: Equatable & Sendable,
        Action: GiftUIAction, Roles: SemanticDeclarationRoles
    {
        appendProjected(
            record: record, semantic: semantic, root: root, rootIdentity: rootIdentity,
            rootOrdinal: rootOrdinal, actionType: actionType, roles: roles,
            isEnabled: isEnabled, bounds: bounds, clip: clip, paintOrder: paintOrder,
            interaction: &interaction, projection: { $0 })
    }

    @inlinable
    @inline(__always)
    static func appendProjected<
        Candidate, Committed, Hits, Model, RootIdentity, Action, Roles, Payload
    >(
        record: SemanticRecordReference,
        semantic: borrowing SemanticRecordView<Payload>,
        root: borrowing ObservableStateRootScope<Model, RootIdentity>, rootIdentity: RootIdentity,
        rootOrdinal: UInt16, actionType: Action.Type, roles: Roles.Type,
        isEnabled: Bool, bounds: Rect, clip: Rect, paintOrder: UInt16,
        interaction: inout InteractionOwnedKeyState<Candidate, Committed, Hits>,
        projection: (Payload) -> SemanticStandardPayload?
    ) -> InteractionCandidateAppendResult
    where
        Candidate: InteractionCandidateRecordStorage & ~Copyable & ~Escapable,
        Committed: InteractionCommittedRecordStorage & ~Copyable & ~Escapable,
        Hits: InteractionHitRegionStorage & ~Copyable & ~Escapable,
        Candidate.Identity == SemanticCompleteIdentity,
        Committed.Identity == SemanticCompleteIdentity, Hits.Identity == SemanticCompleteIdentity,
        Model: ObservableStateModel & ~Copyable, RootIdentity: Equatable & Sendable,
        Action: GiftUIAction, Roles: SemanticDeclarationRoles
    {
        var failures = InteractionVisibleFailures()
        let identity = semantic.completeIdentity(for: record)
        let value = semantic.record(record)
        let generation = root.generation(
            identity: rootIdentity, ordinal: rootOrdinal, publishable: true)
        if generation == nil { failures.insert(.missingModelTarget) }
        var code: UInt16?
        if semantic.isCandidate, let value, value.kind == .action,
            let stored = semantic.payload(at: value.payload), let payload = projection(stored),
            case .action(let role, let raw) = payload
        {
            code = raw
            if Roles.role(of: Action.self)?.rawValue != role {
                failures.insert(.incompatibleActionDomain)
            }
            if Action(rawValue: raw)?.rawValue != raw { failures.insert(.invalidActionValue) }
        } else {
            failures.insert(.invalidIdentity)
        }
        if let error = interaction.appendFailure(
            identity: identity ?? SemanticCompleteIdentity(), bounds: bounds, clip: clip,
            paintOrder: paintOrder)
        {
            failures.insert(error)
        }
        if let error = InteractionFailurePrecedence.select(from: failures) {
            return interaction.rejectCandidate(error)
        }
        return interaction.append(
            record: record, in: semantic, isEnabled: isEnabled, bounds: bounds,
            clip: clip, paintOrder: paintOrder, action: .init(code: code!),
            targetGeneration: .init(rawValue: generation!))
    }

    @inlinable
    @inline(__always)
    package static func dispatch<Records, Model, RootIdentity, Action>(
        _ captured: CapturedAction<Records.Identity>, records: borrowing Records,
        target: borrowing ObservableStateRootTargetAccess<Model, RootIdentity>,
        actionType: Action.Type, operation: (Action) -> Model.Mutation
    ) -> RuntimeRecordInteractionDispatchResult
    where
        Records: InteractionCommittedActionView & ~Copyable & ~Escapable,
        Model: ObservableStateModel & ObservableModelMutation & ~Copyable,
        RootIdentity: Equatable & Sendable, Action: GiftUIAction
    {
        guard let record = records.committedRecord(for: captured.identity),
            record.identity == captured.identity, record.generation == captured.generation,
            record.isEnabled, target.currentGeneration() == record.targetGeneration
        else { return .interaction(.cancelled) }
        guard let action = Action(rawValue: record.action.code),
            action.rawValue == record.action.code
        else { return .interaction(.failure(.invariantViolation)) }
        switch target.mutate(matching: record.targetGeneration, operation: { operation(action) }) {
        case .success: return .interaction(.dispatched)
        case .failure(.staleModel): return .interaction(.cancelled)
        case .failure(let error): return .observableFailure(error)
        }
    }
}

@usableFromInline
package enum RuntimeRecordInteractionDispatchResult: Equatable {
    case interaction(InteractionDispatchResult)
    case observableFailure(ObservableStateError)
}
