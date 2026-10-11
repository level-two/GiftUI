import GiftUI
import GiftUIDrawing
import GiftUIInteraction
import GiftUIObservableState
import GiftUIRuntimeCore
import GiftUIRuntimeStatic
import GiftUISemanticCore
import CycleSchema
@testable import RuntimeCycleProbe

typealias InvestigationPipeline = CyclePipelineOwner<StaticCycleGeometry, CycleStaticCandidate, CycleStaticCommitted, CycleStaticHits>
typealias InvestigationCoordinator = StaticRuntimeExecutionCoordinator<CycleExecutionBinding, CycleAdmission, InvestigationPipeline>

// Evidence-only supplied state. These are actual backing scopes and owned
// workspaces. There is no endpoint, pipeline or coordinator in the inert case.
struct InvestigationSuppliedStorage<Geometry: CycleGeometry>: ~Copyable, ~Escapable {
    private let models: ObservableModelScope<CycleOwnedModel, CycleModelSchema>
    private let root: ObservableStateRootScope<CycleOwnedModel, SemanticCompleteIdentity>
    private let semantic: SemanticRecordStore<CyclePayload>
    private let values: CanvasStagedValues<SemanticRecordReference, CycleValueTable>
    let control: UnsafeMutablePointer<CycleControl>
    let audit: RuntimeStorageAudit
    var geometry: Geometry
    var interaction: CycleStaticKeys

    @_lifetime(copy models, copy root, copy semantic, copy values, borrow control)
    init(models: consuming ObservableModelScope<CycleOwnedModel, CycleModelSchema>,
         root: consuming ObservableStateRootScope<CycleOwnedModel, SemanticCompleteIdentity>,
         semantic: consuming SemanticRecordStore<CyclePayload>,
         values: consuming CanvasStagedValues<SemanticRecordReference, CycleValueTable>,
         control: borrowing UnsafeMutablePointer<CycleControl>, audit: RuntimeStorageAudit,
         geometry: consuming Geometry, interaction: consuming CycleStaticKeys) {
        self.models = consume models
        self.root = consume root
        self.semantic = consume semantic
        self.values = consume values
        self.control = copy control
        self.audit = audit
        self.geometry = consume geometry
        self.interaction = consume interaction
    }
    @_lifetime(copy self)
    borrowing func borrowedModels() -> ObservableModelScope<CycleOwnedModel, CycleModelSchema> { models.borrowedScope() }
    @_lifetime(copy self)
    borrowing func borrowedRoot() -> ObservableStateRootScope<CycleOwnedModel, SemanticCompleteIdentity> { root.borrowedRoot() }
    @_lifetime(copy self)
    borrowing func borrowedSemantic() -> SemanticRecordStore<CyclePayload> { semantic.borrowedStore() }
    @_lifetime(copy self)
    borrowing func borrowedValues() -> CanvasStagedValues<SemanticRecordReference, CycleValueTable> { values.borrowedValues() }
}

typealias InvestigationSupplied = InvestigationSuppliedStorage<StaticCycleGeometry>
