import P08CounterTable
import GiftUI
import GiftUIDrawing
@testable import GiftUIExecution
import GiftUIInteraction
import GiftUIHostConfiguration
import GiftUIBackendIntegration
import GiftUICapabilities
import GiftUIDisplayCore
import GiftUIFailureCore
import GiftUIRasterCore
import GiftUISurfaceCore
import GiftUITextResources
import GiftUILayout
import GiftUIObservableState
import GiftUIRenderCore
import GiftUIRenderLowering
@testable import GiftUIRuntimeCore
import GiftUISemanticCore
import P08CounterSchema
import P08CounterPresentation

struct CounterRuntimeControl {
    var admission = CounterAdmissionBacking()
    var pointer = CounterPointerState()
    var committedPresentation: PresentationRevision?
    var result: RuntimeCompletePipelineResult<RuntimeOwnerFailure>?
    var context = ExecutionContext(cycle: nil, semanticRevision: nil, candidateFrame: nil, phase: .idle)
    var unavailable = false
    var changed = true
}
// Fixture-private producer identity; raw Execution identities remain runtime-local.
struct CounterProducerOrigin: Equatable {
    private let owner: UInt
    private let serial: UInt64
    fileprivate init(owner: UInt, serial: UInt64) { self.owner = owner; self.serial = serial }
}
struct CounterProducedAction {
    fileprivate let origin: CounterProducerOrigin
    let captured: CapturedAction<SemanticCompleteIdentity>
    let targetGeneration: UInt32
    let targetIdentity: SemanticCompleteIdentity
    fileprivate init(origin: CounterProducerOrigin, captured: CapturedAction<SemanticCompleteIdentity>, targetGeneration: UInt32, targetIdentity: SemanticCompleteIdentity) {
        self.origin = origin; self.captured = captured; self.targetGeneration = targetGeneration; self.targetIdentity = targetIdentity
    }
}
enum CounterRuntimeSlotPhase: UInt8, Equatable { case vacant, installing, installed, quiesced }

// Five independent stored fields below are borrowed separately. These scalar
// claims record the one pipeline installation; they are not Interaction state.
struct CounterControl {
    var runtimeEndpoint: CounterEndpoint?
    var runtimeRootIdentity: SemanticCompleteIdentity?
    var runtimeActionIdentity: SemanticCompleteIdentity?
    var runtimeCandidateRootIdentity: SemanticCompleteIdentity?
    var runtimeCandidateActionIdentity: SemanticCompleteIdentity?
    private(set) var runtimeSlotPhase: CounterRuntimeSlotPhase = .vacant
    private(set) var runtimeSlotOwner: UInt64?
    private(set) var runtimeLastOwnerSerial: UInt64 = 0
    mutating func claimRuntimeSlot() -> UInt64 {
        guard let claim = tryClaimRuntimeSlot() else { preconditionFailure("duplicate/overflow runtime claim") }
        return claim
    }
    mutating func tryClaimRuntimeSlot() -> UInt64? {
        guard runtimeSlotPhase == .vacant && runtimeSlotOwner == nil && runtimeEndpoint == nil,
            runtimeRootIdentity == nil && runtimeActionIdentity == nil && runtimeCandidateRootIdentity == nil && runtimeCandidateActionIdentity == nil else { return nil }
        let next = runtimeLastOwnerSerial.addingReportingOverflow(1)
        guard !next.overflow else { return nil }
        runtimeLastOwnerSerial = next.partialValue
        runtimeSlotOwner = next.partialValue; runtimeSlotPhase = .installing
        return next.partialValue
    }
    private static func requireVacantFacts(phaseVacant: Bool, ownerAbsent: Bool,
        endpointAbsent: Bool, rootAbsent: Bool, actionAbsent: Bool,
        candidateRootAbsent: Bool, candidateActionAbsent: Bool) {
        let vacant = phaseVacant && ownerAbsent && endpointAbsent
        let noKeys = rootAbsent && actionAbsent && candidateRootAbsent && candidateActionAbsent
        precondition(vacant && noKeys)
    }
    private static func requireClaimFacts(sameOwner: Bool, installed: Bool, quiesced: Bool,
        endpointPresent: Bool) {
        let matches = sameOwner && (installed || quiesced) && endpointPresent
        precondition(matches)
    }
    borrowing func requireVacantRuntimeSlot() {
        let phaseVacant = runtimeSlotPhase == .vacant
        let ownerAbsent = runtimeSlotOwner == nil
        let endpointAbsent = runtimeEndpoint == nil
        let rootAbsent = runtimeRootIdentity == nil
        let actionAbsent = runtimeActionIdentity == nil
        let candidateRootAbsent = runtimeCandidateRootIdentity == nil
        let candidateActionAbsent = runtimeCandidateActionIdentity == nil
        Self.requireVacantFacts(phaseVacant: phaseVacant, ownerAbsent: ownerAbsent,
            endpointAbsent: endpointAbsent, rootAbsent: rootAbsent, actionAbsent: actionAbsent,
            candidateRootAbsent: candidateRootAbsent, candidateActionAbsent: candidateActionAbsent)
    }
    static func requireVacantRuntimeSlot(at control: UnsafeMutablePointer<CounterControl>) {
        let phaseVacant = control.pointee.runtimeSlotPhase == .vacant
        let ownerAbsent = control.pointee.runtimeSlotOwner == nil
        let endpointAbsent = control.pointee.runtimeEndpoint == nil
        let rootAbsent = control.pointee.runtimeRootIdentity == nil
        let actionAbsent = control.pointee.runtimeActionIdentity == nil
        let candidateRootAbsent = control.pointee.runtimeCandidateRootIdentity == nil
        let candidateActionAbsent = control.pointee.runtimeCandidateActionIdentity == nil
        Self.requireVacantFacts(phaseVacant: phaseVacant, ownerAbsent: ownerAbsent,
            endpointAbsent: endpointAbsent, rootAbsent: rootAbsent, actionAbsent: actionAbsent,
            candidateRootAbsent: candidateRootAbsent, candidateActionAbsent: candidateActionAbsent)
    }
    borrowing func requireRuntimeClaim(_ claim: UInt64) {
        let sameOwner = runtimeSlotOwner == claim
        let installed = runtimeSlotPhase == .installed
        let quiesced = runtimeSlotPhase == .quiesced
        let endpointPresent = runtimeEndpoint != nil
        Self.requireClaimFacts(sameOwner: sameOwner, installed: installed, quiesced: quiesced,
            endpointPresent: endpointPresent)
    }
    static func requireRuntimeClaim(at control: UnsafeMutablePointer<CounterControl>, _ claim: UInt64) {
        let sameOwner = control.pointee.runtimeSlotOwner == claim
        let installed = control.pointee.runtimeSlotPhase == .installed
        let quiesced = control.pointee.runtimeSlotPhase == .quiesced
        let endpointPresent = control.pointee.runtimeEndpoint != nil
        Self.requireClaimFacts(sameOwner: sameOwner, installed: installed, quiesced: quiesced,
            endpointPresent: endpointPresent)
    }
    mutating func completeRuntimeInstallation(_ claim: UInt64) {
        precondition(runtimeSlotOwner == claim && runtimeSlotPhase == .installing && runtimeEndpoint != nil)
        precondition(runtimeRootIdentity == nil && runtimeActionIdentity == nil && runtimeCandidateRootIdentity == nil && runtimeCandidateActionIdentity == nil)
        runtimeSlotPhase = .installed
    }
    mutating func markRuntimeQuiesced(_ claim: UInt64) {
        Self.requireClaimFacts(sameOwner: runtimeSlotOwner == claim,
            installed: runtimeSlotPhase == .installed, quiesced: runtimeSlotPhase == .quiesced,
            endpointPresent: runtimeEndpoint != nil)
        precondition(!backend.active)
        runtimeSlotPhase = .quiesced
    }
    mutating func clearRuntimeSlot(_ claim: UInt64) {
        let cleared = tryClearRuntimeSlot(claim)
        precondition(cleared)
    }
    mutating func tryClearRuntimeSlot(_ claim: UInt64) -> Bool {
        guard runtimeSlotOwner == claim && runtimeSlotPhase == .quiesced,
              runtimeEndpoint != nil && !backend.active else { return false }
        let idle = runtimeEndpoint!.actual.sink.isIdleForOffer
        guard idle else { return false }
        // Offers are synchronous and resolved before quiescence. These owned
        // fields have no destructor callback and no scope-bearing capability.
        runtimeEndpoint = nil
        runtimeRootIdentity = nil; runtimeActionIdentity = nil
        runtimeCandidateRootIdentity = nil; runtimeCandidateActionIdentity = nil
        runtimeSlotOwner = nil; runtimeSlotPhase = .vacant
        Self.requireVacantFacts(phaseVacant: runtimeSlotPhase == .vacant, ownerAbsent: runtimeSlotOwner == nil,
            endpointAbsent: runtimeEndpoint == nil, rootAbsent: runtimeRootIdentity == nil,
            actionAbsent: runtimeActionIdentity == nil, candidateRootAbsent: runtimeCandidateRootIdentity == nil,
            candidateActionAbsent: runtimeCandidateActionIdentity == nil)
        return true
    }
    private var producerOrigin: CounterProducerOrigin?
    private var selectedProducer = false
    mutating func installProducerOrigin(owner: UInt, serial: UInt64) {
        precondition(!selectedProducer && producerOrigin == nil && admissionController == nil)
        selectedProducer = true; producerOrigin = .init(owner: owner, serial: serial)
    }
    func snapshotProducerOrigin() -> CounterProducerOrigin? { producerOrigin }
    func acceptsProducer(_ origin: CounterProducerOrigin?) -> Bool {
        selectedProducer ? origin != nil && origin == producerOrigin : origin == nil
    }
    static func snapshotProducerOrigin(at control: UnsafeMutablePointer<CounterControl>) -> CounterProducerOrigin? {
        control.pointee.producerOrigin
    }
    static func acceptsProducer(at control: UnsafeMutablePointer<CounterControl>, _ origin: CounterProducerOrigin?) -> Bool {
        if control.pointee.selectedProducer {
            guard origin != nil else { return false }
            return origin == control.pointee.producerOrigin
        }
        return origin == nil
    }
    mutating func retireProducerOrigin() {
        precondition(!inputGate.inputIsEligible && !wakeEnabled && !frameActive && admission.pointerCount == 0 && admission.pendingStateCount == 0 && !admission.sealActive)
        producerOrigin = nil
    }

