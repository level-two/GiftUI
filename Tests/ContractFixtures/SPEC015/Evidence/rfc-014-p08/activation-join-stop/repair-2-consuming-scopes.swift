import GiftUI
import GiftUIInteraction

import GiftUIObservableState
import GiftUISemanticCore
import GiftUIDrawing
import GiftUIRuntimeCore
import GiftUIRuntimeStatic
import CycleSchema
@testable import RuntimeCycleProbe

struct P08ActivationJoin<G,C,R,H>: ~Copyable, ~Escapable
where G: CycleGeometry,C: CycleCandidateBacking,R:CycleCommittedBacking,H:CycleHitBacking,
 C.Identity == SemanticCompleteIdentity,R.Identity == SemanticCompleteIdentity,H.Identity == SemanticCompleteIdentity {
 typealias Pipeline = CyclePipelineOwner<G,C,R,H>
 typealias Coordinator = StaticRuntimeExecutionCoordinator<CycleExecutionBinding,CycleAdmission,Pipeline>
 let models: ObservableModelScope<CycleOwnedModel,CycleModelSchema>
 let root: ObservableStateRootScope<CycleOwnedModel,SemanticCompleteIdentity>
 let semantic: SemanticRecordStore<CyclePayload>
 let values: CanvasStagedValues<SemanticRecordReference,CycleValueTable>
 let control: UnsafeMutablePointer<CycleControl>
 let audit: RuntimeStorageAudit
 var geometry: G?
 var interaction: InteractionOwnedKeyState<C,R,H>?
 var coordinator: Coordinator?
 @_lifetime(copy models,copy root,copy semantic,copy values,borrow control)
 init(models: consuming ObservableModelScope<CycleOwnedModel,CycleModelSchema>,root: consuming ObservableStateRootScope<CycleOwnedModel,SemanticCompleteIdentity>,semantic: consuming SemanticRecordStore<CyclePayload>,values: consuming CanvasStagedValues<SemanticRecordReference,CycleValueTable>,control: borrowing UnsafeMutablePointer<CycleControl>,audit:RuntimeStorageAudit,geometry: consuming G,interaction:consuming InteractionOwnedKeyState<C,R,H>) {
 self.models=consume models;self.root=consume root;self.semantic=consume semantic;self.values=consume values;self.control=copy control;self.audit=audit;self.geometry=consume geometry;self.interaction=consume interaction;self.coordinator=nil
 }
}
