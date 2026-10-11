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
 init(models: borrowing ObservableModelScope<CycleOwnedModel,CycleModelSchema>,root: borrowing ObservableStateRootScope<CycleOwnedModel,SemanticCompleteIdentity>,semantic: borrowing SemanticRecordStore<CyclePayload>,values: borrowing CanvasStagedValues<SemanticRecordReference,CycleValueTable>,control: borrowing UnsafeMutablePointer<CycleControl>,audit:RuntimeStorageAudit,geometry: consuming G,interaction:consuming InteractionOwnedKeyState<C,R,H>) {
 self.models=models.borrowedScope();self.root=root.borrowedRoot();self.semantic=semantic.borrowedStore();self.values=values.borrowedValues();self.control=copy control;self.audit=audit;self.geometry=consume geometry;self.interaction=consume interaction;self.coordinator=nil
 }
 mutating func activate() {
 let pipeline=Pipeline(models:models.borrowedScope(),root:root.borrowedRoot(),semantic:semantic.borrowedStore(),values:values.borrowedValues(),geometry:geometry.take()!,interaction:interaction.take()!,control:control,limits:audit.limits)
 let binding=CycleExecutionBinding(models:models.borrowedScope(),root:root.borrowedRoot(),control:control,audit:audit)!
 coordinator=Coordinator(binding:binding,admission:CycleAdmission(control:control,limits:audit.limits.execution),opportunity:pipeline)
 }
}
