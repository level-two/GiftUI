#if !hasFeature(Embedded)
import P08CounterSchema
import GiftUI
import GiftUIDrawing
import GiftUIExecution
import GiftUIInteraction
import GiftUIObservableState
import GiftUIRuntimeCore
import GiftUIRuntimeDynamic
import GiftUISemanticCore

@testable import GiftUIHostConfiguration

typealias CounterDynamicHostPipeline = CounterPipelineOwner<
    DynamicCounterGeometry, CounterDynamicCandidate, CounterDynamicCommitted, CounterDynamicHits
>
typealias CounterDynamicHostCoordinator = DynamicRuntimeExecutionCoordinator<
    CounterExecutionBinding, CounterAdmission, CounterDynamicHostPipeline
>

// Actual finite counter supplied state. These are actual backing scopes and owned
// workspaces. There is no endpoint, pipeline or coordinator in the inert case.
struct CounterDynamicHostSuppliedStorage<Geometry: CounterGeometry>: ~Copyable, ~Escapable {
    private let models: ObservableModelScope<CounterOwnedModel, CounterModelSchema>
    private let root: ObservableStateRootScope<CounterOwnedModel, SemanticCompleteIdentity>
    private let semantic: SemanticRecordStore<CounterPayload>
    private let values: CanvasStagedValues<SemanticRecordReference, CounterValueTable>
    private let control: CounterHostControl
    let audit: RuntimeStorageAudit
    var geometry: Geometry
    var interaction: CounterDynamicKeys

    @_lifetime(copy models, copy root, copy semantic, copy values, borrow control)
    init(
        models: consuming ObservableModelScope<CounterOwnedModel, CounterModelSchema>,
        root: consuming ObservableStateRootScope<CounterOwnedModel, SemanticCompleteIdentity>,
        semantic: consuming SemanticRecordStore<CounterPayload>,
        values: consuming CanvasStagedValues<SemanticRecordReference, CounterValueTable>,
        control: borrowing UnsafeMutablePointer<CounterControl>, audit: RuntimeStorageAudit,
        geometry: consuming Geometry, interaction: consuming CounterDynamicKeys
    ) {
        self.models = consume models
        self.root = consume root
        self.semantic = consume semantic
        self.values = consume values
        self.control = CounterHostControl(pointer: control)
        self.audit = audit
        self.geometry = consume geometry
        self.interaction = consume interaction
    }
    @_lifetime(copy self)
    borrowing func borrowedModels(selection: CounterProfileConstructionInput = .supplied) -> ObservableModelScope<CounterOwnedModel, CounterModelSchema> {
        switch selection { case .supplied: return models.borrowedScope() }
    }
    @_lifetime(copy self)
    borrowing func borrowedRoot(selection: CounterProfileConstructionInput = .supplied) -> ObservableStateRootScope<
        CounterOwnedModel, SemanticCompleteIdentity
    > { switch selection { case .supplied: return root.borrowedRoot() } }
    @_lifetime(copy self)
    borrowing func borrowedSemantic() -> SemanticRecordStore<CounterPayload> {
        semantic.borrowedStore()
    }
    @_lifetime(copy self)
    borrowing func borrowedValues() -> CanvasStagedValues<SemanticRecordReference, CounterValueTable>
    { values.borrowedValues() }
    var controlPointer: UnsafeMutablePointer<CounterControl> { control.pointer }
    @_lifetime(copy self)
    borrowing func borrowedControl() -> CounterHostControl { control.borrowed() }
}

typealias CounterDynamicHostSupplied = CounterDynamicHostSuppliedStorage<DynamicCounterGeometry>