    #if hasFeature(Embedded) || GIFTUI_COUNTER_TILED
    var backend = CounterTiledBackendStorage()
    #else
    var backend = CounterNativeBackendStorage()
    #endif
    private(set) var lastSealedAction: CapturedAction<SemanticCompleteIdentity>?
    private(set) var lastDispatchedAction: CapturedAction<SemanticCompleteIdentity>?
    private(set) var lastDispatchContext: ExecutionContext?
    private(set) var actionDispatches = 0
    mutating func observeSealedAction(_ action: CapturedAction<SemanticCompleteIdentity>?) { lastSealedAction = action }
    mutating func observeActionDispatch(_ action: CapturedAction<SemanticCompleteIdentity>, context: ExecutionContext) {
        precondition(context.phase == .mutating && lastSealedAction == action)
        let next = actionDispatches.addingReportingOverflow(1); precondition(!next.overflow)
        actionDispatches = next.partialValue; lastDispatchedAction = action; lastDispatchContext = context
    }
    var runtime = CounterRuntimeControl()
    // The coordinator and finite callback adapter share this single controller.
    var admissionController: CounterAdmission.Controller?
    var wake: ExecutionWakeAccumulator<CounterWake>?
    var scheduler: HostScheduledOpportunityController?
    var wakeClockMicroseconds: UInt64 = 0
    var wakeFirstFactMicroseconds: UInt64?
    var wakeEnabled = false
    var forwardedWakeRequestCount: UInt32 = 0
    var hostWakeRequests = 0
    var wakeTakes = 0
    var lastTakenWakeReasons: ExecutionWakeReasons = []
    var acceptedFactWakeRecords = 0
    var disabledWakeRejections = 0
    var injectCompletionAtApply = false
    var lateCallbackObservedActive = false
    var lateCallbackDidNotRunRuntime = false
    var inputGate = HostNormalizedInputGate(configuredSource: .init(rawValue: 0))
    var semanticSnapshot = CounterSemanticSnapshot()
    var lastFrame = CounterRenderSink()
    var actionPoints: InlineArray<2, Point> = .init(repeating: Point(x: 0, y: 0))
    var admission: CounterAdmissionBacking {
        get { runtime.admission }
        set { runtime.admission = newValue }
        _modify { yield &runtime.admission }
    }
    var result: RuntimeCompletePipelineResult<RuntimeOwnerFailure>? {
        get { runtime.result }
        set { runtime.result = newValue }
    }
    var context: ExecutionContext {
        get { runtime.context }
        set { runtime.context = newValue }
    }
    var unavailable: Bool {
        get { runtime.unavailable }
        set { runtime.unavailable = newValue }
    }
    var applicationConstructions = 0
    var applicationCallbacks = 0
    var observationsInstalled = 0
    var observationsDetached = 0
    var reentrantApplicationRejections = 0
    var stoppedApplicationChecks = 0
    var show = true
    var mutate: Bool {
        get { admission.pendingState != nil }
        set { admission.pendingState = newValue ? 1 : nil }
    }
    mutating func cancelPointerSequence(source: InputSourceID, sequence: PointerSequenceID) {
        // Already queued phases passed producer-order admission. Preserve that
        // trusted baseline when cancellation removes them before seal.
        for index in 0..<2 {
            guard let event = admission.pendingPointers[index], event.source == source, event.sequence == sequence else { continue }
            let outcome = runtime.pointer.sequence.validate(phase: event.phase, sequence: event.sequence, ordinal: event.ordinal, targetGateAllowsResynchronization: true)
            if outcome == .accepted || outcome == .consumedWhileCancelled { runtime.pointer.source = source }
        }
        runtime.pointer.cancel(source: source)
        for index in 0..<Int(admission.sealedPointerCount) {
            if let event = admission.sealedPointers[index], event.source == source && event.sequence == sequence {
                admission.sealedAction = nil
            }
        }
        admission.cancel(source: source, sequence: sequence)
    }
    var actionPoint = Point(x: 0, y: 0)
    var idleQuiesceMode: UInt8 = 0
    var teardowns = 0
    var terminalRetry = false
    var failAfterMutation = false
    var cleanupOrder: InlineArray<9, UInt8> = .init(repeating: 255)
    var cleanupCount = 0
    var boundaryFailure: RunCycleFailure<RuntimeOwnerFailure> = .execution(.capacityExhausted)
    var fault: RuntimeCompletePipelineStage?
    var offer: FrameOfferDisposition = .accepted
    var stages: UInt16 = 0
    var cleanups: UInt16 = 0
    var finalized = 0
    var applied = 0
    var streams = 0
    var commits = 0
    var committedRecords: UInt16 = 0
    var hasRoot = false
    var frameActive = false
}
struct CounterPipelineOwner<Geometry, Candidate, Committed, Hits>: ~Copyable, ~Escapable, RuntimeCompletePipelineOwner
where Geometry: CounterGeometry & ~Copyable & ~Escapable, Candidate: CounterCandidateBacking & ~Copyable & ~Escapable, Committed: CounterCommittedBacking & ~Copyable & ~Escapable, Hits: CounterHitBacking & ~Copyable & ~Escapable, Candidate.Identity == SemanticCompleteIdentity, Committed.Identity == SemanticCompleteIdentity, Hits.Identity == SemanticCompleteIdentity {
    typealias OwnerFailure = RuntimeOwnerFailure
    let models: ObservableModelScope<CounterOwnedModel, CounterModelSchema>
    let root: ObservableStateRootScope<CounterOwnedModel, SemanticCompleteIdentity>
    let semantic: SemanticRecordStore<CounterPayload>
    let values: CanvasStagedValues<SemanticRecordReference, CounterValueTable>
    let control: UnsafeMutablePointer<CounterControl>
    private var geometry: Geometry
    private var interaction: InteractionOwnedKeyState<Candidate, Committed, Hits>
    var phase = ExecutionPhaseMachine()
    var counters = RunCycleIDAllocator()
    let limits: RuntimeProfileLimits
    var revisions = SemanticRevisionAllocator()
    var candidates = CandidateFrameIDAllocator()
    var presentations = PresentationRevisionAllocator()
    var generations = RuntimeActionGenerationAllocator<SemanticCompleteIdentity>()
    var completedContext = ExecutionContext(cycle: nil, semanticRevision: nil, candidateFrame: nil, phase: .idle)
    var committedPresentation: PresentationRevision?
    var sealedAdmission: AdmissionSummary?
    var recovery = PresentationPendingState(maximumRetryableRefusals: 3)!
    private let runtimeClaim: UInt64
    var frameActive = false
    var observableCandidate = false
    var semanticCandidate = false
    var interactionCandidate = false
    var rootIdentity: SemanticCompleteIdentity? {
        get { CounterControl.requireRuntimeClaim(at: control, runtimeClaim); return control.pointee.runtimeRootIdentity }
        nonmutating set { CounterControl.requireRuntimeClaim(at: control, runtimeClaim); control.pointee.runtimeRootIdentity = newValue }
    }
    var actionIdentity: SemanticCompleteIdentity? {
        get { CounterControl.requireRuntimeClaim(at: control, runtimeClaim); return control.pointee.runtimeActionIdentity }
        nonmutating set { CounterControl.requireRuntimeClaim(at: control, runtimeClaim); control.pointee.runtimeActionIdentity = newValue }
    }
    var candidateRootIdentity: SemanticCompleteIdentity? {
        get { CounterControl.requireRuntimeClaim(at: control, runtimeClaim); return control.pointee.runtimeCandidateRootIdentity }
        nonmutating set { CounterControl.requireRuntimeClaim(at: control, runtimeClaim); control.pointee.runtimeCandidateRootIdentity = newValue }
    }
    var candidateActionIdentity: SemanticCompleteIdentity? {
        get { CounterControl.requireRuntimeClaim(at: control, runtimeClaim); return control.pointee.runtimeCandidateActionIdentity }
        nonmutating set { CounterControl.requireRuntimeClaim(at: control, runtimeClaim); control.pointee.runtimeCandidateActionIdentity = newValue }
    }
    var header: RenderPlanHeader?
    var provenance: FrameProvenance?
    var presentation: PresentationRevision?
    var changed: Bool {
        get { control.pointee.runtime.changed }
        set { control.pointee.runtime.changed = newValue }
    }
    var pending = false
    var presentationIntentState: PresentationIntentState { quiescent || control.pointee.unavailable ? .unavailable : pending ? .pending : .satisfied }
    var hasAllocatedCandidateFrame: Bool { phase.context.candidateFrame != nil }
    var quiescent = false
    var presentationTeardownComplete = false
    @_lifetime(copy models, copy root, copy semantic, copy values, borrow control, copy geometry, copy interaction)
    init(models: consuming ObservableModelScope<CounterOwnedModel, CounterModelSchema>, root: consuming ObservableStateRootScope<CounterOwnedModel, SemanticCompleteIdentity>, semantic: consuming SemanticRecordStore<CounterPayload>, values: consuming CanvasStagedValues<SemanticRecordReference, CounterValueTable>, geometry: consuming Geometry, interaction: consuming InteractionOwnedKeyState<Candidate, Committed, Hits>, control: borrowing UnsafeMutablePointer<CounterControl>, limits: RuntimeProfileLimits, endpointConfiguration: HostEndpointConfiguration) {
        let sameOwner = root.belongs(to: models)
        precondition(sameOwner)
        self.models = consume models; self.root = consume root; self.semantic = consume semantic; self.values = consume values
        self.limits = limits
        let claim = control.pointee.claimRuntimeSlot()
        control.pointee.initializeCounterWake()
        let constructedEndpoint = CounterEndpoint(configuration: endpointConfiguration, control: control)
        control.pointee.runtimeEndpoint = constructedEndpoint
        control.pointee.completeRuntimeInstallation(claim)
        runtimeClaim = claim
        self.geometry = consume geometry; self.interaction = consume interaction; self.control = copy control
        precondition(self.root.belongs(to: self.models))
    }
    // Consuming the complete scoped owner ends its borrows while forwarding the
    // two escapable owned workspace values. No original owner survives the call.


    @_lifetime(copy self)
    consuming func retireQuiescedStorage() -> CounterRetiredStorage<Geometry, Candidate, Committed, Hits> {
        precondition(quiescent && presentationTeardownComplete && !frameActive && !observableCandidate && !semanticCandidate && !interactionCandidate)
        precondition(control.pointee.unavailable && control.pointee.admission.pendingStateCount == 0 && !control.pointee.admission.sealActive)
        clearOwnedRuntimeSlot()
        return CounterRetiredStorage(semantic: semantic, geometry: geometry, interaction: interaction)
    }
    mutating func runTracedPipeline() -> RuntimeCompletePipelineResult<RuntimeOwnerFailure> {
        let result = RuntimeCompletePipeline.run(owner: &self)
        counterTrace("result", result)
        return result
    }
    mutating func terminatePresentation() {
        guard !presentationTeardownComplete else { return }
        // Called only after the synchronous attempt finalized and released reads.
        precondition(!frameActive && !observableCandidate && !semanticCandidate && !interactionCandidate)
        presentationTeardownComplete = true
        control.pointee.teardowns += 1
        control.pointee.unavailable = true
        control.pointee.inputGate.quiesce()
        quiescent = true; pending = false
        control.pointee.admission.resetAll()
        control.pointee.runtime.pointer.capture.cancel()
        control.pointee.runtime.pointer.sequence.cancelCurrentSequence()
        control.pointee.runtime.pointer.source = nil
        if let retained = recovery.pendingIntent { recovery.clearPending(for: retained.semanticRevision) }
        control.pointee.disableCounterWake()
        interaction.resetAllStorage()
        control.pointee.committedRecords = 0
        do throws(ObservableStateError) { try root.shutdown() }
        catch { models.requireStop() }
        rootIdentity = nil; actionIdentity = nil
        let idle = control.pointee.runtimeEndpoint!.isIdleForRuntimeRelease
        precondition(idle)
        control.pointee.markRuntimeQuiesced(runtimeClaim)
        control.pointee.hasRoot = false
        counterTrace("terminal", (interaction.committedRecordCount, values.count, models.phase))
    }
    mutating func boundary(_ stage: RuntimeCompletePipelineStage) -> RunCycleFailure<RuntimeOwnerFailure>? {
        control.pointee.context = phase.context
        counterTrace("stage", stage)
        control.pointee.stages |= UInt16(1) << stage.rawValue
        if stage == .applyAdmittedWork && control.pointee.injectCompletionAtApply {
            control.pointee.injectCompletionAtApply = false
            let finalized = control.pointee.finalized
            var producer = CounterAdmission(borrowing: control)
            precondition(producer.submit(completion: 0).result == .queued)
            control.pointee.lateCallbackObservedActive = phase.context.phase == .mutating
            control.pointee.lateCallbackDidNotRunRuntime = control.pointee.finalized == finalized
        }
        if control.pointee.unavailable { return .execution(.requiredFacilityUnavailable) }
        if control.pointee.fault == stage { return control.pointee.boundaryFailure }
        return nil
    }
    borrowing func observeModelValue() -> UInt8 {
        guard let rootIdentity, let key = root.modelKey(identity: rootIdentity, ordinal: 0) else { preconditionFailure("reuse current model") }
        do throws(ObservableStateError) {
            try models.beginFrame(); try models.pin(key)
            var value: UInt8 = 0
            do throws(_GiftUIAccessFailure) {
                value = try models.withRead(CounterDomain.self) { (read) throws(_GiftUIAccessFailure) in
                    try CounterRead<CounterDomain>(key, read: read).value
                }
            } catch { throw ObservableStateError(accessFailure: error) }
            try models.endFrame()
            return value
        } catch { preconditionFailure("reuse actual model observation") }
    }
    borrowing func observeProducedAction() -> CounterProducedAction {
        guard let origin = CounterControl.snapshotProducerOrigin(at: control), let rootIdentity,
              let targetGeneration = root.generation(identity: rootIdentity, ordinal: 0, publishable: false) else { preconditionFailure("selected capture observation") }
        var capture = PointerActionCapture<SemanticCompleteIdentity>()
        let point = control.pointee.actionPoints[0]
        _ = ExecutionGestureAdapter.down(at: point, capture: &capture, resolver: interaction)
        guard case .activationAdmitted(let captured) = ExecutionGestureAdapter.up(at: point, capture: &capture, resolver: interaction) else { preconditionFailure("actual selected capture") }
        return .init(origin: origin, captured: captured, targetGeneration: targetGeneration, targetIdentity: rootIdentity)
    }
    // The original owned capture enters the existing pointer capture/seal path.
    // No target capability, dispatch callback or second pending owner is retained.
    borrowing func prepareProducedAction(_ produced: CounterProducedAction) -> Bool {
        guard CounterControl.acceptsProducer(at: control, produced.origin) else { return false }
        guard !control.pointee.unavailable && control.pointee.context.phase == .idle else { return false }
        var admission = CounterAdmission(borrowing: control)
        let result = control.pointee.inputGate.submit(phase: .down, position: control.pointee.actionPoints[0], source: .init(rawValue: 0), observedPresentationRevision: control.pointee.runtime.committedPresentation, isMalformed: false, priorPhysicalSequenceIsComplete: true, to: &admission)
        guard case .queued = result else { return false }
        return true
    }
    borrowing func deliverProducedAction(_ produced: CounterProducedAction) -> Bool {
        guard CounterControl.acceptsProducer(at: control, produced.origin) else { return false }
        guard !control.pointee.unavailable && control.pointee.context.phase == .idle,
              control.pointee.runtime.pointer.capture.current == produced.captured else { return false }
        // Use the retained original value itself after the real down established
        // this sequence. The actual up resolver, seal and mutation revalidate it.
        control.pointee.runtime.pointer.capture.replace(with: produced.captured)
        var admission = CounterAdmission(borrowing: control)
        let result = control.pointee.inputGate.submit(phase: .up, position: control.pointee.actionPoints[0], source: .init(rawValue: 0), observedPresentationRevision: control.pointee.runtime.committedPresentation, isMalformed: false, priorPhysicalSequenceIsComplete: false, to: &admission)
        guard case .queued = result else { return false }
        return true
    }
    mutating func admitAndSeal() -> RuntimePipelineStepResult<RuntimeOwnerFailure> {

        control.pointee.cleanups = 0; control.pointee.cleanupCount = 0
        guard !quiescent else { return .failure(.execution(.requiredFacilityUnavailable)) }
        if let error = phase.beginCycle(reservingFrom: &counters) { return .failure(.execution(error)) }
        if let error = boundary(.admissionAndSeal) { return .failure(error) }
        sealedAdmission = nil
        var transaction = ExecutionAdmissionSealTransaction(limits: limits.execution)!
        precondition(transaction.begin())
        var staged = control.pointee.runtime.pointer
        var activation: CapturedAction<SemanticCompleteIdentity>?
        var selected: UInt16 = 0
        for index in 0..<2 where selected < limits.execution.maximumInputEvents {
            guard let pointer = control.pointee.admission.pendingPointers[index] else { continue }
            let validRevision = pointer.presentationRevision == interaction.committedRevision
            let validSource = staged.source == nil || staged.source == pointer.source
            let validation = staged.sequence.validate(phase: pointer.phase, sequence: pointer.sequence, ordinal: pointer.ordinal, targetGateAllowsResynchronization: true)
            let valid = validRevision && validSource && (validation == .accepted || validation == .consumedWhileCancelled)
            var createsActivation = false
            if valid && validation == .accepted {
                staged.source = pointer.source
                let gesture: PointerGestureOutcome<SemanticCompleteIdentity>
                switch pointer.phase {
                case .down: gesture = ExecutionGestureAdapter.down(at: pointer.position, capture: &staged.capture, resolver: interaction)
                case .move: gesture = ExecutionGestureAdapter.move(at: pointer.position, capture: &staged.capture, resolver: interaction)
                case .up: gesture = ExecutionGestureAdapter.up(at: pointer.position, capture: &staged.capture, resolver: interaction)
                }
                if case .activationAdmitted(let captured) = gesture { activation = captured; createsActivation = true }
                counterTrace("gesture", gesture)
            }
            guard transaction.stagePointer(pointer, provenanceValid: valid, createsActivation: createsActivation, transitionReservationAvailable: true) else { break }
            selected += 1
        }
        switch transaction.finish(pendingStateChangeFacts: control.pointee.admission.pendingStateCount, pendingCompletionFacts: control.pointee.admission.pendingCompletion == nil ? 0 : 1, includesDirtyRederivation: changed, includesPresentationRecovery: pending, batchReservationAvailable: true) {
        case .failure(let failure):
            if let cancelled = failure.cancelledSequence {
                control.pointee.cancelPointerSequence(source: cancelled.source, sequence: cancelled.sequence)
            }
            sealedAdmission = failure.summary
            return .failure(.execution(failure.failure == .invalidProvenance ? .invalidProvenance : .capacityExhausted))
        case .success(let selection):
            guard control.pointee.admission.seal(selection.summary) else { return .failure(.execution(.invariantViolation)) }
            control.pointee.runtime.pointer = staged
            control.pointee.admission.sealedAction = activation
            control.pointee.observeSealedAction(activation)
            sealedAdmission = selection.summary
        }
        return .advanced
    }
    mutating func applyAdmittedWork() -> RuntimePipelineMutationResult<RuntimeOwnerFailure> {
        if let error = phase.transition(to: .mutating) { return .failure(.execution(error), mutationApplied: false) }
        if let error = boundary(.applyAdmittedWork) { return .failure(error, mutationApplied: false) }
        var applied = false
        while let value = control.pointee.admission.takeState() {
            guard let rootIdentity, let key = root.modelKey(identity: rootIdentity, ordinal: 0) else { return .failure(.execution(.invalidProvenance), mutationApplied: applied) }
            switch root.mutate(key, mutation: .fact(value)) {
            case .success(.unchanged): break
            case .success: applied = true; changed = true; control.pointee.applied += 1
            case .failure(let error): return .failure(.focusedOwner(.observableState(error)), mutationApplied: applied)
            }
        }
        control.pointee.admission.sealedCompletion = nil
        if let captured = control.pointee.admission.sealedAction.take() {
            switch dispatch(captured) {
            case .applied(let changed): applied = applied || changed
            case .failure(let failure, let changed): return .failure(failure, mutationApplied: applied || changed)
            }
        }
        return .applied(applied)
    }
    mutating func dispatch(_ captured: CapturedAction<SemanticCompleteIdentity>) -> RuntimePipelineMutationResult<RuntimeOwnerFailure> {
        precondition(phase.context.phase == .mutating)
        guard let rootIdentity else { return .applied(false) }
        let target = ObservableStateRootTargetAccess(root: root, identity: rootIdentity, ordinal: 0)
        let result = RuntimeRecordInteractionBridge.dispatch(captured, records: interaction, target: target, actionType: CounterAction.self, operation: CounterHandler.operation)
        counterTrace("dispatch", result)
        switch result {
        case .interaction(.dispatched):
            control.pointee.observeActionDispatch(captured, context: phase.context)
            control.pointee.applied += 1; changed = true
            if control.pointee.failAfterMutation { return .failure(.execution(.capacityExhausted), mutationApplied: true) }
            return .applied(true)
        case .interaction(.cancelled): return .applied(false)
        case .observableFailure(let error): return .failure(.focusedOwner(.observableState(error)), mutationApplied: false)
        case .interaction(.failure(let error)): return .failure(.focusedOwner(.interaction(error)), mutationApplied: false)
        }
    }
    mutating func freezeObservableMutation() -> RuntimePipelineStepResult<RuntimeOwnerFailure> {
        if let error = boundary(.freezeObservableMutation) { return .failure(error) }
        do throws(ObservableStateError) { try models.beginFrame(); frameActive = true }
        catch { return .failure(.focusedOwner(.observableState(error))) }
        if let error = phase.transition(to: .deriving) { return .failure(.execution(error)) }
        control.pointee.context = phase.context
        return .advanced
    }
    mutating func beginObservableCandidateAndExpandSemantics() -> RuntimePipelineStepResult<RuntimeOwnerFailure> {
        if let error = boundary(.observableCandidateAndSemanticExpansion) { return .failure(error) }
        do throws(ObservableStateError) {
            try models.withDiscovery { () throws(ObservableStateError) in
                if case .failure(let error) = root.beginCandidate() { throw error }
            }
            observableCandidate = true
        } catch { return .failure(.focusedOwner(.observableState(error))) }
        let result = semantic.expand(CounterScreen<CounterDomain>(), roles: CounterRoles.self, codec: CanvasSemanticPayloadCodec<CounterRoles, CounterValueTable>.self, limits: limits.semantic, binding: ObservableSemanticBodyBinding(models: models.borrowedScope(), root: root.borrowedRoot(), domain: CounterDomain.self))
        switch result {
        case .success: semanticCandidate = true
        case .semanticFailure(let error): discardLocalCandidates(); return .failure(.focusedOwner(.semantic(error)))
        case .bindingFailure(let error): discardLocalCandidates(); return .failure(.focusedOwner(.observableState(error)))
        case .accessFailure: discardLocalCandidates(); return .failure(.focusedOwner(.observableState(.staleModel)))
        }
        do throws(DrawingError) { try CanvasSemanticTransfer.stage(from: semantic, into: values, table: CounterValueTable()) }
        catch {
            discardLocalCandidates()
            let production: DrawingProductionError = switch error {
            case .invalidModelAccess: .invalidModelAccess
            case .invalidValue: .invalidValue
            case .invalidPathState: .invalidPathState
            case .arithmeticOverflow: .arithmeticOverflow
            case .capacityExhausted: .capacityExhausted
            case .invalidScope: .invalidScope
            case .invalidPhase: .invalidPhase
            case .reentrancyViolation: .reentrancyViolation
            case .invariantViolation: .invariantViolation
            }
            return .failure(.focusedOwner(.drawing(production)))
        }
        return .advanced
    }
    mutating func resolveLayout() -> RuntimePipelineStepResult<RuntimeOwnerFailure> {
        if let error = boundary(.layout) { return .failure(error) }
        do throws(SemanticExpansionError) {
            return try semantic.withCandidateView { bank in
                control.pointee.semanticSnapshot = CounterSemanticSnapshot(bank)
                switch geometry.layout(bank, limits: limits) { case .success: return .advanced; case .failure(let error): return .failure(.focusedOwner(.layout(error))) }
            }
        } catch { return .failure(.focusedOwner(.semantic(error))) }
    }
    mutating func invokeCanvasesAndDerivePlan() -> RuntimePipelineStepResult<RuntimeOwnerFailure> {
        if let error = boundary(.canvasInvocationAndPlan) { return .failure(error) }
        var source = CounterSource(models: models.borrowedScope(), values: values.borrowedValues(), table: CounterValueTable())
        switch geometry.draw(source: &source, context: phase.context, limits: limits) { case .success: return .advanced; case .failure(let error): return .failure(.focusedOwner(.drawing(error))) }
    }
    mutating func preflightCombinedRender() -> RuntimePipelineStepResult<RuntimeOwnerFailure> {
        if let error = boundary(.combinedRenderPreflight) { return .failure(error) }
        do throws(SemanticExpansionError) {
            return try semantic.withCandidateView { bank in
                switch geometry.preflight(bank, limits: limits) { case .success(let value): header = value; return .advanced; case .failure(let error): return .failure(.renderProduction(error)) }
            }
        } catch { return .failure(.focusedOwner(.semantic(error))) }
    }
    mutating func buildInteractionCandidate() -> RuntimePipelineStepResult<RuntimeOwnerFailure> {
        if let error = boundary(.interactionCandidate) { return .failure(error) }
        if let error = interaction.beginCandidate(limits: limits.interaction) { return .failure(.focusedOwner(.interaction(error))) }
        interactionCandidate = true
        candidateRootIdentity = nil; candidateActionIdentity = nil
        do throws(SemanticExpansionError) {
            return try semantic.withCandidateView { bank in
                var target: SemanticCompleteIdentity?
                var paintOrder: UInt16 = 0
                for index: UInt16 in 0..<bank.recordCount {
                    var identity = bank.completeIdentity(for: bank.reference(at: index)!)!
                    guard identity.append(.init(kind: .customBody)) else { return .failure(.execution(.invariantViolation)) }
                    if root.generation(identity: identity, ordinal: 0, publishable: true) != nil { target = identity; break }
                }
                for index: UInt16 in 0..<bank.recordCount {
                    let ref = bank.reference(at: index)!
                    guard bank.record(ref)?.kind == .action else { continue }
                    guard let target, let bounds = geometry.bounds(ref), let clip = geometry.clip(ref) else { return .failure(.execution(.invariantViolation)) }
                    let identity = bank.completeIdentity(for: ref)!
                    switch RuntimeRecordInteractionBridge.append(record: ref, semantic: bank, root: root, rootIdentity: target, rootOrdinal: 0, actionType: CounterAction.self, roles: CounterRoles.self, isEnabled: counterActionIsEnabled(ref, bank: bank), bounds: bounds, clip: clip, paintOrder: paintOrder, interaction: &interaction) {
                    case .failure(let error): return .failure(.focusedOwner(.interaction(error)))
                    case .requiresGeneration:
                        guard let generation = generations.generation(for: identity), interaction.assignGeneration(generation, to: identity) == nil else { return .failure(.execution(.identityExhausted)) }
                    case .preserved: break
                    }
                    paintOrder += 1
                    candidateActionIdentity = identity
                    control.pointee.actionPoint = bounds.origin
                    let code = counterActionCode(ref, bank: bank)
                    precondition(code < 2)
                    control.pointee.actionPoints[Int(code)] = bounds.origin
                }
                candidateRootIdentity = target
                if let error = interaction.finishCandidate() { return .failure(.focusedOwner(.interaction(error))) }
                return .advanced
            }
        } catch { return .failure(.focusedOwner(.semantic(error))) }
    }
    mutating func publishSemanticAndObservableCandidate() -> RuntimePipelinePublicationResult<RuntimeOwnerFailure> {
        if let error = boundary(.semanticAndObservablePublication) { return .failure(error) }
        let revision: SemanticRevision
        if changed || phase.context.semanticRevision == nil { guard let next = revisions.reserve() else { return .failure(.execution(.identityExhausted)) }; revision = next }
        else { revision = phase.context.semanticRevision! }
        if let error = phase.transition(to: .publishing) { return .failure(.execution(error)) }
        do throws(ObservableStateError) {
            try models.withDiscovery { () throws(ObservableStateError) in
                if case .failure(let error) = root.finishCandidate(.publish) { throw error }
            }
            observableCandidate = false
        } catch { quiescent = true; return .failure(.focusedOwner(.observableState(error))) }
        do throws(SemanticExpansionError) { try semantic.publishCandidate(); semanticCandidate = false }
        catch { quiescent = true; return .failure(.focusedOwner(.semantic(error))) }
        rootIdentity = candidateRootIdentity
        if let error = phase.recordPublishedSemanticRevision(revision) { return .failure(.execution(error)) }
        control.pointee.context = phase.context
        return .published(.init(semanticRevision: revision, changed: changed))
    }
    mutating func allocateCandidate() -> RuntimePipelineStepResult<RuntimeOwnerFailure> {
        if let error = boundary(.candidateAllocation) { return .failure(error) }
        guard let candidate = candidates.reserve(), let counter = phase.context.cycle, let revision = phase.context.semanticRevision else { return .failure(.execution(.identityExhausted)) }
        if let error = phase.recordCandidateFrame(candidate) { return .failure(.execution(error)) }
        guard let presentation = presentations.reserve() else { return .failure(.execution(.identityExhausted)) }
        self.presentation = presentation; provenance = .init(cycle: counter, semanticRevision: revision, candidateFrame: candidate)
        return .advanced
    }
    mutating func offerAndProduce() -> RuntimePipelineOfferResult<RuntimeOwnerFailure> {
        if let error = boundary(.offerAndProduction) { return .failure(error) }
        if let error = phase.transition(to: .offering) { return .failure(.execution(error)) }
        control.pointee.context = phase.context
        CounterControl.requireRuntimeClaim(at: control, runtimeClaim)
        let productionSemantic = semantic.borrowedStore()
        let productionHeader = header!, productionLimits = limits, productionProvenance = provenance!
        // Only these disjoint fields/formals are lent across the producer.
        // No whole pipeline/control value or mutator enters that callback.
        let produced = counterProduceStoredEndpoint(endpoint: &control.pointee.runtimeEndpoint!,
            streams: &control.pointee.streams, geometry: &geometry, semantic: productionSemantic,
            header: productionHeader, limits: productionLimits, provenance: productionProvenance)
        let offer = produced.endpoint.result
        control.pointee.backend.envelopeRejections += produced.endpoint.invalidEnvelopeRejections
        control.pointee.backend.endpointHealthObservation = produced.endpoint.health
        precondition(produced.endpoint.health == control.pointee.backend.health)
        if let recording = produced.endpoint.acceptedRecording { control.pointee.lastFrame = recording }
        if let retained = produced.error { return .failure(.renderProduction(retained)) }
        switch offer.disposition {
        case .accepted: return .accepted(presentation!)
        case .backpressured: return .backpressured
        case .retryableRefusal: return .retryableRefusal
        case .nonRetryableRefusal: return .nonRetryableRefusal(.endpoint)
        case .failed: return .failure(.frameOffer(offer.failure!))
        }
    }
    mutating func discardLocalCandidates() {
        values.discard()
        if semanticCandidate { do throws(SemanticExpansionError) { try semantic.discardCandidate() } catch { quiescent = true }; semanticCandidate = false }
        if observableCandidate {
            do throws(ObservableStateError) { try models.withDiscovery { () throws(ObservableStateError) in
                if case .failure(let error) = root.finishCandidate(.discard) { throw error }
            } } catch { quiescent = true }
            observableCandidate = false
        }
    }
    mutating func cleanup(_ action: RuntimeCleanupAction) {
        precondition(control.pointee.cleanupCount < 9)
        counterTrace("cleanup", action)
        control.pointee.cleanupOrder[control.pointee.cleanupCount] = action.rawValue
        control.pointee.cleanupCount += 1
        precondition(control.pointee.cleanups & (UInt16(1) << action.rawValue) == 0)
        control.pointee.cleanups |= UInt16(1) << action.rawValue
        switch action {
        case .releaseCanvasCallable: values.discard()
        case .resetRenderWorkspace: geometry.resetRender()
        case .resetDrawingPlan: geometry.resetPlan()
        case .resetLayoutCandidate: geometry.resetLayout()
        case .discardSemanticCandidate: if semanticCandidate { do throws(SemanticExpansionError) { try semantic.discardCandidate() } catch { quiescent = true }; semanticCandidate = false }
        case .discardObservableCandidate:
            if observableCandidate { discardLocalCandidates() }
        case .discardInteractionCandidate: interaction.resolveCandidate(.discard); generations.resolveCandidate(committed: false); interactionCandidate = false
        case .commitInteractionCandidate: interaction.resolveCandidate(.commit(presentation!)); generations.resolveCandidate(committed: true); interactionCandidate = false; control.pointee.commits += 1; actionIdentity = candidateActionIdentity; committedPresentation = presentation; control.pointee.runtime.committedPresentation = presentation; control.pointee.inputGate.installPhysicalPresentation(presentation!)
        case .resetAttemptStorage:
            discardLocalCandidates()
            if interactionCandidate { interaction.resolveCandidate(.discard); generations.resolveCandidate(committed: false); interactionCandidate = false }
            candidateRootIdentity = nil; candidateActionIdentity = nil
            geometry.reset()
            if frameActive { do throws(ObservableStateError) { try models.endFrame() } catch { quiescent = true }; frameActive = false }
        }
    }
    mutating func applyDisposition(_ disposition: RuntimePipelineDisposition) {
        counterTrace("disposition", disposition)
        changed = disposition.semanticDisposition == .dirty
        if changed { control.pointee.emitCounterWake(.semanticDirty) }
        pending = disposition.presentationIntentState == .pending
    }
    mutating func finalizePipeline() {
        control.pointee.admission.finishAttempt()
        completedContext = phase.context
        control.pointee.committedRecords = interaction.committedRecordCount
        control.pointee.hasRoot = rootIdentity != nil
        control.pointee.frameActive = frameActive
        if phase.context.phase != .idle {
            precondition(phase.transition(to: .finalizing) == nil)
            precondition(phase.transition(to: .idle) == nil)
        }
        control.pointee.context = phase.context
        counterTrace("finalized", (completedContext, control.pointee.applied, control.pointee.commits, interaction.committedRecordCount, values.count, models.phase))
        control.pointee.finalized += 1
        if quiescent { terminatePresentation() }
    }
}

