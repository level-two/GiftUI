import GiftUI
import GiftUIDrawing
import GiftUIExecution
import GiftUIInteraction
import GiftUIObservableState
import GiftUISemanticCore

// The combined bank changes only the payload envelope. All validation, failure
// precedence and owned-key staging remain in the existing interaction bridge.
extension RuntimeRecordInteractionBridge {
    package static func append<
        Candidate, Committed, Hits, Model, RootIdentity, Action, Roles, CanvasValue
    >(
        record: SemanticRecordReference,
        semantic: borrowing SemanticRecordView<CanvasSemanticPayload<CanvasValue>>,
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
            interaction: &interaction,
            projection: { value in
                if case .standard(let standard) = value { return standard }
                return nil
            })
    }
}