// Internal storage for the existing scoped host role, retaining every actual
// supplied backing scope through inert, active and retired states.
enum CounterDynamicHostState: ~Copyable, ~Escapable {
    case inert(CounterDynamicHostSupplied, Span<UInt8>)
    case active(CounterDynamicHostCoordinator, ObservableModelTicket<CounterModelSchema>?, Span<UInt8>)
    case retired(SemanticRecordStore<CounterPayload>, DynamicCounterGeometry, CounterDynamicKeys, Span<UInt8>)
    @_lifetime(copy supplied, copy activationSpan)
    init(supplied: consuming CounterDynamicHostSupplied, activationSpan: Span<UInt8>) {
        self = .inert(consume supplied, activationSpan)
    }
    var controlPointer: UnsafeMutablePointer<CounterControl> {
        switch self {
        case .inert(let supplied, _): supplied.controlPointer
        case .active(let coordinator, _, _): coordinator.opportunity.control
        case .retired: preconditionFailure("retired counter control")
        }
    }
    @_lifetime(self: copy self)
    mutating func activate(assembly: CounterHostAssembly) -> HostConfigurationError? {
        switch consume self {
        case .inert(let supplied, let span):
            precondition(span.count == 1 && span[0] == 1)
            let construction = CounterConstructionInputs.canonical
            let models = supplied.borrowedModels(selection: construction.root)
            let root = supplied.borrowedRoot(selection: construction.root)
            let control = supplied.borrowedControl()
            let audit = construction.root.audit(supplied.audit)
            let report = assembly.report
            if let error = counterBindingJoinError(expectedModels: models, expectedControl: supplied.controlPointer, expectedAudit: supplied.audit, expectedReport: assembly.report, kind: .macOSDynamic, profile: .dynamic, models: models, root: root, control: control.pointer, audit: audit, report: report) {
                self = .inert(consume supplied, span)
                return error
            }
            let pipeline = CounterDynamicHostPipeline(models: models.borrowedScope(), root: root.borrowedRoot(), semantic: supplied.borrowedSemantic(), values: supplied.borrowedValues(), geometry: supplied.geometry, interaction: supplied.interaction, scopedControl: control.borrowed(), limits: audit.limits, endpointConfiguration: assembly.endpoint)
            let binding = CounterExecutionBinding(models: models.borrowedScope(), root: root.borrowedRoot(), scopedControl: control.borrowed(), audit: audit)!
            let coordinator = CounterDynamicHostCoordinator(binding: binding, admission: CounterAdmission(control: construction.admission.control(control.pointer), limits: construction.admission.audit(audit).limits.execution), opportunity: pipeline)
            self = .active(consume coordinator, nil, span)
        case .active(let coordinator, let cache, let span): self = .active(consume coordinator, consume cache, span)
        case .retired(let semantic, let geometry, let interaction, let span): self = .retired(consume semantic, geometry, interaction, span); preconditionFailure("retired host")
        }
        return nil
    }
    @_lifetime(self: copy self)
    mutating func activate(assembly: CounterHostAssembly, models: borrowing ObservableModelScope<CounterOwnedModel, CounterModelSchema>, root: borrowing ObservableStateRootScope<CounterOwnedModel, SemanticCompleteIdentity>, control: UnsafeMutablePointer<CounterControl>, audit: RuntimeStorageAudit, report: HostAssemblyReport) -> HostConfigurationError? {
        switch self {
        case .inert(let supplied, _):
            if let error = counterBindingJoinError(expectedModels: supplied.borrowedModels(), expectedControl: supplied.controlPointer, expectedAudit: supplied.audit, expectedReport: assembly.report, kind: .macOSDynamic, profile: .dynamic, models: models, root: root, control: control, audit: audit, report: report) { return error }
        case .active: return .invariantViolation
        case .retired: return .invariantViolation
        }
        // Successful proposals name exactly the canonical supplied backing and
        // configuration. Reborrow those same checked values for retained lifetime.
        return activate(assembly: assembly)
    }
    @_lifetime(self: copy self)
    mutating func attachRoot() -> Bool {
        switch consume self {
        case .active(var coordinator, _, let span):
            coordinator.opportunity.control.pointee.offer = .backpressured
            let result = coordinator.runOpportunity()
            guard case .operational(.backpressured, _) = result,
                let identity = coordinator.opportunity.rootIdentity,
                let key = coordinator.opportunity.root.modelKey(identity: identity, ordinal: 0)
            else { self = .active(consume coordinator, nil, span); return false }
            do throws(ObservableStateError) {
                let cache = try coordinator.opportunity.models.retain(key)
                self = .active(consume coordinator, cache, span)
                return true
            } catch { self = .active(consume coordinator, nil, span); return false }
        case .inert(let supplied, let span): self = .inert(consume supplied, span); return false
        case .retired(let semantic, let geometry, let interaction, let span): self = .retired(consume semantic, geometry, interaction, span); return false
        }
    }
    @_lifetime(self: copy self)
    mutating func admit(_ value: UInt8) -> Bool {
        switch consume self {
        case .active(var coordinator, let cache, let span):
            let outcome = coordinator.submit(stateChange: value)
            self = .active(consume coordinator, consume cache, span)
            return outcome.result == .queued
        case .inert(let supplied, let span): self = .inert(consume supplied, span); return false
        case .retired(let semantic, let geometry, let interaction, let span): self = .retired(consume semantic, geometry, interaction, span); return false
        }
    }
    @_lifetime(self: copy self)
    mutating func runOpportunity() -> RunCycleResult<RuntimeOwnerFailure> {
        switch consume self {
        case .active(var coordinator, let cache, let span):
            let result = coordinator.runOpportunity()
            self = .active(consume coordinator, consume cache, span)
            return result
        case .inert(let supplied, let span): self = .inert(consume supplied, span); preconditionFailure("inactive host")
        case .retired(let semantic, let geometry, let interaction, let span): self = .retired(consume semantic, geometry, interaction, span); preconditionFailure("retired host")
        }
    }
    @_lifetime(self: copy self)
    mutating func quiesce() {
        switch consume self {
        case .active(var coordinator, var cache, let span):
            if var ticket = cache.take() {
                do throws(ObservableStateError) { try coordinator.opportunity.models.release(&ticket) }
                catch { preconditionFailure("counter cache release") }
            }
            coordinator.quiesce()
            precondition(coordinator.isQuiescent)
            self = .active(consume coordinator, nil, span)
        case .inert(let supplied, let span): self = .inert(consume supplied, span)
        case .retired(let semantic, let geometry, let interaction, let span): self = .retired(consume semantic, geometry, interaction, span)
        }
    }
    @_lifetime(self: copy self)
    mutating func releasePlatformOwners() {
        switch consume self {
        case .active(let coordinator, let cache, let span):
            precondition(coordinator.isQuiescent && cache == nil)
            let returned = coordinator.takeQuiescedOpportunity()!
            let semantic = returned.semantic.borrowedStore()
            self = .retired(consume semantic, returned.geometry, returned.interaction, span)
        case .inert(let supplied, let span): self = .retired(supplied.borrowedSemantic(), supplied.geometry, supplied.interaction, span)
        case .retired(let semantic, let geometry, let interaction, let span): self = .retired(consume semantic, geometry, interaction, span)
        }
    }
    @_lifetime(self: copy self)
    mutating func resetProfileStorage() {
        switch consume self {
        case .retired(let semantic, var geometry, var interaction, let span):
            do throws(SemanticExpansionError) { try semantic.resetAfterQuiescence() }
            catch { preconditionFailure("counter semantic reset") }
            geometry.reset()
            interaction.resetAllStorage()
            self = .retired(consume semantic, geometry, interaction, span)
        case .active(let coordinator, let cache, let span):
            self = .active(consume coordinator, consume cache, span)
            preconditionFailure("platform owners must release before profile reset")
        case .inert(let supplied, let span):
            self = .inert(consume supplied, span)
            preconditionFailure("platform owners must release before profile reset")
        }
    }

}