// Enabled state comes from the actual traversed modifier chain, not a copied
// host value or precomputed action table.
private func counterActionIsEnabled(_ ref: SemanticRecordReference, bank: borrowing SemanticRecordView<CounterPayload>) -> Bool {
    var current = ref
    while let record = bank.record(current) {
        if let payload = bank.payload(at: record.payload), case .standard(.disabled(true)) = payload { return false }
        guard record.parent < current.ordinal, let parent = bank.reference(at: record.parent) else { break }
        current = parent
    }
    return true
}
func counterTrace<T>(_ label: StaticString, _ value: T) {
#if !hasFeature(Embedded)
print(label, value)
#endif
}

private func counterActionCode(_ ref: SemanticRecordReference, bank: borrowing SemanticRecordView<CounterPayload>) -> UInt16 {
    guard let record = bank.record(ref), let payload = bank.payload(at: record.payload), case .standard(.action(_, let code)) = payload else { preconditionFailure("counter action payload") }
    return code
}

extension CounterPipelineOwner
where Geometry: CounterGeometry & ~Copyable & ~Escapable, Candidate: CounterCandidateBacking & ~Copyable & ~Escapable, Committed: CounterCommittedBacking & ~Copyable & ~Escapable, Hits: CounterHitBacking & ~Copyable & ~Escapable, Candidate.Identity == SemanticCompleteIdentity, Committed.Identity == SemanticCompleteIdentity, Hits.Identity == SemanticCompleteIdentity {
    @_lifetime(copy models, copy root, copy semantic, copy values, copy scopedControl, copy geometry, copy interaction)
    init(
        models: consuming ObservableModelScope<CounterOwnedModel, CounterModelSchema>,
        root: consuming ObservableStateRootScope<CounterOwnedModel, SemanticCompleteIdentity>,
        semantic: consuming SemanticRecordStore<CounterPayload>,
        values: consuming CanvasStagedValues<SemanticRecordReference, CounterValueTable>,
        geometry: consuming Geometry,
        interaction: consuming InteractionOwnedKeyState<Candidate, Committed, Hits>,
        scopedControl: consuming CounterHostControl, limits: RuntimeProfileLimits, endpointConfiguration: HostEndpointConfiguration
    ) {
        let sameOwner = root.belongs(to: models)
        precondition(sameOwner)
        self.models = consume models
        self.root = consume root
        self.semantic = consume semantic
        self.values = consume values
        self.limits = limits
        let claim = scopedControl.pointer.pointee.claimRuntimeSlot()
        scopedControl.pointer.pointee.initializeCounterWake()
        let construction = CounterConstructionInputs.canonical
        let constructedEndpoint = CounterEndpoint(configuration: construction.endpointConfiguration.configuration(endpointConfiguration), control: construction.endpointBacking.control(scopedControl.pointer))
        scopedControl.pointer.pointee.runtimeEndpoint = constructedEndpoint
        scopedControl.pointer.pointee.completeRuntimeInstallation(claim)
        runtimeClaim = claim
        self.geometry = consume geometry
        self.interaction = consume interaction
        self.control = scopedControl.pointer
        precondition(self.root.belongs(to: self.models))
    }
}


