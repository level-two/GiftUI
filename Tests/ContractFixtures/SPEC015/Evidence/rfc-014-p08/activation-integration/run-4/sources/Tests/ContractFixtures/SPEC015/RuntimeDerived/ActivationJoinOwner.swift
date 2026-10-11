import CycleSchema
import GiftUI
import GiftUIDrawing
import GiftUIExecution
import GiftUIInteraction
import GiftUIObservableState
import GiftUIRuntimeCore
import GiftUIRuntimeStatic
import GiftUISemanticCore

@testable import GiftUIHostConfiguration

struct P08ActivationControl: ~Copyable, ~Escapable {
    let pointer: UnsafeMutablePointer<CycleControl>
    @_lifetime(borrow pointer)
    init(pointer: borrowing UnsafeMutablePointer<CycleControl>) { self.pointer = copy pointer }
    @_lifetime(copy other)
    private init(other: borrowing P08ActivationControl) { pointer = other.pointer }
    @_lifetime(copy self)
    borrowing func borrowed() -> P08ActivationControl { P08ActivationControl(other: self) }
}

typealias P08ActivationPipeline = CyclePipelineOwner<
    StaticCycleGeometry, CycleStaticCandidate, CycleStaticCommitted, CycleStaticHits
>
typealias P08ActivationCoordinator = StaticRuntimeExecutionCoordinator<
    CycleExecutionBinding, CycleAdmission, P08ActivationPipeline
>

// Evidence-only supplied state. These are actual backing scopes and owned
// workspaces. There is no endpoint, pipeline or coordinator in the inert case.
struct P08ActivationSuppliedStorage<Geometry: CycleGeometry>: ~Copyable, ~Escapable {
    private let models: ObservableModelScope<CycleOwnedModel, CycleModelSchema>
    private let root: ObservableStateRootScope<CycleOwnedModel, SemanticCompleteIdentity>
    private let semantic: SemanticRecordStore<CyclePayload>
    private let values: CanvasStagedValues<SemanticRecordReference, CycleValueTable>
    private let control: P08ActivationControl
    let audit: RuntimeStorageAudit
    var geometry: Geometry
    var interaction: CycleStaticKeys

    @_lifetime(copy models, copy root, copy semantic, copy values, borrow control)
    init(
        models: consuming ObservableModelScope<CycleOwnedModel, CycleModelSchema>,
        root: consuming ObservableStateRootScope<CycleOwnedModel, SemanticCompleteIdentity>,
        semantic: consuming SemanticRecordStore<CyclePayload>,
        values: consuming CanvasStagedValues<SemanticRecordReference, CycleValueTable>,
        control: borrowing UnsafeMutablePointer<CycleControl>, audit: RuntimeStorageAudit,
        geometry: consuming Geometry, interaction: consuming CycleStaticKeys
    ) {
        self.models = consume models
        self.root = consume root
        self.semantic = consume semantic
        self.values = consume values
        self.control = P08ActivationControl(pointer: control)
        self.audit = audit
        self.geometry = consume geometry
        self.interaction = consume interaction
    }
    @_lifetime(copy self)
    borrowing func borrowedModels() -> ObservableModelScope<CycleOwnedModel, CycleModelSchema> {
        models.borrowedScope()
    }
    @_lifetime(copy self)
    borrowing func borrowedRoot() -> ObservableStateRootScope<
        CycleOwnedModel, SemanticCompleteIdentity
    > { root.borrowedRoot() }
    @_lifetime(copy self)
    borrowing func borrowedSemantic() -> SemanticRecordStore<CyclePayload> {
        semantic.borrowedStore()
    }
    @_lifetime(copy self)
    borrowing func borrowedValues() -> CanvasStagedValues<SemanticRecordReference, CycleValueTable>
    { values.borrowedValues() }
    var controlPointer: UnsafeMutablePointer<CycleControl> { control.pointer }
    @_lifetime(copy self)
    borrowing func borrowedControl() -> P08ActivationControl { control.borrowed() }
}

typealias P08ActivationSupplied = P08ActivationSuppliedStorage<StaticCycleGeometry>