typealias CounterDynamicApplicationOwners = CounterApplicationOwners

struct CounterDynamicHostOwner: ~Copyable, ~Escapable, SignalAnalyzerPresetLiveOwner {
    #if os(Linux)
    typealias ActivationFailure = RaspberryPiDynamicHostActivationFailure
    #else
    typealias ActivationFailure = MacOSDynamicHostActivationFailure
    #endif
    private var state: CounterDynamicHostState
    private var application: CounterDynamicApplicationOwners?
    private(set) var constructions = 0
    private(set) var activationStep: UInt8 = 0
    private(set) var teardownStep: UInt8 = 0
    private var quiesced = false
    private var reportValid = true
    let assembly: CounterHostAssembly
    private let failAfterRuntime: Bool
    @_lifetime(copy supplied, copy activationSpan)
    init(supplied: consuming CounterDynamicHostSupplied, activationSpan: Span<UInt8>, assembly: CounterHostAssembly, failAfterRuntime: Bool) {
        state = CounterDynamicHostState(supplied: consume supplied, activationSpan: activationSpan)
        self.assembly = assembly
        self.failAfterRuntime = failAfterRuntime
    }
    mutating func constructRuntimeAndEndpoint() -> HostActivationStepResult<ActivationFailure> {
        precondition(activationStep == 0 && constructions == 0)
        if let error = state.activate(assembly: assembly) { return .failure(.configuration(error), progress: .init()) }
        constructions += 1; activationStep = 1
        return failAfterRuntime || state.controlPointer.pointee.idleQuiesceMode == 1 ? .failure(.configuration(.arithmeticOverflow), progress: .init(runtimeConstructed: true)) : .advanced
    }
    mutating func constructRuntimeAndEndpoint(models: borrowing ObservableModelScope<CounterOwnedModel, CounterModelSchema>, root: borrowing ObservableStateRootScope<CounterOwnedModel, SemanticCompleteIdentity>, control: UnsafeMutablePointer<CounterControl>, audit: RuntimeStorageAudit, report: HostAssemblyReport) -> HostActivationStepResult<ActivationFailure> {
        precondition(activationStep == 0 && constructions == 0)
        if let error = state.activate(assembly: assembly, models: models, root: root, control: control, audit: audit, report: report) { return .failure(.configuration(error), progress: .init()) }
        constructions += 1; activationStep = 1
        return .advanced
    }
    mutating func constructApplicationOwners() -> HostActivationStepResult<ActivationFailure> {
        precondition(activationStep == 1)
        application = CounterDynamicApplicationOwners(control: state.controlPointer); activationStep = 2; return state.controlPointer.pointee.idleQuiesceMode == 2 ? .failure(.configuration(.arithmeticOverflow), progress: .init()) : .advanced
    }
    mutating func attachRootModelInFirstCandidate() -> HostActivationStepResult<ActivationFailure> {
        precondition(activationStep == 2)
        guard state.attachRoot() else { return .failure(.invariant, progress: .init()) }
        activationStep = 3; return state.controlPointer.pointee.idleQuiesceMode == 3 ? .failure(.configuration(.arithmeticOverflow), progress: .init()) : .advanced
    }
    mutating func installRepositoryObservationAndAdmitCurrentValues() -> HostActivationStepResult<ActivationFailure> {
        precondition(activationStep == 3)
        let current = application!.installObservation()
        guard state.admit(current) else { return .failure(.invariant, progress: .init(observationInstalled: true)) }
        application!.deliveryEnabled = true
        activationStep = 4; return state.controlPointer.pointee.idleQuiesceMode == 4 ? .failure(.configuration(.arithmeticOverflow), progress: .init(observationInstalled: true)) : .advanced
    }
    mutating func acceptFirstPresentationAndEnableInput() -> HostActivationStepResult<ActivationFailure> {
        precondition(activationStep == 4)
        state.controlPointer.pointee.offer = .accepted
        guard case .success(let summary) = state.runOpportunity(), summary.logicalFrameDisposition == .committed else { return .failure(.invariant, progress: .init()) }
        application!.inputEnabled = true
        activationStep = 5; return state.controlPointer.pointee.idleQuiesceMode == 5 ? .failure(.configuration(.arithmeticOverflow), progress: .init()) : .advanced
    }
    mutating func startAcquisitionThroughApplicationOpportunity() -> HostActivationStepResult<ActivationFailure> {
        precondition(activationStep == 5)
        guard application!.startSource() else { return .failure(.invariant, progress: .init(sourceStarted: true)) }
        activationStep = 6; return state.controlPointer.pointee.idleQuiesceMode == 6 ? .failure(.configuration(.arithmeticOverflow), progress: .init(sourceStarted: true)) : .advanced
    }
    mutating func establishWakeAndPacingHostLoop() -> HostActivationStepResult<ActivationFailure> {
        precondition(activationStep == 6)
        state.controlPointer.pointee.establishCounterScheduler(report: assembly.report)
        let control = state.controlPointer
        let runtimeProjection = control.pointee.hasRoot
            && control.pointee.committedRecords == 2
            && control.pointee.admissionController != nil
            && control.pointee.wake != nil
            && control.pointee.scheduler != nil
        let applicationProjection = application!.constructedProjectionIsValid
        precondition(runtimeProjection && applicationProjection)
        #if !hasFeature(Embedded)
        precondition(state.controlPointer.pointee.backend.constructedEndpoints == 1)
        precondition(state.controlPointer.pointee.backend.constructedProjection == assembly.endpoint)
        #endif
        activationStep = 7; return state.controlPointer.pointee.idleQuiesceMode == 7 ? .failure(.configuration(.arithmeticOverflow), progress: .init()) : .advanced
    }
    mutating func stopSourceDeliveryAndRepositoryObservation() { application?.stopDelivery() }
    mutating func preventInputEligibility() { application?.inputEnabled = false }
    mutating func quiesceConstructedRuntime() { quiesceOnce() }
    mutating func refuseApplicationDeliveryAndInput() { precondition(teardownStep == 0); application?.stopDelivery(); teardownStep = 1 }
    mutating func stopSourceDeliveryAndDetachObservations() { precondition(teardownStep == 1); application?.stopDelivery(); teardownStep = 2 }
    mutating func cancelPointerSequencesAndHostCallbacks() { precondition(teardownStep == 2); teardownStep = 3 }
    mutating func quiesceRuntimeAndFinalizeActiveCycle() { precondition(teardownStep == 3); quiesceOnce(); teardownStep = 4 }
    mutating func retireObservableRegistrationAndRouting() { precondition(teardownStep == 4 && quiesced); teardownStep = 5 }
    mutating func releasePlatformOwners() { precondition(teardownStep == 5); state.releasePlatformOwners(); application = nil; teardownStep = 6 }
    mutating func resetProfileStorage() { precondition(teardownStep == 6); state.resetProfileStorage(); teardownStep = 7 }
    mutating func invalidateAssemblyReportRuntimeUse() { precondition(teardownStep == 7); reportValid = false; teardownStep = 8 }
    private mutating func quiesceOnce() { if !quiesced { state.quiesce(); quiesced = true } }
    mutating func runOpportunity() -> RunCycleResult<RuntimeOwnerFailure> { precondition(reportValid && activationStep == 7); return state.runOpportunity() }
}

#endif