// Extensions must repeat the scoped generic permissions: omitted constraints
// otherwise introduce implicit Copyable/Escapable specialization in Swift.
extension CounterPipelineOwner
where Geometry: CounterGeometry & ~Copyable & ~Escapable, Candidate: CounterCandidateBacking & ~Copyable & ~Escapable, Committed: CounterCommittedBacking & ~Copyable & ~Escapable, Hits: CounterHitBacking & ~Copyable & ~Escapable, Candidate.Identity == SemanticCompleteIdentity, Committed.Identity == SemanticCompleteIdentity, Hits.Identity == SemanticCompleteIdentity {
    private borrowing func clearOwnedRuntimeSlot() {
        CounterControl.requireRuntimeClaim(at: control, runtimeClaim)
        let idle = control.pointee.runtimeEndpoint!.isIdleForRuntimeRelease
        let inactive = !control.pointee.backend.active
        precondition(idle && inactive)
        control.pointee.clearRuntimeSlot(runtimeClaim)
    }
}

extension CounterPipelineOwner
where Geometry: Copyable & Escapable, Candidate: Copyable & Escapable, Committed: Copyable & Escapable, Hits: Copyable & Escapable {
    consuming func returnWorkspaces(checks: Int) -> CounterReturnedWorkspaces<Geometry, Candidate, Committed, Hits> {
        precondition(quiescent && presentationTeardownComplete)
        clearOwnedRuntimeSlot()
        return CounterReturnedWorkspaces(geometry: geometry, interaction: interaction, checks: checks)
    }
}

