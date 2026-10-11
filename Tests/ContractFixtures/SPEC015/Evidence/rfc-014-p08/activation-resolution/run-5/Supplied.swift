import GiftUI
import GiftUIDrawing
import GiftUIInteraction
import GiftUIObservableState
import GiftUIRuntimeCore
import GiftUIRuntimeStatic
import GiftUISemanticCore
import CycleSchema

typealias InvestigationPipeline = CyclePipelineOwner<StaticCycleGeometry, CycleStaticCandidate, CycleStaticCommitted, CycleStaticHits>
typealias InvestigationCoordinator = StaticRuntimeExecutionCoordinator<CycleExecutionBinding, CycleAdmission, InvestigationPipeline>

// Evidence-only supplied state. These are actual backing scopes and owned
// workspaces. There is no endpoint, pipeline or coordinator in the inert case.
struct InvestigationSupplied: ~Copyable, ~Escapable {
    let models: ObservableModelScope<CycleOwnedModel, CycleModelSchema>
    let root: ObservableStateRootScope<CycleOwnedModel, SemanticCompleteIdentity>
    let semantic: SemanticRecordStore<CyclePayload>
    let values: CanvasStagedValues<SemanticRecordReference, CycleValueTable>
    let control: UnsafeMutablePointer<CycleControl>
    let audit: RuntimeStorageAudit
    var geometry: StaticCycleGeometry
    var interaction: CycleStaticKeys

    @_lifetime(copy models, copy root, copy semantic, copy values, borrow control)
    init(models: consuming ObservableModelScope<CycleOwnedModel, CycleModelSchema>,
         root: consuming ObservableStateRootScope<CycleOwnedModel, SemanticCompleteIdentity>,
         semantic: consuming SemanticRecordStore<CyclePayload>,
         values: consuming CanvasStagedValues<SemanticRecordReference, CycleValueTable>,
         control: borrowing UnsafeMutablePointer<CycleControl>, audit: RuntimeStorageAudit,
         geometry: consuming StaticCycleGeometry, interaction: consuming CycleStaticKeys) {
        self.models = consume models
        self.root = consume root
        self.semantic = consume semantic
        self.values = consume values
        self.control = copy control
        self.audit = audit
        self.geometry = consume geometry
        self.interaction = consume interaction
    }
}