extension CyclePipelineOwner {
    @_lifetime(copy models, copy root, copy semantic, copy values, copy scopedControl)
    init(
        models: consuming ObservableModelScope<CycleOwnedModel, CycleModelSchema>,
        root: consuming ObservableStateRootScope<CycleOwnedModel, SemanticCompleteIdentity>,
        semantic: consuming SemanticRecordStore<CyclePayload>,
        values: consuming CanvasStagedValues<SemanticRecordReference, CycleValueTable>,
        geometry: consuming Geometry,
        interaction: consuming InteractionOwnedKeyState<Candidate, Committed, Hits>,
        scopedControl: consuming P08ActivationControl, limits: RuntimeProfileLimits
    ) {
        self.models = consume models
        self.root = consume root
        self.semantic = consume semantic
        self.values = consume values
        self.limits = limits
        self.geometry = consume geometry
        self.interaction = consume interaction
        self.control = scopedControl.pointer
        precondition(self.root.belongs(to: self.models))
    }
}

extension CycleExecutionBinding {
    @_lifetime(copy models, copy root, copy scopedControl)
    init?(
        models: consuming ObservableModelScope<CycleOwnedModel, CycleModelSchema>,
        root: consuming ObservableStateRootScope<CycleOwnedModel, SemanticCompleteIdentity>,
        scopedControl: consuming P08ActivationControl, audit: RuntimeStorageAudit
    ) {
        guard root.belongs(to: models) else { return nil }
        storageAudit = audit
        self.models = consume models
        self.root = consume root
        self.control = scopedControl.pointer
    }
}

// Candidate A: internal state storage control; not a new host role or protocol.
enum P08ActivationState: ~Copyable, ~Escapable {
    case inert(P08ActivationSupplied, Span<UInt8>)
    case active(P08ActivationCoordinator, Span<UInt8>)
    case retired(Span<UInt8>)
    @_lifetime(copy supplied, copy activationSpan)
    init(supplied: consuming P08ActivationSupplied, activationSpan: Span<UInt8>) {
        self = .inert(consume supplied, activationSpan)
    }

    @_lifetime(self: copy self)
    mutating func activate() {
        switch consume self {
        case .retired(let span):
            self = .retired(span)
            preconditionFailure("retired runtime")
        case .inert(let supplied, let activationSpan):
            p08CheckActivationSpan(activationSpan)
            let pipeline = P08ActivationPipeline(
                models: supplied.borrowedModels(), root: supplied.borrowedRoot(),
                semantic: supplied.borrowedSemantic(), values: supplied.borrowedValues(),
                geometry: supplied.geometry, interaction: supplied.interaction,
                scopedControl: supplied.borrowedControl(), limits: supplied.audit.limits)
            let binding = CycleExecutionBinding(
                models: supplied.borrowedModels(),
                root: supplied.borrowedRoot(), scopedControl: supplied.borrowedControl(),
                audit: supplied.audit)!
            let coordinator = P08ActivationCoordinator(
                binding: binding,
                admission: CycleAdmission(
                    control: supplied.controlPointer, limits: supplied.audit.limits.execution),
                opportunity: pipeline)
            self = .active(consume coordinator, activationSpan)
        case .active(let coordinator, let activationSpan):
            p08CheckActivationSpan(activationSpan)
            self = .active(consume coordinator, activationSpan)
        }
    }
    @_lifetime(self: copy self)
    mutating func runOpportunity() -> RunCycleResult<RuntimeOwnerFailure> {
        switch consume self {
        case .retired(let span):
            self = .retired(span)
            preconditionFailure("retired runtime")
        case .inert(let supplied, let activationSpan):
            p08CheckActivationSpan(activationSpan)
            self = .inert(consume supplied, activationSpan)
            preconditionFailure("host must gate inactive opportunities")
        case .active(var coordinator, let activationSpan):
            p08CheckActivationSpan(activationSpan)
            let success = coordinator.runOpportunity()
            self = .active(consume coordinator, activationSpan)
            return success
        }
    }
    @_lifetime(self: copy self)
    mutating func quiesce() {
        switch consume self {
        case .retired(let span):
            self = .retired(span)
            preconditionFailure("retired runtime")
        case .inert(let supplied, let activationSpan):
            self = .inert(consume supplied, activationSpan)
        case .active(var coordinator, let activationSpan):
            p08CheckActivationSpan(activationSpan)
            coordinator.quiesce()
            precondition(coordinator.isQuiescent)
            self = .active(consume coordinator, activationSpan)
        }
    }
    @_lifetime(self: copy self)
    mutating func release() {
        switch consume self {
        case .inert(_, let span): self = .retired(span)
        case .active(_, let span): self = .retired(span)
        case .retired(let span): self = .retired(span)
        }
    }

}