struct CounterRetiredStorage<Geometry, Candidate, Committed, Hits>: ~Copyable, ~Escapable
where Geometry: CounterGeometry & ~Copyable & ~Escapable, Candidate: CounterCandidateBacking & ~Copyable & ~Escapable, Committed: CounterCommittedBacking & ~Copyable & ~Escapable, Hits: CounterHitBacking & ~Copyable & ~Escapable, Candidate.Identity == SemanticCompleteIdentity, Committed.Identity == SemanticCompleteIdentity, Hits.Identity == SemanticCompleteIdentity {
    private let semantic: SemanticRecordStore<CounterPayload>
    private var geometry: Geometry
    private var interaction: InteractionOwnedKeyState<Candidate, Committed, Hits>
    @_lifetime(copy semantic, copy geometry, copy interaction)
    init(semantic: consuming SemanticRecordStore<CounterPayload>, geometry: consuming Geometry, interaction: consuming InteractionOwnedKeyState<Candidate, Committed, Hits>) {
        self.semantic = consume semantic; self.geometry = consume geometry; self.interaction = consume interaction
    }
    @_lifetime(self: copy self)
    mutating func resetAfterQuiescence() {
        do throws(SemanticExpansionError) { try semantic.resetAfterQuiescence() }
        catch { preconditionFailure("counter semantic reset") }
        geometry.reset(); interaction.resetAllStorage()
    }
}


