import GiftUI
import GiftUIDrawing
import GiftUIInteraction
import GiftUIObservableState
import GiftUIRuntimeCore
import GiftUIRuntimeStatic
import GiftUISemanticCore
import CycleSchema

extension CyclePipelineOwner {
    @_lifetime(copy models, copy root, copy semantic, copy values, copy scopedControl)
    init(models: consuming ObservableModelScope<CycleOwnedModel, CycleModelSchema>, root: consuming ObservableStateRootScope<CycleOwnedModel, SemanticCompleteIdentity>, semantic: consuming SemanticRecordStore<CyclePayload>, values: consuming CanvasStagedValues<SemanticRecordReference, CycleValueTable>, geometry: consuming Geometry, interaction: consuming InteractionOwnedKeyState<Candidate, Committed, Hits>, scopedControl: consuming InvestigationControl, limits: RuntimeProfileLimits) {
        self.models = consume models; self.root = consume root; self.semantic = consume semantic; self.values = consume values
        self.limits = limits
        self.geometry = consume geometry; self.interaction = consume interaction; self.control = scopedControl.pointer
        precondition(self.root.belongs(to: self.models))
    }
}

extension CycleExecutionBinding {
    @_lifetime(copy models, copy root, copy scopedControl)
    init?(models: consuming ObservableModelScope<CycleOwnedModel, CycleModelSchema>, root: consuming ObservableStateRootScope<CycleOwnedModel, SemanticCompleteIdentity>, scopedControl: consuming InvestigationControl, audit: RuntimeStorageAudit) {
        guard root.belongs(to: models) else { return nil }
        storageAudit = audit
        self.models = consume models; self.root = consume root; self.control = scopedControl.pointer
    }
}