@inline(never)
func p08CheckActivationSpan(_ span: borrowing Span<UInt8>) {
    precondition(span.count == 1 && span[0] != 0)
}

@inline(never)
func p08InvokeActivationCallback(_ body: () -> Int) -> Int { body() }

// The fixture implements the existing live-owner role. Only the first controller
// activation step constructs the real pipeline, endpoint, binding and coordinator.
struct P08ActivationOwner: ~Copyable, ~Escapable, SignalAnalyzerPresetLiveOwner {
    typealias ActivationFailure = MacOSStaticHostActivationFailure
    private var state: P08ActivationState
    private let failAfterRuntime: Bool
    private(set) var trace = InlineArray<32, UInt8>(repeating: 0)
    private(set) var traceCount = 0
    private(set) var constructions = 0
    private var quiesced = false
    private var released = false
    @_lifetime(copy supplied, copy activationSpan)
    init(
        supplied: consuming P08ActivationSupplied, activationSpan: Span<UInt8>,
        failAfterRuntime: Bool = false
    ) {
        state = P08ActivationState(supplied: consume supplied, activationSpan: activationSpan)
        self.failAfterRuntime = failAfterRuntime
    }
    mutating func record(_ value: UInt8) {
        trace[traceCount] = value
        traceCount += 1
    }
    mutating func constructRuntimeAndEndpoint() -> HostActivationStepResult<ActivationFailure> {
        record(1)
        state.activate()
        constructions += 1
        return failAfterRuntime
            ? .failure(
                .configuration(.arithmeticOverflow), progress: .init(runtimeConstructed: true))
            : .advanced
    }
    mutating func constructApplicationOwners() -> HostActivationStepResult<ActivationFailure> {
        record(2)
        return .advanced
    }
    mutating func attachRootModelInFirstCandidate() -> HostActivationStepResult<ActivationFailure> {
        record(3)
        return .advanced
    }
    mutating func installRepositoryObservationAndAdmitCurrentValues() -> HostActivationStepResult<
        ActivationFailure
    > {
        record(4)
        return .advanced
    }
    mutating func acceptFirstPresentationAndEnableInput() -> HostActivationStepResult<
        ActivationFailure
    > {
        record(5)
        return .advanced
    }
    mutating func startAcquisitionThroughApplicationOpportunity() -> HostActivationStepResult<
        ActivationFailure
    > {
        record(6)
        return .advanced
    }
    mutating func establishWakeAndPacingHostLoop() -> HostActivationStepResult<ActivationFailure> {
        record(7)
        return .advanced
    }
    mutating func stopSourceDeliveryAndRepositoryObservation() { record(8) }
    mutating func preventInputEligibility() { record(9) }
    mutating func quiesceConstructedRuntime() {
        record(10)
        quiesceOnce()
    }
    mutating func refuseApplicationDeliveryAndInput() { record(11) }
    mutating func stopSourceDeliveryAndDetachObservations() { record(12) }
    mutating func cancelPointerSequencesAndHostCallbacks() { record(13) }
    mutating func quiesceRuntimeAndFinalizeActiveCycle() {
        record(14)
        quiesceOnce()
    }
    mutating func retireObservableRegistrationAndRouting() {
        record(15)
        precondition(quiesced)
    }
    mutating func releasePlatformOwners() {
        record(16)
        precondition(quiesced)
        state.release()
        released = true
    }
    mutating func resetProfileStorage() {
        record(17)
        precondition(released)
    }
    mutating func invalidateAssemblyReportRuntimeUse() {
        record(18)
        precondition(released)
    }
    private mutating func quiesceOnce() {
        if !quiesced {
            state.quiesce()
            quiesced = true
        }
    }
    mutating func runOpportunity() -> RunCycleResult<RuntimeOwnerFailure> { state.runOpportunity() }
}
typealias P08ActivationHost = SignalAnalyzerPresetHostInstance<P08ActivationOwner>