struct CounterEndpointOfferObservation {
    let result: FrameOfferResult
    let invalidEnvelopeRejections: Int
    let health: GiftUIOperationalHealth
    let acceptedRecording: CounterRenderSink?
}
struct CounterProductionObservation {
    let endpoint: CounterEndpointOfferObservation
    let error: RenderProductionError?
}
// The callback borrows only these separate formal loans. The original semantic
// lender is retained by borrowedStore; no callback captures a pipeline/control.
private func counterProduceStoredEndpoint<G: CounterGeometry & ~Copyable & ~Escapable>(
    endpoint: inout CounterEndpoint, streams: inout Int, geometry: inout G,
    semantic: borrowing SemanticRecordStore<CounterPayload>, header: RenderPlanHeader,
    limits: RuntimeProfileLimits, provenance: FrameProvenance
) -> CounterProductionObservation {
    var retained: RenderProductionError?
    let observed = endpoint.offerAndObserve(provenance: provenance) { sink in
        streams += 1
        do throws(SemanticExpansionError) {
            return try semantic.withPublishedView { bank in
                switch geometry.produce(bank, header: header, sink: &sink, limits: limits) {
                case .success: return .complete
                case .failure(let error): retained = error; return RecordingRenderProductionAdapter.observe(error: error).streamResult!
                }
            }
        } catch { retained = .invariantViolation; return .contractViolation }
    }
    return .init(endpoint: observed, error: retained)
}


// Owned facts only: no endpoint, pointer, scoped value or callback is retained.
struct CounterRecordingObservation: Equatable {
    private var value: CounterRenderSink
    init() { value = CounterRenderSink() }
    init(_ value: borrowing CounterRenderSink) { self.value = copy value }
    mutating func capture(_ current: borrowing CounterRenderSink) { value = copy current }
    borrowing func matches(_ current: borrowing CounterRenderSink) -> Bool {
        let sameCapacity = value.capacity == current.capacity
        guard sameCapacity else { return false }
        let sameHeader = value.header == current.header
        guard sameHeader else { return false }
        let sameOperations = value.operations == current.operations
        guard sameOperations else { return false }
        let sameGlyphs = value.glyphs == current.glyphs
        guard sameGlyphs else { return false }
        let sameStrokes = value.strokes == current.strokes
        guard sameStrokes else { return false }
        let sameFinishes = value.finishes == current.finishes
        guard sameFinishes else { return false }
        let sameDiscards = value.discards == current.discards
        guard sameDiscards else { return false }
        let sameFirstPoint = value.firstPoint == current.firstPoint
        guard sameFirstPoint else { return false }
        let sameSecondPoint = value.secondPoint == current.secondPoint
        guard sameSecondPoint else { return false }
        let sameStrokeHeader = value.strokeHeader == current.strokeHeader
        guard sameStrokeHeader else { return false }
        for index in 0..<64 {
            let same = value.glyphRecords[index] == current.glyphRecords[index]
            guard same else { return false }
        }
        return true
    }
    @inline(never)
    mutating func captureAccepted(_ control: UnsafeMutablePointer<CounterControl>) { value = control.pointee.lastFrame }
    @inline(never)
    mutating func matchesAccepted(_ control: UnsafeMutablePointer<CounterControl>) -> Bool {
        let sameCapacity = value.capacity == control.pointee.lastFrame.capacity
        guard sameCapacity else { return false }
        let sameHeader = value.header == control.pointee.lastFrame.header
        guard sameHeader else { return false }
        let sameOperations = value.operations == control.pointee.lastFrame.operations
        guard sameOperations else { return false }
        let sameGlyphs = value.glyphs == control.pointee.lastFrame.glyphs
        guard sameGlyphs else { return false }
        let sameStrokes = value.strokes == control.pointee.lastFrame.strokes
        guard sameStrokes else { return false }
        let sameFinishes = value.finishes == control.pointee.lastFrame.finishes
        guard sameFinishes else { return false }
        let sameDiscards = value.discards == control.pointee.lastFrame.discards
        guard sameDiscards else { return false }
        let sameFirstPoint = value.firstPoint == control.pointee.lastFrame.firstPoint
        guard sameFirstPoint else { return false }
        let sameSecondPoint = value.secondPoint == control.pointee.lastFrame.secondPoint
        guard sameSecondPoint else { return false }
        let sameStrokeHeader = value.strokeHeader == control.pointee.lastFrame.strokeHeader
        guard sameStrokeHeader else { return false }
        for index in 0..<64 {
            let same = value.glyphRecords[index] == control.pointee.lastFrame.glyphRecords[index]
            guard same else { return false }
        }
        return true
    }
    @inline(never)
    mutating func captureEndpoint(_ endpoint: inout CounterEndpoint) { value = endpoint.actual.sink.recording }
    @inline(never)
    mutating func matchesEndpoint(_ endpoint: inout CounterEndpoint) -> Bool {
        let sameCapacity = value.capacity == endpoint.actual.sink.recording.capacity
        guard sameCapacity else { return false }
        let sameHeader = value.header == endpoint.actual.sink.recording.header
        guard sameHeader else { return false }
        let sameOperations = value.operations == endpoint.actual.sink.recording.operations
        guard sameOperations else { return false }
        let sameGlyphs = value.glyphs == endpoint.actual.sink.recording.glyphs
        guard sameGlyphs else { return false }
        let sameStrokes = value.strokes == endpoint.actual.sink.recording.strokes
        guard sameStrokes else { return false }
        let sameFinishes = value.finishes == endpoint.actual.sink.recording.finishes
        guard sameFinishes else { return false }
        let sameDiscards = value.discards == endpoint.actual.sink.recording.discards
        guard sameDiscards else { return false }
        let sameFirstPoint = value.firstPoint == endpoint.actual.sink.recording.firstPoint
        guard sameFirstPoint else { return false }
        let sameSecondPoint = value.secondPoint == endpoint.actual.sink.recording.secondPoint
        guard sameSecondPoint else { return false }
        let sameStrokeHeader = value.strokeHeader == endpoint.actual.sink.recording.strokeHeader
        guard sameStrokeHeader else { return false }
        for index in 0..<64 {
            let same = value.glyphRecords[index] == endpoint.actual.sink.recording.glyphRecords[index]
            guard same else { return false }
        }
        return true
    }
    @inline(never)
    mutating func installAcceptedProbe(_ index: Int, control: UnsafeMutablePointer<CounterControl>) {
        guard let probe = value.glyphRecords[0] else { preconditionFailure("baseline glyph positive") }
        control.pointee.lastFrame.glyphRecords[index] = value.glyphRecords[index] == nil ? probe : nil
    }
    @inline(never)
    mutating func restoreAcceptedProbe(_ index: Int, control: UnsafeMutablePointer<CounterControl>) {
        control.pointee.lastFrame.glyphRecords[index] = value.glyphRecords[index]
    }
    static func == (left: Self, right: Self) -> Bool { left.matches(right.value) }
}
struct CounterWriterObservation: Equatable {
    let bytes: UInt32
    let regions: UInt16
    let origin: Point?
    let pixels: UInt16
    let remaining: UInt32
    let completed: Bool
}
struct CounterEndpointObservation: Equatable {
    let effectivePresentation: EffectiveRasterPresentation
    let descriptor: RasterSurfaceDescriptor
    let payloadLimits: RasterPayloadLimits
    let realization: RasterRealizationID
    let bodyCalls: UInt32
    let reservations: UInt32
    let displayError: DisplayTargetError?
    let producerError: RenderProductionError?
    let capacity: RenderSinkCapacity
    let sinkDescriptor: RasterSurfaceDescriptor
    let sinkLimits: RasterPayloadLimits
    let sinkFailure: RasterBackendError?
    let streamCompleted: Bool
    let presentationAccepted: Bool
    let sinkProducerError: RenderProductionError?
    let idle: Bool
    let health: GiftUIOperationalHealth
    let recording: CounterRecordingObservation
    let targetConfiguration: HostEndpointConfiguration
    let writer: CounterWriterObservation?
    let nativeReservation: DisplayReservationID?
    let nativeGlyphHeader: PositionedGlyphOperationHeader?
}
// Captured only once by the enclosing full baseline; never a live endpoint.
struct CounterEndpointBaseline: ~Copyable {
    var recording = CounterRecordingObservation()
    var effectivePresentation: EffectiveRasterPresentation? = nil
    var descriptor: RasterSurfaceDescriptor? = nil
    var payloadLimits: RasterPayloadLimits? = nil
    var realization: RasterRealizationID? = nil
    var bodyCalls: UInt32? = nil
    var reservations: UInt32? = nil
    var displayError: DisplayTargetError? = nil
    var producerError: RenderProductionError? = nil
    var capacity: RenderSinkCapacity? = nil
    var sinkDescriptor: RasterSurfaceDescriptor? = nil
    var sinkLimits: RasterPayloadLimits? = nil
    var sinkFailure: RasterBackendError? = nil
    var streamCompleted: Bool? = nil
    var presentationAccepted: Bool? = nil
    var sinkProducerError: RenderProductionError? = nil
    var idle: Bool? = nil
    var health: GiftUIOperationalHealth? = nil
    var targetConfiguration: HostEndpointConfiguration? = nil
    var writer: CounterWriterObservation? = nil
    var nativeReservation: DisplayReservationID? = nil
    var nativeGlyphHeader: PositionedGlyphOperationHeader? = nil
}
// Actual backend completion facts are independent of endpoint/adapter counters.
// This owned value contains no payload arrays, pointer, callback or live owner.
struct CounterBackendObservation: Equatable {
    let active: Bool
    let reservations: Int
    let submissions: Int
    let finishes: Int
    let cancellations: Int
    let submittedBytes: UInt32
    let submittedRows: UInt32
    let health: GiftUIOperationalHealth
    let endpointHealthObservation: GiftUIOperationalHealth
    let constructedProjection: HostEndpointConfiguration?
    let constructedEndpoints: Int
    let projectionControls: Int
    let envelopeRejections: Int
}
struct CounterRuntimeSlotObservation: Equatable {
    let backend: CounterBackendObservation
    let phase: CounterRuntimeSlotPhase
    let owner: UInt64?
    let lastSerial: UInt64
    let endpoint: CounterEndpointObservation?
    let root: SemanticCompleteIdentity?
    let action: SemanticCompleteIdentity?
    let candidateRoot: SemanticCompleteIdentity?
    let candidateAction: SemanticCompleteIdentity?
    init(_ control: UnsafeMutablePointer<CounterControl>) {
        backend = counterObserveBackend(control.pointee.backend)
        phase = control.pointee.runtimeSlotPhase; owner = control.pointee.runtimeSlotOwner
        lastSerial = control.pointee.runtimeLastOwnerSerial
        endpoint = control.pointee.runtimeEndpoint?.ownedObservation
        root = control.pointee.runtimeRootIdentity; action = control.pointee.runtimeActionIdentity
        candidateRoot = control.pointee.runtimeCandidateRootIdentity
        candidateAction = control.pointee.runtimeCandidateActionIdentity
    }
}

// Every field of CounterRuntimeSlotObservation, captured into existing storage.
struct CounterRuntimeSlotBaseline: ~Copyable {
    private var captured = false
    private var backend: CounterBackendObservation? = nil
    private var phase: CounterRuntimeSlotPhase? = nil
    private var owner: UInt64? = nil
    private var lastSerial: UInt64 = 0
    private var endpointPresent = false
    private var endpoint = CounterEndpointBaseline()
    private var root: SemanticCompleteIdentity? = nil
    private var action: SemanticCompleteIdentity? = nil
    private var candidateRoot: SemanticCompleteIdentity? = nil
    private var candidateAction: SemanticCompleteIdentity? = nil
    @inline(never)
    mutating func installKeyProbe0(_ control: UnsafeMutablePointer<CounterControl>) {
        var changed = SemanticCompleteIdentity()
        let appendedRoot = changed.append(.init(kind: .root)); precondition(appendedRoot)
        let appendedChild = changed.append(.init(kind: .fixedChild, ordinal: 4)); precondition(appendedChild)
        let equalsOriginal = root == changed
        if equalsOriginal {
            changed = SemanticCompleteIdentity()
            let appendedRoot = changed.append(.init(kind: .root)); precondition(appendedRoot)
            let appendedChild = changed.append(.init(kind: .fixedChild, ordinal: 3)); precondition(appendedChild)
        }
        let distinct = root != changed; precondition(distinct)
        control.pointee.runtimeRootIdentity = changed
    }
    @inline(never)
    mutating func restoreKeyProbe0(_ control: UnsafeMutablePointer<CounterControl>) {
        control.pointee.runtimeRootIdentity = root
    }
    @inline(never)
    mutating func installKeyProbe1(_ control: UnsafeMutablePointer<CounterControl>) {
        var changed = SemanticCompleteIdentity()
        let appendedRoot = changed.append(.init(kind: .root)); precondition(appendedRoot)
        let appendedChild = changed.append(.init(kind: .fixedChild, ordinal: 4)); precondition(appendedChild)
        let equalsOriginal = action == changed
        if equalsOriginal {
            changed = SemanticCompleteIdentity()
            let appendedRoot = changed.append(.init(kind: .root)); precondition(appendedRoot)
            let appendedChild = changed.append(.init(kind: .fixedChild, ordinal: 3)); precondition(appendedChild)
        }
        let distinct = action != changed; precondition(distinct)
        control.pointee.runtimeActionIdentity = changed
    }
    @inline(never)
    mutating func restoreKeyProbe1(_ control: UnsafeMutablePointer<CounterControl>) {
        control.pointee.runtimeActionIdentity = action
    }
    @inline(never)
    mutating func installKeyProbe2(_ control: UnsafeMutablePointer<CounterControl>) {
        var changed = SemanticCompleteIdentity()
        let appendedRoot = changed.append(.init(kind: .root)); precondition(appendedRoot)
        let appendedChild = changed.append(.init(kind: .fixedChild, ordinal: 4)); precondition(appendedChild)
        let equalsOriginal = candidateRoot == changed
        if equalsOriginal {
            changed = SemanticCompleteIdentity()
            let appendedRoot = changed.append(.init(kind: .root)); precondition(appendedRoot)
            let appendedChild = changed.append(.init(kind: .fixedChild, ordinal: 3)); precondition(appendedChild)
        }
        let distinct = candidateRoot != changed; precondition(distinct)
        control.pointee.runtimeCandidateRootIdentity = changed
    }
    @inline(never)
    mutating func restoreKeyProbe2(_ control: UnsafeMutablePointer<CounterControl>) {
        control.pointee.runtimeCandidateRootIdentity = candidateRoot
    }
    @inline(never)
    mutating func installKeyProbe3(_ control: UnsafeMutablePointer<CounterControl>) {
        var changed = SemanticCompleteIdentity()
        let appendedRoot = changed.append(.init(kind: .root)); precondition(appendedRoot)
        let appendedChild = changed.append(.init(kind: .fixedChild, ordinal: 4)); precondition(appendedChild)
        let equalsOriginal = candidateAction == changed
        if equalsOriginal {
            changed = SemanticCompleteIdentity()
            let appendedRoot = changed.append(.init(kind: .root)); precondition(appendedRoot)
            let appendedChild = changed.append(.init(kind: .fixedChild, ordinal: 3)); precondition(appendedChild)
        }
        let distinct = candidateAction != changed; precondition(distinct)
        control.pointee.runtimeCandidateActionIdentity = changed
    }
    @inline(never)
    mutating func restoreKeyProbe3(_ control: UnsafeMutablePointer<CounterControl>) {
        control.pointee.runtimeCandidateActionIdentity = candidateAction
    }
    mutating func capture(_ control: UnsafeMutablePointer<CounterControl>) {
        let mayCapture = !captured; precondition(mayCapture)
        backend = counterObserveBackend(control.pointee.backend)
        phase = control.pointee.runtimeSlotPhase; owner = control.pointee.runtimeSlotOwner
        lastSerial = control.pointee.runtimeLastOwnerSerial
        endpointPresent = control.pointee.runtimeEndpoint != nil
        control.pointee.runtimeEndpoint?.captureBaselinePrefix(into: &endpoint)
        endpoint.health = CounterEndpoint.runtimeBaselineHealth(at: control)
        control.pointee.runtimeEndpoint?.captureBaselineSuffix(into: &endpoint)
        root = control.pointee.runtimeRootIdentity; action = control.pointee.runtimeActionIdentity
        candidateRoot = control.pointee.runtimeCandidateRootIdentity
        candidateAction = control.pointee.runtimeCandidateActionIdentity
        captured = true
    }
    @inline(never)
    private mutating func matchesBackend(_ control: UnsafeMutablePointer<CounterControl>) -> Bool {
        let same = backend == counterObserveBackend(control.pointee.backend)
        return same
    }
    @inline(never)
    private mutating func matchesRoot(_ control: UnsafeMutablePointer<CounterControl>) -> Bool {
        let same = root == control.pointee.runtimeRootIdentity
        return same
    }
    @inline(never)
    private mutating func matchesAction(_ control: UnsafeMutablePointer<CounterControl>) -> Bool {
        let same = action == control.pointee.runtimeActionIdentity
        return same
    }
    @inline(never)
    private mutating func matchesCandidateRoot(_ control: UnsafeMutablePointer<CounterControl>) -> Bool {
        let same = candidateRoot == control.pointee.runtimeCandidateRootIdentity
        return same
    }
    @inline(never)
    private mutating func matchesCandidateAction(_ control: UnsafeMutablePointer<CounterControl>) -> Bool {
        let same = candidateAction == control.pointee.runtimeCandidateActionIdentity
        return same
    }
    mutating func matches(_ control: UnsafeMutablePointer<CounterControl>) -> Bool {
        let wasCaptured = captured; precondition(wasCaptured)
        let samebackend = matchesBackend(control)
        guard samebackend else { return false }
        let samephase = phase == control.pointee.runtimeSlotPhase
        guard samephase else { return false }
        let sameowner = owner == control.pointee.runtimeSlotOwner
        guard sameowner else { return false }
        let samelastSerial = lastSerial == control.pointee.runtimeLastOwnerSerial
        guard samelastSerial else { return false }
        let sameendpointPresent = endpointPresent == (control.pointee.runtimeEndpoint != nil)
        guard sameendpointPresent else { return false }
        let sameroot = matchesRoot(control)
        guard sameroot else { return false }
        let sameaction = matchesAction(control)
        guard sameaction else { return false }
        let samecandidateRoot = matchesCandidateRoot(control)
        guard samecandidateRoot else { return false }
        let samecandidateAction = matchesCandidateAction(control)
        guard samecandidateAction else { return false }
        if endpointPresent {
            let samePrefix = control.pointee.runtimeEndpoint?.matchesBaselinePrefix(&endpoint) == true
            guard samePrefix else { return false }
            let sameHealth = endpoint.health == CounterEndpoint.runtimeBaselineHealth(at: control)
            guard sameHealth else { return false }
            let sameSuffix = control.pointee.runtimeEndpoint?.matchesBaselineSuffix(&endpoint) == true
            guard sameSuffix else { return false }
        }
        return true
    }
}
